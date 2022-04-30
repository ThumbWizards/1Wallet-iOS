//
//  LocalDB.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 20/04/2022.
//
// swiftlint:disable identifier_name
// swiftlint:disable force_try

import GRDB
import Sentry

protocol TimelessTable {
    static func migrations(version: Tables.Versions, db: Database)
    static func initialize(_ db: Database) // Post db open init
}

extension TimelessTable {
    static func initialize(_: Database) {}
}

class Tables {
    enum Versions: String, CaseIterable {
        case v1   /// Initial version
    }

    static let tables: [TimelessTable.Type] = [
    ]
}

class LocalDBQueue {
    let underlyingDBQueue: DatabaseQueue
    private let dispatchQueue = DispatchQueue(label: "LOCAL_DB_DATABASE_QUEUE")

    init(path: String) throws {
        var configuration = Configuration()
        configuration.targetQueue = dispatchQueue
        underlyingDBQueue = try DatabaseQueue(path: path, configuration: configuration)
    }

    func write<T>(_ updates: (Database) throws -> T) throws -> T {
        try underlyingDBQueue.write(updates)
    }

    func read<T>(_ block: (Database) throws -> T) throws -> T {
        try underlyingDBQueue.read(block)
    }
}

public class LocalDB {
    public static let shared = LocalDB()

    private init() {
        dbQueue = try! LocalDB.openDatabase(atPath: databaseURL.path)
    }

    private(set) var dbQueue: LocalDBQueue

    private let databaseURL = try! FileManager.default.url(
        for: .applicationSupportDirectory,
           in: .userDomainMask,
           appropriateFor: nil,
           create: true
    )
        .appendingPathComponent("localdb.sqlite")

    /// Creates a fully initialized database at path
    static func openDatabase(atPath path: String) throws -> LocalDBQueue {
        let dbQueue = try LocalDBQueue(path: path)

        var migrator = DatabaseMigrator()

        Tables.Versions.allCases.forEach {
            let version = $0
            let versionString = $0.rawValue
            migrator.registerMigration(versionString) { db in
                Tables.tables.forEach {
                    $0.migrations(version: version, db: db)
                }
            }
        }

        var attempts = 0
        var migrationError: Error?
        repeat {
            do {
                try migrator.migrate(dbQueue.underlyingDBQueue)
                migrationError = nil
            } catch {
                migrationError = error
            }
            attempts += 1
        } while (migrationError != nil && attempts <= 3)
        if migrationError != nil {
            try dbQueue.underlyingDBQueue.write { db in
                try LocalDB.truncate(db: db)
            }
            try migrator.migrate(dbQueue.underlyingDBQueue)
        }

        try dbQueue.write { db in
            Tables.tables.forEach {
                $0.initialize(db)
            }
        }

        return dbQueue
    }

    func write<T>(_ updates: (Database) throws -> T) throws -> T {
        try dbQueue.write(updates)
    }

    func read<T>(_ block: (Database) throws -> T) throws -> T {
        try dbQueue.read(block)
    }
}

extension LocalDB {
    static func fetchAllTables(db: Database) throws -> [String] {
        return try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type='table' AND name LIKE '\(Tables.EOTP.tablePrefix)%'
                """)
    }

    static func truncate(db: Database) throws {
        let allTables = try LocalDB.fetchAllTables(db: db)
        try allTables.forEach { table in
            try db.drop(table: table)
        }
    }

    func truncate() {
        try? write { db in
            try LocalDB.truncate(db: db)
        }
    }

    func allTables() -> [String] {
        var tables: [String] = []
        try? write { db in
            tables = try LocalDB.fetchAllTables(db: db)
        }
        return tables
    }

    func cleanUp() {
        try? write { db in
            let allTables = try Self.fetchAllTables(db: db)
            let allWalletRootHexes = Wallet.allWalletRootHexes.values
            try allTables.forEach { table in
                let tableRootHex = Tables.EOTP.rootHex(from: table)
                if !allWalletRootHexes.contains(tableRootHex) {
                    try db.drop(table: table)
                }
            }
        }
    }
}

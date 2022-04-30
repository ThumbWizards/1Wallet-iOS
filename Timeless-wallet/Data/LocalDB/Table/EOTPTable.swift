//
//  EOTPTable.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 20/04/2022.
//
// swiftlint:disable identifier_name
// swiftlint:disable force_try

import GRDB

extension Tables {
    struct EOTP: Codable, FetchableRecord, PersistableRecord, TimelessTable {
        static var tablePrefix = "EOTP_"
        var otpIndex: Int
        var encryptedEOTP: String

        static func batchInsert(elements: [Self], mTreeRootHex: String) throws {
            try LocalDB.shared.write { db in
                let tableName = Tables.EOTP.tableName(mTreeRootHex)
                let sql = """
                    INSERT INTO \(tableName) (
                        otpIndex,
                        encryptedEOTP
                    )
                    VALUES (?, ?)
                    """
                let statement = try db.makeStatement(literal: .init(sql: sql))
                for element in elements {
                    statement.setUncheckedArguments([element.otpIndex, element.encryptedEOTP])
                    try statement.execute()
                }
            }
        }

        static func migrations(version: Tables.Versions, db: Database) {
            switch version {
            case .v1:
                try! v1_migration(db: db)
            }
        }

        static func v1_migration(db: Database) throws {
            // Dynamic initialize for v1
        }

        static func tableName(_ mTreeRootHex: String) -> String {
            return "\(EOTP.tablePrefix)\(mTreeRootHex)"
        }

        static func rootHex(from tableName: String) -> String {
            return tableName.replace(string: EOTP.tablePrefix, replacement: "")
        }

        static func dynamicInitialize(mTreeRootHex: String) throws {
            try LocalDB.shared.write { db in
                let tableName = Tables.EOTP.tableName(mTreeRootHex)
                try db.create(table: "\(tableName)", body: { db in
                    db.column("otpIndex", .integer).notNull()
                    db.column("encryptedEOTP", .text).notNull()
                })
            }
        }

        static func drop(mTreeRootHex: String) throws {
            try LocalDB.shared.write { db in
                let tableName = Tables.EOTP.tableName(mTreeRootHex)
                try db.drop(table: tableName)
            }
        }

        static func fetchEOTP(mTreeRootHex: String, index: Int) -> EOTP? {
            var eotp: EOTP?
            try? LocalDB.shared.read { db in
                let tableName = Tables.EOTP.tableName(mTreeRootHex)
                if let row = try Row.fetchOne(db, sql: """
                            SELECT * FROM \(tableName)
                            WHERE otpIndex = ?
                            LIMIT 1
                            """, arguments: [index]) {
                    if let index: Int = row["otpIndex"],
                       let encryptedEOTP: String = row["encryptedEOTP"] {
                        eotp = EOTP(otpIndex: index, encryptedEOTP: encryptedEOTP)
                    }
                }
            }
            return eotp
        }

        static func eotpCount(mTreeRootHex: String) -> Int {
            var count = 0
            try? LocalDB.shared.read { db in
                let tableName = Tables.EOTP.tableName(mTreeRootHex)
                count = try Int.fetchOne(db, sql: """
                            SELECT COUNT(*) FROM \(tableName)
                            """) ?? 0
            }
            return count
        }
    }
}

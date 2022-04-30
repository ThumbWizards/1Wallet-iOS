//
//  Constants.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/8/21.
//

import Foundation
import SwiftUI

enum Constants {

    enum Urls {
        static let discordUrl = "https://discord.gg/1wallet"
    }

    enum DataType {
        static let videos = ["mp4", "avi", youtube]
        static let youtube = "youtube"
    }

    enum URLAvatar {
        static let url = "https://res.cloudinary.com/timeless/image/upload/v1/app/Wallet/"
    }

    enum blockExplore {
        static let url = "https://explorer.harmony.one/tx/"
    }

    enum privateGroup {
        static let baseDeepLinkUrl = "timeless-wallet://join-private-group"
    }

    enum daoGroup {
        static let baseDeepLinkUrl = "timeless-wallet://join-dao-group"
    }

    enum URLImageContact {
        static let url = "\(AppConstant.serverURL)v1/wallets/avatar_by_address"
    }
    
    enum harmony {
        static let baseWalletAddress = "https://explorer.harmony.one/address/"
    }

    enum DynamicLink {
        static let daoBaseUrl = "\(AppConstant.firebaseDynamicLinkDomain)/join-dao-group/"
        static let privateGroupBaseUrl = "\(AppConstant.firebaseDynamicLinkDomain)/join-private-group/"
        static let generalGroupInviteBaseUrl = "\(AppConstant.firebaseDynamicLinkDomain)/group_invite/"
        static let profileBaseUrl = "\(AppConstant.firebaseDynamicLinkDomain)/profile/"
    }

    enum CreateWallet {
        static let randomCreationText = [
            "Swapping time and space...",
            "Spinning violently around the y-axis...",
            "Tokenizing real life...",
            "Beta testers preferred the loading to be long, so, here goes...",
            "Sorry, you’re actually early…",
            "Chuck Norris once urinated in a semi truck's gas tank as a joke....that truck is now known as Optimus Prime.",
            "We're building the buildings as fast as we can",
            "Please wait while the little elves create your wallet",
            "Go ahead -- hold your breath!",
            "Just a few sec - we're beta testing your patience",
            "Why don't you order a sandwich?",
            "The bits are flowing slowly today",
            "It's still faster than buying an IRL wallet",
            "Reconfoobling energymotron...",
            "Just count to 10",
            "It's not you. It's me.",
            "Counting backwards from Infinity",
            "Embiggening Prototypes",
            "Do not run! We are your friends!",
            "Creating time-loop inversion field",
            "Spinning the wheel of fortune...",
            "Please wait until the sloth starts moving.",
            "Let's take a mindfulness minute...",
            "Unicorns are at the end of this road, I promise.",
            "Listening for the sound of one hand clapping...",
            "Cleaning off the cobwebs...",
            "Making sure all the i's have dots...",
            "We need more dilithium crystals",
            "Convincing AI not to turn evil..",
            "There is no spoon. Because we are not done loading it",
            "Wait, do you smell something burning?",
            "Computing the secret to life, the universe, and everything.",
            "I think I am, therefore, I am. I think.",
            "Coffee, Chocolate, Men. The richer the better!",
            "Please wait while the intern refills his coffee.",
            "Whatever you do, don't look behind you...",
            "Go ahead, hold your breath and do an ironman plank till loading complete",
            "Patience! This is difficult, you know...",
            "Discovering new ways of making you wait...",
            "Time flies like an arrow; fruit flies like a banana",
            "Two men walked into a bar; the third ducked...",
            "Sorry we are busy catching em' all, we're done soon",
            "Still faster than Windows update",
            "Please wait while the minions do their work",
            "Grabbing extra minions",
            "Doing the heavy lifting",
            "We're working very Hard .... Really",
            "Waking up the minions",
            "Feeding unicorns..."
        ]
    }

    enum ErrorText {
        static let randomError = [
            "Don't worry - a few bits tried to escape, but we caught them",
            "Some days, you just can’t get rid of a bug!",
            "Kindly hold on as we convert this bug to a feature...",
            "Working on squashing bugs for you",
            "Sh!t happens, we are working on it",
            "Bugs! Call the exterminator!",
            "Apologies for bugging. Exterminator on the way",
            "It’s not you, it’s me.",
            "Oopsies! Got stuck in the metaverse.",
            "Welp! Sh!t happens, hang tight",
            "Sorry about the error. At least you look nice!"
        ]
    }

    enum RedPacketClaimedText {
        static let randomText = [
            "Gotta be quicker than that! You’ll get it next time ;)",
            "Don’t look at me, it’s you who didn’t go fast enough!",
            "Use those twitter fingers for next time",
            "You were so close! DW, you’ll get it next time"
        ]
    }

    enum RedPacketExpiredText {
        static let randomText = [
            "Gotta be quicker than that!",
            "Need for speed, better luck next time!",
            "Competition is fierce. Better luck next time!"
        ]
    }
}

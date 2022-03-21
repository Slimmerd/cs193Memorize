//
//  cs193MemorizeApp.swift
//  cs193Memorize
//
//  Created by Daniil Silin on 01/03/2022.
//

import SwiftUI

@main
struct cs193MemorizeApp: App {
    private let game = EmojiMemoryGame()
    
    var body: some Scene {
        WindowGroup {
            EmojiMemoryGameView(gameViewModel: game)
        }
    }
}

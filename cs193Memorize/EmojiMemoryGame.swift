//
//  EmojiMemoryGame.swift
//  cs193Memorize
//
//  Created by Daniil Silin on 02/03/2022.
//
// VIEWMODEL

import SwiftUI


class EmojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    
    static let emojis = ["🤡", "🚜", "♿️", "🚀","🏎","🚌","🚍","🚎","🚐","🚑","🚒","🚓","🚔","🚕","🚖","🚗","🚘","🚙","🚚","🚛","🛻","🚜","🛺"]
    
    static func createMemoryGame() -> MemoryGame<String> {
        return MemoryGame(numberOfPairsOfCards: 4, createCardContent: {pairIndex in emojis[pairIndex]})
    }
    
    @Published private var model: MemoryGame<String> = createMemoryGame()
    
    var cards: Array<Card>{
        return model.cards
    }
    
    
//    MARK: - Intent(s)
    
    
    func choose(_ card: Card){
        model.choose(card)
    }
    
    func shuffle(){
        model.shuffle()
    }
    
    func restart(){
        model = EmojiMemoryGame.createMemoryGame()
    }
}

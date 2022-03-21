//
//  EmojiMemoryGameView.swift
//  cs193Memorize
//
//  Created by Daniil Silin on 01/03/2022.
//
// VIEW

import SwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var gameViewModel: EmojiMemoryGame
    
    @Namespace private var dealingNamespace

    var body: some View {
        ZStack(alignment: .bottom){
            VStack{
                gameBody
                HStack{
                    restart
                    Spacer()
                    shuffle
                }
                .padding(.horizontal)
            }
            deckBody
        }
        .padding()
    }
    
    @State private var dealt = Set<Int>()
    
    private func deal(_ card: EmojiMemoryGame.Card){
        dealt.insert(card.id)
    }
    
    private func isUnDealt(_ card: EmojiMemoryGame.Card) -> Bool{
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation {
        var delay = 0.0
        if let index = gameViewModel.cards.firstIndex(where: { $0.id == card.id}){
            delay = Double(index) * (CardConstants.totalDealDuration / Double(gameViewModel.cards.count))
        }
         
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    private func zIndex(of card: EmojiMemoryGame.Card) -> Double{
        -Double(gameViewModel.cards.firstIndex(where: { $0.id == card.id}) ?? 0)
    }
    
    var gameBody: some View{
        AspectVGrid(items: gameViewModel.cards, aspectRatio: 2/3, content: {
            card in
            if isUnDealt(card) || (card.isMatched && !card.isFaceUp) {
                Color.clear
            } else {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(4)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        withAnimation{
                            gameViewModel.choose(card)
                        }
                    }
            }
        })
          
            .foregroundColor(CardConstants.color)
    }
    
    var deckBody: some View {
        ZStack{
            ForEach(gameViewModel.cards.filter(isUnDealt)) {
                card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .zIndex(zIndex(of: card))
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(CardConstants.color)
        .onTapGesture{
                // "deal" cards
            for card in gameViewModel.cards{
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }
    
    
    var shuffle: some View {
        Button("Shuffle"){
            withAnimation{
                gameViewModel.shuffle()
            }
        }
    }
    
    
    var restart: some View{
        Button("Restart"){
            withAnimation{
                dealt = []
                gameViewModel.restart()
            }
        }
    }
    
    private struct CardConstants {
        static let color = Color.pink
        static let aspectRatio: CGFloat = 2/3
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2
        static let undealtHeight: CGFloat = 90
        static let undealtWidth = undealtHeight * aspectRatio
    }
    
}


struct CardView: View{
    let card: EmojiMemoryGame.Card
    
    @State private var animatedBonusRemaining: Double = 0
    
    var body: some View {
        GeometryReader(content: {
            geometry in
            ZStack {
                Group{
                    if card.isConsumingBonusTime {
                        Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-animatedBonusRemaining )*360-90))
                            .onAppear{
                                animatedBonusRemaining = card.bonusRemaining
                                withAnimation(.linear(duration: card.bonusTimeRemaining)){
                                    animatedBonusRemaining = 0
                                }
                            }
                        
                    } else {
                        Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-card.bonusRemaining)*360-90))
                    }
                }
                .padding(4)
                .opacity(0.5)
                    
                    Text(card.content)
//                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
//                    .animation(.linear(duration: 5).repeatForever(autoreverses: false))
                    .font(Font.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
                }
            .cardify(isFaceUp: card.isFaceUp)
        })
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    
    private struct DrawingConstants {
        static let fontScale: CGFloat = 0.65
        static let fontSize: CGFloat = 32
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        EmojiMemoryGameView(gameViewModel: game)
    }
}

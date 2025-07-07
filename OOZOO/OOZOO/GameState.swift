import Foundation
import Combine

class GameState: ObservableObject {
    @Published var currentDay: Int = 1
    @Published var oxygenLevel: Int = 100
    @Published var foodLevel: Int = 100
    @Published var systemPower: Float = 1.0

    @Published var messages: [DayMessage] = []
    @Published var responses: [PlayerResponse] = []
    @Published var logs: [SystemLog] = []

    @Published var isGameOver: Bool = false
    @Published var endingType: EndingType? = nil
    enum EndingType { case survive, dead, aiFusion, alienMerge, loopEscape }
} 
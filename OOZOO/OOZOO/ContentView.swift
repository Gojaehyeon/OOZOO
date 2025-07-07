//
//  ContentView.swift
//  OOZOO
//
//  Created by Gojaehyun on 7/7/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var gameState = GameState()
    @State private var inputText: String = ""
    let nlp = NLPAnalyzer()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                // 1. 상단 상태바 (흰색만)
                HStack(spacing: 16) {
                    statusBar(icon: "aqi.medium", label: "산소", value: Float(gameState.oxygenLevel), max: 100)
                    statusBar(icon: "takeoutbag.and.cup.and.straw.fill", label: "식량", value: Float(gameState.foodLevel), max: 100)
                    statusBar(icon: "bolt.fill", label: "전력", value: gameState.systemPower, max: 1.0)
                    Spacer()
                    Text("Day \(gameState.currentDay)/10")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.trailing, 4)
                }
                .padding(.horizontal)
                .padding(.top, 12)

                // 2. 로그/메시지 영역 (흰색)
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(gameState.logs) { log in
                            Text(log.content)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.vertical, 2)
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .frame(maxHeight: 220)
                .background(Color.clear)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 8)

                // 3. 오늘의 메시지 (중복 방지: 마지막 로그가 오늘 메시지면 생략)
                if let todayMsg = gameState.messages.last, !isLastLogTodayMessage() {
                    Text(todayMsg.content)
                        .font(.custom("DOSGothic", size: 19))
                        .kerning(1.5)
                        .foregroundColor(.green)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.green, lineWidth: 2)
                                )
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                }

                Spacer()

                // 4. 입력창 (흰색)
                HStack(spacing: 12) {
                    TextField("신호 보내기...", text: $inputText)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    Button(action: submitResponse) {
                        Image(systemName: "return.right")
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding(10)
                            .background(inputText.isEmpty ? Color.white.opacity(0.08) : Color.white.opacity(0.18))
                            .cornerRadius(10)
                    }
                    .disabled(inputText.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .onAppear { startGame() }
        .alert(isPresented: $gameState.isGameOver) {
            Alert(title: Text("게임 종료"), message: Text(endingMessage()), dismissButton: .default(Text("확인")))
        }
    }

    // 상태바 뷰 (흰색)
    func statusBar(icon: String, label: String, value: Float, max: Float) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.title3)
            ProgressView(value: value, total: max)
                .tint(.white)
                .frame(width: 48)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white)
        }
    }

    func isLastLogTodayMessage() -> Bool {
        guard let todayMsg = gameState.messages.last, let lastLog = gameState.logs.last else { return false }
        return lastLog.content.contains(todayMsg.content)
    }

    func startGame() {
        let msg = DayMessage(day: 1, content: "시스템: [경고] 산소 및 식량 부족. 구조 신호를 보내시겠습니까?")
        gameState.messages = [msg]
        gameState.logs = [SystemLog(day: 1, content: msg.content, type: .info)]
    }

    func submitResponse() {
        let day = gameState.currentDay
        let (sentiment, keywords) = nlp.analyze(text: inputText)
        let intent = nlp.classifyIntent(text: inputText)
        let response = PlayerResponse(day: day, text: inputText, sentiment: sentiment, intent: intent, keywords: keywords)
        gameState.responses.append(response)

        let logMsg = "응답: \(inputText) [감정: \(sentiment?.label ?? "-")] [키워드: \(keywords.joined(separator: ", "))]"
        gameState.logs.append(SystemLog(day: day, content: logMsg, type: .info))

        updateGameState(with: response)

        if !gameState.isGameOver {
            advanceDay()
        }
        inputText = ""
    }

    func updateGameState(with response: PlayerResponse) {
        if response.keywords.contains("산소") { gameState.oxygenLevel += 5 }
        gameState.oxygenLevel -= 10
        gameState.foodLevel -= 8
        gameState.systemPower -= 0.05

        if gameState.oxygenLevel <= 0 || gameState.foodLevel <= 0 || gameState.systemPower <= 0 {
            gameState.isGameOver = true
            gameState.endingType = .dead
        } else if gameState.currentDay >= 10 {
            gameState.isGameOver = true
            gameState.endingType = .survive
        }
        if response.keywords.contains("AI") && response.keywords.contains("융합") {
            gameState.isGameOver = true
            gameState.endingType = .aiFusion
        }
    }

    func advanceDay() {
        gameState.currentDay += 1
        let msg = DayMessage(day: gameState.currentDay, content: "Day \(gameState.currentDay): 새로운 메시지 도착.")
        gameState.messages.append(msg)
        gameState.logs.append(SystemLog(day: gameState.currentDay, content: msg.content, type: .info))
    }

    func endingMessage() -> String {
        switch gameState.endingType {
        case .survive: return "10일을 버티고 구조되었습니다!"
        case .dead: return "자원이 소진되어 사망했습니다."
        case .aiFusion: return "당신은 AI와 융합되었습니다."
        case .alienMerge: return "외계 존재와 융합되었습니다."
        case .loopEscape: return "루프에서 탈출했습니다."
        default: return "알 수 없는 엔딩"
        }
    }
}

#Preview {
    ContentView()
}

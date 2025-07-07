//
//  ContentView.swift
//  OOZOO
//
//  Created by Gojaehyun on 7/7/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatGameViewModel()
    @State private var userInput: String = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                // 1. 상단 상태바 (흰색만)
                HStack(spacing: 16) {
                    statusBar(icon: "aqi.medium", label: "산소", value: 80, max: 100)
                    statusBar(icon: "takeoutbag.and.cup.and.straw.fill", label: "식량", value: 60, max: 100)
                    statusBar(icon: "bolt.fill", label: "전력", value: 0.7, max: 1.0)
                    Spacer()
                    Text("Day 2/10")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.trailing, 4)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                Divider()
                    .background(Color.white)
                    .frame(height: 2)
                    .padding(.horizontal, 8)
                    .padding(.top, 12)
                    .padding(.bottom, 2)

                // 2. 채팅 로그 영역
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { msg in
                            HStack {
                                if msg.isUser {
                                    Spacer()
                                    Text(msg.text)
                                        .font(.custom("DOSGothic", size: 19))
                                        .kerning(1.5)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.black)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.white, lineWidth: 2)
                                                )
                                        )
                                        .padding(.vertical, 2)
                                } else {
                                    Text(msg.text)
                                        .font(.custom("DOSGothic", size: 19))
                                        .kerning(1.5)
                                        .foregroundColor(.green)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.black)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.green, lineWidth: 2)
                                                )
                                        )
                                        .padding(.vertical, 2)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.bottom, 4)
            }
            // 입력창을 SafeAreaInset으로 분리
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    TextField("신호 보내기...", text: $userInput)
                        .font(.custom("DOSGothic", size: 19))
                        .kerning(1.5)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )
                    Button(action: send) {
                        Image(systemName: "return.right")
                            .foregroundColor(.green)
                            .font(.title2)
                            .padding(10)
                            .background(userInput.isEmpty ? Color.white.opacity(0.08) : Color.white.opacity(0.18))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 2)
                            )
                    }
                    .disabled(viewModel.isLoading || userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(Color.black.ignoresSafeArea())
            }
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

    func send() {
        guard !viewModel.isLoading, !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let text = userInput
        userInput = ""
        viewModel.sendUserMessage(text)
    }
}

#Preview {
    ContentView()
}

import SwiftUI

struct StoryPage {
    let text: String
    let imageName: String?
}

struct StoryView: View {
    @State private var showGame = false
    @State private var currentPage = 0
    @State private var displayedText = ""
    @State private var charIndex = 0
    @State private var timer: Timer?
    @State private var isTypingDone = false

    let storyPages: [StoryPage] = [
        StoryPage(
            text: "2045년, 인류는 에너지 혁명이라 불릴만한 신원소 [키리듐]을 발견한다. 위험성은 없으면서 에너지 효율은 기존 원자력 발전의 120배 이상, 단 1그램만으로 뉴욕의 1년치 전기를 공급할 수 있는, 그야말로 신의 원소.",
            imageName: "01"
        ),
        StoryPage(
            text: "문제는 이 원소가 지구에는 존재하지 않는다는 것. 처음 발견된 건 화성 탐사선 레비아탄-3의 드릴 헤드 안쪽. 귀환 당시 고작 0.4g의 분말이었으나, 그 가치는 그 무엇과도 바꾸기 어려웠다.\n\n그 순간부터 인류의 시선은 완전히 지구 바깥을 향하게 되었다.",
            imageName: nil
        ),
        StoryPage(
            text: "나는 공식적으로 키리듐을 채굴하기 위한 첫 임무에 투입된 탐사 엔지니어이자 비행사 에어.\n\n함께 간 비행사는 두 명 더. 조종 및 수리 담당인 핀과 키리듐 물리 해석 전문가 제인, 어마어마한 미인이지.\n\n(아, 물론 괴팍한 성격 탓에 남자친구는 있을리가 없다.)",
            imageName: "2"
        ),
        StoryPage(
            text: "탑승선은 비교적 소형이었기에 우리는 먼저 중간 기착지인 오로라 정거장(Aurora Station)으로 향했다. 거기서 대형 채굴선으로 환승한 후, 화성 이면의 붉은 협곡으로 들어갈 참이었다.\n\n모든 게 순조로웠다.\n\n도킹 직전까지는.",
            imageName: "1"
        ),
        StoryPage(
            text: "접근 속도, 각도, 통신 상태를 비롯한 모든 수치는 정상이었다. 그런데 순간, 오로라 정거장 측에서 권한 오류라며 도킹을 거절하는 것이다. 이어지는 강제 우회 지시, 그리고 경보음이 울리기 시작한다.\n\n[궤도 이탈 경고!]\n\n그 순간이 마지막이었다. 엄청난 충돌과 함께 우리는 정거장과 완전히 분리되었다.\n\n산소농도가 급격히 하락했고, 정신은 빠르게 혼미해진다. 옆에 있던 제인과 핀이 점점 흐려진다.\n\n[이게 내 마지막인가...]",
            imageName: "3"
        )
    ]

    var body: some View {
        if showGame {
            ContentView()
        } else {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 0) {
                    if let imageName = storyPages[currentPage].imageName {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 280)
                            .padding(.top, 50)
                            .padding(.bottom, 30)
                    }
                    Text(displayedText)
                        .font(.custom("DOSGothic", size: 19))
                        .kerning(1.5)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        .onAppear {
                            startTyping()
                        }
                    Spacer()
                    HStack(spacing: 20) {
                        Button(action: {
                            if currentPage > 0 {
                                currentPage -= 1
                                startTyping()
                            }
                        }) {
                            Text("이전")
                                .font(.headline)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(currentPage == 0 ? Color.gray.opacity(0.2) : Color.white.opacity(0.12))
                                .foregroundColor(currentPage == 0 ? .gray : .white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .disabled(currentPage == 0)

                        Button(action: {
                            if isTypingDone {
                                goToNextPage()
                            } else {
                                timer?.invalidate()
                                displayedText = storyPages[currentPage].text
                                isTypingDone = true
                            }
                        }) {
                            Text(currentPage == storyPages.count - 1 ? "계속" : "다음")
                                .font(.headline)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.12))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }

    func startTyping() {
        displayedText = ""
        charIndex = 0
        isTypingDone = false
        let text = storyPages[currentPage].text
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { t in
            if charIndex < text.count {
                let idx = text.index(text.startIndex, offsetBy: charIndex)
                displayedText += String(text[idx])
                charIndex += 1
            } else {
                t.invalidate()
                isTypingDone = true
            }
        }
    }

    func goToNextPage() {
        if currentPage < storyPages.count - 1 {
            currentPage += 1
            startTyping()
        } else {
            withAnimation { showGame = true }
        }
    }
} 

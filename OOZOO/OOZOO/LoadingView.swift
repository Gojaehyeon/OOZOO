import SwiftUI

struct LoadingView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            StoryView()
        } else {
            ZStack {
                Color.black.ignoresSafeArea()
                Image("intro_art")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { isActive = true }
                }
            }
        }
    }
} 
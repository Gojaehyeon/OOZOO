import Foundation
import NaturalLanguage

class NLPAnalyzer {
    func analyze(text: String) -> (SentimentResult?, [String]) {
        let tagger = NLTagger(tagSchemes: [.sentimentScore, .lexicalClass])
        tagger.string = text

        // 감정 분석
        let sentimentScore = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore).0
        let sentiment = sentimentScore.flatMap { Double($0.rawValue) }
        let sentimentLabel: String
        if let score = sentiment {
            if score > 0.2 { sentimentLabel = "희망" }
            else if score < -0.2 { sentimentLabel = "공포" }
            else { sentimentLabel = "중립" }
        } else {
            sentimentLabel = "중립"
        }
        let sentimentResult = SentimentResult(label: sentimentLabel, score: sentiment ?? 0)

        // 키워드 추출 (명사 등)
        var keywords: [String] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, range in
            if tag == .noun {
                keywords.append(String(text[range]))
            }
            return true
        }
        return (sentimentResult, keywords)
    }

    // CoreML 기반 의도 분류 (확장용)
    // var intentModel: NLModel? = nil
    // init() {
    //     // intentModel = try? NLModel(mlModel: MyIntentClassifier().model)
    // }
    func classifyIntent(text: String) -> IntentResult? {
        // guard let model = intentModel else { return nil }
        // let label = model.predictedLabel(for: text) ?? "기타"
        // let score = 1.0
        // return IntentResult(label: label, score: score)
        return nil // 기본은 nil 반환
    }
} 
struct Question: Codable {
    let id: String
    let type: String
    let headline: LocalizedText
    let required: Bool
    let charLimit: CharLimit
    let inputType: String
    let buttonLabel: LocalizedText
    let placeholder: LocalizedText
}

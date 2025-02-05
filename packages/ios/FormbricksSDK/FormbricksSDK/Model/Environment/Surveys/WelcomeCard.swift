struct WelcomeCard: Codable {
    let html: LocalizedText
    let enabled: Bool
    let headline: LocalizedText
    let buttonLabel: LocalizedText
    let timeToFinish: Bool
    let showResponseCount: Bool
}

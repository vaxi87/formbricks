struct Survey: Codable {
    let id: String
    let welcomeCard: WelcomeCard
    let name: String
    let questions: [Question]
    let variables: [String]
    let type: String
    let showLanguageSwitch: Bool?
    let languages: [String]
    let endings: [Ending]
    let autoClose: Bool?
    let styling: Styling?
    let status: String
    let segment: Segment
    let recontactDays: Int?
    let displayLimit: Int?
    let displayOption: String
    let hiddenFields: HiddenFields
    let triggers: [Trigger]
    let displayPercentage: Int?
    let delay: Int
}

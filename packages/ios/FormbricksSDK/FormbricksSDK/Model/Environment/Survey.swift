struct Survey: Codable {
    let id: String
    let name: String
    let autoClose: Bool?
    let triggers: [Trigger]?
    let recontactDays: Int?
    let displayLimit: Int?
    let delay: Int?
    let displayPercentage: Int?
}


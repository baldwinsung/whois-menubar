import Foundation

struct IPResult: Identifiable, Sendable {
    let id: UUID
    let ip: String
    var state: LookupState

    enum LookupState: Sendable {
        case pending
        case inProgress
        case success(WhoisRecord)
        case timedOut
        case failed(String)
    }
}

struct WhoisRecord: Sendable {
    let orgName: String
    let country: String
    let abuse: ContactSet
    let noc: ContactSet
    let tech: ContactSet
}

struct ContactSet: Sendable {
    let emails: [String]
    let phones: [String]

    var isEmpty: Bool { emails.isEmpty && phones.isEmpty }

    static let empty = ContactSet(emails: [], phones: [])
}

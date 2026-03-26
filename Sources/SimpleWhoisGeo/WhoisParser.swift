import Foundation

enum WhoisParser {
    static func parse(_ raw: String) -> WhoisRecord {
        let pairs = tokenise(raw)
        let flat = bucket(pairs)
        let blocks = extractBlocks(raw)

        let orgName = firstValue(flat, keys: ["orgname", "org-name", "netname", "descr"])
        let country = firstValue(flat, keys: ["country"])

        let abuse = abuseContact(from: flat, blocks: blocks)
        let noc   = nocContact(from: flat)
        let tech  = techContact(from: flat, blocks: blocks)

        return WhoisRecord(
            orgName: orgName,
            country: country.uppercased(),
            abuse: abuse,
            noc: noc,
            tech: tech
        )
    }

    // MARK: - Private

    private static func tokenise(_ raw: String) -> [(key: String, value: String)] {
        raw.components(separatedBy: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty,
                  !trimmed.hasPrefix("%"),
                  !trimmed.hasPrefix("#"),
                  let colonRange = trimmed.range(of: ":") else { return nil }
            let key = String(trimmed[trimmed.startIndex..<colonRange.lowerBound])
                .trimmingCharacters(in: .whitespaces)
            let value = String(trimmed[colonRange.upperBound...])
                .trimmingCharacters(in: .whitespaces)
            guard !key.isEmpty, !value.isEmpty else { return nil }
            return (key.lowercased(), value)
        }
    }

    private static func bucket(_ pairs: [(key: String, value: String)]) -> [String: [String]] {
        var result: [String: [String]] = [:]
        for (key, value) in pairs {
            result[key, default: []].append(value)
        }
        return result
    }

    private static func extractBlocks(_ raw: String) -> [[String: [String]]] {
        raw.components(separatedBy: "\n\n").map { block in
            bucket(tokenise(block))
        }.filter { !$0.isEmpty }
    }

    private static func firstValue(_ dict: [String: [String]], keys: [String]) -> String {
        for key in keys {
            if let values = dict[key], let first = values.first, !first.isEmpty {
                return first
            }
        }
        return ""
    }

    private static func abuseContact(
        from flat: [String: [String]],
        blocks: [[String: [String]]]
    ) -> ContactSet {
        // ARIN path
        if let emails = flat["orgabuseemail"], !emails.isEmpty {
            let phones = flat["orgabusephone"] ?? []
            return ContactSet(emails: emails, phones: phones)
        }
        // RIPE/APNIC: look for abuse-mailbox in any block
        for block in blocks {
            if let mailboxes = block["abuse-mailbox"], !mailboxes.isEmpty {
                let phones = block["phone"] ?? []
                return ContactSet(emails: mailboxes, phones: phones)
            }
        }
        // Fallback: top-level abuse-mailbox
        if let mailboxes = flat["abuse-mailbox"], !mailboxes.isEmpty {
            let phones = flat["phone"] ?? []
            return ContactSet(emails: mailboxes, phones: phones)
        }
        return .empty
    }

    private static func nocContact(from flat: [String: [String]]) -> ContactSet {
        let emails = flat["orgnoc-email"] ?? flat["orgnocemail"] ?? []
        let phones = flat["orgnoc-phone"] ?? flat["orgnocphone"] ?? []
        return emails.isEmpty && phones.isEmpty ? .empty : ContactSet(emails: emails, phones: phones)
    }

    private static func techContact(
        from flat: [String: [String]],
        blocks: [[String: [String]]]
    ) -> ContactSet {
        // ARIN path
        if let emails = flat["orgtechemail"], !emails.isEmpty {
            let phones = flat["orgtechphone"] ?? []
            return ContactSet(emails: emails, phones: phones)
        }
        // RIPE/APNIC: look for a block with role containing "tech" and an e-mail
        for block in blocks {
            if let roles = block["role"] {
                let istech = roles.contains { $0.lowercased().contains("tech") }
                if istech, let emails = block["e-mail"], !emails.isEmpty {
                    let phones = block["phone"] ?? []
                    return ContactSet(emails: emails, phones: phones)
                }
            }
        }
        return .empty
    }
}

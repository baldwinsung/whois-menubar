import SwiftUI

struct ContactPopover: View {
    let ip: String
    let record: WhoisRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(ip)
                .font(.headline)
                .textSelection(.enabled)

            if record.abuse.isEmpty && record.noc.isEmpty && record.tech.isEmpty {
                Text("No contact information available.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                ContactSection(title: "Abuse", contacts: record.abuse)
                ContactSection(title: "NOC", contacts: record.noc)
                ContactSection(title: "Tech", contacts: record.tech)
            }
        }
        .padding()
        .frame(minWidth: 280, maxWidth: 400)
    }
}

private struct ContactSection: View {
    let title: String
    let contacts: ContactSet

    var body: some View {
        if !contacts.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                ForEach(contacts.emails, id: \.self) { email in
                    if let url = URL(string: "mailto:\(email)") {
                        Link(email, destination: url)
                            .font(.callout)
                    }
                }
                ForEach(contacts.phones, id: \.self) { phone in
                    let digits = phone.filter { $0.isNumber || $0 == "+" }
                    if let url = URL(string: "tel:\(digits)") {
                        Link(phone, destination: url)
                            .font(.callout)
                    } else {
                        Text(phone)
                            .font(.callout)
                    }
                }
            }
        }
    }
}

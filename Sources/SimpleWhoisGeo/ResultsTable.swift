import SwiftUI

struct ResultsTable: View {
    let results: [IPResult]
    @Binding var selectedResult: IPResult?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 0) {
                Text("IP").frame(width: 130, alignment: .leading)
                Text("Provider / Org").frame(maxWidth: .infinity, alignment: .leading)
                Text("Country").frame(width: 70, alignment: .trailing)
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)

            Divider()

            List(results) { result in
                ResultRow(result: result)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if case .success = result.state {
                            selectedResult = (selectedResult?.id == result.id) ? nil : result
                        }
                    }
                    .background(selectedResult?.id == result.id ? Color.accentColor.opacity(0.15) : Color.clear)
                    .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
    }
}

private struct ResultRow: View {
    let result: IPResult

    var body: some View {
        HStack(spacing: 0) {
            Text(result.ip)
                .font(.system(.body, design: .monospaced))
                .frame(width: 130, alignment: .leading)
                .lineLimit(1)

            Group {
                switch result.state {
                case .pending:
                    Text("—").foregroundStyle(.secondary)
                case .inProgress:
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.small)
                        Text("Looking up…").foregroundStyle(.secondary)
                    }
                case .success(let record):
                    Text(record.orgName.isEmpty ? "—" : record.orgName)
                        .lineLimit(1)
                case .timedOut:
                    Text("Timed out").foregroundStyle(.secondary).italic()
                case .failed(let msg):
                    Text(msg).foregroundStyle(.red).lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                if case .success(let record) = result.state {
                    let flag = countryFlag(record.country)
                    let display = flag.isEmpty ? (record.country.isEmpty ? "—" : record.country) : flag
                    Text(display)
                } else {
                    Text("")
                }
            }
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }
}

private func countryFlag(_ code: String) -> String {
    guard code.count == 2 else { return "" }
    let base: UInt32 = 127397
    return code.uppercased().unicodeScalars.compactMap {
        Unicode.Scalar($0.value + base)
    }.map(String.init).joined()
}

import SwiftUI

@MainActor
final class LookupViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var results: [IPResult] = []
    @Published var isLookingUp: Bool = false
    @Published var selectedResult: IPResult?

    private let service = WhoisService()
    private var lookupTask: Task<Void, Never>?

    func startLookup() {
        let ips = parseIPs(inputText)
        guard !ips.isEmpty else { return }

        lookupTask?.cancel()
        selectedResult = nil
        results = ips.map { IPResult(id: UUID(), ip: $0, state: .inProgress) }
        isLookingUp = true

        lookupTask = Task {
            let stream = await service.lookup(ips: ips)
            for await result in stream {
                if let idx = results.firstIndex(where: { $0.ip == result.ip }) {
                    results[idx] = result
                }
            }
            isLookingUp = false
        }
    }

    private func parseIPs(_ text: String) -> [String] {
        var seen = Set<String>()
        return text
            .components(separatedBy: CharacterSet(charactersIn: ",\n"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .filter { seen.insert($0).inserted }
    }
}

struct LookupView: View {
    @ObservedObject var viewModel: LookupViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Input area
            VStack(alignment: .leading, spacing: 6) {
                Text("IP Addresses")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextEditor(text: $viewModel.inputText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 80)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                    )
                    .overlay(
                        Group {
                            if viewModel.inputText.isEmpty {
                                Text("Enter IPs separated by commas or newlines…")
                                    .foregroundStyle(.secondary)
                                    .font(.system(.body, design: .monospaced))
                                    .padding(6)
                                    .allowsHitTesting(false)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            }
                        }
                    )

                HStack {
                    Spacer()
                    Button("Lookup") {
                        viewModel.startLookup()
                    }
                    .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                              || viewModel.isLookingUp)
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
            .padding(12)

            if !viewModel.results.isEmpty {
                Divider()

                ResultsTable(
                    results: viewModel.results,
                    selectedResult: $viewModel.selectedResult
                )
                .popover(item: $viewModel.selectedResult) { result in
                    if case .success(let record) = result.state {
                        ContactPopover(ip: result.ip, record: record)
                    }
                }
            } else {
                Spacer()
            }

            Divider()

            // Footer — always visible
            HStack {
                Link("Help", destination: URL(string: "https://github.com/baldwinsung/SimpleWhoisGeo")!)
                    .font(.caption)
                Spacer()
                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
    }
}

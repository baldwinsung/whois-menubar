import Foundation

enum WhoisError: Error {
    case timeout
    case processLaunchFailed(String)
}

actor WhoisService {
    private let whoisPath = "/usr/bin/whois"
    private let timeoutNanoseconds: UInt64 = 10_000_000_000

    func lookup(ips: [String]) -> AsyncStream<IPResult> {
        AsyncStream { continuation in
            Task {
                await withTaskGroup(of: IPResult.self) { group in
                    for ip in ips {
                        group.addTask {
                            do {
                                let raw = try await self.runWhois(ip: ip)
                                let record = WhoisParser.parse(raw)
                                return IPResult(id: UUID(), ip: ip, state: .success(record))
                            } catch WhoisError.timeout {
                                return IPResult(id: UUID(), ip: ip, state: .timedOut)
                            } catch {
                                return IPResult(id: UUID(), ip: ip, state: .failed(error.localizedDescription))
                            }
                        }
                    }
                    for await result in group {
                        continuation.yield(result)
                    }
                }
                continuation.finish()
            }
        }
    }

    private func runWhois(ip: String) async throws -> String {
        try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask { try await self.launchProcess(ip: ip) }
            group.addTask {
                try await Task.sleep(nanoseconds: self.timeoutNanoseconds)
                throw WhoisError.timeout
            }
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }

    private func launchProcess(ip: String) async throws -> String {
        let process = Process()
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.executableURL = URL(fileURLWithPath: whoisPath)
        process.arguments = [ip]
        process.standardOutput = outPipe
        process.standardError = errPipe

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                process.terminationHandler = { _ in
                    let data = outPipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? ""
                    continuation.resume(returning: output)
                }
                do {
                    try process.run()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        } onCancel: {
            process.terminate()
        }
    }
}

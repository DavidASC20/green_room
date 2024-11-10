import Foundation

struct EnvironmentLoader {
    private var env: [String: String] = [:]

    init() {
        loadEnvFile()
    }

    private mutating func loadEnvFile() {
        guard let path = Bundle.main.path(forResource: ".env", ofType: nil) else {
            print("⚠️ No .env file found")
            return
        }
        
        do {
            let contents = try String(contentsOfFile: path)
            contents
                .split(separator: "\n")
                .forEach { line in
                    let parts = line.split(separator: "=", maxSplits: 1)
                    if parts.count == 2 {
                        let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
                        let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                        env[key] = value
                    }
                }
        } catch {
            print("⚠️ Failed to load .env file: \(error)")
        }
    }

    func get(_ key: String) -> String? {
        return env[key]
    }
}


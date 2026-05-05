import Foundation

extension URLRequest {
    public func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "'\(shellEscaped(self.url?.absoluteString ?? ""))' \(newLine)"

        var cURL = "curl "
        var header = ""
        var data: String = ""

        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key, value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "'\(shellEscaped("\(key): \(value)"))' \(newLine)"
            }
        }

        if let bodyData = self.httpBody {
            let bodyString = String(data: bodyData, encoding: .utf8) ?? ""
            if !bodyString.isEmpty {
                data = "--data '\(shellEscaped(bodyString))'"
            }
        }

        cURL += method + url + header + data

        return cURL
    }

    private func shellEscaped(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "'\\''")
    }
}

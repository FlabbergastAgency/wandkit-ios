import Foundation

@available(iOS 14.0, macOS 10.15, *)
struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func post(
        to url: URL,
        headers: [String: String] = [:],
        body: Data? = nil
    ) async throws -> HTTPResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body

        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }

        let (data, response) = try await perform(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse
        }

        return HTTPResponse(data: data, response: httpResponse)
    }

    func post<Body: Encodable>(
        to url: URL,
        headers: [String: String] = [:],
        body: Body,
        encoder: JSONEncoder = JSONEncoder()
    ) async throws -> HTTPResponse {
        var requestHeaders = headers
        requestHeaders["Content-Type"] = requestHeaders["Content-Type"] ?? "application/json"

        let data = try encoder.encode(body)
        return try await post(to: url, headers: requestHeaders, body: data as Data?)
    }

    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            print(request.cURL(pretty: true))

            let task = session.dataTask(with: request) { data, response, error in
                if let error {
                    WandKitLogger.debug("Network request failed: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }

                guard let data, let response else {
                    WandKitLogger.debug("Network request returned empty response")
                    continuation.resume(throwing: HTTPClientError.invalidResponse)
                    return
                }

                continuation.resume(returning: (data, response))
            }

            task.resume()
        }
    }
}

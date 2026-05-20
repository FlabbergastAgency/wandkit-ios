import Foundation

@available(iOS 14.0, macOS 10.15, *)
protocol HTTPClient {
    func get(
        from url: URL,
        headers: [String: String]
    ) async throws -> HTTPResponse

    func post(
        to url: URL,
        headers: [String: String],
        body: Data?
    ) async throws -> HTTPResponse

    func post<Body: Encodable>(
        to url: URL,
        headers: [String: String],
        body: Body,
        encoder: JSONEncoder
    ) async throws -> HTTPResponse
}

struct HTTPResponse {
    let data: Data
    let response: HTTPURLResponse
}

enum HTTPClientError: Error {
    case invalidResponse
    case invalidStatusCode(Int)
}

import Foundation
import FactoryKit

public protocol PomoDuoHTTPService {
    func get<Response: Decodable>(
        from url: URL,
        responseType: Response.Type,
        headers: [String: String]?
    ) async throws -> Response
    
    func post<Request: Encodable, Response: Decodable>(
        to url: URL,
        _ request: Request,
        responseType: Response.Type,
        headers: [String: String]?
    ) async throws -> Response
}

public enum PomoDuoHTTPServiceError: Error {
    case invalidResponse
    case invalidURL
    case encodingFailed
    case decodingFailed(underlying: Error)
    case httpError(statusCode: Int, data: Data)
}

public struct _PomoDuoHTTPService: PomoDuoHTTPService {
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func get<Response: Decodable>(
        from url: URL,
        responseType: Response.Type,
        headers: [String: String]? = nil
    ) async throws -> Response {
        var urlRequest = URLRequest(url: url)
        
        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpURLResponse = response as? HTTPURLResponse else {
            throw PomoDuoHTTPServiceError.invalidResponse
        }
        
        guard (200...299).contains(httpURLResponse.statusCode) else {
            throw PomoDuoHTTPServiceError.httpError(statusCode: httpURLResponse.statusCode, data: data)
        }
        
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw PomoDuoHTTPServiceError.decodingFailed(underlying: error)
        }
    }

    public func post<Request: Encodable, Response: Decodable>(
        to url: URL,
        _ request: Request,
        responseType: Response.Type,
        headers: [String: String]? = nil
    ) async throws -> Response {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        do {
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            throw PomoDuoHTTPServiceError.encodingFailed
        }

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpURLResponse = response as? HTTPURLResponse else {
            throw PomoDuoHTTPServiceError.invalidResponse
        }

        guard (200...299).contains(httpURLResponse.statusCode) else {
            throw PomoDuoHTTPServiceError.httpError(statusCode: httpURLResponse.statusCode, data: data)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw PomoDuoHTTPServiceError.decodingFailed(underlying: error)
        }
    }
}

extension Container {
    public var pomoDuoHTTPService: Factory<PomoDuoHTTPService> {
        Factory(self) { _PomoDuoHTTPService() }
            .scope(.unique)
        // Default scope is unique, but I want to be extra specific
    }
}

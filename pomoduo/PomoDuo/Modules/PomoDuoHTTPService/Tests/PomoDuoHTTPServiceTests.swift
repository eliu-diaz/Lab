import Testing
import Foundation
import PomoDuoHTTPService
import FactoryTesting

// MARK: - Test Models
struct TestRequest: Codable, Equatable {
    let name: String
    let value: Int
}

struct TestResponse: Codable, Equatable {
    let id: String
    let success: Bool
}

// MARK: - Tests
@Suite("PomoDuo HTTP Service Tests")
final class PomoDuoHTTPServiceTests {
    let mockSession: URLSession
    
    init() {
        // Configure mock
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: configuration)
    }
    
    @Test("GET request succeeds with valid response")
    func getRequestSucceeds() async throws {
        // Arrange
        let testURL = URL(string: "https://test.example.com/api")!
        let expectedResponse = TestResponse(id: "123", success: true)
        
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: testURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            
            let responseData = try JSONEncoder().encode(expectedResponse)
            return (response, responseData)
        }
        
        // Act
        let networking = _PomoDuoHTTPService(session: mockSession)
        let response = try await networking.get(
            from: testURL,
            responseType: TestResponse.self
        )
        
        // Assert
        #expect(response == expectedResponse)
    }

    @Test("POST request succeeds with valid response")
    func postRequestSucceeds() async throws {
        // Arrange
        let testURL = URL(string: "https://test.example.com/api")!
        let request = TestRequest(name: "test", value: 42)
        let expectedResponse = TestResponse(id: "123", success: true)

        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: testURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!

            let responseData = try JSONEncoder().encode(expectedResponse)
            return (response, responseData)
        }

        // Act
        let networking = _PomoDuoHTTPService(session: mockSession)
        let response = try await networking.post(
            to: testURL,
            request,
            responseType: TestResponse.self,
            headers: nil
        )

        // Assert
        #expect(response == expectedResponse)
    }

    @Test("POST request includes custom headers")
    func postRequestIncludesCustomHeaders() async throws {
        // Arrange
        let testURL = URL(string: "https://test.example.com/api")!
        let request = TestRequest(name: "test", value: 42)
        let customHeaders = ["Authorization": "Bearer token123", "X-Custom-Header": "value"]

        var receivedHeaders: [String: String]?

        MockURLProtocol.requestHandler = { request in
            receivedHeaders = request.allHTTPHeaderFields

            let response = HTTPURLResponse(
                url: testURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            let responseData = try JSONEncoder().encode(TestResponse(id: "123", success: true))
            return (response, responseData)
        }

        // Act
        let networking = _PomoDuoHTTPService(session: mockSession)
        _ = try await networking.post(
            to: testURL,
            request,
            responseType: TestResponse.self,
            headers: customHeaders
        )

        // Assert
        #expect(receivedHeaders?["Authorization"] == "Bearer token123")
        #expect(receivedHeaders?["X-Custom-Header"] == "value")
        #expect(receivedHeaders?["Content-Type"] == "application/json")
    }

    @Test("POST request throws on HTTP error")
    func postRequestThrowsOnHTTPError() async throws {
        let testURL = URL(string: "https://test.example.com/api")!
        let request = TestRequest(name: "test", value: 42)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: testURL,
                statusCode: 400,
                httpVersion: nil,
                headerFields: nil
            )!

            let errorData = Data("Bad Request".utf8)
            return (response, errorData)
        }

        // Act & Assert
        let networking = _PomoDuoHTTPService(session: mockSession)

        await #expect(throws: PomoDuoHTTPServiceError.self) {
            try await networking.post(
                to: testURL,
                request,
                responseType: TestResponse.self,
                headers: nil
            )
        }
    }

    @Test("POST request encodes body correctly")
    func postRequestEncodesBodyCorrectly() async throws {
        // Arrange
        let testURL = URL(string: "https://test.example.com/api")!
        let request = TestRequest(name: "test", value: 42)

        var receivedBody: Data?

        MockURLProtocol.requestHandler = { urlRequest in
            // Capture body from httpBody or httpBodyStream
            if let httpBody = urlRequest.httpBody {
                receivedBody = httpBody
            } else if let bodyStream = urlRequest.httpBodyStream {
                bodyStream.open()
                defer { bodyStream.close() }

                let bufferSize = 4096
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                defer { buffer.deallocate() }

                var data = Data()
                while bodyStream.hasBytesAvailable {
                    let read = bodyStream.read(buffer, maxLength: bufferSize)
                    if read > 0 {
                        data.append(buffer, count: read)
                    }
                }
                receivedBody = data
            }

            let response = HTTPURLResponse(
                url: testURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            let responseData = try JSONEncoder().encode(TestResponse(id: "123", success: true))
            return (response, responseData)
        }

        // Act
        let networking = _PomoDuoHTTPService(session: mockSession)
        _ = try await networking.post(
            to: testURL,
            request,
            responseType: TestResponse.self,
            headers: nil
        )

        // Assert
        #expect(receivedBody != nil)
        let decodedRequest = try JSONDecoder().decode(TestRequest.self, from: receivedBody!)
        #expect(decodedRequest == request)
    }
}

@testable import SwiftRESTAPI
import VaporTesting
import Testing

@Suite("App Tests")
struct SwiftRESTAPITests {
    @Test("Health endpoint returns JSON")
    func health() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "health", afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(res.headers.contentType == .json)
                let body = try res.content.decode(HealthResponse.self)
                #expect(body.status == "ok")
            })
        }
    }

    @Test("Test Hello World Route")
    func helloWorld() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "hello", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == "Hello, world!")
            })
        }
    }
}

import Vapor

struct HealthResponse: Content {
    let status: String
}

func routes(_ app: Application) throws {
    // Liveness only: no external dependencies exist yet.
    app.get("health") { req async -> HealthResponse in
        HealthResponse(status: "ok")
    }

    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
}

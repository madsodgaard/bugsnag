import Vapor

public final class BugsnagClient: Service, Middleware {
    public let apiKey: String
    public let hostName: String
    public let payloadVersion: UInt8
    
    public init(_ config: BugsnagConfig) {
        self.apiKey = config.apiKey
        self.hostName = config.hostName
        self.payloadVersion = config.payloadVersion
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        do {
            return try next.respond(to: request).map(to: Response.self) { res in
                return res
            }
        } catch let error {
            // try self.report(error: error, request: request)
            self.report(on: request)
            throw error
        }
    }
    
    private func report(on request: Request) {
        _ = HTTPClient.connect(hostname: "notify.bugsnag.com", on: request)
            .flatMap(to: HTTPResponse.self) { client in
                let apiKey : String = "d70977c90ea82f8fa72c0d655bda637e"
                
                let headers = HTTPHeaders.init([
                    ("Content-Type", "application/json"),
                    ("Bugsnag-Api-Key", apiKey),
                    ("Bugsnag-Payload-Version", "4")
                ])
                
                let body : LosslessHTTPBodyRepresentable = HTTPBody(string: "test")
                
                let req = HTTPRequest(method: .POST, url: "/", headers: headers, body: body)
                return client.send(req)
            }
            .map(to: Void.self) { response in
                print(response.status)
        }
        
        //print("lol")
    }
}
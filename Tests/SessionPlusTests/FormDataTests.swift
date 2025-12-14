import Foundation
@testable import SessionPlus
import Testing

struct FormDataTests {

    private let imageBase64 = "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"
    private let filename = "Image.png"

    @Test func formDataRequest() throws {
        let imageData = try #require(Data(base64Encoded: imageBase64))

        let request = FormData(path: "", field: "image", filename: filename, mimeType: .png, content: imageData)
        let contentType = try #require(request.headers?[.contentType] as? String)
        let boundary = contentType.suffix(32)
        let body = try #require(request.body)
        let data = originalImplementation(data: imageData, filename: filename, boundary: String(boundary))

        #expect(body == data)
    }

    private func originalImplementation(data: Data, filename: String, boundary: String) -> Data {
        var output = Data()

        if let d = "--\(boundary)\r\n".data(using: .utf8) {
            output.append(d)
        }
        if let d = "Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n".data(using: .utf8) {
            output.append(d)
        }
        if let d = "Content-Type: image/png\r\n\r\n".data(using: .utf8) {
            output.append(d)
        }
        output.append(data)
        if let d = "\r\n".data(using: .utf8) {
            output.append(d)
        }
        if let d = "--\(boundary)--\r\n".data(using: .utf8) {
            output.append(d)
        }

        return output
    }
}


import CoreImage
import Metal

private func defaultMetalLibrary() throws -> Data {
    let url = Bundle.main.url(forResource: "Resource", withExtension: "metallib")!
    return try Data(contentsOf: url)
}

extension CIKernel {
    /// Init CI kernel with just a `functionName` directly from default metal library
    convenience init(functionName: String) throws {
        let metalLibrary = try defaultMetalLibrary()
        try self.init(functionName: functionName, fromMetalLibraryData: metalLibrary)
    }
}

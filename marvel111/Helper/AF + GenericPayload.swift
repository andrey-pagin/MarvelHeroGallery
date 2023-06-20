import Foundation
import Alamofire

extension DataRequest {
    
    struct AnyPayload<T: Decodable>: Decodable {
        let data: T?
    }
    
    /// Adds a handler using a `DecodableResponseSerializer` to be called once the request has finished.
    ///
    /// - Parameters:
    ///   - type:                `Decodable` type to decode from response data.
    ///   - queue:               The queue on which the completion handler is dispatched. `.main` by default.
    ///   - dataPreprocessor:    `DataPreprocessor` which processes the received `Data` before calling the
    ///                          `completionHandler`. `PassthroughPreprocessor()` by default.
    ///   - decoder:             `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
    ///   - emptyResponseCodes:  HTTP status codes for which empty responses are always valid. `[204, 205]` by default.
    ///   - emptyRequestMethods: `HTTPMethod`s for which empty responses are always valid. `[.head]` by default.
    ///   - completionHandler:   A closure to be executed once the request has finished.
    ///
    /// - Returns:               The request.
    @discardableResult
    func responseDataDecodable<T: Decodable>(
        of type: T.Type = T.self,
        queue: DispatchQueue = .main,
        dataPreprocessor: DataPreprocessor = DecodableResponseSerializer<T>.defaultDataPreprocessor,
        decoder: DataDecoder = JSONDecoder(),
        emptyResponseCodes: Set<Int> = DecodableResponseSerializer<T>.defaultEmptyResponseCodes,
        emptyRequestMethods: Set<HTTPMethod> = DecodableResponseSerializer<T>.defaultEmptyRequestMethods,
        completionHandler: @escaping (AFDataResponse<AnyPayload<T>>) -> Void
    ) -> Self {
        response(queue: queue,
                 responseSerializer: DecodableResponseSerializer(dataPreprocessor: dataPreprocessor,
                                                                 decoder: decoder,
                                                                 emptyResponseCodes: emptyResponseCodes,
                                                                 emptyRequestMethods: emptyRequestMethods),
                 completionHandler: completionHandler)
    }
}

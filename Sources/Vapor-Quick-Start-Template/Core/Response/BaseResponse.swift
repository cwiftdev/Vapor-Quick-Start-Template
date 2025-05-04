import Vapor

struct BaseResponse<T: Content>: Content {
    var success: Bool = true
    var data: T? = nil
    var error: BaseErrorResponse? = nil
}

extension BaseResponse{
    static func success(data: T? = nil) -> BaseResponse {
        BaseResponse(data: data)
    }
    
    static func failure(errorResponse: BaseErrorResponse) -> BaseResponse {
        BaseResponse(success: false, error: errorResponse)
    }
}

struct BaseErrorResponse: Content {
    let identifier: String
    let systemMessage: String?
    let userMessage: String?
}

struct EmptyResponse: Content {}



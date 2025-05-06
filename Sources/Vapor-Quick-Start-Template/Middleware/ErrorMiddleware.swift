import Vapor

final class ErrorMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: any Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).flatMapErrorThrowing { error in
            return self.convertToError(request: request, error: error)
        }
    }
}

private extension ErrorMiddleware {
    @Sendable
    func convertToError(request: Request, error: any Error) -> Response {
        request.logger.report(error: error)
        
        guard let error = error as? (any LocalizableErrorProtocol) else {
            let localizationService = request.dSource.localizationService
            let localizedUserMessage = localizationService.localize(localizable: "error.common.generic_oops")
            var systemMessage: String?
            if request.application.environment != .production {
                systemMessage = error.localizedDescription
            }
            let errorResponse = BaseErrorResponse(
                identifier: "unknow_error",
                systemMessage: systemMessage,
                userMessage: localizedUserMessage
            )
            return convertErrorIntoResponse(
                for: request,
                status: .internalServerError,
                errorResponse: errorResponse
            )
        }
        
        let localizationService = request.dSource.localizationService
        let localizedUserMessage = localizationService.localize(localizable: error)
        let errorResponse = BaseErrorResponse(
            identifier: error.identifier,
            systemMessage: error.systemMessage,
            userMessage: localizedUserMessage
        )
        return convertErrorIntoResponse(
            for: request,
            status: error.status,
            errorResponse: errorResponse
        )
    }
    
    @Sendable
    func convertErrorIntoResponse(
        for request: Request,
        status: HTTPResponseStatus,
        errorResponse: BaseErrorResponse
    ) -> Response {
        let response = Response(status: status)
        let baseResponse = BaseResponse<EmptyResponse>.failure(errorResponse: errorResponse)
        if let data = try? JSONEncoder().encode(baseResponse) {
            response.body = .init(data: data, byteBufferAllocator: request.byteBufferAllocator)
        }
        response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        return response
    }
}

import Vapor
import Queues
import SMTPKitten
import VaporSMTPKit

struct SendEmailPayload: Content, Sendable {
    let subject: String
    let content: String
    let recipients: Set<String>
}

fileprivate extension SendEmailPayload {
    func mapToMail(_ sender: String) -> Mail {
        .init(
            from: MailUser(stringLiteral: sender),
            to: Set(recipients.compactMap{ MailUser(stringLiteral: $0) }),
            subject: subject,
            contentType: .html,
            text: content
        )
    }
}

struct SendEmailJob: AsyncJob {
    typealias Payload = SendEmailPayload
    
    func dequeue(_ context: Queues.QueueContext, _ payload: SendEmailPayload) async throws {
        let application = context.application
        let envConfig = application.environmentConfiguration
        let credentials = SMTPCredentials(
            hostname: envConfig.smtpHost,
            ssl: .startTLS(configuration: .default),
            email: envConfig.smtpMail,
            password: envConfig.smtpPassword
        )
        try await application.sendMail(
            payload.mapToMail(envConfig.smtpMail),
            withCredentials: credentials
        ).get()
    }
}

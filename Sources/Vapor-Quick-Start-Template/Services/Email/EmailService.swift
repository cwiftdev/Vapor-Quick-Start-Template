import Queues
import Vapor

/// A protocol that represents a user who can receive emails.
/// Conforming types must provide an email address.
protocol AppMailUser: Content {
    /// The email  associated with the user.
    var email: String { get }
}

/// A protocol that defines the structure of an email template to be sent to users.
protocol EmailTemplate {
    /// The subject line of the email.
    var subject: String { get }
    /// The main content/body of the email
    var content: String { get }
    /// The list of recipients who will receive the email.
    var recipients: [any AppMailUser] { get }
}

/// A service responsible for sending emails using predefined templates.
protocol EmailService: Sendable {
    /// Sends an email based on the provided template.
    /// - Parameter template: The email template containing subject, content, and recipients.
    /// - Throws: An error if the email fails to send.
    func send(_ template: any EmailTemplate) async throws
}

extension SendEmailPayload {
    init(template: any EmailTemplate) {
        self.init(
            subject: template.subject,
            content: template.content,
            recipients: Set(template.recipients.compactMap(\.email))
        )
    }
}

extension Application {
    private enum EmailServiceStorageKey: StorageKey {
        typealias Value = any EmailService.Type
    }
    
    var emailServiceType: any EmailService.Type {
        get {
            storage[EmailServiceStorageKey.self, default: AppEmailService.self]
        }
        set {
            storage[EmailServiceStorageKey.self] = newValue
        }
    }
}

struct AppEmailService: EmailService {
    private let queue: any Queue
    init(request: Request) { queue = request.queue }
    
    func send(_ template: any EmailTemplate) async throws {
        try await queue.dispatch(SendEmailJob.self, .init(template: template))
    }
}

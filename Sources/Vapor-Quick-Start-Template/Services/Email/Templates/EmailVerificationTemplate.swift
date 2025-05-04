import Vapor

private extension VerifyEmailMailTemplate {
    enum Constant {
        static let urlReplaceKey = "{{verify_url}}"
    }
}

struct VerifyEmailMailTemplate {
    private let receiver: any AppMailUser
    private let verificationURL: String
    private let localizationService: any LocalizationService
    
    @ResourceFileContent(fileName: "EmailVerificationTemplate.html", directory: .emails)
    private var templateContent: String
    
    private var localizedContent: String {
        localizationService.localize(
            content: templateContent,
            locale: nil,
            partialLocalizations: ResourcePartialLocalization.allCases
        )
    }
    
    init(
        localizationService: any LocalizationService,
        verificationURL: String,
        receiver: any AppMailUser
    ) {
        self.localizationService = localizationService
        self.verificationURL = verificationURL
        self.receiver = receiver
    }
}

extension VerifyEmailMailTemplate: EmailTemplate {
    var recipients: [any AppMailUser] { [receiver] }
    var subject: String {
        let subjectKey = ResourcePartialLocalization.subject.localizationKey
        return localizationService.localize(localizable: subjectKey)
    }
    var content: String {
        localizedContent.replacingOccurrences(
            of: Constant.urlReplaceKey,
            with: verificationURL
        )
    }
}

private extension VerifyEmailMailTemplate {
    enum ResourcePartialLocalization: CaseIterable, PartialLocalizable {
        case subject
        case clickToVerifyButtonInfo
        case clickToVerifyButton
        case buttonDoesntWorkInfo
        
        var localizationKey: String { "email.verify_email.\(replacingKeySuffix)" }
        
        private var replacingKeySuffix: String {
            switch self {
            case .subject:
                return "subject"
            case .clickToVerifyButtonInfo:
                return "body.click_to_verify_button_info"
            case .clickToVerifyButton:
                return "body.click_to_verify_button"
            case .buttonDoesntWorkInfo:
                return "body.click_to_verify_button_doesnt_work_info"
            }
        }
    }
}

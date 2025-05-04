import Vapor

private extension ResetPasswordMailTemplate {
    enum Constant {
        static let urlReplaceKey = "{{reset_url}}"
    }
}

struct ResetPasswordMailTemplate {
    private let receiver: any AppMailUser
    private let resetPasswordUrl: String
    private let localizationService: any LocalizationService
    
    @ResourceFileContent(fileName: "ResetPasswordTemplate.html", directory: .emails)
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
        resetPasswordUrl: String,
        receiver: any AppMailUser
    ) {
        self.localizationService = localizationService
        self.resetPasswordUrl = resetPasswordUrl
        self.receiver = receiver
    }
}

extension ResetPasswordMailTemplate: EmailTemplate {
    var recipients: [any AppMailUser] { [receiver] }
    var subject: String {
        let subjectKey = ResourcePartialLocalization.subject.localizationKey
        return localizationService.localize(localizable: subjectKey)
    }
    var content: String {
         localizedContent.replacingOccurrences(
            of: Constant.urlReplaceKey,
            with: resetPasswordUrl
        )
    }
}

private extension ResetPasswordMailTemplate {
    enum ResourcePartialLocalization: CaseIterable, PartialLocalizable {
        case subject
        case clickToResetPasswordButtonInfo
        case resetButtonText
        case buttonDoesntWorkInfo
        
        var localizationKey: String { "email.reset_password.\(replacingKeySuffix)" }
        
        private var replacingKeySuffix: String {
            switch self {
            case .subject:
                return "subject"
            case .clickToResetPasswordButtonInfo:
                return "body.click_to_reset_password_button_info"
            case .resetButtonText:
                return "body.reset_button_text"
            case .buttonDoesntWorkInfo:
                return "body.button_doesnt_work_info"
            }
        }
    }
}

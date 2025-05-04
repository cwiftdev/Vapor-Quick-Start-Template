import Vapor
import Fluent

final class UserResetPasswordTokenEntity: Model,
                                          @unchecked Sendable {
    static let schema = "user_reset_password_tokens"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int?
    
    @Parent(key: "user_id")
    var user: UserEntity
    
    @Field(key: "token")
    var token: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    init() {}
    
    init(
        userID: UserEntity.IDValue,
        token: String,
        expiresAt: Date = .addTimeIntervalNow(Constants.TokenDuration.RESET_PASSWORD_TOKEN)
    ) {
        self.$user.id = userID
        self.token = token
        self.expiresAt = expiresAt
    }
}

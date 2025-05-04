import Vapor
import Fluent

final class UserRefreshTokenEntity: Model,
                                    @unchecked Sendable {
    static let schema = "user_refresh_tokens"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int?
    
    @Parent(key: "user_id")
    var user: UserEntity
    
    @Field(key: "token")
    var token: String
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(
        userID: UserEntity.IDValue,
        token: String,
        expiresAt: Date = .addTimeIntervalNow(Constants.TokenDuration.REFRESH_TOKEN)
    ) {
        self.token = token
        self.$user.id = userID
        self.expiresAt = expiresAt
    }
}

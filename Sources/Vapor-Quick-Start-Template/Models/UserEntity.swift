import Fluent
import Vapor

final class UserEntity: Model,
                        AppMailUser,
                        @unchecked Sendable {
    static let schema = "users"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "role")
    var role: UserRole
    
    @Field(key: "is_email_verified")
    var isEmailVerified: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init(
        id: UserEntity.IDValue? = nil,
        email: String,
        passwordHash: String,
        role: UserRole,
        isEmailVerified: Bool = false
    ) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
        self.role = role
        self.isEmailVerified = isEmailVerified
    }
    
    init() {}
}

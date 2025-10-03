import Foundation

enum Role: String {
    case user
    case operatorRole = "operator"

    init(serverValue: String?) {
        switch serverValue?.lowercased() {
        case "operator", "admin", "ops": self = .operatorRole
        default: self = .user
        }
    }
}

final class UserSession {
    static let shared = UserSession()
    private init() {}

    var jwtToken: String?
    var role: Role = .user

    var isOperator: Bool { role == .operatorRole }
}

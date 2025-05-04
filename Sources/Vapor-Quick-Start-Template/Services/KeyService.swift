import Vapor

protocol KeyService: Sendable {
    func generateUniqueKey() -> String
}

struct AppKeyService: KeyService {
    func generateUniqueKey() -> String { UUID().uuidString }
}

extension Application {
    struct KeyServiceStorageKey: StorageKey {
        typealias Value = KeyService
    }
    
    var keyService: any KeyService {
        guard let keyService = storage.get(KeyServiceStorageKey.self) else {
            let keyService = AppKeyService()
            storage[KeyServiceStorageKey.self] = keyService
            return keyService
        }
        return keyService
    }
}

import Foundation

final class AppStorage {
    
    static var deviceId: String {
        get {
            if let id = UserDefaults.standard.string(forKey: "deivce_id") {
                return id
            }
            let id = UUID().uuidString
            UserDefaults.standard.set(id, forKey: "deivce_id")
            return id
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "deivce_id")
        }
    }
    
    static var jwt: String? {
        get {
            return UserDefaults.standard.string(forKey: "access_token")
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "access_token")
            } else {
                UserDefaults.standard.set(newValue, forKey: "access_token")
            }
        }
    }
    
    static var fcmToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "fcm_token")
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "fcm_token")
            } else {
                UserDefaults.standard.set(newValue, forKey: "fcm_token")
            }
        }
    }
    
}


import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    struct LoginData: Codable {
            let username: String
            let password: String
        }
        
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
              emailTextField.layer.cornerRadius = 10
              emailTextField.layer.masksToBounds = true
              
              passwordTextField.layer.cornerRadius = 10
              passwordTextField.layer.masksToBounds = true
              
              // "LOG IN" butonu için
              if let loginButton = view.subviews.first(where: { ($0 as? UIButton)?.title(for: .normal) == "LOG IN" }) as? UIButton {
                  loginButton.layer.cornerRadius = 10
                  loginButton.layer.masksToBounds = true
              }
        
        
        
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
               let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

               guard !email.isEmpty, !password.isEmpty else {
                   showAlert(title: "Hata", message: "Lütfen tüm alanları doldurun.")
                   return
               }
               loginUser(email: email, password: password)
           }

    // LoginViewController.swift dosyasının içindeki loginUser fonksiyonu
    private func loginUser(email: String, password: String) {
        guard let url = URL(string: "http://127.0.0.1:3000/auth/login") else { return }

        let body = LoginData(username: email, password: password)
        guard let json = try? JSONEncoder().encode(body) else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = json

        URLSession.shared.dataTask(with: req) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Hata", message: error.localizedDescription)
                    return
                }

                guard let http = response as? HTTPURLResponse else {
                    self.showAlert(title: "Hata", message: "Geçersiz yanıt.")
                    return
                }

                if (200...299).contains(http.statusCode),
                   let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["access_token"] as? String {
                    
                    // MARK: - JWT TOKEN'ı KAYDETME
                    UserDefaults.standard.set(token, forKey: "jwtToken")
                    print("✅ JWT Token UserDefaults'a kaydedildi")
                    
                    // MARK: - KULLANICI ROLÜNÜ KAYDETME
                    if let userDict = json["user"] as? [String: Any],
                       let userRole = userDict["role"] as? String {
                        UserDefaults.standard.set(userRole, forKey: "userRole")
                        print("✅ Kullanıcı rolü UserDefaults'a kaydedildi: \(userRole)")
                    }

                    print("JWT Token:", token)
                    // Başarı: Sadece bu noktada geçiş yap
                    self.performSegue(withIdentifier: "toMap", sender: nil)
                    
                } else {
                    if let data = data, let s = String(data: data, encoding: .utf8) {
                        print("Hata yanıtı:", s)
                    }
                    self.showAlert(title: "Hata", message: "Giriş başarısız.")
                }
            }
        }.resume()
    }
           private func showAlert(title: String, message: String) {
               let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
               ac.addAction(UIAlertAction(title: "Tamam", style: .default))
               present(ac, animated: true)
           }

    @IBAction func signupButtonTapped(_ sender: Any) {
    }
}
        

    




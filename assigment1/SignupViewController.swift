import UIKit
import Foundation

class SignupViewController: UIViewController {
    
    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    struct UserRegistration: Codable {
        let username: String
        let password: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Text field'ların köşelerini oval yap
             let cornerRadius: CGFloat = 10
             
             fullNameTextField.layer.cornerRadius = cornerRadius
             fullNameTextField.layer.masksToBounds = true
             
             emailTextField.layer.cornerRadius = cornerRadius
             emailTextField.layer.masksToBounds = true
             
             passwordTextField.layer.cornerRadius = cornerRadius
             passwordTextField.layer.masksToBounds = true
             
             confirmPasswordTextField.layer.cornerRadius = cornerRadius
             confirmPasswordTextField.layer.masksToBounds = true
             
             // Butonların köşelerini oval yap
             if let signupButton = view.subviews.first(where: { ($0 as? UIButton)?.title(for: .normal) == "SIGN UP" }) as? UIButton {
                 signupButton.layer.cornerRadius = 10
                 signupButton.layer.masksToBounds = true
             }
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
    
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,
               let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !password.isEmpty,
               let confirmPassword = confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !confirmPassword.isEmpty else {
             showErrorAlert(message: "Lütfen tüm alanları doldurun.")
             return
         }
         
         if password != confirmPassword {
             showErrorAlert(message: "Şifreler eşleşmiyor.")
             return
         }
         
         registerUser(username: email, password: password)
     }
    
    func registerUser(username: String, password: String) {
        guard let url = URL(string: "http://localhost:3000/auth/register") else {
            return
        }

        let registrationData = UserRegistration(username: username, password: password)

        guard let jsonData = try? JSONEncoder().encode(registrationData) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Kayıt sırasında bir hata oluştu: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }

            if httpResponse.statusCode == 201 {
                DispatchQueue.main.async {
                    self.showSuccessAlert()
                }
            } else {
                var errorMessage = "Kayıt başarısız oldu."
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Yanıt Mesajı: \(responseString)")
                    errorMessage = responseString
                }
                DispatchQueue.main.async {
                    self.showErrorAlert(message: errorMessage)
                }
            }
        }

        task.resume()
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func showSuccessAlert() {
        let alert = UIAlertController(title: "Başarılı", message: "Hesabınız başarıyla oluşturuldu.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
   
    @IBAction func loginButtonTapped(_ sender: Any) {
    }
}

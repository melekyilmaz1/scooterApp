import UIKit
import CoreLocation

final class AddScooterViewController: UIViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let uniqueNameTextField = UITextField()
    private let batteryStatusTextField = UITextField()
    private let latitudeTextField = UITextField()
    private let longitudeTextField = UITextField()
    private let addButton = UIButton(type: .system)
    private let currentLocationButton = UIButton(type: .system)
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Yeni Scooter Ekle"
        
        setupNavigationBar()
        setupLocationManager()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        if presentingViewController != nil && navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "İptal",
                style: .plain,
                target: self,
                action: #selector(close)
            )
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setupUI() {
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Unique Name Field
        setupTextField(uniqueNameTextField, placeholder: "Scooter Adı (örn: S-001)", keyboardType: .default)
        
        // Battery Status Field
        setupTextField(batteryStatusTextField, placeholder: "Batarya Durumu (0-100)", keyboardType: .numberPad)
        
        // Latitude Field
        setupTextField(latitudeTextField, placeholder: "Enlem (Latitude)", keyboardType: .decimalPad)
        
        // Longitude Field
        setupTextField(longitudeTextField, placeholder: "Boylam (Longitude)", keyboardType: .decimalPad)
        
        // Current Location Button
        currentLocationButton.setTitle("📍 Mevcut Konumu Kullan", for: .normal)
        currentLocationButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        currentLocationButton.setTitleColor(.systemBlue, for: .normal)
        currentLocationButton.backgroundColor = .systemGray6
        currentLocationButton.layer.cornerRadius = 8
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
        currentLocationButton.addTarget(self, action: #selector(useCurrentLocation), for: .touchUpInside)
        contentView.addSubview(currentLocationButton)
        
        // Add Button
        addButton.setTitle("➕ Scooter Ekle", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .systemBlue
        addButton.layer.cornerRadius = 12
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addScooter), for: .touchUpInside)
        contentView.addSubview(addButton)
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String, keyboardType: UIKeyboardType) {
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Text Fields
            uniqueNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            uniqueNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            uniqueNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            uniqueNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            batteryStatusTextField.topAnchor.constraint(equalTo: uniqueNameTextField.bottomAnchor, constant: 16),
            batteryStatusTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            batteryStatusTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            batteryStatusTextField.heightAnchor.constraint(equalToConstant: 50),
            
            latitudeTextField.topAnchor.constraint(equalTo: batteryStatusTextField.bottomAnchor, constant: 16),
            latitudeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            latitudeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            latitudeTextField.heightAnchor.constraint(equalToConstant: 50),
            
            longitudeTextField.topAnchor.constraint(equalTo: latitudeTextField.bottomAnchor, constant: 16),
            longitudeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            longitudeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            longitudeTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Current Location Button
            currentLocationButton.topAnchor.constraint(equalTo: longitudeTextField.bottomAnchor, constant: 24),
            currentLocationButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            currentLocationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Add Button
            addButton.topAnchor.constraint(equalTo: currentLocationButton.bottomAnchor, constant: 32),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    @objc private func close() {
        dismiss(animated: true)
    }
    
    @objc private func useCurrentLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            showAlert(title: "Konum İzni Gerekli", message: "Mevcut konumunuzu kullanmak için Ayarlar > Gizlilik > Konum Servisleri'nden izin verin.")
        @unknown default:
            break
        }
    }
    
    @objc private func addScooter() {
        guard let uniqueName = uniqueNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !uniqueName.isEmpty else {
            showAlert(title: "Hata", message: "Lütfen scooter adını girin.")
            return
        }
        
        guard let batteryText = batteryStatusTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let batteryStatus = Int(batteryText),
              batteryStatus >= 0 && batteryStatus <= 100 else {
            showAlert(title: "Hata", message: "Lütfen geçerli bir batarya durumu girin (0-100).")
            return
        }
        
        guard let latitudeText = latitudeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let latitude = Double(latitudeText) else {
            showAlert(title: "Hata", message: "Lütfen geçerli bir enlem değeri girin.")
            return
        }
        
        guard let longitudeText = longitudeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let longitude = Double(longitudeText) else {
            showAlert(title: "Hata", message: "Lütfen geçerli bir boylam değeri girin.")
            return
        }
        
        // API'ye scooter ekleme isteği gönder
        addScooterToAPI(uniqueName: uniqueName, batteryStatus: batteryStatus, latitude: latitude, longitude: longitude)
    }
    
    private func addScooterToAPI(uniqueName: String, batteryStatus: Int, latitude: Double, longitude: Double) {
        guard let url = URL(string: "http://127.0.0.1:3000/scooters") else { return }
        
        // JWT token'ı al
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            showAlert(title: "Hata", message: "Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.")
            return
        }
        
        let scooterData: [String: Any] = [
            "unique_name": uniqueName,
            "battery_status": batteryStatus,
            "latitude": latitude,
            "longitude": longitude
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: scooterData) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(title: "Hata", message: error.localizedDescription)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.showAlert(title: "Hata", message: "Geçersiz yanıt.")
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    // Başarılı: Map ekranına haber ver ve kapat
                    NotificationCenter.default.post(name: Notification.Name("ScooterAdded"), object: nil)
                    self?.showSuccessAlert()
                } else {
                    if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        self?.showAlert(title: "Hata", message: errorMessage)
                    } else {
                        self?.showAlert(title: "Hata", message: "Scooter eklenirken bir hata oluştu.")
                    }
                }
            }
        }.resume()
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "✅ Başarılı", message: "Scooter başarıyla eklendi!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension AddScooterViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        latitudeTextField.text = String(format: "%.6f", location.coordinate.latitude)
        longitudeTextField.text = String(format: "%.6f", location.coordinate.longitude)
        
        showAlert(title: "📍 Konum Alındı", message: "Mevcut konumunuz form alanlarına eklendi.")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "Konum Hatası", message: "Konum alınamadı: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}

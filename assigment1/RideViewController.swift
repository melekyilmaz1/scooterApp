// src/ios/assigment1/RideViewController.swift

import UIKit
import Foundation

class RideViewController: UIViewController {

    var scooter: Scooter!
    var countdownLabel: UILabel!
    var timer: Timer?
    var secondsLeft: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Batarya seviyesini başlangıç değeri olarak ayarla
        self.secondsLeft = scooter.batteryStatus

        // UI elemanlarını oluşturma
        countdownLabel = UILabel()
        countdownLabel.textAlignment = .center
        countdownLabel.font = .systemFont(ofSize: 60, weight: .bold)
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countdownLabel)
        
        let stopButton = UIButton(type: .system)
        stopButton.setTitle("Sürüşü Bitir", for: .normal)
        stopButton.titleLabel?.font = .systemFont(ofSize: 22)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.addTarget(self, action: #selector(stopRide), for: .touchUpInside)
        view.addSubview(stopButton)

        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.topAnchor.constraint(equalTo: countdownLabel.bottomAnchor, constant: 40)
        ])

        startTimer()
    }
    
    // Geri sayım durduğunda veya ekran kapatıldığında timer'ı durdur
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    // MARK: - Timer Logic

    private func startTimer() {
        self.countdownLabel.text = "\(self.secondsLeft)%"
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.secondsLeft -= 1
            self.countdownLabel.text = "\(self.secondsLeft)%"
            
            // Eğer süre 0'a ulaşırsa
            if self.secondsLeft <= 0 {
                self.stopRide(isTimeUp: true)
            }
        }
    }

    @objc private func stopRide(isTimeUp: Bool = false) {
        // Timer'ı durdur
        timer?.invalidate()
        timer = nil

        // API çağrısını yap
        updateScooterBattery(newBatteryStatus: self.secondsLeft)

        // Sürüş ekranını kapat
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - API Çağrısı (Sürüşü Bitir)
    private func updateScooterBattery(newBatteryStatus: Int) {
        guard let jwtToken = UserDefaults.standard.string(forKey: "user_jwt_token") else {
            print("Hata: JWT token bulunamadı. Güncelleme yapılamıyor.")
            return
        }
        
        guard let url = URL(string: "http://localhost:3000/scooters/update-battery") else {
            print("Hata: Geçersiz URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let updateData = ["id": scooter.id, "batteryStatus": newBatteryStatus] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: updateData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Scooter bataryası başarıyla güncellendi.")
            } else {
                print("Batarya güncelleme hatası: \(error?.localizedDescription ?? "Bilinmeyen Hata")")
            }
        }.resume()
    }
}

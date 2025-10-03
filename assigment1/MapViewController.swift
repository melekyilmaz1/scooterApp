import UIKit
import MapboxMaps
import CoreLocation

struct Scooter: Codable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let uniqueName: String
    var batteryStatus: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case uniqueName = "unique_name"
        case batteryStatus = "battery_status"
    }
}

final class MapViewController: UIViewController, AnnotationInteractionDelegate {
    
    private var mapView: MapView!
    private var pointAnnotationManager: PointAnnotationManager!
    private var allScooters: [Scooter] = []
    
    private let addScooterButton = UIButton(type: .system)
    
    // Sürüş simülasyonu
    private var rideTimer: Timer?
    private var ridingScooterIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)

        setupMap()
        setupAnnotations()
        setupOperatorUI()
        refreshOperatorUIVisibility()
        waitMapLoadedThenFetch()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAndFitAfterAdd), name: Notification.Name("ScooterAdded"), object: nil)
    }

    @objc private func reloadAndFitAfterAdd() {
        fetchScootersFromAPI()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshOperatorUIVisibility()
    }
    
    // MARK: - Map
    private func setupMap() {
        let options = MapInitOptions(
            cameraOptions: CameraOptions(
                center: CLLocationCoordinate2D(latitude: 39.9334, longitude: 32.8597),
                zoom: 12
            )
        )
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Stil yükle (mavi ekran kalmasın)
        mapView.mapboxMap.loadStyleURI(StyleURI.streets) { [weak self] _ in
            self?.fetchScootersFromAPI()
        }
    }
    
    private func setupAnnotations() {
        pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        pointAnnotationManager.iconAllowOverlap = true
        pointAnnotationManager.textAllowOverlap = true
        pointAnnotationManager.delegate = self
    }
    
    // MARK: - Operator UI
    private func isOperator() -> Bool {
        // Login'da UserDefaults.standard.set("operator", forKey: "userRole") yaptığını söylemiştin
        return UserDefaults.standard.string(forKey: "userRole") == "operator"
    }
    
    private func setupOperatorUI() {
        addScooterButton.setTitle("➕ Yeni Scooter Ekle", for: .normal)
        addScooterButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        addScooterButton.setTitleColor(.white, for: .normal)
        addScooterButton.backgroundColor = .systemRed // Daha belirgin renk
        addScooterButton.layer.cornerRadius = 8
        addScooterButton.layer.borderWidth = 2
        addScooterButton.layer.borderColor = UIColor.white.cgColor
        addScooterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addScooterButton)
        
        NSLayoutConstraint.activate([
            addScooterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addScooterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20), // ▼ -20 olmalı
            addScooterButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            addScooterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        addScooterButton.addTarget(self, action: #selector(didTapAddScooter), for: .touchUpInside)
    }
    
    private func refreshOperatorUIVisibility() {
        // Debug için rol bilgisini yazdır
        let userRole = UserDefaults.standard.string(forKey: "userRole") ?? "rol_yok"
        print("🔍 Debug - Kullanıcı rolü: \(userRole)")
        print("🔍 Debug - isOperator(): \(isOperator())")
        print("🔍 Debug - Buton view hiyerarşide mi: \(addScooterButton.superview != nil)")
        print("🔍 Debug - Buton frame: \(addScooterButton.frame)")
        
        // Buton zaten hiyerarşide; sadece görünürlüğünü rol'e göre ayarla
        addScooterButton.isHidden = !isOperator()
        print("🔍 Debug - Buton gizli mi: \(addScooterButton.isHidden)")
        print("🔍 Debug - Buton alpha: \(addScooterButton.alpha)")
    }
    
    // MARK: - Data (API)
    private func waitMapLoadedThenFetch() {
        mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in
            self?.fetchScootersFromAPI()
        }
    }
    
    private func fetchScootersFromAPI() {
        guard let url = URL(string: "http://127.0.0.1:3000/scooters") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        // İsteğe bağlı: token eklenebilir
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: req) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error { print("Fetch error:", error); return }
            guard let data = data else { return }
            if let scooters = try? JSONDecoder().decode([Scooter].self, from: data) {
                DispatchQueue.main.async {
                    self.allScooters = scooters
                    self.addAnnotations(from: scooters)
                    self.fitCameraToScooters(scooters)
                }
            } else {
                if let s = String(data: data, encoding: .utf8) { print("Decode error, raw:", s) }
            }
        }.resume()
    }
    
    private func addAnnotations(from scooters: [Scooter]) {
        var annotations: [PointAnnotation] = []
        
        for (index, s) in scooters.enumerated() {
            var pa = PointAnnotation(
                id: "scooter_\(s.id)",
                coordinate: CLLocationCoordinate2D(latitude: s.latitude, longitude: s.longitude)
            )
            
            if let icon = makeScooterIcon(for: s.batteryStatus) {
                pa.image = .init(image: icon, name: "scooter_\(s.id)")
                pa.iconAnchor = .bottom
            }
            
            pa.textField  = "\(s.batteryStatus)%"
            pa.textSize   = 10
            pa.textAnchor = .top
            pa.textOffset = [0, 0.3]
            pa.textColor  = .init(UIColor.label)
            
            // Mapbox v11: userInfo yerine customData (JSONValue)
            pa.customData = ["idx": .number(Double(index))]
            
            annotations.append(pa)
        }
        
        pointAnnotationManager.annotations = annotations
        print("✅ \(annotations.count) scooter gösterildi (API)")
    }
    
    // Tüm scooter'ları ekranda gösterecek şekilde kamerayı ayarla (Sadece Ankara)
    private func fitCameraToScooters(_ scooters: [Scooter]) {
        // Ankara il sınırlarını geniş aralıkla tanımla (Çankaya + Sincan dahil)
        let ankaraSouth: Double = 39.60
        let ankaraNorth: Double = 40.20
        let ankaraWest: Double  = 32.35
        let ankaraEast: Double  = 33.15
        let ankaraCenter = CLLocationCoordinate2D(latitude: 39.9334, longitude: 32.8597)

        // Yalnızca Ankara içinde kalan noktaları al
        let coordinatesInAnkara = scooters
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            .filter { coord in
                coord.latitude  >= ankaraSouth && coord.latitude  <= ankaraNorth &&
                coord.longitude >= ankaraWest  && coord.longitude <= ankaraEast
            }

        // Ankara içinde scooter yoksa Ankara merkezine dön
        guard !coordinatesInAnkara.isEmpty else {
            let camera = CameraOptions(center: ankaraCenter, zoom: 12)
            mapView.mapboxMap.setCamera(to: camera)
            return
        }

        // Ankara içindeki noktalara göre kadrajla
        let padding = UIEdgeInsets(top: 60, left: 24, bottom: 120, right: 24)
        let camera = mapView.mapboxMap.camera(for: coordinatesInAnkara, padding: padding, bearing: nil, pitch: nil)
        mapView.mapboxMap.setCamera(to: camera)
    }
    
    // MARK: - Actions
    @objc private func didTapAddScooter() {
        let addScooterVC = AddScooterViewController()
        let navController = UINavigationController(rootViewController: addScooterVC)
        present(navController, animated: true)
    }
    
    // MARK: - Annotation Tap
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        guard let tapped = annotations.first as? PointAnnotation else { return }
        
        // customData sözlüğünden idx'yi oku
        let obj = tapped.customData
        if case let .number(n)? = obj["idx"] {
            let idx = Int(n)
            guard allScooters.indices.contains(idx) else { return }
            showScooterDetails(for: allScooters[idx])
        }
    }
    
    private func showScooterDetails(for scooter: Scooter) {
        let msg =
        """
        🔋 Batarya: \(scooter.batteryStatus)%
        📍 Konum: \(String(format: "%.4f", scooter.latitude)), \(String(format: "%.4f", scooter.longitude))
        """
        let ac = UIAlertController(title: "🛴 \(scooter.uniqueName)", message: msg, preferredStyle: .alert)
        
        let canStart = scooter.batteryStatus > 20
        ac.addAction(UIAlertAction(title: canStart ? "🚀 Sürüşü Başlat" : "⚡ Düşük Batarya",
                                   style: canStart ? .default : .destructive) { [weak self] _ in
            canStart ? self?.startRide(for: scooter) : self?.showLowBatteryWarning()
        })
        
        // Operatörse Sil butonu
        if isOperator() {
            ac.addAction(UIAlertAction(title: "🗑️ Sil", style: .destructive) { [weak self] _ in
                self?.deleteScooter(id: scooter.id)
            })
        }
        
        ac.addAction(UIAlertAction(title: "❌ Kapat", style: .cancel))
        present(ac, animated: true)
    }

    private func deleteScooter(id: Int) {
        guard let url = URL(string: "http://127.0.0.1:3000/scooters/\(id)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: req) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error { print("Silme hatası:", error.localizedDescription); return }
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                    if let data = data, let s = String(data: data, encoding: .utf8) { print("Silme hata yanıtı:", s) }
                    return
                }
                // Lokal listeden çıkar ve ekranı güncelle
                if let i = self?.allScooters.firstIndex(where: { $0.id == id }) {
                    self?.allScooters.remove(at: i)
                }
                self?.addAnnotations(from: self?.allScooters ?? [])
                self?.fitCameraToScooters(self?.allScooters ?? [])
            }
        }.resume()
    }
    
    private func startRide(for scooter: Scooter) {
        // Mevcut timer'ı durdur
        rideTimer?.invalidate()
        rideTimer = nil
        
        // Hangi scooter üzerinde olduğumuzu bul
        guard let idx = allScooters.firstIndex(where: { $0.id == scooter.id }) else { return }
        ridingScooterIndex = idx
        
        // Her saniye bataryayı 1 azalt
        rideTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self, let i = self.ridingScooterIndex, self.allScooters.indices.contains(i) else { return }
            var current = self.allScooters[i].batteryStatus
            if current <= 0 {
                t.invalidate()
                self.rideTimer = nil
                self.ridingScooterIndex = nil
                self.showLowBatteryWarning()
                return
            }
            current -= 1
            self.allScooters[i].batteryStatus = max(0, current)
            // Anotasyonları güncelle
            self.addAnnotations(from: self.allScooters)
        }
    }
    
    private func startRide(for scooter: Scooter, decrementPerSecond: Int) {
        // Opsiyonel: farklı hızlarda düşüş için overloading
        rideTimer?.invalidate()
        rideTimer = nil
        guard let idx = allScooters.firstIndex(where: { $0.id == scooter.id }) else { return }
        ridingScooterIndex = idx
        rideTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self, let i = self.ridingScooterIndex, self.allScooters.indices.contains(i) else { return }
            var current = self.allScooters[i].batteryStatus
            if current <= 0 {
                t.invalidate()
                self.rideTimer = nil
                self.ridingScooterIndex = nil
                self.showLowBatteryWarning()
                return
            }
            current -= decrementPerSecond
            self.allScooters[i].batteryStatus = max(0, current)
            self.addAnnotations(from: self.allScooters)
        }
    }
    
    private func showLowBatteryWarning() {
        let ac = UIAlertController(title: "⚠️ Uyarı",
                                   message: "Bu scooter'ın bataryası düşük. Lütfen başka bir scooter seçin.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Anladım", style: .default))
        present(ac, animated: true)
    }
    
    // MARK: - Icon
    private func makeScooterIcon(for batteryStatus: Int) -> UIImage? {
        let color: UIColor = batteryStatus >= 70 ? .systemGreen : (batteryStatus >= 40 ? .systemOrange : .systemRed)
        let size = CGSize(width: 24, height: 24)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            let cg = ctx.cgContext
            let circle = CGRect(x: 2, y: 2, width: 20, height: 20)
            cg.setFillColor(color.cgColor)
            cg.fillEllipse(in: circle)
            cg.setStrokeColor(UIColor.white.cgColor)
            cg.setLineWidth(2)
            cg.strokeEllipse(in: circle)
            
            cg.setFillColor(UIColor.white.cgColor)
            cg.setStrokeColor(UIColor.white.cgColor)
            
            cg.fill(CGRect(x: 6, y: 12, width: 10, height: 2))
            cg.setLineWidth(1.5)
            cg.move(to: CGPoint(x: 7, y: 12))
            cg.addLine(to: CGPoint(x: 9, y: 7))
            cg.strokePath()
            cg.fill(CGRect(x: 6, y: 6, width: 5, height: 1.5))
            cg.fill(CGRect(x: 5, y: 5, width: 1.5, height: 3))
            cg.fill(CGRect(x: 10, y: 5, width: 1.5, height: 3))
            cg.fillEllipse(in: CGRect(x: 5, y: 15, width: 3.5, height: 3.5))
            cg.strokeEllipse(in: CGRect(x: 5, y: 15, width: 3.5, height: 3.5))
            cg.fillEllipse(in: CGRect(x: 14, y: 15, width: 3.5, height: 3.5))
            cg.strokeEllipse(in: CGRect(x: 14, y: 15, width: 3.5, height: 3.5))
        }
    }
}

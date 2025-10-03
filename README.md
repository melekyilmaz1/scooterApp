# 🚲 ScooterApp – Elektrikli Scooter Paylaşım Uygulaması

ScooterApp, şehir genelinde kullanıcıların elektrikli scooter’ları harita üzerinden görebildiği ve kullanabildiği fullstack bir uygulamadır. Proje, Swift ile geliştirilmiş iOS mobil uygulaması, NestJS (Node.js, TypeScript) tabanlı backend servisi, PostgreSQL veritabanı ve React frontend arayüzünden oluşmaktadır. Harita işlemleri için **Mapbox** entegrasyonu kullanılmıştır.  

Kullanıcılar sisteme kayıt olup giriş yaptıktan sonra Mapbox haritası üzerinde scooter’ları görebilir, seçilen scooter’ın detaylarını inceleyebilir ve “Start Ride” ile sürüş başlatabilirler. Sayaç çalıştıkça scooter’ın batarya seviyesi backend’e gönderilen isteklerle güncellenir, “Stop Ride” ile sürüş sonlandırıldığında batarya bilgisi tekrar kaydedilir. Kullanıcı rolündekiler yalnızca bataryası %20’nin üzerinde olan scooter’ları görürken, operator rolündekiler tüm scooter’lara erişebilir ve sisteme yeni scooter ekleyebilir.  

JWT tabanlı kimlik doğrulama sayesinde güvenli erişim sağlanır ve her API çağrısında token kullanımı zorunludur. PostgreSQL’de kullanıcı ve scooter bilgileri tutulur, NestJS backend bu verileri işleyerek Swift iOS uygulamasına ve React arayüzüne sunar. Böylece ScooterApp, rol bazlı yetkilendirme ve gerçek zamanlı harita entegrasyonu ile scooter paylaşımı için ölçeklenebilir bir çözüm sunar.  

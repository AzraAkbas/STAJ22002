# Hastane İlaç ve Stok Yönetim Sistemi

## Proje Genel Hatları ve Modüller

Sistem 3 temel kullanıcı rolü üzerinden çalışır:

* **Giriş ve Güvenlik:** Kullanıcılar sicil numarası ve şifreleriyle giriş yapar. Rol bazlı yetkilendirme (RBAC) ile yalnızca kendi ekranlarına erişirler.
* **Doktor Modülü:**
  * Görevli olduğu servisteki aktif yatan hastaları listeleme ve arama.
  * Hastanın klinik profilini, yatış bilgilerini ve alerji durumunu inceleme.
  * İlaç adı/etken maddeye göre anlık arama yaparak doz, öğün ve süre bilgileriyle reçete oluşturma.
  * Geçmiş reçeteleri görüntüleme ve PDF olarak çıktı alma.
* **Hemşire Modülü:**
  * Servisteki hastaları ve güncel tedavi planlarını dinamik kartlar üzerinden takip etme.
  * İlaçları "Uygulandı" olarak kaydetme veya "Uygulanmadı" gerekçesi girerek ilacı otomatik servis stoğuna iade etme.
  * Servis deposundaki ilaç stoklarını ve yaklaşan son kullanma tarihlerini (renk kodlarıyla) izleme.
  * Azalan ilaçlar için merkez eczaneden transfer talebinde bulunma.
* **Merkez Eczane Modülü:**
  * Doktorların yazdığı reçeteleri ve hemşirelerin servis stok taleplerini onaylayıp sevk etme.
  * İlaç sevkinde son kullanma tarihi en yakın olan partiye (FEFO) ve giriş sırasına (FIFO) göre otomatik stok düşümü yapma.
  * Hastane merkez deposu için dış ecza deposuna sipariş oluşturma ve gelen ürünleri parti/lot ve SKT bilgisiyle teslim alma.
  * Sisteme yeni ilaç kartı tanımlama ve mevcut ilaç bilgilerini güncelleme.

---

## Kullanılan Teknolojiler ve Araçlar

* **Programlama Dili:** Object Pascal (Delphi)
* **Geliştirme Ortamı (IDE):** Embarcadero Delphi
* **Veritabanı:** SQLite 3 (Ilac_Takip_DB.db)
* **Veri Tabanı Bileşenleri:** FireDAC (TFDConnection, TFDQuery)
* **Güvenlik ve Kriptografi:**
  * **SHA-256:** Kullanıcı giriş şifrelerinin tek yönlü özetlenmesi.
  * **AES-128 (CBC Modu):** Windows CNG API (bcrypt.dll) kullanılarak hasta T.C. kimlik, telefon, kronik hastalık ve alerji verilerinin veritabanında şifreli saklanması ve çözümlenmesi.
  * **Parametrik SQL:** SQL Injection açıklarını önleme.
* **Raporlama:** Windows Printing API / Microsoft Print to PDF
* **Veritabanı Yönetimi:** DB Browser for SQLite

---

## Form ve Ekran Yapısı

| Form / Unit | Ekran / Görev |
| :--- | :--- |
| **Unit1** | Kullanıcı Giriş Ekranı (Login) |
| **Unit2** | Doktor Paneli - Hasta Listesi ve Arama |
| **Unit3** | Hasta Detay ve Reçete Oluşturma |
| **Unit4** | Geçmiş Reçeteler ve PDF Raporlama |
| **Unit5** | Hemşire Paneli - Hasta Tedavi Planı |
| **Unit6** | Servis Stok Takibi ve Eczane Talep Ekranı |
| **Unit7** | Geçmiş Tedavi Uygulamaları Kayıtları |
| **Unit8** | Eczane Paneli - Reçete ve Servis Sevk Masası |
| **Unit9** | Eczane Geçmiş Sevk Hareketleri |
| **Unit10** | Merkez Eczane Stok ve SKT Takip Ekranı |
| **Unit11** | Ecza Deposu Sipariş ve Parti Teslim Alma |
| **Unit12** | Yeni İlaç Tanımlama ve Bilgi Düzenleme |

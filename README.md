# Hastane Ilac ve Stok Yonetim Sistemi

## Proje Genel Hatlari ve Moduller

Sistem 3 temel kullanici rolu uzerinden calisir:

* **Giris ve Guvenlik:** Kullanicilar sicil numarasi ve sifreleriyle giris yapar. Rol bazli yetkilendirme (RBAC) ile yalnizca kendi ekranlarina erisirler.
* **Doktor Modulu:**
  * Gorevli oldugu servisteki aktif yatan hastalari listeleme ve arama.
  * Hastanin klinik profilini, yatis bilgilerini ve alerji durumunu inceleme.
  * Ilac adi/etken maddeye gore anlik arama yaparak doz, ogun ve sure bilgileriyle recete olusturma.
  * Gecmis receteleri goruntuleme ve PDF olarak cikti alma.
* **Hemsire Modulu:**
  * Servisteki hastalari ve guncel tedavi planlarini dinamik kartlar uzerinden takip etme.
  * Ilaclari "Uygulandi" olarak kaydetme veya "Uygulanmadi" gerekcesi girerek ilaci otomatik servis stoguna iade etme.
  * Servis deposundaki ilac stoklarini ve yaklasan son kullanma tarihlerini (renk kodlariyla) izleme.
  * Azalan ilaclar icin merkez eczaneden transfer talebinde bulunma.
* **Merkez Eczane Modulu:**
  * Doktorlarin yazdigi receteleri ve hemsirelerin servis stok taleplerini onaylayip sevk etme.
  * Ilac sevkinde son kullanma tarihi en yakin olan partiye (FEFO) ve giris sirasina (FIFO) gore otomatik stok dusumu yapma.
  * Hastane merkez deposu icin dis ecza deposuna siparis olusturma ve gelen urunleri parti/lot ve SKT bilgisiyle teslim alma.
  * Sisteme yeni ilac karti tanimlama ve mevcut ilac bilgilerini guncelleme.

---

## Kullanilan Teknolojiler ve Araclar

* **Programlama Dili:** Object Pascal (Delphi)
* **Gelistirme Ortami (IDE):** Embarcadero Delphi
* **Veritabani:** SQLite 3 (Ilac_Takip_DB.db)
* **Veri Tabani Bilesenleri:** FireDAC (TFDConnection, TFDQuery)
* **Guvenlik ve Kriptografi:**
  * **SHA-256:** Kullanici giris sifrelerinin tek yonlu ozetlenmesi.
  * **AES-128 (CBC Modu):** Windows CNG API (bcrypt.dll) kullanilarak hasta T.C. kimlik, telefon, kronik hastalik ve alerji verilerinin veritabaninda sifreli saklanmasi ve cozumlenmesi.
  * **Parametrik SQL:** SQL Injection aciklarini onleme.
* **Raporlama:** Windows Printing API / Microsoft Print to PDF
* **Veritabani Yonetimi:** DB Browser for SQLite

---

## Form ve Ekran Yapisi

| Form / Unit | Ekran / Gorev |
| :--- | :--- |
| **Unit1** | Kullanici Giris Ekrani (Login) |
| **Unit2** | Doktor Paneli - Hasta Listesi ve Arama |
| **Unit3** | Hasta Detay ve Recete Olusturma |
| **Unit4** | Gecmis Receteler ve PDF Raporlama |
| **Unit5** | Hemsire Paneli - Hasta Tedavi Plani |
| **Unit6** | Servis Stok Takibi ve Eczane Talep Ekrani |
| **Unit7** | Gecmis Tedavi Uygulamalari Kayitlari |
| **Unit8** | Eczane Paneli - Recete ve Servis Sevk Masasi |
| **Unit9** | Eczane Gecmis Sevk Hareketleri |
| **Unit10** | Merkez Eczane Stok ve SKT Takip Ekrani |
| **Unit11** | Ecza Deposu Siparis ve Parti Teslim Alma |
| **Unit12** | Yeni Ilac Tanimlama ve Bilgi Duzenleme |

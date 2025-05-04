//
//  UrunDetay.swift
//  Bootcamp Bitirme
//
//  Created by Arda Toprak on 4.05.2025.
//

import UIKit
import NotificationCenter

class UrunDetay: UIViewController {
    
    @IBOutlet weak var imageViewUrun: UIImageView!
    @IBOutlet weak var labelUrunAd: UILabel!
    @IBOutlet weak var labelUrunFiyat: UILabel!
    @IBOutlet weak var labelUrunMarka: UILabel!
    @IBOutlet weak var labelUrunKategori: UILabel!
    @IBOutlet weak var buttonSepeteEkle: UIButton!
    @IBOutlet weak var buttonFavorilereEkle: UIButton!
    @IBOutlet weak var stepperAdet: UIStepper!
    @IBOutlet weak var labelAdet: UILabel!
    @IBOutlet weak var labelUrunDetay: UILabel!
    
    var urun: Urunler?
    let sepetViewModel = SepetViewModel()
    let favorilerViewModel = FavorilerViewModel()
    var secilenAdet = 1
    var favorideMi = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        if let urun = urun {
            gosterUrun(urun: urun)
            favorideMi = favorilerViewModel.favoriKontrol(urun: urun)
            favoriButtonGuncelle()
        }
    }
    
    func setupUI() {
        // Navigation bar title
        navigationItem.title = "Ürün Detayı"
        
        
        if let customFont = UIFont(name: "Pacifico-Regular", size: 24) {
            labelUrunDetay.font = customFont
        } else {
            // Fallback to system font if custom font fails to load
            labelUrunDetay.font = UIFont.systemFont(ofSize: 24)
            print("Failed to load custom font for labelSepettekiUrunler")
        }
        
        // UI Bileşenlerini özelleştirme
        imageViewUrun.layer.cornerRadius = 10
        imageViewUrun.clipsToBounds = true
        
        buttonSepeteEkle.layer.cornerRadius = 20 // Daha oval buton görünümü
        buttonSepeteEkle.clipsToBounds = true // Köşeleri düzgün kesmek için
        buttonSepeteEkle.backgroundColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0) // iOS Mavi
        // Sepete Ekle butonu metnini tek satırda tut
        buttonSepeteEkle.titleLabel?.numberOfLines = 1
        buttonSepeteEkle.titleLabel?.adjustsFontSizeToFitWidth = true
        
        buttonFavorilereEkle.layer.cornerRadius = 20 // Daha oval buton görünümü
        buttonFavorilereEkle.clipsToBounds = true // Köşeleri düzgün kesmek için
        buttonFavorilereEkle.layer.borderWidth = 1
        buttonFavorilereEkle.layer.borderColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0).cgColor
        buttonFavorilereEkle.setTitleColor(UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0), for: .normal)
        // Buton metninin tek satırda görüntülenmesini sağlama
        buttonFavorilereEkle.titleLabel?.numberOfLines = 1
        buttonFavorilereEkle.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonFavorilereEkle.titleLabel?.lineBreakMode = .byClipping
        
        // Buton genişliklerini stack view'da eşitle - her iki buton için de aynı genişliği ayarla
        if let superview = buttonFavorilereEkle.superview, superview is UIStackView {
            let stackView = superview as! UIStackView
            stackView.distribution = .fillEqually // Butonların eşit genişlikte olmasını sağla
            stackView.spacing = 10 // Butonlar arasında yeterli boşluk bırak
        }
        
        // Stepper ayarları
        stepperAdet.minimumValue = 1
        stepperAdet.maximumValue = 10
        stepperAdet.value = 1
        stepperAdet.stepValue = 1
        
        // Başlangıç adet değeri
        labelAdet.text = "Adet: 1"
    }
    
    func favoriButtonGuncelle() {
        if favorideMi {
            buttonFavorilereEkle.setTitle("Favorilerden Çıkar", for: .normal)
            buttonFavorilereEkle.backgroundColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 0.1)
        } else {
            buttonFavorilereEkle.setTitle("Favorilere Ekle", for: .normal)
            buttonFavorilereEkle.backgroundColor = .white
        }
    }
    
    func gosterUrun(urun: Urunler) {
        labelUrunAd.text = urun.ad
        labelUrunFiyat.text = "\(urun.fiyat ?? 0) ₺"
        labelUrunMarka.text = "\(urun.marka ?? "")"
        labelUrunKategori.text = "\(urun.kategori ?? "")"
        labelUrunDetay.text = "\(urun.ad!) Detayları"
        
        // Resim yükleme
        if let resimAdi = urun.resim, let resimURL = URL(string: "http://kasimadalan.pe.hu/urunler/resimler/\(resimAdi)") {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: resimURL) {
                    DispatchQueue.main.async {
                        self.imageViewUrun.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    @IBAction func stepperAdetChanged(_ sender: UIStepper) {
        secilenAdet = Int(sender.value)
        labelAdet.text = "Adet: \(secilenAdet)"
    }
    
    @IBAction func sepeteEkleButtonTapped(_ sender: UIButton) {
        if let urun = urun {
            // Sepete ekleme işlemi
            sepetViewModel.sepeteEkle(urun: urun, adet: secilenAdet)
            
            // Başarılı mesajı göster
            let alert = UIAlertController(title: "Sepete Eklendi", message: "\(urun.ad ?? "") sepete başarıyla eklendi.", preferredStyle: .alert)
            
            let alisveriseDevamAction = UIAlertAction(title: "Tamam", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true)
            }
            alert.addAction(alisveriseDevamAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func favorilereEkleButtonTapped(_ sender: UIButton) {
        if let urun = urun {
            var mesaj = ""
            
            if favorideMi {
                // Favorilerden çıkar
                let basarili = favorilerViewModel.favoridenCikar(urun: urun)
                mesaj = basarili ? "\(urun.ad ?? "") favorilerden çıkarıldı." : "Favorilerden çıkarma işlemi başarısız oldu."
                favorideMi = false
                
                // Favoriler sayfasının yenilenmesi için bildirim gönder
                NotificationCenter.default.post(name: NSNotification.Name("FavorilerGuncellendi"), object: nil)
            } else {
                // Favorilere ekle
                let basarili = favorilerViewModel.favoriyeEkle(urun: urun)
                mesaj = basarili ? "\(urun.ad ?? "") favorilere eklendi." : "Favorilere ekleme işlemi başarısız oldu."
                favorideMi = true
            }
            
            // Favori butonunun görünümünü güncelle
            favoriButtonGuncelle()
            
            // Başarılı mesajı göster
            let alert = UIAlertController(title: favorideMi ? "Favorilere Eklendi" : "Favorilerden Çıkarıldı", message: mesaj, preferredStyle: .alert)
            
            let tamamAction = UIAlertAction(title: "Tamam", style: .default) { _ in
                // Alert'i kapat
            }
            alert.addAction(tamamAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
}

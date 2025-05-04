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
        navigationItem.title = "Ürün Detayı"
        
        
        if let customFont = UIFont(name: "Pacifico-Regular", size: 24) {
            labelUrunDetay.font = customFont
        } else {
            labelUrunDetay.font = UIFont.systemFont(ofSize: 24)
            print("Failed to load custom font for labelSepettekiUrunler")
        }
        
        imageViewUrun.layer.cornerRadius = 10
        imageViewUrun.clipsToBounds = true
        
        buttonSepeteEkle.layer.cornerRadius = 20
        buttonSepeteEkle.clipsToBounds = true
        
        buttonFavorilereEkle.layer.cornerRadius = 20
        buttonFavorilereEkle.clipsToBounds = true
        
        buttonFavorilereEkle.titleLabel?.numberOfLines = 1
        buttonFavorilereEkle.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonFavorilereEkle.titleLabel?.lineBreakMode = .byClipping
        

        if let superview = buttonFavorilereEkle.superview, superview is UIStackView {
            let stackView = superview as! UIStackView
            stackView.distribution = .fillEqually
            stackView.spacing = 10
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
            sepetViewModel.sepeteEkle(urun: urun, adet: secilenAdet)
            
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
                let basarili = favorilerViewModel.favoridenCikar(urun: urun)
                mesaj = basarili ? "\(urun.ad ?? "") favorilerden çıkarıldı." : "Favorilerden çıkarma işlemi başarısız oldu."
                favorideMi = false
                
                NotificationCenter.default.post(name: NSNotification.Name("FavorilerGuncellendi"), object: nil)
            } else {

                let basarili = favorilerViewModel.favoriyeEkle(urun: urun)
                mesaj = basarili ? "\(urun.ad ?? "") favorilere eklendi." : "Favorilere ekleme işlemi başarısız oldu."
                favorideMi = true
            }
            

            favoriButtonGuncelle()
            
 
            let alert = UIAlertController(title: favorideMi ? "Favorilere Eklendi" : "Favorilerden Çıkarıldı", message: mesaj, preferredStyle: .alert)
            
            let tamamAction = UIAlertAction(title: "Tamam", style: .default) { _ in

            }
            alert.addAction(tamamAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
}

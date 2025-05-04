//
//  Sepet.swift
//  Bootcamp Bitirme
//
//  Created by Arda Toprak on 4.05.2025.
//

import UIKit
import RxSwift

class Sepet: UIViewController {
    
    @IBOutlet weak var tableViewSepet: UITableView!
    @IBOutlet weak var labelToplamTutar: UILabel!
    @IBOutlet weak var buttonTumunuSatinAl: UIButton!
    
    @IBOutlet weak var labelSepettekiUrunler: UILabel!
    var sepetUrunListesi = [SepetUrun]()
    var sepetViewModel = SepetViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sepetViewModel.sepetListesiniYukle()
    }
    
    func setupUI() {
        // Navigation Bar
        navigationItem.title = "Sepetim"
        
        // Custom Font for labelSepettekiUrunler
        if let customFont = UIFont(name: "Pacifico-Regular", size: 24) {
            labelSepettekiUrunler.font = customFont
        } else {
            // Fallback to system font if custom font fails to load
            labelSepettekiUrunler.font = UIFont.systemFont(ofSize: 24)
            print("Failed to load custom font for labelSepettekiUrunler")
        }
        
       
        
        // TableView
        tableViewSepet.delegate = self
        tableViewSepet.dataSource = self
        
        // Satın Al Butonu
        buttonTumunuSatinAl.layer.cornerRadius = 20 // Daha oval buton görünümü
        buttonTumunuSatinAl.clipsToBounds = true // Köşeleri düzgün kesmek için
        buttonTumunuSatinAl.backgroundColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0) // iOS mavi
        
        // Boş sepet mesajı için backgroundView oluşturma
        let emptyView = UIView()
        
        let imageView = UIImageView(image: UIImage(systemName: "cart"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let messageLabel = UILabel()
        messageLabel.text = "Sepetinizde ürün bulunmamaktadır"
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = UIColor.gray
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let actionButton = UIButton(type: .system)
        actionButton.setTitle("ALIŞVERİŞE BAŞLA", for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        actionButton.tintColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0) // iOS mavi
        actionButton.layer.borderWidth = 1
        actionButton.layer.borderColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0).cgColor
        actionButton.layer.cornerRadius = 20 // Daha oval buton görünümü
        actionButton.clipsToBounds = true // Köşeleri düzgün kesmek için
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(alisveriseBaslaButtonTapped), for: .touchUpInside)
        
        emptyView.addSubview(imageView)
        emptyView.addSubview(messageLabel)
        emptyView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            // İkon kısıtlamaları
            imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -50),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Mesaj etiketi kısıtlamaları
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -16),
            
            // Buton kısıtlamaları
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            actionButton.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 200),
            actionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        tableViewSepet.backgroundView = emptyView
    }
    
    @objc func alisveriseBaslaButtonTapped() {
        tabBarController?.selectedIndex = 0 // Ana sayfaya geç
    }
    
    func setupBindings() {
        sepetViewModel.sepetListesi
            .subscribe(onNext: { liste in
                self.sepetUrunListesi = liste
                
                // Toplam tutarı güncelle
                let toplamTutar = self.sepetViewModel.sepetToplamTutarHesapla()
                self.labelToplamTutar.text = "Toplam Tutar: \(toplamTutar) ₺"
                
                // Boş sepet durumunu göster/gizle
                self.tableViewSepet.backgroundView?.isHidden = !liste.isEmpty
                self.labelToplamTutar.isHidden = liste.isEmpty
                self.buttonTumunuSatinAl.isHidden = liste.isEmpty // Buton tamamen gizleniyor
                
                DispatchQueue.main.async {
                    self.tableViewSepet.reloadData()
                }
            }).disposed(by: disposeBag)
    }
    
    @IBAction func tumunuSatinAlButtonTapped(_ sender: UIButton) {
        // Satın alma işlemi
        let alert = UIAlertController(title: "Satın Alma", message: "Satın alma işlemi başarıyla tamamlandı.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default) { _ in
            // Sepetteki tüm ürünleri silme işlemi
            let dispatchGroup = DispatchGroup()
            
            for urun in self.sepetUrunListesi {
                if let sepetid = urun.sepetid {
                    dispatchGroup.enter()
                    self.sepetViewModel.sepetUrunSil(sepetid: sepetid) { basarili, mesaj in
                        if !basarili {
                            print("Ürün silinirken hata: \(mesaj)")
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // Tüm silme işlemleri tamamlandıktan sonra sepeti yenile
                self.sepetViewModel.sepetListesiniYukle()
            }
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

extension Sepet: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sepetUrunListesi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let urun = sepetUrunListesi[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sepetHucre") as! SepetHucre
        cell.configure(with: urun)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // Sağdan kaydırmalı silme işlemi
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let urun = sepetUrunListesi[indexPath.row]
        print("Silme işlemi için hazırlanıyor: \(urun.ad ?? "")") // Debug log
        
        let silAction = UIContextualAction(style: .destructive, title: "Sil") { (action, view, completion) in
            print("Sil butonu tıklandı") // Debug log
            
            // Silme işlemi için onay iste
            if let sepetid = urun.sepetid {
                print("Ürün sepetID: \(sepetid)") // Debug log
                
                let alert = UIAlertController(title: "Ürünü Sil", message: "\(urun.ad ?? "") sepetten silinecek. Emin misiniz?", preferredStyle: .alert)
                
                let iptalAction = UIAlertAction(title: "İptal", style: .cancel) { _ in
                    print("Silme işlemi iptal edildi") // Debug log
                    completion(false) // Swipe işlemini iptal et
                }
                alert.addAction(iptalAction)
                
                let silAction = UIAlertAction(title: "Sil", style: .destructive) { _ in
                    print("Silme işlemi onaylandı, API çağrısı yapılıyor...") // Debug log
                    
                    // Ürünü sepetten sil
                    self.sepetViewModel.sepetUrunSil(sepetid: sepetid) { basarili, mesaj in
                        print("API yanıtı: başarı=\(basarili), mesaj=\(mesaj)") // Debug log
                        
                        DispatchQueue.main.async {
                            if basarili {
                                // Başarılı silme işlemi sonrası bildirim
                                print("Silme başarılı, alert gösteriliyor") // Debug log
                                let basariAlert = UIAlertController(title: "Başarılı", message: "\(urun.ad ?? "") sepetten başarıyla silindi.", preferredStyle: .alert)
                                let tamamAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                                basariAlert.addAction(tamamAction)
                                self.present(basariAlert, animated: true)
                            } else {
                                // Hata durumunda bildirim
                                print("Silme başarısız, hata alert'i gösteriliyor") // Debug log
                                let hataAlert = UIAlertController(title: "Hata", message: "Silme işlemi sırasında bir hata oluştu: \(mesaj)", preferredStyle: .alert)
                                let tamamAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                                hataAlert.addAction(tamamAction)
                                self.present(hataAlert, animated: true)
                            }
                        }
                    }
                    completion(true) // Swipe işlemini tamamla
                }
                alert.addAction(silAction)
                
                self.present(alert, animated: true)
            } else {
                print("HATA: sepetid nil!") // Debug log
                completion(false)
            }
        }
        
        // Silme butonunun görünümünü özelleştirme
        silAction.backgroundColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0) // Kırmızı
        silAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [silAction])
    }
}

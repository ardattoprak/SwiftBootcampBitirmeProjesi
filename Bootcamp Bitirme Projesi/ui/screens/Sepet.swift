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
        
        if let customFont = UIFont(name: "Pacifico-Regular", size: 24) {
            labelSepettekiUrunler.font = customFont
        } else {
            labelSepettekiUrunler.font = UIFont.systemFont(ofSize: 24)
            print("Failed to load custom font for labelSepettekiUrunler")
        }
        
       
        
        tableViewSepet.delegate = self
        tableViewSepet.dataSource = self
        

        buttonTumunuSatinAl.layer.cornerRadius = 20
        buttonTumunuSatinAl.clipsToBounds = true
 
        
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
        actionButton.tintColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0)
        actionButton.layer.borderWidth = 1
        actionButton.layer.borderColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0).cgColor
        actionButton.layer.cornerRadius = 20
        actionButton.clipsToBounds = true
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(alisveriseBaslaButtonTapped), for: .touchUpInside)
        
        emptyView.addSubview(imageView)
        emptyView.addSubview(messageLabel)
        emptyView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([

            imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -50),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            

            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -16),
            

            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            actionButton.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 200),
            actionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        tableViewSepet.backgroundView = emptyView
    }
    
    @objc func alisveriseBaslaButtonTapped() {
        tabBarController?.selectedIndex = 0
    }
    
    func setupBindings() {
        sepetViewModel.sepetListesi
            .subscribe(onNext: { liste in
                self.sepetUrunListesi = liste
                

                let toplamTutar = self.sepetViewModel.sepetToplamTutarHesapla()
                self.labelToplamTutar.text = "Toplam Tutar: \(toplamTutar) ₺"
                

                self.tableViewSepet.backgroundView?.isHidden = !liste.isEmpty
                self.labelToplamTutar.isHidden = liste.isEmpty
                self.buttonTumunuSatinAl.isHidden = liste.isEmpty
                
                DispatchQueue.main.async {
                    self.tableViewSepet.reloadData()
                }
            }).disposed(by: disposeBag)
    }
    
    @IBAction func tumunuSatinAlButtonTapped(_ sender: UIButton) {
        // ilk alert emin misiniz alertı
        let confirmAlert = UIAlertController(title: "Satın Alma", message: "Tüm ürünleri satın almak istediğinize emin misiniz?", preferredStyle: .alert)
        
        let iptalAction = UIAlertAction(title: "İptal", style: .cancel)
        confirmAlert.addAction(iptalAction)
        
        let satinAlAction = UIAlertAction(title: "Satın Al", style: .default) { _ in
            // Satın alma işlemini başlat
            let loadingAlert = UIAlertController(title: nil, message: "İşlem yapılıyor...", preferredStyle: .alert)
            
            self.present(loadingAlert, animated: true)
            
            let dispatchGroup = DispatchGroup()
            var basariliSilmeSayisi = 0
            var hataliUrunler = [String]()
            
            for (index, urun) in self.sepetUrunListesi.enumerated() {
                if let sepetId = urun.sepetId {
                    dispatchGroup.enter()
                    self.sepetViewModel.sepetUrunSil(sepetid: sepetId) { basarili, mesaj in
                        if basarili {
                            basariliSilmeSayisi += 1
                        } else {
                            hataliUrunler.append(urun.ad ?? "Bilinmeyen ürün")
                            print("HATA: Ürün silme hatası - Ürün: \(urun.ad ?? "Bilinmeyen ürün"), SepetId: \(sepetId), Hata Mesajı: \(mesaj)")
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                loadingAlert.dismiss(animated: true) {
                    if basariliSilmeSayisi == self.sepetUrunListesi.count {

                        let successAlert = UIAlertController(title: "Başarılı", message: "Satın alma işlemi başarıyla tamamlandı.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Tamam", style: .default)
                        successAlert.addAction(okAction)
                        self.present(successAlert, animated: true)
                    } else if basariliSilmeSayisi > 0 && !hataliUrunler.isEmpty {
                        print("KISMEN BAŞARILI: \(basariliSilmeSayisi) ürün başarıyla silindi, \(hataliUrunler.count) ürün silinemedi")
                        print("HATA DETAYLARI: Silinemeyenler: \(hataliUrunler.joined(separator: ", "))")
                        
                        let partialSuccessAlert = UIAlertController(title: "Kısmen Başarılı", 
                                                                  message: "\(basariliSilmeSayisi) ürün satın alındı, ancak \(hataliUrunler.count) ürün işlemi sırasında hata oluştu.", 
                                                                  preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Tamam", style: .default)
                        partialSuccessAlert.addAction(okAction)
                        self.present(partialSuccessAlert, animated: true)
                    } else if basariliSilmeSayisi > 0 {
                        let successAlert = UIAlertController(title: "Başarılı", message: "Satın alma işlemi başarıyla tamamlandı.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Tamam", style: .default)
                        successAlert.addAction(okAction)
                        self.present(successAlert, animated: true)
                    } else {
                        
                        let failureAlert = UIAlertController(title: "Hata",
                                                           message: "Satın alma işlemi sırasında hata oluştu. Lütfen daha sonra tekrar deneyin.", 
                                                           preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Tamam", style: .default)
                        failureAlert.addAction(okAction)
                        self.present(failureAlert, animated: true)
                    }
                    
                    self.sepetViewModel.sepetListesiniYukle()
                }
            }
        }
        confirmAlert.addAction(satinAlAction)
        
        present(confirmAlert, animated: true)
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
    

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let urun = sepetUrunListesi[indexPath.row]
        print("Silme işlemi için hazırlanıyor: \(urun.ad ?? "")")
        
        let silAction = UIContextualAction(style: .destructive, title: "Sil") { (action, view, completion) in
            print("Sil butonu tıklandı")
            

            if let sepetId = urun.sepetId {
                print("Ürün sepetID: \(sepetId)")
                
                let alert = UIAlertController(title: "Ürünü Sil", message: "\(urun.ad ?? "") sepetten silinecek. Emin misiniz?", preferredStyle: .alert)
                
                let iptalAction = UIAlertAction(title: "İptal", style: .cancel) { _ in
                    print("Silme işlemi iptal edildi")
                    completion(false)
                }
                alert.addAction(iptalAction)
                
                let silAction = UIAlertAction(title: "Sil", style: .destructive) { _ in
                    print("Silme işlemi onaylandı, API çağrısı yapılıyor...")
                    

                    self.sepetViewModel.sepetUrunSil(sepetid: sepetId) { basarili, mesaj in
                        print("API yanıtı: başarı=\(basarili), mesaj=\(mesaj)")
                        
                        DispatchQueue.main.async {
                            if basarili {
                        
                                print("Silme başarılı, alert gösteriliyor") 
                                let basariAlert = UIAlertController(title: "Başarılı", message: "\(urun.ad ?? "") sepetten başarıyla silindi.", preferredStyle: .alert)
                                let tamamAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                                basariAlert.addAction(tamamAction)
                                self.present(basariAlert, animated: true)
                            } else {
                
                                print("Silme başarısız, hata alert'i gösteriliyor")
                                let hataAlert = UIAlertController(title: "Hata", message: "Silme işlemi sırasında bir hata oluştu: \(mesaj)", preferredStyle: .alert)
                                let tamamAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                                hataAlert.addAction(tamamAction)
                                self.present(hataAlert, animated: true)
                            }
                        }
                    }
                    completion(true)
                }
                alert.addAction(silAction)
                
                self.present(alert, animated: true)
            } else {
                print("HATA: sepetId nil!")
                completion(false)
            }
        }
        
        silAction.backgroundColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        silAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [silAction])
    }
}

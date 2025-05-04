//
//  Favoriler.swift
//  Bootcamp Bitirme
//
//  Created by Arda Toprak on 4.05.2025.
//

import UIKit
import RxSwift

class Favoriler: UIViewController {
    
    @IBOutlet weak var collectionViewFavoriler: UICollectionView!
    
    @IBOutlet weak var labelFavoriler: UILabel!
    var favorilerListesi = [Urunler]()
    var favorilerViewModel = FavorilerViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
        
        // Favorilerin değişimini dinleyen observer
        NotificationCenter.default.addObserver(self,
                                              selector: #selector(favorilerGuncellendi), 
                                              name: NSNotification.Name("FavorilerGuncellendi"), 
                                              object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func favorilerGuncellendi() {
        print("Favoriler güncellendi bildirimi alındı")
        favorilerViewModel.favorileriYukle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favorilerViewModel.favorileriYukle()
    }
    
    func setupUI() {
        // Navigation bar
        navigationItem.title = "Favorilerim"
        
        if let customFont = UIFont(name: "Pacifico-Regular", size: 24) {
            labelFavoriler.font = customFont
        } else {
            print("Failed to load Pacifico-Regular font")
            labelFavoriler.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        }
        
        // Collection View
        collectionViewFavoriler.delegate = self
        collectionViewFavoriler.dataSource = self

        let tasarim = UICollectionViewFlowLayout()
        let genislik = UIScreen.main.bounds.width
        let hucreGenislik = (genislik - 40) / 2
        tasarim.itemSize = CGSize(width: hucreGenislik, height: hucreGenislik + 70)
        tasarim.minimumLineSpacing = 10
        tasarim.minimumInteritemSpacing = 10
        tasarim.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionViewFavoriler.collectionViewLayout = tasarim
        
        // Favoriler boşken gözükecek view
        setupEmptyView()
    }
    
    func setupEmptyView() {
        let emptyView = UIView()
        
        let imageView = UIImageView(image: UIImage(systemName: "heart"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let messageLabel = UILabel()
        messageLabel.text = "Favorilerinizde henüz ürün bulunmamaktadır."
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
        
        collectionViewFavoriler.backgroundView = emptyView
    }
    
    @objc func alisveriseBaslaButtonTapped() {
        tabBarController?.selectedIndex = 0
    }
    
    func setupBindings() {
        favorilerViewModel.favorilerListesi
            .subscribe(onNext: { liste in
                self.favorilerListesi = liste
                
                // Boş favoriler mesajını göster/gizle
                self.collectionViewFavoriler.backgroundView?.isHidden = !liste.isEmpty
                
                DispatchQueue.main.async {
                    self.collectionViewFavoriler.reloadData()
                }
            }).disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUrunDetay" {
            if let urun = sender as? Urunler {
                let gidilecekVC = segue.destination as! UrunDetay
                gidilecekVC.urun = urun
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension Favoriler: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorilerListesi.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let urun = favorilerListesi[indexPath.row]
        

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "urunHucre", for: indexPath) as? UrunlerHucre else {
            print("HATA: UrunlerHucre olarak dönüştürülemedi veya nil!")
            return UICollectionViewCell()
        }
        

        cell.configure(with: urun)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let urun = favorilerListesi[indexPath.row]
        print("Favori seçilen ürün: \(urun.ad ?? "")")
        

        performSegue(withIdentifier: "toUrunDetay", sender: urun)
    }
}

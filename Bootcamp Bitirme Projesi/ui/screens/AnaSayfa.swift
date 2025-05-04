//
//  ViewController.swift
//  Bootcamp Bitirme
//
//  Created by Arda Toprak on 3.05.2025.
//

import UIKit
import RxSwift

class AnaSayfa: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControlKategoriler: UISegmentedControl!
    @IBOutlet weak var collectionViewUrunler: UICollectionView!
    
    @IBOutlet weak var labelUrunler: UILabel!
    var urunlerListesi = [Urunler]()
    var anasayfaViewModel = AnaSayfaViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        anasayfaViewModel.urunleriYukle()
    }
    
    func setupUI() {
        // Navigation Bar Ayarları
        navigationItem.title = "Ürünler"
        
        // font
        if let customFont = UIFont(name: "Pacifico-Regular", size: 24) {
            labelUrunler.font = customFont
        } else {
            labelUrunler.font = UIFont.systemFont(ofSize: 24)
            print("Failed to load custom font for labelSepettekiUrunler")
        }
        
        // Collection View
        collectionViewUrunler.delegate = self
        collectionViewUrunler.dataSource = self
        
        let tasarim = UICollectionViewFlowLayout()
        let genislik = UIScreen.main.bounds.width
        let hucreGenislik = (genislik - 40) / 2
        tasarim.itemSize = CGSize(width: hucreGenislik, height: hucreGenislik + 70)
        tasarim.minimumLineSpacing = 10
        tasarim.minimumInteritemSpacing = 10
        tasarim.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionViewUrunler.collectionViewLayout = tasarim
        
        // Görünüm
        collectionViewUrunler.showsVerticalScrollIndicator = true
        collectionViewUrunler.showsHorizontalScrollIndicator = false
        collectionViewUrunler.alwaysBounceVertical = true
        
        // SearchBar
        searchBar.delegate = self
        searchBar.placeholder = "Ürün, kategori veya marka ara..."
        searchBar.showsCancelButton = true // Cancel düğmesini göster
        searchBar.tintColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0)
        searchBar.barTintColor = .white
        
        // Segment Control
        segmentedControlKategoriler.removeAllSegments()
        segmentedControlKategoriler.insertSegment(withTitle: "Tümü", at: 0, animated: false)
        segmentedControlKategoriler.insertSegment(withTitle: "Teknoloji", at: 1, animated: false)
        segmentedControlKategoriler.insertSegment(withTitle: "Aksesuar", at: 2, animated: false)
        segmentedControlKategoriler.selectedSegmentIndex = 0
        segmentedControlKategoriler.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        // Segment Control Stil
        if #available(iOS 13.0, *) {
            segmentedControlKategoriler.selectedSegmentTintColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0)
            let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            segmentedControlKategoriler.setTitleTextAttributes(titleTextAttributes, for: .selected)
        }
    }
    
    func setupBindings() {
        anasayfaViewModel.urunlerListesi
            .subscribe(onNext: { liste in
                self.urunlerListesi = liste
                DispatchQueue.main.async {
                    self.collectionViewUrunler.reloadData()
                }
            }).disposed(by: disposeBag)
    }
    
    @objc func segmentChanged() {
        switch segmentedControlKategoriler.selectedSegmentIndex {
        case 0:
            anasayfaViewModel.urunleriYukle()
        case 1:
            anasayfaViewModel.kategoriyeGoreFiltrele(kategori: "Teknoloji")
        case 2:
            anasayfaViewModel.kategoriyeGoreFiltrele(kategori: "Aksesuar")
        default:
            break
        }
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
extension AnaSayfa: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urunlerListesi.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let urun = urunlerListesi[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "urunHucre", for: indexPath) as! UrunlerHucre
        cell.configure(with: urun)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let urun = urunlerListesi[indexPath.row]
        print("Seçilen ürün: \(urun.ad ?? "")")
        
        performSegue(withIdentifier: "toUrunDetay", sender: urun)
    }
}

// MARK: - UISearchBarDelegate
extension AnaSayfa: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            anasayfaViewModel.urunleriYukle()
        } else {
            anasayfaViewModel.ara(aramaKelimesi: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        anasayfaViewModel.urunleriYukle()
    }
}


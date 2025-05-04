//
//  SepetHucre.swift
//  Bootcamp Bitirme
//
//  Created by Arda Toprak on 5.05.2025.
//

import UIKit

class SepetHucre: UITableViewCell {
    
    @IBOutlet weak var imageViewUrun: UIImageView!
    @IBOutlet weak var labelUrunAd: UILabel!
    @IBOutlet weak var labelUrunFiyat: UILabel!
    
    @IBOutlet weak var labelAdet: UILabel!
    var sepetUrun: SepetUrun?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        imageViewUrun.layer.cornerRadius = 8
        imageViewUrun.clipsToBounds = true
        
        selectionStyle = .none
    }
    
    func configure(with urun: SepetUrun) {
        self.sepetUrun = urun
        
        labelUrunAd.text = urun.ad
        
        if let fiyat = urun.fiyat {
            labelUrunFiyat.text = "\(fiyat) ₺"
        }
        

        if let adet = urun.siparisAdeti {
            labelAdet.text = "Adet: \(adet)"
        } else {
            labelAdet.text = "Adet: 1"
        }
        
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
} 

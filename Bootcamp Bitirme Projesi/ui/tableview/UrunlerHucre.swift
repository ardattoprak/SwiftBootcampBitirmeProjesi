//
//  UrunlerHucre.swift
//  Bootcamp Bitirme
//
//  Created by Arda Toprak on 3.05.2025.
//

import UIKit

class UrunlerHucre: UICollectionViewCell {
    
    @IBOutlet weak var imageViewUrun: UIImageView!
    @IBOutlet weak var labelUrunAd: UILabel!
    @IBOutlet weak var labelUrunFiyat: UILabel!
    @IBOutlet weak var labelUrunMarka: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardView()
    }
    
    private func setupCardView() {
        // Köşeleri yuvarlatma
        self.layer.cornerRadius = 15
        self.clipsToBounds = false
        

      
        

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 6
        self.layer.shadowOpacity = 0.15
        self.layer.masksToBounds = false
        

        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
        
        self.backgroundColor = .clear
        contentView.backgroundColor = .white
        

        imageViewUrun?.contentMode = .scaleAspectFill
        imageViewUrun?.clipsToBounds = true
        imageViewUrun?.layer.cornerRadius = 8
        

        labelUrunAd?.font = UIFont.boldSystemFont(ofSize: 16)
        labelUrunFiyat?.font = UIFont.boldSystemFont(ofSize: 16)
        labelUrunFiyat?.textColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0)
        labelUrunMarka?.font = UIFont.systemFont(ofSize: 14)
        labelUrunMarka?.textColor = UIColor.gray
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
   
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 15).cgPath
        layer.shadowPath = shadowPath
        

        layer.zPosition = -1
        

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateTouch(isHighlighted: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateTouch(isHighlighted: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateTouch(isHighlighted: false)
    }
    
    private func animateTouch(isHighlighted: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.contentView.alpha = isHighlighted ? 0.7 : 1.0
            self.transform = isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
    
    func configure(with urun: Urunler) {
        if let ad = urun.ad, let fiyat = urun.fiyat, let marka = urun.marka {
            labelUrunAd?.text = ad
            labelUrunFiyat?.text = "\(fiyat) ₺"
            labelUrunMarka?.text = marka
            

            if let resimAdi = urun.resim, let resimURL = URL(string: "http://kasimadalan.pe.hu/urunler/resimler/\(resimAdi)") {

                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: resimURL) {
                        DispatchQueue.main.async {
                            guard let self = self else { return }
                            if let image = UIImage(data: data) {
                                self.imageViewUrun?.image = image
                            }
                        }
                    }
                }
            }
        }
    }
} 

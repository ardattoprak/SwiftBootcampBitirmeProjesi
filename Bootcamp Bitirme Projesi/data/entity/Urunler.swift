//
//  Urunler.swift
//  Bootcamp Bitirme
//
//  Created by Arda Toprak on 3.05.2025.
//

class Urunler: Codable {
    var id: Int?
    var ad: String?
    var resim: String?
    var kategori: String?
    var fiyat: Int?
    var marka: String?
    
    init() {
        
    }
    
    init(id: Int, ad: String, resim: String, kategori: String, fiyat: Int, marka: String) {
        self.id = id
        self.ad = ad
        self.resim = resim
        self.kategori = kategori
        self.fiyat = fiyat
        self.marka = marka
    }
} 
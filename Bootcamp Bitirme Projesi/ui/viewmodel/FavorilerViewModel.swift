//
//  FavorilerViewModel.swift
//  Bootcamp Bitirme
//
//  Created by Arda Toprak on 6.05.2025.
//

import Foundation
import RxSwift

class FavorilerViewModel {
    var favorilerRepository = FavorilerRepository()
    var favorilerListesi = BehaviorSubject<[Urunler]>(value: [Urunler]())
    
    init() {
        favorilerListesi = favorilerRepository.favorilerListesi
    }
    
    func favoriyeEkle(urun: Urunler) -> Bool {
        return favorilerRepository.favoriyeEkle(urun: urun)
    }
    
    func favoridenCikar(urun: Urunler) -> Bool {
        return favorilerRepository.favoridenCikar(urun: urun)
    }
    
    func favorileriYukle() {
        favorilerRepository.favorileriYukle()
    }
    
    func favoriKontrol(urun: Urunler) -> Bool {
        return favorilerRepository.favoriKontrol(urun: urun)
    }
} 

//
//  AnaSayfaViewModel.swift
//  Bootcamp Bitirme
//
//  Created by Arda Toprak on 3.05.2025.
//

import Foundation
import RxSwift

class AnaSayfaViewModel {
    var urunlerRepository = UrunlerRepository()
    var urunlerListesi = BehaviorSubject<[Urunler]>(value: [Urunler]())
    
    init() {
        urunlerListesi = urunlerRepository.urunlerListesi 
    }
    
    func ara(aramaKelimesi: String) {
        urunlerRepository.ara(aramaKelimesi: aramaKelimesi)
    }
    
    func urunleriYukle() {
        urunlerRepository.urunleriYukle()
    }
    
    func kategoriyeGoreFiltrele(kategori: String) {
        urunlerRepository.kategoriyeGoreFiltrele(kategori: kategori)
    }
} 

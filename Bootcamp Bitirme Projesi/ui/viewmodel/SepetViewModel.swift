//
//  SepetViewModel.swift
//  Bootcamp Bitirme
//
//  Created by Arda Toprak on 5.05.2025.
//

import Foundation
import RxSwift

class SepetViewModel {
    var sepetRepository = SepetRepository()
    var sepetListesi = BehaviorSubject<[SepetUrun]>(value: [SepetUrun]())
    
    init() {
        sepetListesi = sepetRepository.sepetListesi
    }
    
    func sepeteEkle(urun: Urunler, adet: Int) {
        sepetRepository.sepeteEkle(urun: urun, adet: adet)
    }
    
    func sepetUrunSil(sepetid: Int, completion: @escaping (Bool, String) -> Void) {
        sepetRepository.sepetUrunSil(sepetid: sepetid, completion: completion)
    }
    
    func sepetListesiniYukle() {
        sepetRepository.sepetListesiniYukle()
    }
    
    func sepetToplamTutarHesapla() -> Int {
        do {
            let liste = try sepetListesi.value()
            var toplam = 0
            
            for urun in liste {
                if let fiyat = urun.fiyat, let adet = urun.siparisAdeti {
                    toplam += fiyat * adet
                }
            }
            
            return toplam
        } catch {
            return 0
        }
    }
} 

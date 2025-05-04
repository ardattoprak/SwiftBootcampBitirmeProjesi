//
//  FavorilerRepository.swift
//  Bootcamp Bitirme
//
//  Created by Arda Toprak on 6.05.2025.
//

import Foundation
import RxSwift

class FavorilerRepository {
    private let favoriUrunlerKey = "favoriUrunler"
    var favorilerListesi = BehaviorSubject<[Urunler]>(value: [Urunler]())
    
    init() {
        favorileriYukle()
    }
    
    func favoriyeEkle(urun: Urunler) -> Bool {
        var mevcutFavoriler = getCurrentFavorites()
        
        // ürün favda mı kontrol
        if !mevcutFavoriler.contains(where: { $0.id == urun.id }) {
            mevcutFavoriler.append(urun)
            saveFavorites(mevcutFavoriler)
            favorilerListesi.onNext(mevcutFavoriler)
            return true
        }
        
        return false
    }
    
    func favoridenCikar(urun: Urunler) -> Bool {
        var mevcutFavoriler = getCurrentFavorites()
        
        // id bul ve kaldır
        if let index = mevcutFavoriler.firstIndex(where: { $0.id == urun.id }) {
            mevcutFavoriler.remove(at: index)
            saveFavorites(mevcutFavoriler)
            favorilerListesi.onNext(mevcutFavoriler)
            return true
        }
        
        return false
    }
    
    func favorileriYukle() {
        let favoriler = getCurrentFavorites()
        favorilerListesi.onNext(favoriler)
    }
    
    func favoriKontrol(urun: Urunler) -> Bool {
        let mevcutFavoriler = getCurrentFavorites()
        return mevcutFavoriler.contains(where: { $0.id == urun.id })
    }
    
    // MARK: - Private Helper Methods
    
    private func getCurrentFavorites() -> [Urunler] {
        if let savedData = UserDefaults.standard.data(forKey: favoriUrunlerKey) {
            do {
                let savedFavorites = try JSONDecoder().decode([Urunler].self, from: savedData)
                return savedFavorites
            } catch {
                print("Favorileri çözme hatası: \(error.localizedDescription)")
            }
        }
        return []
    }
    
    private func saveFavorites(_ favorites: [Urunler]) {
        do {
            let encodedData = try JSONEncoder().encode(favorites)
            UserDefaults.standard.set(encodedData, forKey: favoriUrunlerKey)
        } catch {
            print("Favorileri kaydetme hatası: \(error.localizedDescription)")
        }
    }
} 

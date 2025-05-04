//
//  UrunlerRepository.swift
//  Bootcamp Bitirme
//
//  Created by Arda Toprak on 3.05.2025.
//

import Foundation
import RxSwift
import Alamofire

class UrunlerRepository {
    var urunlerListesi = BehaviorSubject<[Urunler]>(value: [Urunler]())
    
    func urunleriYukle() {
        let url = "http://kasimadalan.pe.hu/urunler/tumUrunleriGetir.php"
        
        AF.request(url, method: .get).response { response in
            if let data = response.data {
                do {
                    let cevap = try JSONDecoder().decode(UrunlerCevap.self, from: data)
                    if let liste = cevap.urunler {
                        print("Veriler başarıyla alındı:", liste)
                        self.urunlerListesi.onNext(liste)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func ara(aramaKelimesi: String) {
        let url = "http://kasimadalan.pe.hu/urunler/tumUrunleriGetir.php"
        AF.request(url, method: .get).response { response in
            if let data = response.data {
                do {
                    let cevap = try JSONDecoder().decode(UrunlerCevap.self, from: data)
                    if let liste = cevap.urunler {
                        let filtrelenmisListe = liste.filter { urun in
                            if let ad = urun.ad, let kategori = urun.kategori, let marka = urun.marka {
                                return ad.lowercased().contains(aramaKelimesi.lowercased()) ||
                                       kategori.lowercased().contains(aramaKelimesi.lowercased()) ||
                                       marka.lowercased().contains(aramaKelimesi.lowercased())
                            }
                            return false
                        }
                        self.urunlerListesi.onNext(filtrelenmisListe)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func kategoriyeGoreFiltrele(kategori: String) {
        let url = "http://kasimadalan.pe.hu/urunler/tumUrunleriGetir.php"
        
        AF.request(url, method: .get).response { response in
            if let data = response.data {
                do {
                    let cevap = try JSONDecoder().decode(UrunlerCevap.self, from: data)
                    if let liste = cevap.urunler {
                        // kategori filtreleme
                        let filtrelenmisListe = liste.filter { urun in
                            if let urunKategori = urun.kategori {
                                return urunKategori.lowercased() == kategori.lowercased()
                            }
                            return false
                        }
                        self.urunlerListesi.onNext(filtrelenmisListe)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
} 

//
//  SepetRepository.swift
//  Bootcamp Bitirme
//
//  Created by Arda Toprak on 5.05.2025.
//

import Foundation
import RxSwift
import Alamofire

class SepetRepository {
    var sepetListesi = BehaviorSubject<[SepetUrun]>(value: [SepetUrun]())
    let kullaniciAdi = "arda_toprak" 
    
    func sepeteEkle(urun: Urunler, adet: Int) {
        let url = "http://kasimadalan.pe.hu/urunler/sepeteUrunEkle.php"
        
        // apinin istediği parametreler
        let parametreler: Parameters = [
            "ad": urun.ad ?? "",
            "resim": urun.resim ?? "",
            "kategori": urun.kategori ?? "",
            "fiyat": urun.fiyat ?? 0,
            "marka": urun.marka ?? "",
            "siparisAdeti": adet,
            "kullaniciAdi": kullaniciAdi
        ]
        
        AF.request(url, method: .post, parameters: parametreler).response { response in
            if let data = response.data {
                do {
                    let cevap = try JSONDecoder().decode(CRUDCevap.self, from: data)
                    
                    if cevap.success == 1 {
                        self.sepetListesiniYukle()
                    }
                } catch {
                    // Hata durumunu sessizce geç
                }
            }
        }
    }
    
    func sepetUrunSil(sepetid: Int, completion: @escaping (Bool, String) -> Void) {
        let url = "http://kasimadalan.pe.hu/urunler/sepettenUrunSil.php"
        
        let parametreler: Parameters = [
            "sepetId": sepetid,
            "kullaniciAdi": kullaniciAdi
        ]
        
        AF.request(url, method: .post, parameters: parametreler).response { response in
            if let data = response.data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("SepetUrunSil API yanıtı: \(jsonString)")
                }
                
                do {
                    let cevap = try JSONDecoder().decode(CRUDCevap.self, from: data)
                    
                    let basarili = cevap.success == 1
                    let mesaj = cevap.message ?? "İşlem sonucu"
                    
                    if !basarili {
                        print("SepetUrunSil Başarısız: sepetId=\(sepetid), başarı=\(cevap.success ?? 0), mesaj=\(mesaj)")
                    }
                    
                    if basarili {
                        self.sepetListesiniYukle()
                    }
                    
                    completion(basarili, mesaj)
                } catch {
                    print("SepetUrunSil JSON çözümleme hatası: \(error)")
                    completion(false, "Sepetten silme işlemi sırasında bir hata oluştu: \(error.localizedDescription)")
                }
            } else {
                print("SepetUrunSil veri alınamadı: \(response.debugDescription)")
                completion(false, "Sepetten silme işlemi sırasında bir hata oluştu: Veri alınamadı")
            }
        }
    }
    
    func sepetListesiniYukle() {
        let url = "http://kasimadalan.pe.hu/urunler/sepettekiUrunleriGetir.php"
        
        let parametreler: Parameters = [
            "kullaniciAdi": kullaniciAdi
        ]
        
        AF.request(url, method: .post, parameters: parametreler).response { response in
            if let data = response.data {
                do {
                    let cevap = try JSONDecoder().decode(SepetCevap.self, from: data)
                    if let liste = cevap.urunler_sepeti {
                        self.sepetListesi.onNext(liste)
                    } else {
                        self.sepetListesi.onNext([])
                    }
                } catch {
                    self.sepetListesi.onNext([])
                }
            } else {
                self.sepetListesi.onNext([])
            }
        }
    }
} 

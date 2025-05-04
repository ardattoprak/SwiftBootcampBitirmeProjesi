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
                    print("Başarı: \(cevap.success ?? 0)")
                    print("Mesaj: \(cevap.message ?? "")")
                    
                    if cevap.success == 1 {
                        self.sepetListesiniYukle()
                    }
                } catch {
                    print("Sepete ekleme hatası: \(error.localizedDescription)")
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
        
        print("API isteği gönderiliyor: \(url)")
        print("Parametreler: sepetId=\(sepetid), kullaniciAdi=\(kullaniciAdi)")
        
        AF.request(url, method: .post, parameters: parametreler).response { response in
            print("API yanıtı alındı: \(response.debugDescription)")
            
            if let data = response.data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("API JSON yanıtı: \(jsonString)")
                }
                
                do {
                    let cevap = try JSONDecoder().decode(CRUDCevap.self, from: data)
                    print("Başarı: \(cevap.success ?? 0)")
                    print("Mesaj: \(cevap.message ?? "")")
                    
                    let basarili = cevap.success == 1
                    let mesaj = cevap.message ?? "İşlem sonucu"
                    
                    if basarili {
                        print("Silme başarılı, sepet listesi yenileniyor")
                        self.sepetListesiniYukle()
                    } else {
                        print("Silme başarısız: \(mesaj)")
                    }
                    
                    completion(basarili, mesaj)
                } catch {
                    print("JSON çözümleme hatası: \(error)")
                    print("Sepetten silme hatası: \(error.localizedDescription)")
                    completion(false, "Sepetten silme işlemi sırasında bir hata oluştu: \(error.localizedDescription)")
                }
            } else {
                print("Sepetten silme hatası: Veri alınamadı, Response: \(response)")
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
                    // Debug için ham veriyi yazdır
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Sepet JSON cevabı: \(jsonString)")
                    }
                    
                    let cevap = try JSONDecoder().decode(SepetCevap.self, from: data)
                    if let liste = cevap.urunler_sepeti {
                        print("Sepet ürünleri bulundu: \(liste.count) adet")
                        self.sepetListesi.onNext(liste)
                    } else {
                        print("Sepet listesi boş veya nil döndü")
                        self.sepetListesi.onNext([])
                    }
                } catch {
                    print("Sepet listesi yükleme hatası: \(error)")
                    print("Hata detayı: \(error.localizedDescription)")
                    self.sepetListesi.onNext([])
                }
            } else {
                print("Sepet verisi alınamadı, response: \(response.debugDescription)")
                self.sepetListesi.onNext([])
            }
        }
    }
} 

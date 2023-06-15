//
//  ImageUtils.swift
//  app
//
//  Created by 신이삭 on 2023/06/14.
//

import Foundation
import PhotosUI
import RxSwift

final class ImageUtils {
    @available(iOS 14, *)
    public class func pickerResultConvertToUIImage(result: PHPickerResult) -> Observable<UIImage?>{
        
        return Observable.create { emitter -> Disposable in
            
            let dispos = Disposables.create()
            let provider = result.itemProvider
            
            guard provider.canLoadObject(ofClass: UIImage.self) == true else{
                emitter.onNext(nil)
                emitter.onCompleted()
                return dispos
            }
            
            provider.loadObject(ofClass: UIImage.self) { rawData, _ in
                
                let uImg = rawData as? UIImage
                emitter.onNext(uImg)
                emitter.onCompleted()
                
            }
            

            return dispos
        }
        
    }
    @available(iOS 14, *)
    public class func pickerResultConvertToMetaData(result: PHPickerResult) -> Observable<URL?>{
        
        return Observable.create { emitter -> Disposable in
            
            let dispos = Disposables.create()
            let provider = result.itemProvider
            
            guard provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) == true else{
                emitter.onNext(nil)
                emitter.onCompleted()
                return dispos
            }
            
            provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, _ in
                
                let final = url
                
                emitter.onNext(final)
                emitter.onCompleted()
                
            }
 
            return dispos
        }
        
    }
}

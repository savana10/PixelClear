
//
//  ImageSelection.swift
//  ImageTesting
//
//  Created by savana kranth on 09/08/2020.
//  Copyright © 2020 savana kranth. All rights reserved.
//


import UIKit
import Photos

typealias BooleanCompletionHandler = ((Bool) -> Void)

@IBDesignable
class ImageSelection: NSObject {

    @IBOutlet var selectedImageView: UIImageView!
    @IBOutlet var displayController: UIViewController!
    @IBInspectable var addInteractionOnImageView: Bool = false {
        didSet{
            if addInteractionOnImageView && selectedImageView != nil {
                addTapGesture()
            }
        }
    }
    @IBInspectable var showImageOptions: Bool = false
    
    private lazy var imagePicker: UIImagePickerController = {
       let imagePicker = UIImagePickerController()
        return imagePicker
    }()
    
    @objc var imageSelected: BooleanCompletionHandler?
    @objc var cancelSelected: BooleanCompletionHandler?
    fileprivate var imageHasBeenSelected = false
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(displayImagePickerOptions))
        tapGesture.numberOfTapsRequired = 1
        selectedImageView.isUserInteractionEnabled = true
        selectedImageView.addGestureRecognizer(tapGesture)
    }
    
    func createANormalImageView() {
        selectedImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
    }
    
    func newImageSelection() {
        imageHasBeenSelected = false
    }
    
    @IBAction @objc func displayImagePickerOptions() {
         self.imagePickerOptions(false)
    }
    
    
    @objc func imagePickerOptions(_ camera: Bool) {
        imagePicker = UIImagePickerController()
        if camera && UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = .front
            }
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.delegate = self
        displayController.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func getSelectedImageData(_ jpeg: Bool = true) -> Data? {
        if imageHasBeenSelected {
             return jpeg ? selectedImageView.image!.jpegData(compressionQuality: 0.2) : selectedImageView.image!.pngData()
        }
        return nil
    }
    
}

extension ImageSelection: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
            if let im = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                self.selectedImageView.image = im
                self.imageHasBeenSelected = true
                self.imageSelected?(true)
            } else  if let url = info[UIImagePickerController.InfoKey.referenceURL.rawValue] as? URL,
                let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                manager.requestImage(for: asset, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFit, options: option, resultHandler: {(image: UIImage?, info: [AnyHashable : Any]?) in
                    if let _ = image {
                        self.selectedImageView.image = image
                        self.imageHasBeenSelected = true
                        self.imageSelected?(true)
                    }
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageSelected?(imageHasBeenSelected)
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

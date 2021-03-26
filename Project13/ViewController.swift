//
//  ViewController.swift
//  Project13
//
//  Created by Ali Karababa on 25.03.2021.
//

import CoreImage
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var intensity: UISlider!
    @IBOutlet var imageView: UIImageView!
    var currentImage : UIImage!
    
    var context : CIContext!
    var currentFilter : CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing  = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        currentImage = image
        
        self.dismiss(animated: true)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    func applyProcessing() {
        guard let outputImage = currentFilter.outputImage else { return }
        let inputKeys = currentFilter.inputKeys
        
        
        if inputKeys.contains(kCIInputIntensityKey) {currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)}
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)}
        if inputKeys.contains(kCIInputScaleKey) {currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)}
        if inputKeys.contains(kCIInputCenterKey) {currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)}
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage:cgImage)
            self.imageView.image = processedImage
        }
        
    }

    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose Filter", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: UIAlertAction.Style.default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: UIAlertAction.Style.default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: UIAlertAction.Style.default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: UIAlertAction.Style.default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: UIAlertAction.Style.default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: UIAlertAction.Style.default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: UIAlertAction.Style.default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel))
                     
        if let popOverController = ac.popoverPresentationController {
            popOverController.sourceView = sender
            popOverController.sourceRect = sender.bounds
        }
        
        present(ac, animated: true)
        
    }
    
    @objc func image(_ image : UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
            self.present(ac, animated: true)
        }else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: UIAlertController.Style.alert)
            ac.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
            self.present(ac, animated: true)
        }
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    func setFilter(action: UIAlertAction) {
        guard currentImage != nil else { return }
        
        
        guard let actionTitle = action.title else { return }
        title = actionTitle
        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    
    @IBAction func save(_ sender: Any) {
      //  guard let selectedImage = imageView.image else {return}
        if  imageView.image == nil {
            let ac = UIAlertController(title: "There is no image", message: "error was found", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
            self.present(ac, animated: true)
        }else {
            UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image), nil)
        }
        
        
    }
    
   
}


//
//  ViewController.swift
//  StickerApp
//
//  Created by Lavanya on 06/01/20.
//  Copyright © 2020 Lavanya. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    let cameraPicker = UIImagePickerController()
    var imageViewScale: CGFloat = 1.0
    let maxScale: CGFloat = 4.0
    let minScale: CGFloat = 1.0
    override func viewDidLoad() {
        super.viewDidLoad()
        //disable buttons before capturing the picture
        addButton.isEnabled = false
        saveButton.isEnabled = false
        //adding camera picker delegate
        cameraPicker.delegate = self
    }
    
    //MARK:- IBActions
    @IBAction func addSticker(_ sender: Any) {
        addImageViewWithRemoveButton()
    }
    
    func addImageViewWithRemoveButton(){
        let imageView = UIImageView()
        let images = ["emoji","HiImage"]
        let randomNumber = arc4random_uniform(UInt32(images.count)) // generating random number
        imageView.image = UIImage(named: images[Int(randomNumber)])
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width:80, height: 80)
        imageView.center = mainImageView.center
        imageView.isUserInteractionEnabled = true
        imageView.tag = Int(randomNumber)
        imageView.addSubview(addRemoveButton(imageview:imageView))
        self.view.addSubview(imageView)
        addGestures(view:imageView)
    }
    
    func addRemoveButton(imageview:UIImageView)-> UIButton{
        let removeButton = UIButton()
        removeButton.addTarget(self, action: #selector(removeEmoji(sender:)), for: .allEvents)
        removeButton.frame = CGRect(x:imageview.frame.width-20, y:-5 , width: 20, height: 20)
        removeButton.setImage(UIImage(named:"Clear"), for: .normal)
        removeButton.isHidden = true
        return removeButton
    }
    
    @objc func removeEmoji(sender:UIButton){
        sender.superview?.removeFromSuperview()
    }
   
    
    @IBAction func takePhoto(_ sender: Any) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.showCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        #if targetEnvironment(simulator)
        // your simulator code
        print("camera won't available in simulator")
        addAlertView(title: "Camera won't available in simulator", message:"", actionTitle: "ok")
        
        #else
        // your real device code
        cameraPicker.sourceType = .camera
        present(cameraPicker, animated: true, completion: nil)
        #endif
        
    }
    
    func showAlbum() {
        cameraPicker.sourceType = .photoLibrary
        present(cameraPicker, animated: true, completion: nil)
    }
    
    
    @IBAction func savePhoto(_ sender: Any) {
        if ((mainImageView?.image) != nil){
            hideViewsForScreenShotOfImage()
            takeScreenshotOfImage(true)
        }
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            addAlertView(title: "Save error", message: error.localizedDescription, actionTitle: "OK")
            
        } else {
            addAlertView(title: "Saved!", message: "Your altered image has been saved to your photos.", actionTitle: "OK")
            
            for imageView in self.view.subviews  {
                if imageView is UIImageView {
                    imageView.removeFromSuperview()
                    
                }
                
            }
            self.view.addSubview(mainImageView)
            mainImageView.image = nil
        }
    }
    
    
    func addAlertView(title:String,message:String, actionTitle:String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default))
        present(ac, animated: true)
    }
    
    open func takeScreenshotOfImage(_ shouldSave: Bool = true) {
        
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return }
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = screenshotImage, shouldSave {
            unHideViewsForScreenShotOfImage()
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func unHideViewsForScreenShotOfImage(){
        addButton.isEnabled = true
        saveButton.isEnabled = true
        takePhotoButton.isHidden = false
    }
    
    func hideViewsForScreenShotOfImage(){
        addButton.isEnabled = true
        saveButton.isEnabled = true
        takePhotoButton.isHidden = true
    }
}

// MARK: UIImagePickerControllerDelegate

extension ImageViewController:UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            mainImageView.image = image
            saveButton.isEnabled = true
            addButton.isEnabled = true
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ImageViewController:UIGestureRecognizerDelegate{
    
    func addGestures(view: UIView){
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGesture(recognizer:)))
        panGesture.delegate = self
        
        let  pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinchGesture(recognizer:)))
        pinchGesture.delegate = self
        
        let rotateGesture = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotateGesture(recognizer:)))
        rotateGesture.delegate = self
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        
        view.addGestureRecognizer(panGesture)
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(rotateGesture)
        view.addGestureRecognizer(lpgr)
        
    }
    
    @objc func handleRotateGesture(recognizer:UIRotationGestureRecognizer){
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    @objc func handlePinchGesture(recognizer:UIPinchGestureRecognizer){
        
        if let view = recognizer.view {
            let pinchScale: CGFloat = recognizer.scale
            if imageViewScale * pinchScale < maxScale && imageViewScale * pinchScale > minScale {
                imageViewScale *= pinchScale
                view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            }
            recognizer.scale = 1
        }
    }
    @objc func handlePanGesture(recognizer:UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    //MARK: - UILongPressGestureRecognizer Action -
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            //When lognpress is start or running
            if let view = gestureReconizer.view {
                for button in view.subviews  {
                    if button is UIButton {
                        button.isHidden = false
                    }
                }
            }
        }
        else {
            //When lognpress is finish
        }
    }
}

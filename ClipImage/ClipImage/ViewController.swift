//
//  ViewController.swift
//  ClipImage
//
//  Created by hujunhua on 13/05/2017.
//  Copyright © 2017 hujunhua. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    func initUI() {
        imageView.layer.cornerRadius = imageView.frame.size.height / 2.0
        imageView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage.init()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    // MARK: - Action
    @IBAction func chooseImageButtonAction(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerVC = UIImagePickerController.init()
            imagePickerVC.sourceType = .photoLibrary
            imagePickerVC.delegate = self
            present(imagePickerVC, animated: true, completion: nil)
        }
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let vc = ClipImageVC.init()
        vc.delegate = self
        vc.image = info[.originalImage] as? UIImage
        navigationController?.pushViewController(vc, animated: true)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController: ClipImageVCDelegate {
    
    func clipImageVC(_ clipImageVC: ClipImageVC, didFinishClipingImage image: UIImage) {
        imageView.image = image
    }
    
}


//
//  UploadImagesViewController.swift
//  FarmersMarked
//
//  Created by Thomas Haulik Barchager on 11/10/2019.
//  Copyright © 2019 Haulik. All rights reserved.
//

import UIKit
import Firebase

class UploadImagesViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    @IBOutlet weak var NameCell: UITextField!
    @IBOutlet weak var DescriptionCell: UITextField!
    @IBOutlet weak var AgeCell: UITextField!
    
    
    var originalImage: UIImage?
    let imageController = UIImagePickerController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageController.delegate = self
        progressView.isHidden = true
        labelText.isHidden = true
        textField.isHidden = true

    }
    
    
    @IBAction func uploadButtonWasTapped(_ sender: Any) {
        progressView.isHidden = false
        labelText.isHidden = false
        textField.isHidden = false
        let randomID = UUID.init().uuidString
        let uploadRef = Storage.storage().reference(withPath: "personlist/images/Thomas")
        guard let imageData =  imageView.image?.jpegData(compressionQuality: 0.75) else {return}
        let uploadMetadata = StorageMetadata.init()
        let taskReference = uploadRef.putData(imageData, metadata: uploadMetadata) { (downloadMetadata, error) in
            if let error = error {
                print("Oh no, something went wrong! \(error.localizedDescription)")
                return
            }
            print("Put is complete and I got this back: \(String(describing: downloadMetadata))")
            
            
            guard let age = self.AgeCell.text else { return }
            guard let description = self.DescriptionCell.text else { return }
          //  guard let image = self.imageView.image else { return }
            guard let Name = self.NameCell.text else { return }
            
            let values = ["age": age, "description": description,/* "image": image,*/ "Name": Name] as [String : Any]
            
            Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
 
            uploadRef.downloadURL { (url, error) in
                if let error = error{
                    print("Something went wrong! \(error.localizedDescription)")
                    return
                }
                if let url = url {
                    print("Here is your download URL: \(url.absoluteString)")
                    self.textField.text = url.absoluteString
                }
            }
        }
        )}
        
        taskReference.observe(.progress) { (snapshot) in
            guard let pctThere = snapshot.progress?.fractionCompleted else {return }
            print("You are \(pctThere) complete")
            self.progressView.progress = Float(pctThere)
        }
    }
    
    @IBAction func fetchImageWasTapped(_ sender: Any) {
        progressView.isHidden = false
        labelText.isHidden = false
        textField.isHidden = false
        let storageRef = Storage.storage().reference(withPath: "personlist/images/Thomas.jpg")
        let taskReference = storageRef.getData(maxSize: 6 * 1024 * 1024) { [weak self] (data, error) in
            if let error = error {
                print("Something went wrong: \(error.localizedDescription)")
                return
            }
            if let data = data {
                self?.imageView.image = UIImage(data: data)
            }
        }
        
        storageRef.downloadURL { (url, error) in
            if let error = error{
                print("Something went wrong! \(error.localizedDescription)")
                return
            }
            if let url = url {
                print("Here is your download URL: \(url.absoluteString)")
                self.textField.text = url.absoluteString
            }
        }
        
        taskReference.observe(.progress) { (snapshot) in
            guard let pctThere = snapshot.progress?.fractionCompleted else {return }
            print("You are \(pctThere) complete")
            self.progressView.progress = Float(pctThere)
        }
    }
    
    
    @IBAction func pickImage(_ sender: Any) {
        imageController.sourceType = .photoLibrary
                   
                   imageController.allowsEditing = true
                   
                   self.present(imageController, animated: true){
                       //after it is complete
        }

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            imageView.image = image
            
        }else{
            print("Well somthing went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

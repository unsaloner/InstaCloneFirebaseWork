//
//  UploadViewController.swift
//  InstaCloneFirebase
//
//  Created by Unsal Oner on 23.01.2022.
//

import UIKit
import Firebase
import FirebaseFirestore

class UploadViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var uploadButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func chooseImage(){
//        Kullanıcının kütüphanesine erişebilmek için pickercontroller kullanıyoruz.
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func uplaoadButton(_ sender: Any) {
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            
            let uuid = UUID().uuidString
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data, metadata: nil) { metadata, error in
                if error != nil {
                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                }else{
                    imageReference.downloadURL { url, error in
                        
                        if error == nil {
//                            url.absolutestring = url mi  al stringe çevir.
                            let imageUrl = url?.absoluteString
//                            DATABASE
                            let firestoreDatabase = Firestore.firestore()
                            
                            var firestoreReference : DocumentReference?
                            
//                            Bir dictionary oluşturmamız gerek dictionary nin içine neyi kaydetmek istiyorsak onu yazmalıyız.
                            
                            let firestorePost = ["imageUrl" : imageUrl!,"postedBy" : Auth.auth().currentUser!.email!, "postComment" : self.textField.text!, "date" : FieldValue.serverTimestamp() , "likes" : 0  ] as [String : Any]
//                            FieldValue.serverTimestamp : Kullanıcının işlemi yaptığı andaki tarihi kaydeder.
                            
                            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                if error != nil{
                                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error" )
                                    
                                }else {
                                    self.imageView.image = UIImage(named: "selectimage.png")
                                    self.textField.text = ""
//                              eğer datalar yüklenirken bir hata yoksa beni seçilen index'e(Feed'e) götür.
                                    self.tabBarController?.selectedIndex = 0
                                    
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    


}

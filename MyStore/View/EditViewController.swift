//
//  EditViewController.swift
//  MyStore
//
//  Created by souvik_roy on 30/07/24.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Kingfisher

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var ratingTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var closeLabel: UILabel!
    
    @IBOutlet weak var saveBtn: UIButton!
    var product: ProductDetails?
    var selectedImageName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prefill data
        if let product = product {
            nameTextField.text = product.name
            priceTextField.text = product.price
            descriptionTextField.text = product.description
            ratingTextField.text = product.rating
            //  imageView.image = UIImage(named: product.imageName)
            
            imageView.kf.setImage(with: URL(string: product.imageName))
            selectedImageName = product.imageName
            saveBtn.layer.cornerRadius = 10
            saveBtn.clipsToBounds = true
        }
        
        // Add tap gesture recognizer to imageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeLabelTapped))
        closeLabel.isUserInteractionEnabled = true
        closeLabel.addGestureRecognizer(tapGesture)
        
       
        
    }
    
    @objc func closeLabelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            let imageName = UUID().uuidString // Generate a unique name for the image
            uploadImage(image: selectedImage, imageName: imageName) { [weak self] imageUrl in
                guard let self = self else { return }
                if let imageUrl = imageUrl {
                    self.selectedImageName = imageUrl
                } else {
                    print("Error uploading image")
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(image: UIImage, imageName: String, completion: @escaping (_ imageUrl: String?) -> Void) {
        let storageRef = Storage.storage().reference().child("product_images/\(imageName).png")
        
        if let imageData = image.pngData() {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error getting download URL: \(error.localizedDescription)")
                            completion(nil)
                        } else if let url = url {
                            completion(url.absoluteString)
                        }
                    }
                }
            }
        } else {
            print("Error converting image to data")
            completion(nil)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        //        guard let productIdToUpdate = product?.id,
        //                 let updatedName = nameTextField.text,
        //                 let updatedPrice = priceTextField.text,
        //                 let updatedDescription = descriptionTextField.text,
        //                 let updatedRating = ratingTextField.text else {
        //               print("Error: Missing required fields")
        //               return
        //           }
        
        let productIdToUpdate = self.product?.id
        let updatedName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let updatedPrice = priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let updatedDescription = descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let updatedRating = ratingTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        let ref = Database.database().reference().child("products")
        
        self.uploadImage(self.imageView.image!) { [weak self] url in
            guard let self = self, let imageUrl = url else {
                print("Failed to upload image")
                return
            }
            let product = ProductDetails(id: Int.random(in: 1...1000), name: updatedName!, imageName: imageUrl.absoluteString, price: updatedPrice!, description: updatedDescription!, rating: updatedRating!)
         
            
            
            ref.observeSingleEvent(of: .value) { snapshot in
                print("Fetched snapshot value: \(snapshot.value ?? "No data")")
                
                guard let data = snapshot.value as? [String: Any],
                      let productsData = data["response"] as? [[String: Any]] else {
                    print("Error: Unable to fetch or cast data")
                    return
                }
                
                var updatedData = productsData
                
                for (categoryIndex, category) in updatedData.enumerated() {
                    if var products = category["products"] as? [[String: Any]] {
                        if let productIndex = products.firstIndex(where: { $0["id"] as? Int == productIdToUpdate }) {
                            var updatedProduct = products[productIndex]
                            updatedProduct["name"] = updatedName
                            updatedProduct["price"] = updatedPrice
                            updatedProduct["description"] = updatedDescription
                            updatedProduct["rating"] = updatedRating
                            if let imageUrl = self.selectedImageName {
                                updatedProduct["image_name"] = imageUrl
                            }
                            products[productIndex] = updatedProduct
                            updatedData[categoryIndex]["products"] = products
                            
                            // Save updated data back to Firebase
                            ref.setValue(["response": updatedData]) { error, _ in
                                if let error = error {
                                    print("Error updating product: \(error.localizedDescription)")
                                } else {
                                    print("Product updated successfully!")
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                            return
                        }
                    }
                }
            }
        
        }
            
    }
    
    
    func uploadImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        let uniqueImageName = self.nameTextField.text!
        let storageRef = Storage.storage().reference().child("\(uniqueImageName)"+".png")
        let imgData = imageView.image?.pngData()
        let metadata = StorageMetadata()
        metadata.contentType = "image.png"
        
        storageRef.putData(imgData!, metadata: metadata) { (metadata , error) in
            if error == nil{
                print("success")
                storageRef.downloadURL(completion:  { (url, error) in
                    completion(url)
                })
            }else{
                
                print("error saving image")
                completion(nil)
                
            }
            
            
        }
        
    }
}

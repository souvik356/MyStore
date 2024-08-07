//
//  AddViewController.swift
//  MyStore
//
//  Created by souvik_roy on 29/07/24.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AddViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var closeLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
       @IBOutlet weak var priceTextField: UITextField!
       @IBOutlet weak var descriptionTextField: UITextField!
       @IBOutlet weak var ratingTextField: UITextField!
       @IBOutlet weak var categoryTextField: UITextField!
       @IBOutlet weak var imageView: UIImageView!

    var selectedImage: UIImage?
        let categories = ["Shoes", "Mobile Phones", "Bags", "Watches"]
        var categoryPicker = UIPickerView()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Set up image view tap gesture
            let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImageTapped))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(imageTapGesture)
            
            // Set up close label tap gesture
            let closeTapGesture = UITapGestureRecognizer(target: self, action: #selector(closeLabelTapped))
            closeLabel.isUserInteractionEnabled = true
            closeLabel.addGestureRecognizer(closeTapGesture)
            
            // Set up category picker view
            categoryPicker.delegate = self
            categoryPicker.dataSource = self
            categoryTextField.inputView = categoryPicker
            
            // Add a toolbar with a Done button to the picker view
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
            toolbar.setItems([doneButton], animated: true)
            toolbar.isUserInteractionEnabled = true
            categoryTextField.inputAccessoryView = toolbar
        }
        
        @objc func doneTapped() {
            categoryTextField.resignFirstResponder()
        }
        
        @objc func closeLabelTapped() {
            dismiss(animated: true, completion: nil)
        }
        
        @objc func selectImageTapped() {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true, completion: nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                imageView.image = image
                selectedImage = image
            }
            dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
        
        @IBAction func submitButtonTapped(_ sender: UIButton) {
//            guard let name = nameTextField.text, !name.isEmpty,
//                  let price = priceTextField.text, !price.isEmpty,
//                  let description = descriptionTextField.text, !description.isEmpty,
//                  let rating = ratingTextField.text, !rating.isEmpty,
//                  let category = categoryTextField.text, !category.isEmpty,
//                  let image = selectedImage else {
//                print("Please fill in all fields and select an image")
//                return
//            }
            
            let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let price = priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let desc = descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let rating = ratingTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let category = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    
    
            self.uploadImage(self.imageView.image!) { [weak self] url in
                guard let self = self, let imageUrl = url else {
                    print("Failed to upload image")
                    return
                }
                let product = ProductDetails(id: Int.random(in: 1...1000), name: name!, imageName: imageUrl.absoluteString, price: price!, description: desc!, rating: rating!)
                self.addProduct(product, to: category!)
            }
        }
        
        func uploadImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
            let uniqueImageName = self.nameTextField.text!
            let storageRef = Storage.storage().reference().child("\(uniqueImageName)"+".png")
            let imgData = imageView.image?.pngData()
//            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
//                print("Failed to convert image to data")
//                completion(nil)
//                return
//            }
            let metadata = StorageMetadata()
            metadata.contentType = "image.png"
            
            storageRef.putData(imgData!, metadata: metadata) { (metadata , error) in
//                if let error = error {
//                    print("Failed to upload image: \(error.localizedDescription)")
//                    completion(nil)
//                    return
//                }
                
                
                
//                storageRef.downloadURL { url, error in
//                    if let error = error {
//                        print("Failed to retrieve download URL: \(error.localizedDescription)")
//                        completion(nil)
//                        return
//                    }
//
//                    // Clean the URL by removing ":443" if it exists
//                    if let urlString = url?.absoluteString.replacingOccurrences(of: ":443", with: ""),
//                       let cleanedUrl = URL(string: urlString) {
//                        completion(cleanedUrl)
//                    } else {
//                        completion(url)
//                    }
//                }
                
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
        
        func addProduct(_ product: ProductDetails, to category: String) {
            let ref = Database.database().reference().child("products/response")
            ref.observeSingleEvent(of: .value) { snapshot in
                var foundCategory = false
                for case let categorySnapshot as DataSnapshot in snapshot.children {
                    if var categoryDict = categorySnapshot.value as? [String: Any],
                       let categoryName = categoryDict["category_name"] as? String, categoryName == category {
                        var products = categoryDict["products"] as? [[String: Any]] ?? []
                        let newProduct: [String: Any] = [
                            "id": product.id,
                            "name": product.name,
                            "image_name": product.imageName,
                            "price": product.price,
                            "description": product.description,
                            "rating": product.rating
                        ]
                        products.append(newProduct)
                        categoryDict["products"] = products
                        ref.child(categorySnapshot.key).setValue(categoryDict)
                        foundCategory = true
                        break
                    }
                }
                if !foundCategory {
                    let newCategory: [String: Any] = [
                        "category_name": category,
                        "products": [[
                            "id": product.id,
                            "name": product.name,
                            "image_name": product.imageName,
                            "price": product.price,
                            "description": product.description,
                            "rating": product.rating
                        ]]
                    ]
                    ref.childByAutoId().setValue(newCategory)
                }
                self.dismiss(animated: true, completion: nil)
            } withCancel: { error in
                print("Error adding product: \(error.localizedDescription)")
            }
        }
        
        // UIPickerView Delegate and DataSource methods
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return categories.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return categories[row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            categoryTextField.text = categories[row]
        }
}

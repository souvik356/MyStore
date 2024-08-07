import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class AuthRegisterViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var registerButton: UIButton!
    override func viewDidLoad() {
            super.viewDidLoad()
            
            passwordTextField.isSecureTextEntry = true
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loginLabelTapped))
            loginLabel.isUserInteractionEnabled = true
            loginLabel.addGestureRecognizer(tapGestureRecognizer)
            navigationController?.navigationBar.isHidden = true
            ref = Database.database().reference()
            activityIndicator.hidesWhenStopped = true
        registerButton.layer.cornerRadius = 10
        registerButton.clipsToBounds = true
        nameTextField.layer.cornerRadius = 10
        nameTextField.clipsToBounds = true
        emailTextField.layer.cornerRadius = 10
        emailTextField.clipsToBounds = true
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.clipsToBounds = true
        
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            if Auth.auth().currentUser != nil {
                let tabController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
                tabController.modalPresentationStyle = .fullScreen
                self.present(tabController, animated: true)
            } else {
                self.view.isHidden = false
            }
        }
        
        @objc func loginLabelTapped() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVc = storyboard.instantiateViewController(withIdentifier: "AuthLoginViewController") as! AuthLoginViewController
            navigationController?.pushViewController(loginVc, animated: true)
        }
        
        @IBAction func registerButtonTapped(_ sender: UIButton) {
            guard let name = nameTextField.text, !name.isEmpty,
                  let email = emailTextField.text, !email.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty else {
                displayError(message: "Please fill all the fields")
                return
            }
            
            if !isValidEmail(email) {
                displayError(message: "Please enter a valid email address")
                return
            }
            
            if !isValidPassword(password) {
                displayError(message: "Password must be at least 8 characters, include a number and a special character")
                return
            }
            
            if isSessionActive() {
                displayError(message: "A session is already active. Please logout")
                return
            }
            
            // Show activity indicator
            activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if let error = error {
                    self.displayError(message: "Error creating user: \(error.localizedDescription)")
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                } else if let result = result {
                    let dict = ["name": name, "email": email, "uid": result.user.uid]
                    self.ref.child("RegisterUser").child(result.user.uid).setValue(dict) { (error, ref) in
                        if let error = error {
                            self.displayError(message: "Error saving user details: \(error.localizedDescription)")
                            self.activityIndicator.stopAnimating()
                            self.view.isUserInteractionEnabled = true
                        } else {
                            // Attempt auto-login
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                                    if let error = error {
                                        self.displayError(message: "Error auto login: \(error.localizedDescription)")
                                    } else {
                                        let tabController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
                                        tabController.modalPresentationStyle = .fullScreen
                                        self.present(tabController, animated: true)
                                    }
                                    // Stop activity indicator and enable user interaction
                                    self.activityIndicator.stopAnimating()
                                    self.view.isUserInteractionEnabled = true
                                }
                            }
                        }
                    }
                }
            }
        }
        
        func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
        }
        
        func isValidPassword(_ password: String) -> Bool {
            let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[!@#$&*]).{8,}$"
            let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
            return passwordPred.evaluate(with: password)
        }
        
        func displayError(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        func isSessionActive() -> Bool {
            return UserDefaults.standard.string(forKey: "sessionID") != nil
        }
    
//    func uploadDataToFirebase() {
//        let ref = Database.database().reference()
//        let data: [String: Any] = [
//            "response": [
//                [
//                    "category_name": "Shoes",
//                    "products": [
//                        [
//                            "id": 1,
//                            "name": "Nike",
//                            "image_name": "shoesimage1",
//                            "price": "₹1,000",
//                            "description": "A shoe is an item of footwear intended to protect and comfort the human foot...",
//                            "rating": "4.1"
//                        ],
//                        // Other shoe products...
//                        [
//                            "id": 2,
//                            "name": "Addidas",
//                            "image_name": "shoesimage2",
//                            "price": "₹1,500",
//                            "description": "A shoe is an item of footwear intended to protect and comfort the human foot. Shoes are also used as an item of decoration and fashion. The design of shoes has varied enormously through time and from culture to culture, with appearance originally being tied to function. Additionally, fashion has often dictated many design elements, such as whether shoes have very high heels or flat ones. Contemporary footwear in the 2010s varies widely in style, complexity and cost. Basic sandals may consist of only a thin sole and simple strap and be sold for a low cost. High fashion shoes made by famous designers may be made of expensive materials, use complex construction and sell for hundreds or even thousands of dollars a pair. Some shoes are designed for specific purposes, such as boots designed specifically for mountaineering or skiing.",
//                            "rating": "3.8"
//                        ],
//                        [
//                            "id": 3,
//                            "name": "Casual",
//                            "image_name": "shoesimage3",
//                            "price": "₹1,200",
//                            "description": "A shoe is an item of footwear intended to protect and comfort the human foot. Shoes are also used as an item of decoration and fashion. The design of shoes has varied enormously through time and from culture to culture, with appearance originally being tied to function. Additionally, fashion has often dictated many design elements, such as whether shoes have very high heels or flat ones. Contemporary footwear in the 2010s varies widely in style, complexity and cost. Basic sandals may consist of only a thin sole and simple strap and be sold for a low cost. High fashion shoes made by famous designers may be made of expensive materials, use complex construction and sell for hundreds or even thousands of dollars a pair. Some shoes are designed for specific purposes, such as boots designed specifically for mountaineering or skiing.",
//                            "rating": "4.5"
//                        ],
//                        [
//                            "id": 4,
//                            "name": "Jordan",
//                            "image_name": "shoesimage4",
//                            "price": "₹1,400",
//                            "description": "A shoe is an item of footwear intended to protect and comfort the human foot. Shoes are also used as an item of decoration and fashion. The design of shoes has varied enormously through time and from culture to culture, with appearance originally being tied to function. Additionally, fashion has often dictated many design elements, such as whether shoes have very high heels or flat ones. Contemporary footwear in the 2010s varies widely in style, complexity and cost. Basic sandals may consist of only a thin sole and simple strap and be sold for a low cost. High fashion shoes made by famous designers may be made of expensive materials, use complex construction and sell for hundreds or even thousands of dollars a pair. Some shoes are designed for specific purposes, such as boots designed specifically for mountaineering or skiing.",
//                            "rating": "3.7"
//                        ],
//                        [
//                            "id": 5,
//                            "name": "Forca",
//                            "image_name": "shoesimage5",
//                            "price": "₹1,800",
//                            "description": "A shoe is an item of footwear intended to protect and comfort the human foot. Shoes are also used as an item of decoration and fashion. The design of shoes has varied enormously through time and from culture to culture, with appearance originally being tied to function. Additionally, fashion has often dictated many design elements, such as whether shoes have very high heels or flat ones. Contemporary footwear in the 2010s varies widely in style, complexity and cost. Basic sandals may consist of only a thin sole and simple strap and be sold for a low cost. High fashion shoes made by famous designers may be made of expensive materials, use complex construction and sell for hundreds or even thousands of dollars a pair. Some shoes are designed for specific purposes, such as boots designed specifically for mountaineering or skiing.",
//                            "rating": "3.5"
//                        ]
//                    ]
//                ],
//                // Other categories...
//                [
//                    "category_name": "Mobile Phones",
//                    "products": [
//                        [
//                            "id": 1,
//                            "name": "Iphone",
//                            "image_name": "mobileimage1",
//                            "price": "₹1,00,000",
//                            "description": "An iPhone is a line of smartphones designed and marketed by Apple Inc. All generations of the iPhone use Apple's iOS mobile operating system software...",
//                            "rating": "4.8"
//                        ],
//                        // Other mobile phone products...
//                        [
//                            "id": 2,
//                            "name": "Samsung",
//                            "image_name": "mobileimage2",
//                            "price": "₹95,000",
//                            "description": "An iPhone is a line of smartphones designed and marketed by Apple Inc. All generations of the iPhone use Apple's iOS mobile operating system software. The first-generation iPhone was released on June 29, 2007; as of November 1, 2018, more than 2.2 billion iPhones had been sold. The iPhone was the first mobile phone with multi-touch technology...",
//                            "rating": "4.1"
//                        ],
//                        [
//                            "id": 3,
//                            "name": "Oppo",
//                            "image_name": "mobileimage3",
//                            "price": "₹50,000",
//                            "description": "An iPhone is a line of smartphones designed and marketed by Apple Inc. All generations of the iPhone use Apple's iOS mobile operating system software. The first-generation iPhone was released on June 29, 2007; as of November 1, 2018, more than 2.2 billion iPhones had been sold. The iPhone was the first mobile phone with multi-touch technology. Since the first generation of iPhones, it has gained larger screen sizes, video-recording, waterproofing, and many accessibility features...",
//                            "rating": "4.3"
//                        ],
//                        [
//                            "id": 4,
//                            "name": "Oneplus",
//                            "image_name": "mobileimage4",
//                            "price": "₹75,000",
//                            "description": "An iPhone is a line of smartphones designed and marketed by Apple Inc. All generations of the iPhone use Apple's iOS mobile operating system software. The first-generation iPhone was released on June 29, 2007; as of November 1, 2018, more than 2.2 billion iPhones had been sold. The iPhone was the first mobile phone with multi-touch technology. Since the first generation of iPhones, it has gained larger screen sizes, video-recording, waterproofing, and many accessibility features...",
//                            "rating": "3.9"
//                        ],
//                        [
//                            "id": 5,
//                            "name": "Vivo",
//                            "image_name": "mobileimage5",
//                            "price": "₹30,000",
//                            "description": "An iPhone is a line of smartphones designed and marketed by Apple Inc. All generations of the iPhone use Apple's iOS mobile operating system software. The first-generation iPhone was released on June 29, 2007; as of November 1, 2018, more than 2.2 billion iPhones had been sold. The iPhone was the first mobile phone with multi-touch technology. Since the first generation of iPhones, it has gained larger screen sizes, video-recording, waterproofing, and many accessibility features...",
//                            "rating": "4.4"
//                        ]
//                    ]
//                ]
//            ]
//        ]
//
//        ref.child("products").setValue(data) { error, _ in
//            if let error = error {
//                print("Error uploading data: \(error.localizedDescription)")
//            } else {
//                print("Data uploaded successfully")
//            }
//        }
//    }
}

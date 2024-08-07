import UIKit
import Firebase
import FirebaseAuth

class AuthLoginViewController: UIViewController {
    
    @IBOutlet weak var BackBtnLable: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! // Add this line
    
    @IBOutlet weak var signInButton: UIButton!
    //    let authViewModel = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationItem.hidesBackButton = true
        
        passwordTextField.isSecureTextEntry = true
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(BackBtnTapped))
        BackBtnLable.isUserInteractionEnabled = true
        BackBtnLable.addGestureRecognizer(tapGestureRecogniser)
        
        activityIndicator.hidesWhenStopped = true // Add this line
        signInButton.layer.cornerRadius = 10
        signInButton.clipsToBounds = true
        emailTextField.layer.cornerRadius = 10
        emailTextField.clipsToBounds = true
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.clipsToBounds = true
    }
    
    @objc func BackBtnTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVc = storyboard.instantiateViewController(withIdentifier: "AuthRegisterViewController") as! AuthRegisterViewController
        navigationController?.pushViewController(registerVc, animated: true)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            displayError(message: "Please fill both email and password")
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
            displayError(message: "A session is already active. please logout")
            return
        }
        
        // Show the activity indicator
        activityIndicator.startAnimating()
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            // Hide the activity indicator
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.displayError(message: error.localizedDescription)
            } else {
                let tabController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
                tabController.modalPresentationStyle = .fullScreen
                self.present(tabController, animated: true)
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
    
    func clearTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    func navigateToProductPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let productPageVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
        navigationController?.pushViewController(productPageVC, animated: true)
    }
}


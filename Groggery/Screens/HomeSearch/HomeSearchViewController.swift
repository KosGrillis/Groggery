import UIKit

/// #HomeSearchViewController
///
/// This is the first view controller presented to the user upon app load
class HomeSearchViewController: UIViewController {
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        )

        // Add searchButton as child view of searchTextField, note that the width of the
        // button (set via storyboard) acts as right padding
        self.searchTextField.rightView = self.searchButton
        self.searchTextField.rightViewMode = .always
        
        // Adjust searchTextField left padding to match the above
        self.searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height:  self.searchTextField.frame.height))
        self.searchTextField.leftViewMode = .always
        
        // Adjust non-standard style properties of searchTextField
        self.searchTextField.layer.borderColor = UIColor(named: "EdgeHighlight")?.cgColor
        self.searchTextField.layer.borderWidth = 1
        self.searchTextField.layer.cornerRadius = 16
        self.searchTextField.layer.masksToBounds = true
        
        // Add dynamic placeholder to searchTextField
        self.searchTextField.attributedPlaceholder = NSAttributedString(
            string: self.generateSearchPlaceholder(),
            attributes: [
                NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 13),
                NSAttributedString.Key.foregroundColor: UIColor(named: "TextPlaceholder")!
            ]
        )
    }
    
    private func handleSearch() {
        if let searchQuery = self.searchTextField.text {
            guard searchQuery.count > 0 else {
                return
            }

            self.performSegue(withIdentifier: "HomeSearchSegueToSearchResults", sender: nil)
        }
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func generateSearchPlaceholder() -> String {
        let options = [
            "Try \"Margarita\"",
            "Search for multiple ingredients like \"Gin\", \"Vodka\"",
            "\"Long island iced tea\" perhaps?",
            "Can't go wrong with \"Mojito\"",
            "\"Bourbon\", \"bitters\", ...",
            "Feeling \"Dark and Stormy\"?"
        ]
        
        return options.randomElement()!
    }
    
    @IBAction func onSearchButtonTouchUpInside(_ sender: UIButton) {
        self.dismissKeyboard()
        self.handleSearch()
    }
    
    @IBAction func onSearchTextFieldEditingEnd(_ sender: UITextField) {
        self.handleSearch()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            case let searchResultsViewController as SearchResultsViewController:
                // Default value to silence Swift warnings should not apply because of `guard` in handleSearch()
                searchResultsViewController.searchQuery = self.searchTextField.text ?? ""
                return
            default:
                break
        }
    }
}

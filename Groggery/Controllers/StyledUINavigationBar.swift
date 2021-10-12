import UIKit

/// #StyledUINavigationController
///
/// Used in storyboards by all screens to override default iOS navigation bar
class StyledUINavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.shadowImage = UIImage.colorForNavBar(color: UIColor(named: "EdgeHighlight")!)
        self.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor(named: "Base")!), for: .default)
    }
}

import UIKit

/// #TabBarController
class TabBarController: UITabBarController {
    private static var INITIAL_TAB_INDEX = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.selectedIndex = TabBarController.INITIAL_TAB_INDEX
        self.setSelectedTabBarItemAppearance()
    }

    private func setSelectedTabBarItemAppearance() {
        let tabBarItemsAppearance = UITabBarAppearance();

        tabBarItemsAppearance.shadowImage = UIImage.colorForNavBar(color: UIColor(named: "EdgeHighlight")!)
        tabBarItemsAppearance.backgroundColor = UIColor(named: "Base")
        tabBarItemsAppearance.backgroundImage = UIImage.colorForNavBar(color: UIColor(named: "Base")!)

        tabBarItemsAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(named: "ButtonGrey")
        tabBarItemsAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "ButtonGrey")!
        ]

        tabBarItemsAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(named: "AccentPink")
        tabBarItemsAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "AccentPink")!
        ]

        self.selectedViewController?.tabBarItem.standardAppearance = tabBarItemsAppearance
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.setSelectedTabBarItemAppearance()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let toIndex = self.viewControllers?.firstIndex(of: viewController) else {
            return false
        }

        self.animateToTab(toIndex: toIndex, fadeOutFromView: false, fadeInToView: false)
        return true
    }
    
    private func animateToTab(toIndex: Int, fadeOutFromView: Bool, fadeInToView: Bool) {
        let toView = self.viewControllers![toIndex].view
        let fromView = self.selectedViewController!.view
        let fromIndex = self.viewControllers!.firstIndex(of: selectedViewController!)

        guard fromIndex != toIndex else {
            return
        }

        // Add the toView to the tab bar view
        fromView!.superview!.addSubview(toView!)

        // Position toView off screen (to the left/right of fromView)
        let screenWidth = UIScreen.main.bounds.width
        let scrollRight = toIndex > fromIndex!;
        let offset = (scrollRight ? screenWidth : -screenWidth)
        toView!.center = CGPoint(x: fromView!.center.x + offset, y: toView!.center.y)

        // Disable interaction during animation
        view.isUserInteractionEnabled = false
        if fadeInToView { toView!.alpha = 0.1 }
        
        let animations = {
            if fadeInToView { toView!.alpha = 1.0 }
            if fadeOutFromView { fromView!.alpha = 0.0 }
            toView!.center   = CGPoint(x: toView!.center.x - offset, y: toView!.center.y);
            fromView!.center = CGPoint(x: fromView!.center.x - offset, y: fromView!.center.y);
        }
        let completion: (Bool) -> Void = { _ in
            fromView!.removeFromSuperview()
            self.selectedIndex = toIndex
            self.view.isUserInteractionEnabled = true
        }

        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.curveEaseOut],
            animations: animations,
            completion: completion
        )
    }
}

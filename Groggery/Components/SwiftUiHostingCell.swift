import SwiftUI
import Foundation

/// #SwiftUiHostingTableViewCell
/// 
/// Allows SwiftUI views to be used as table cells in a UITableView.
///
/// Usage:
///     1. Register this class with the UITableView it will be used with
///     2. Call the below .host() function before returning the cell in UITableView.cellForRowAt
///
/// https://www.hackingwithswift.com/articles/140/the-auto-layout-cheat-sheet
/// https://stackoverflow.com/questions/57616494/how-to-use-a-swiftui-view-in-place-of-table-view-cell
///
class SwiftUiHostingTableViewCell<SwiftUIView: View>: UITableViewCell {
    private weak var controller: UIHostingController<SwiftUIView>?

    func host(_ swiftUIView: SwiftUIView, parent: UIViewController) {
        if let controller = controller {
            controller.rootView = swiftUIView
            controller.view.layoutIfNeeded()
        } else {
            let swiftUiHostingTableCellViewController = UIHostingController(rootView: swiftUIView)
            self.controller = swiftUiHostingTableCellViewController
            swiftUiHostingTableCellViewController.view.backgroundColor = .clear
            
            self.layoutIfNeeded()
            
            parent.addChild(swiftUiHostingTableCellViewController)
            self.contentView.addSubview(swiftUiHostingTableCellViewController.view)
            swiftUiHostingTableCellViewController.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                swiftUiHostingTableCellViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                swiftUiHostingTableCellViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                swiftUiHostingTableCellViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                swiftUiHostingTableCellViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ])
        
            swiftUiHostingTableCellViewController.didMove(toParent: parent)
            swiftUiHostingTableCellViewController.view.layoutIfNeeded()
        }
    }
}

/// #SwiftUiHostingCollectionViewCell
///
/// Allows SwiftUI views to be used as cells in a UICollectionView
///
/// Usage:
///     1. Register this class with the UICollectionView it will be used with
///     2. Call the below .host() function before returning the cell in UICollectionView.cellForItemAt
///
/// https://www.hackingwithswift.com/articles/140/the-auto-layout-cheat-sheet
/// https://stackoverflow.com/questions/57616494/how-to-use-a-swiftui-view-in-place-of-table-view-cell
///
class SwiftUiHostingCollectionViewCell<SwiftUIView: View>: UICollectionViewCell {
    private weak var controller: UIHostingController<SwiftUIView>?

    func host(_ swiftUIView: SwiftUIView, parent: UIViewController) {
        if let controller = controller {
            controller.rootView = swiftUIView
            controller.view.layoutIfNeeded()
        } else {
            let swiftUiHostingCollectionCellViewController = UIHostingController(rootView: swiftUIView)
            self.controller = swiftUiHostingCollectionCellViewController
            swiftUiHostingCollectionCellViewController.view.backgroundColor = .clear
            
            self.layoutIfNeeded()
            
            parent.addChild(swiftUiHostingCollectionCellViewController)
            self.contentView.addSubview(swiftUiHostingCollectionCellViewController.view)
            swiftUiHostingCollectionCellViewController.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                swiftUiHostingCollectionCellViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                swiftUiHostingCollectionCellViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                swiftUiHostingCollectionCellViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                swiftUiHostingCollectionCellViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ])
        
            swiftUiHostingCollectionCellViewController.didMove(toParent: parent)
            swiftUiHostingCollectionCellViewController.view.layoutIfNeeded()
        }
    }
}

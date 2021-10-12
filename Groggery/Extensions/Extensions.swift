import UIKit
import Foundation

/// #Extensions/UIImage
///
/// Source: https://stackoverflow.com/a/41590406/3989939
extension UIImage {
    class func colorForNavBar(color: UIColor) -> UIImage {
        // Or if you need a thinner border: let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.5)
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context!.setFillColor(color.cgColor)
        context!.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}

/// #Extensions/URLSession
///
/// Defines helper methods to abstract away some boilerplate code when making network requests
extension URLSession {
    func request<T: Codable>(_ request: URLRequest, completion: @escaping (Result<T, Error>) -> ()) {
        self.dataTask(with: request, semaphore: nil, completion: completion)
    }
    
    func blockingRequest<T: Codable>(_ request: URLRequest, completion: @escaping (Result<T, Error>) -> ()) {
        let semaphore = DispatchSemaphore.init(value: 0) // TODO: Look into async/await
        self.dataTask(with: request, semaphore: semaphore, completion: completion)
        semaphore.wait()
    }
    
    private func dataTask<T: Codable>(with: URLRequest, semaphore: DispatchSemaphore?, completion: @escaping (Result<T, Error>) -> ()) {
        let task = self.dataTask(with: with) { data, res, err in
            defer { semaphore?.signal() }
            
            guard err == nil else {
                return completion(.failure(err!))
            }
            guard let rawData = data else {
                return assertionFailure("URLSession.request: If there is no error, we should have data")
            }
            
            do {
                let json = try JSONDecoder().decode(T.self, from: rawData)
                return completion(.success(json))
            } catch let decodeError as NSError {
                print(decodeError)
                return completion(.failure(decodeError))
            }
        }
        
        task.resume()
    }
}

/// #Extensions/UIFont
///
/// Defines methods to help us modify system fonts (like making them italic etc)
extension UIFont {
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
    
    func withAttributes(attributes: [UIFontDescriptor.AttributeName: Any]) -> UIFont {
        let descriptor = self.fontDescriptor.addingAttributes(attributes)
        return UIFont(descriptor: descriptor, size: 0) // size 0 means keep the size as it is
    }
    
    func fontWeightMedium() -> UIFont {
        let traits = [UIFontDescriptor.TraitKey.weight: UIFont.Weight.medium.rawValue]
        return self.withAttributes(attributes: [UIFontDescriptor.AttributeName.traits: traits])
    }
    
    func fontStyleItalic() -> UIFont {
        return self.withTraits(traits: .traitItalic)
    }
}

/// #Extensions/UILabel
extension UILabel {
    
    /// ##Extensions/UILabel/estimateHeight
    ///
    /// Estimates the rendered height of this UILabel based on its text. Useful when setting height of scroll views etc.
    func estimateHeight() -> CGFloat? {
        
        let size = CGSize(width: self.bounds.size.width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes: [NSAttributedString.Key : UIFont] = [NSAttributedString.Key.font: self.font]
        
        return self.text?.boundingRect(with: size, options: options, attributes: attributes, context: nil).height
    }
}

/// #Extensions/UIStackView
extension UIStackView {
    func clearSubviews() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// #Extensions/UIStackView/leftAlignSubviews
    ///
    /// Forces the subviews of a horizontal stack view to be left-aligned
    func leftAlignSubviews() {
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.addArrangedSubview(spacerView)
    }
}

/// #Extensions/Array
///
/// Provides helper methods to create an array from various other built-in data structures
extension Array {
    static func fromTuple<Tuple> (_ tuple: Tuple) -> [Element]? {
        let val = Array<Element>.fromTupleOptional(tuple)
        return val.allSatisfy({ $0 != nil }) ? val.map { $0! } : nil
    }
    static func fromTupleOptional<Tuple> (_ tuple: Tuple) -> [Element?] {
        return Mirror(reflecting: tuple)
            .children
            .filter { child in
                (child.label ?? "x").allSatisfy { char in ".1234567890".contains(char) }
            }.map { $0.value as? Element }
    }
}

/// #Extensions/UIImageView
extension UIImageView{

    /// ##UIImageView/setImage
    ///
    /// Optionally defines a fade-in animation when setting an image
    func setImage(_ image: UIImage?, animated: Bool = true) {
        UIView.transition(
            with: self,
            duration: animated ? 0.3 : 0.0,
            options: .transitionCrossDissolve,
            animations: { self.image = image },
            completion: nil
        )
    }
}

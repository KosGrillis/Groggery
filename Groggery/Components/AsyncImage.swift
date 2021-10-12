import SwiftUI
import Foundation

/// #AsyncImage
///
/// SwiftUI view for displaying an image fetched from a url.
/// Sources:
/// https://devsday.ru/blog/details/13619
/// https://www.hackingwithswift.com/forums/swiftui/loading-images/3292
struct AsyncImage<PlaceholderContent: View>: View {
    let placeholderContent: () -> PlaceholderContent
    @ObservedObject private var loader: Loader

    init(url: String, placeholderContent: @escaping () -> PlaceholderContent) {
        _loader = ObservedObject(wrappedValue: Loader(url: url))
        self.placeholderContent = placeholderContent
    }
    
    var body: some View {
        ZStack {
            if (loader.state == .loading || loader.state == .failure) {
                self.placeholderContent()
            } else if let loadedImage = UIImage(data: loader.data) {
                Image(uiImage: loadedImage)
                    .resizable()
                    // .transition(.opacity)
            } else {
                self.placeholderContent()
            }
        }
        // .animation(.easeIn)
    }
    
    /// ##AsyncImage/LoadState
    ///
    /// Defines the three states that AsyncImage can be in
    private enum LoadState {
        case loading, success, failure
    }

    /// ##AsyncImage/Loader
    /// 
    /// Private helper class encapsulates fetching the image using URLSession
    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading
        private var cache: ImageCache = Environment(\.imageCache).wrappedValue

        init(url: String) {            
            guard let parsedURL = URL(string: url) else {
                fatalError("Invalid URL: \(url)")
            }
            
            if let cachedImage = self.cache[parsedURL] {
                print("Retrieving image from cache")
                self.data = cachedImage.pngData()!
                self.state = .success
                return
            }

            URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                    
                    let imageToCache = UIImage(data: data)
                    imageToCache.map { self.cache[parsedURL] = $0 }
                } else {
                    self.state = .failure
                }

                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }
}

/// ##AsyncImage/ImageCache
///
/// Lightweight wrapper around NSCache encapsulates caching images to prevent unneccessary duplicate requests by AsyncImage
struct ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

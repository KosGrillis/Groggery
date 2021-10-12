import SwiftUI

/// #Environment
///
/// Define shared global dependencies for SwiftUI environment. These are accessible by any SwiftUI view.

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = ImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}

import SwiftUI

/// #CollectionViewCocktailCell
///
/// SwiftUI view defining the content of an individual collection item on the favourites screen
struct CollectionViewCocktailCell: View {
    static var IDENTIFIER = "collectionViewCocktailCell"
    static var PADDING_BOTTOM = CGFloat(56)
    
    var cocktail: Cocktail
    var parentWidth: CGFloat
    
    private var SubheadingText: Text {
        guard let ingredients = self.cocktail.ingredientsArrays else {
            return Text("")
        }
        if (ingredients.count == 0) {
            return Text("")
        }
        return Text("\(ingredients[0][0]) + \(ingredients.count - 1) more ingredients")
    }
    private var PlaceholderImage: Image {
        let imageAssetNames = ["cocktail1", "cocktail2", "cocktail3", "cocktail4", "cocktail5"]
        return Image(imageAssetNames.randomElement()!)
    }
    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/) {
                if let thumbnailUrlString = self.cocktail.thumbnailUrlString {
                    AsyncImage(url: thumbnailUrlString) {
                        self.PlaceholderImage
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 68, height: 68, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .foregroundColor(Color("TextPlaceholder"))
                    }
                    .frame(width: self.parentWidth, height: self.parentWidth, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(self.cocktail.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundColor(Color("TextStandard"))
                    SubheadingText
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundColor(Color("TextTertiary"))
                        .padding(.top, 4)
                }
            }
        }
        .frame(width: parentWidth, height: parentWidth + CollectionViewCocktailCell.PADDING_BOTTOM, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

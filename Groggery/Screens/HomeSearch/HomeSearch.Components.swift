import SwiftUI

/// #TableViewCocktailCell
///
/// SwiftUI view defining the content of an individual row item on the search results screen
struct TableViewCocktailCell: View {
    static var IDENTIFIER = "tableViewCocktailCell"
    private static var PADDING = EdgeInsets(top: 12, leading: 4, bottom: 12, trailing: 12)
    private static var IMAGE_SIZE: CGFloat = 120
    
    var cocktail: Cocktail
    
    private var PlaceholderImage: Image {
        let imageAssetNames = ["cocktail1", "cocktail2", "cocktail3", "cocktail4", "cocktail5"]
        return Image(imageAssetNames.randomElement()!)
    }
    
    var body: some View {
        Group {
            HStack(alignment: .top, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/) {
                if let thumbnailUrlString = self.cocktail.thumbnailUrlString {
                    AsyncImage(url: thumbnailUrlString) {
                        self.PlaceholderImage
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 68, height: 68, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .foregroundColor(Color("TextPlaceholder"))
                    }
                    .frame(width: TableViewCocktailCell.IMAGE_SIZE, height: TableViewCocktailCell.IMAGE_SIZE, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
                VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/) {
                    Text(self.cocktail.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(Color("TextStandard"))
                }
                .padding(TableViewCocktailCell.PADDING)
            }
        }
        .frame(
          minWidth: 0,
          maxWidth: .infinity,
          minHeight: 0,
          maxHeight: .infinity,
          alignment: .topLeading
        )
        .background(Color("Base"))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("BaseAlt")))
    }
}

/// #TableViewCountCell
///
struct TableViewCountCell: View {
    static var IDENTIFIER = "tableViewCountCell"
    
    var count: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(self.count) results found")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

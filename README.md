#  Groggery

Cocktail search and discovery application for iOS, written in Swift using UIKit and SwiftUI. Uses [TheCocktailDB](https://www.thecocktaildb.com/) as its data source.

## Features

- [x] Search for cocktails by name, single ingredient, multiple ingredients
- [x] Present image, instructions, ingredients, and basic tags via dedicated screen for individual cocktails
- [x] Save/remove cocktails as favourites via a dedicated screen
- [x] Loading/placeholder states for cocktail images
- [ ] Mark "new" and "popular" cocktails using tags on their dedicated screen
- [ ] Discover similar cocktails by tapping tags on any cocktail 
- [ ] Discover similar cocktails by tapping ingredients on any cocktail
- [ ] Seach for "new" and "popular" cocktails, further filtered by name, single ingredient, multiple ingredients etc
- [ ] Manage "on-hand" ingredients (rough idea - needs thought)
- [ ] Empty state for search results
- [ ] Empty state for favourites

## API

Replace `api.key` in `Groggery/Models/API` with your CocktailDB API key.

## Style Guide

Non-existent. Aspire to https://google.github.io/swift/

## Assets

### Icons

Source [@pathlord](https://thenounproject.com/pathlord/) of [The Noun Project](https://thenounproject.com/pathlord/collection/cocktails/).

### Colors

Asset colors are named per their intended use:

| Asset name | Hex value | Color name | Source |
| --- | ---  | ---   | ---  |
| AccentPink | #FF7CD6 | Pantone / PMS 906 C  | [Colorpedia](https://encycolorpedia.com/ff7cd6) |
| AccentYellow | #FDB825 | Citadel / Averland Sunset | [Colorpedia](https://encycolorpedia.com/fdb825) [Games Workshop](https://www.games-workshop.com/en-AU/Base-Averland-Sunset-2019) |
| Base | #363D4A | Sigma / Mistic Purple | [Colorpedia](https://encycolorpedia.com/363f4a) |
| BaseAlt | #393E47 | Natural Color System / NCS S 7010-R90B | [Colorpedia](https://encycolorpedia.com/393e47) |
| ButtonGrey | #86909F | Pantone / PMS 4135 UP | [Colorpedia](https://encycolorpedia.com/86909f) |
| EdgeHighlight | #444C57 | Benjamin Moore / Hale Navy | [Colorpedia](https://encycolorpedia.com/444c57) |
| Primer | #2F3540 | Behr / Blackbird | [Colorpedia](https://encycolorpedia.com/2f3540) |
| Shade | #2F3640 | Custom - shade of Primer above | N/A |
| TextPlaceholder | #6D7888 | RAL / 270 50 10 | [Colorpedia](https://encycolorpedia.com/6d7888) |
| TextSecondary | #E3E4E5 | Glidden / Windswept Beach | [Colorpedia](https://encycolorpedia.com/e3e4e5) |
| TextStandard (primary) | #FEFFFD | Brighto Paints / Sleepy Pink | [Colorpedia](https://encycolorpedia.com/fefffd) |
| TextTertiary | #9DA4AD | Earthpaint / Pebble Walk | [Colorpedia](https://encycolorpedia.com/9da4ad) |


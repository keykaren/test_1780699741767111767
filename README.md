[![Build Status](https://github.com/spacenation/swiftui-grid/workflows/ci/badge.svg)](https://github.com/spacenation/swiftui-grid/actions)

## SwiftUI Grid
SwiftUI Grid view layout with custom styles.

## Features
- ZStack based layout
- Vertical and horizontal scrolling
- Supports all apple platforms
- Custom styles (ModularGridStyle, StaggeredGridStyle)
- SwiftUI code patterns (StyleStructs, EnvironmentValues, ViewBuilder)
- Active development for production apps

Open `GridDemo.xcodeproj` for more examples for iOS, macOS, watchOS and tvOS

## Styles

### ModularGridStyle (Default)
<center>
<img src="Resources/modularGrid.png"/>
</center>

```swift
ScrollView {
    Grid(colors) {
        Rectangle()
            .foregroundColor($0)
    }
}
.gridStyle(
    ModularGridStyle(columns: .min(100), rows: .fixed(100))
)
```

### StaggeredGridStyle

<center>
<img src="Resources/staggeredGrid.png"/>
</center>

```swift
ScrollView {
    Grid(1...69, id: \.self) { index in
        Image("\(index)")
            .resizable()
            .scaledToFit()
    }
}
.gridStyle(
    StaggeredGridStyle(.horizontal, tracks: 8, spacing: 4)
)
```

## Spacing

Both built-in styles can configure spacing across tracks independently from spacing along each track:

```swift
// Vertical: 24 points between columns and 8 points between rows/items.
ModularGridStyle(
    .vertical,
    columns: .min(100),
    rows: .fixed(80),
    crossAxisSpacing: 24,
    mainAxisSpacing: 8
)

// Horizontal: 24 points between rows and 8 points between columns/items.
ModularGridStyle(
    .horizontal,
    columns: .fixed(80),
    rows: .min(100),
    crossAxisSpacing: 24,
    mainAxisSpacing: 8
)

// Vertical masonry: gaps between columns and between items in each column.
StaggeredGridStyle(
    .vertical,
    tracks: .min(100),
    crossAxisSpacing: 16,
    mainAxisSpacing: 6
)

// Horizontal masonry: gaps between rows and between items in each row.
StaggeredGridStyle(
    .horizontal,
    tracks: 4,
    crossAxisSpacing: 16,
    mainAxisSpacing: 6
)
```

For a vertical grid, `crossAxisSpacing` separates columns and `mainAxisSpacing` separates successive items vertically. For a horizontal grid, they separate rows and successive items horizontally. Changing `axis` reinterprets those values for the new orientation; it does not swap them.

The existing `spacing:` initializer argument is the uniform shorthand and sets both directions. The legacy `spacing` property reads `crossAxisSpacing`; assigning it updates both `crossAxisSpacing` and `mainAxisSpacing`. Assigning either independent property changes only that direction.

All spacing is between tracks or items. It does not add padding around the grid or trailing spacing after the last item. Apply SwiftUI's `padding` modifier separately when exterior space is wanted.

## Tracks
Tracks setting allows you to customize grid behaviour to your specific use-case. Both Modular and Staggered grid use tracks value to calculate layout. In Modular layout both columns and rows are tracks.

```swift
public enum Tracks: Hashable {
    case count(Int)
    case fixed(CGFloat)
    case min(CGFloat)
}
```

### Count
Grid is split into equal fractions of size provided by a parent view.

```swift
ModularGridStyle(columns: 3, rows: 3)
StaggeredGridStyle(tracks: 8)
```

### Fixed
Item size is fixed to a specific width or height.
```swift
ModularGridStyle(columns: .fixed(100), rows: .fixed(100))
StaggeredGridStyle(tracks: .fixed(100))
```

### Min
Autolayout respecting a min item width or height.
```swift
ModularGridStyle(columns: .min(100), rows: .fixed(100))
StaggeredGridStyle(tracks: .min(100))
```

## Preferences
Get an item's size and position by the same ID used by `Grid`:

```swift
struct CardsView: View {
    @State private var selection: Int?

    var body: some View {
        ScrollView {
            Grid(0..<100) { number in
                Card(title: "\(number)")
                    .onTapGesture {
                        self.selection = number
                    }
            }
            .padding()
            .overlayPreferenceValue(GridItemBoundsByIDPreferencesKey.self) { preferences in
                self.selectionOverlay(for: preferences)
            }
        }
    }

    private func selectionOverlay(for preferences: GridItemBoundsPreferences) -> AnyView {
        guard let selection = self.selection,
              let bounds = preferences[id: selection] else {
            return AnyView(EmptyView())
        }

        return AnyView(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(lineWidth: 4)
                .foregroundColor(.white)
                .frame(width: bounds.width, height: bounds.height)
                .position(x: bounds.midX, y: bounds.midY)
                .animation(.linear)
        )
    }
}
```

`GridItemBoundsByIDPreferencesKey` initially contains no items while the grid is being measured. Its ID subscript also returns `nil` when an item is missing or removed, so keep selections optional and only draw an overlay when bounds exist. A measured zero-sized item is present and returns `.some(.zero)`.

Every preference contribution is available in `preferences.items`. If the same ID is contributed more than once (for example, by sibling or nested grids), `preferences[id:]` returns `nil` because the result is ambiguous. Use `preferences.allBounds(for:)` to inspect every matching rectangle in contribution order, or attach the preference reader closer to one grid.

The original `GridItemBoundsPreferencesKey` remains available for source compatibility. It returns a positional `[CGRect]` in grid contribution order, but does not preserve item IDs.

## SDKs
- iOS 13.1+
- Mac Catalyst 13.1+
- macOS 10.15+
- watchOS 6+
- Xcode 11.0+

## Roadmap
- Items span
- 'CSS Grid'-like features

## Code Contributions
Feel free to contribute via fork/pull request to master branch. If you want to request a feature or report a bug please start a new issue.

## Coffee Contributions
If you find this project useful please consider becoming my GitHub sponsor.

import SwiftUI

/// Staggered `Grid` style.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct StaggeredGridStyle: GridStyle {
    public var tracks: Tracks
    public var axis: Axis
    public var crossAxisSpacing: CGFloat
    public var mainAxisSpacing: CGFloat
    public var spacing: CGFloat {
        get {
            crossAxisSpacing
        }
        set {
            crossAxisSpacing = newValue
            mainAxisSpacing = newValue
        }
    }
    
    public var autoWidth: Bool {
        axis == .vertical
    }
    public var autoHeight: Bool {
        axis == .horizontal
    }

    public init(_ axis: Axis = .vertical, tracks: Tracks, spacing: CGFloat = 8) {
        self.init(
            axis,
            tracks: tracks,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing
        )
    }

    public init(
        _ axis: Axis = .vertical,
        tracks: Tracks,
        crossAxisSpacing: CGFloat,
        mainAxisSpacing: CGFloat
    ) {
        self.tracks = tracks
        self.axis = axis
        self.crossAxisSpacing = crossAxisSpacing
        self.mainAxisSpacing = mainAxisSpacing
    }

    public func transform(preferences: inout GridPreferences, in size: CGSize) {
        let availableCrossAxisLength = self.axis == .vertical ? size.width : size.height
        let computedTracksCount = tracksCount(
            tracks: self.tracks,
            spacing: self.crossAxisSpacing,
            availableLength: availableCrossAxisLength
        )
        let crossAxisItemLength = itemLength(
            tracks: self.tracks,
            spacing: self.crossAxisSpacing,
            availableLength: availableCrossAxisLength
        )

        preferences = layoutPreferences(
            tracks: computedTracksCount,
            crossAxisSpacing: self.crossAxisSpacing,
            mainAxisSpacing: self.mainAxisSpacing,
            axis: self.axis,
            crossAxisItemLength: crossAxisItemLength,
            preferences: preferences
        )
    }
    
    private func layoutPreferences(
        tracks: Int,
        crossAxisSpacing: CGFloat,
        mainAxisSpacing: CGFloat,
        axis: Axis,
        crossAxisItemLength: CGFloat,
        preferences: GridPreferences
    ) -> GridPreferences {
        var tracksLengths = Array(repeating: CGFloat(0.0), count: tracks)
        var newPreferences: GridPreferences = GridPreferences(items: [])
        
        preferences.items.forEach { preference in
            if let minValue = tracksLengths.min(), let indexMin = tracksLengths.firstIndex(of: minValue) {
                let itemSizeWidth = axis == .vertical ? crossAxisItemLength : preference.bounds.size.width
                let itemSizeHeight = axis == .vertical ? preference.bounds.size.height : crossAxisItemLength
                let width = axis == .vertical ?
                    itemSizeWidth * CGFloat(indexMin) + CGFloat(indexMin) * crossAxisSpacing :
                    tracksLengths[indexMin]
                let height = axis == .vertical ?
                    tracksLengths[indexMin] :
                    itemSizeHeight * CGFloat(indexMin) + CGFloat(indexMin) * crossAxisSpacing
        
                let origin = CGPoint(x: width, y: height)
                tracksLengths[indexMin] += (axis == .vertical ? itemSizeHeight : itemSizeWidth) + mainAxisSpacing
                
                newPreferences.merge(with:
                    GridPreferences(items: [GridPreferences.Item(
                        id: preference.id,
                        bounds: CGRect(origin: origin, size: CGSize(width: itemSizeWidth, height: itemSizeHeight))
                    )])
                )
            }
        }

        return newPreferences
    }
}

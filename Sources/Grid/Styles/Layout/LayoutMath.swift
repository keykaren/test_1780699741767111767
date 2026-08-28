import SwiftUI

func itemLength(tracks: Tracks, spacing: CGFloat, availableLength: CGFloat) -> CGFloat {
    switch tracks {
    case .count(let count):
        return itemLength(tracksCount: count, spacing: spacing, availableLength: availableLength)
    case .fixed(let length):
        return length
    case .min:
        let suggestedTracksCount = tracksCount(tracks: tracks, spacing: spacing, availableLength: availableLength)
        return itemLength(tracksCount: suggestedTracksCount, spacing: spacing, availableLength: availableLength)
    }
}

func tracksCount(tracks: Tracks, spacing: CGFloat, availableLength: CGFloat) -> Int {
    switch tracks {
    case .count(let count):
        return count
    case .fixed(let length):
        precondition(length > 0, "Minimum track length should be greated than 0")
        return adaptiveTracksCount(
            minimumLength: length,
            spacing: spacing,
            availableLength: availableLength
        )
    case .min(let length):
        precondition(length > 0, "Minimum track length should be greated than 0")
        return adaptiveTracksCount(
            minimumLength: length,
            spacing: spacing,
            availableLength: availableLength
        )
    }
}

private func adaptiveTracksCount(minimumLength: CGFloat, spacing: CGFloat, availableLength: CGFloat) -> Int {
    guard availableLength >= minimumLength else {
        return 1
    }

    // Negative spacing controls overlap and sizing, but must not create extra
    // adaptive tracks that would not fit without that overlap.
    let countingSpacing = max(spacing, 0)
    let additionalTracks = Int((availableLength - minimumLength) / (minimumLength + countingSpacing))
    return additionalTracks + 1
}

func itemLength(tracksCount: Int, spacing: CGFloat, availableLength: CGFloat) -> CGFloat {
    let width = availableLength - (spacing * (CGFloat(tracksCount) - 1))
    return (width / CGFloat(tracksCount))
}

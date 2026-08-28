import SwiftUI

func itemLength(tracks: Tracks, spacing: CGFloat, availableLength: CGFloat) -> CGFloat {
    switch tracks {
    case .count(let count):
        return itemLength(tracksCount: count, spacing: spacing, availableLength: availableLength)
    case .fixed(let length):
        return length
    case .min(let minimumLength):
        let suggestedTracksCount = tracksCount(tracks: tracks, spacing: spacing, availableLength: availableLength)
        let expandedLength = itemLength(
            tracksCount: suggestedTracksCount,
            spacing: spacing,
            availableLength: availableLength
        )
        if availableLength >= minimumLength {
            return max(expandedLength, minimumLength)
        }
        return expandedLength
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
    var count = additionalTracks + 1

    // The quotient provides a close estimate, but decimal values can round an
    // exact integer down (or a just-below value up). Validate the estimate
    // against the span that will actually be occupied.
    while count > 1 && !adaptiveTracksFit(
        count: count,
        minimumLength: minimumLength,
        spacing: countingSpacing,
        availableLength: availableLength
    ) {
        count -= 1
    }
    while adaptiveTracksFit(
        count: count + 1,
        minimumLength: minimumLength,
        spacing: countingSpacing,
        availableLength: availableLength
    ) {
        count += 1
    }
    return count
}

private func adaptiveTracksFit(
    count: Int,
    minimumLength: CGFloat,
    spacing: CGFloat,
    availableLength: CGFloat
) -> Bool {
    let span = adaptiveTracksSpan(
        count: count,
        minimumLength: minimumLength,
        spacing: spacing
    )
    guard span == availableLength,
          count > 1,
          availableLength.rounded() == availableLength,
          minimumLength.rounded() == minimumLength else {
        return span <= availableLength
    }

    // Adding a one-ULP spacing increase to a much larger integral track span
    // can round back to the exact boundary. Compare the spacing to the
    // remaining capacity directly so that increase does not create a track.
    let maximumSpacing = (
        availableLength - CGFloat(count) * minimumLength
    ) / CGFloat(count - 1)
    return spacing <= maximumSpacing
}

private func adaptiveTracksSpan(count: Int, minimumLength: CGFloat, spacing: CGFloat) -> CGFloat {
    return CGFloat(count) * minimumLength + CGFloat(count - 1) * spacing
}

func itemLength(tracksCount: Int, spacing: CGFloat, availableLength: CGFloat) -> CGFloat {
    let width = availableLength - (spacing * (CGFloat(tracksCount) - 1))
    return (width / CGFloat(tracksCount))
}

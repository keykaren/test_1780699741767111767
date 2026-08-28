import SwiftUI
import Grid

struct StaggeredGridSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var style: StaggeredGridStyle
    
    @State var tracksCount: Int = 3
    @State var tracksFixed: CGFloat = 150
    @State var tracksMin: CGFloat = 100.0
    
    var body: some View {
        VStack(spacing: 16) {
            Picker(selection: self.$style.axis, label: Text("Axis")) {
                Text("Vertical")
                    .tag(Axis.vertical)
                Text("Horizontal")
                    .tag(Axis.horizontal)
            }
            Picker(selection: self.$style.tracks, label: Text("Tracks")) {
                Text("Count (\(self.tracksCount))")
                    .tag(Tracks.count(self.tracksCount))
                Text("Fixed (\(Int(self.tracksFixed)))")
                    .tag(Tracks.fixed(self.tracksFixed))
                Text("Min (\(Int(self.tracksMin)))")
                    .tag(Tracks.min(self.tracksMin))
            }

            HStack {
                Text("Cross-axis spacing (\(Int(self.style.crossAxisSpacing)))")
                Slider(value: self.$style.crossAxisSpacing, in: 0...32)
            }

            HStack {
                Text("Main-axis spacing (\(Int(self.style.mainAxisSpacing)))")
                Slider(value: self.$style.mainAxisSpacing, in: 0...32)
            }
            
            Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                Text("Close")
            }
        }
        .padding()
        .pickerStyle(
            SegmentedPickerStyle()
        )
    }
}

struct StaggeredGridSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        StaggeredGridSettingsView(style: .constant(StaggeredGridStyle(tracks: 3)))
    }
}

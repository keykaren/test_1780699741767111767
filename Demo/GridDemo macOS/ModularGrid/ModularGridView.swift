import SwiftUI
import Grid

struct ModularGridView: View {
    @State var selection: Item.ID? = nil
    @State var items: [Item] = (0...100).map { Item(number: $0) }
    @State var showSettings: Bool = false
    @State var style = ModularGridStyle(columns: .min(100), rows: .fixed(100))
    
    var body: some View {
        VStack(alignment: .trailing) {
            Button(action: { self.showSettings = true }) {
                Text("Settings")
            }
            ScrollView(style.axes) {
                Grid(items) { item in
                    Card(title: "\(item.number)", color: item.color)
                        .onTapGesture {
                            self.selection = item.id
                        }
                }
                .overlayPreferenceValue(GridItemBoundsByIDPreferencesKey.self) { preferences in
                    if let selection = self.selection, let bounds = preferences[id: selection] {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(lineWidth: 4)
                            .foregroundColor(.white)
                            .frame(width: bounds.width, height: bounds.height)
                            .position(x: bounds.midX, y: bounds.midY)
                            .animation(.linear)
                    }
                }
                .padding(16)
            }

        }
        .sheet(isPresented: self.$showSettings) {
            ModularGridSettingsView(style: self.$style)
        }
        .gridStyle(
            self.style
        )
    }
}

struct ModularGridView_Previews: PreviewProvider {
    static var previews: some View {
        ModularGridView()
    }
}

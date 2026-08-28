import SwiftUI
import Grid

struct ModularGridView: View {
    @State var selection: Item.ID? = nil
    @State var items: [Item] = (0...100).map { Item(number: $0) }
    
    var body: some View {
        ScrollView {
            Grid(items) { item in
                Card(title: "\(item.number)", color: item.color)
                    .focusable(true) { focus in
                        if focus {
                           self.selection = item.id
                        }
                    }
            }
        }
        .overlayPreferenceValue(GridItemBoundsByIDPreferencesKey.self) { preferences in
            self.selectionOverlay(for: preferences)
        }
        .gridStyle(
            ModularGridStyle(columns: .min(300), rows: .fixed(100))
        )
        .navigationBarTitle("Modular Grid")
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

struct ModularGridView_Previews: PreviewProvider {
    static var previews: some View {
        ModularGridView()
    }
}

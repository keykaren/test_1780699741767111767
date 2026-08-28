import SwiftUI
import Grid

struct ModularGridView: View {
    @State var selection: Item.ID? = nil
    @State var items: [Item] = (0...100).map { Item(number: $0) }
    
    var body: some View {
        ScrollView {
            Grid(items) { item in
                Rectangle()
                    .foregroundColor(item.color)
                    .cornerRadius(4)
                    .onTapGesture {
                        self.selection = item.id
                    }
            }
            .overlayPreferenceValue(GridItemBoundsByIDPreferencesKey.self) { preferences in
                if let selection = self.selection, let bounds = preferences[id: selection] {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(lineWidth: 2)
                        .foregroundColor(.white)
                        .frame(width: bounds.width, height: bounds.height)
                        .position(x: bounds.midX, y: bounds.midY)
                        .animation(.linear)
                }
            }
        }
        .gridStyle(
            ModularGridStyle(columns: .min(32), rows: .min(32), spacing: 4)
        )
    }
}

struct ModularGridView_Previews: PreviewProvider {
    static var previews: some View {
        ModularGridView()
    }
}

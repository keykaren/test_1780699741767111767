import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Grid {
    public init<Data, Item>(_ data: Data, @ViewBuilder item: @escaping (Data.Element) -> Item) where Content == ForEach<Data, Data.Element.ID, Item>, Data : RandomAccessCollection, Item : View, Data.Element : Identifiable {
        self.items = data.map { GridItem(view: AnyView(item($0)), id: AnyHashable($0.id)) }
    }

    public init<Data, ID, Item>(_ data: Data, id: KeyPath<Data.Element, ID>, @ViewBuilder item: @escaping (Data.Element) -> Item) where Content == ForEach<Data, ID, Item>, Data : RandomAccessCollection, ID : Hashable, Item : View {
        self.items = data.map { GridItem(view: AnyView(item($0)), id: AnyHashable($0[keyPath: id])) }
    }

    public init<Item>(_ data: Range<Int>, @ViewBuilder item: @escaping (Int) -> Item) where Content == ForEach<Range<Int>, Int, Item>, Item : View {
        self.items = data.map { GridItem(view: AnyView(item($0)), id: AnyHashable($0)) }
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Grid {
    public init<C0: View, C1: View>(@ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1)> {
        let builtContent = content()
        self.items = [GridItem(view: AnyView(builtContent.value.0), id: AnyHashable(0)),
                      GridItem(view: AnyView(builtContent.value.1), id: AnyHashable(1))]
    }

    public init<C0: View, C1: View, C2: View>(@ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2)> {
        let builtContent = content()
        self.items = [GridItem(view: AnyView(builtContent.value.0), id: AnyHashable(0)),
                      GridItem(view: AnyView(builtContent.value.1), id: AnyHashable(1)),
                      GridItem(view: AnyView(builtContent.value.2), id: AnyHashable(2))]
    }

    public init<C0: View, C1: View, C2: View, C3: View>(@ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2, C3)> {
        let builtContent = content()
        self.items = [GridItem(view: AnyView(builtContent.value.0), id: AnyHashable(0)),
                      GridItem(view: AnyView(builtContent.value.1), id: AnyHashable(1)),
                      GridItem(view: AnyView(builtContent.value.2), id: AnyHashable(2)),
                      GridItem(view: AnyView(builtContent.value.3), id: AnyHashable(3))]
    }

    public init<C0: View, C1: View, C2: View, C3: View, C4: View>(@ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2, C3, C4)> {
        let builtContent = content()
        self.items = [GridItem(view: AnyView(builtContent.value.0), id: AnyHashable(0)),
                      GridItem(view: AnyView(builtContent.value.1), id: AnyHashable(1)),
                      GridItem(view: AnyView(builtContent.value.2), id: AnyHashable(2)),
                      GridItem(view: AnyView(builtContent.value.3), id: AnyHashable(3)),
                      GridItem(view: AnyView(builtContent.value.4), id: AnyHashable(4))]
    }

    public init<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View>(@ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2, C3, C4, C5)> {
        let builtContent = content()
        self.items = [GridItem(view: AnyView(builtContent.value.0), id: AnyHashable(0)),
                      GridItem(view: AnyView(builtContent.value.1), id: AnyHashable(1)),
                      GridItem(view: AnyView(builtContent.value.2), id: AnyHashable(2)),
                      GridItem(view: AnyView(builtContent.value.3), id: AnyHashable(3)),
                      GridItem(view: AnyView(builtContent.value.4), id: AnyHashable(4)),
                      GridItem(view: AnyView(builtContent.value.5), id: AnyHashable(5))]
    }

    public init<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View>(@ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2, C3, C4, C5, C6)> {
        let builtContent = content()
        self.items = [GridItem(view: AnyView(builtContent.value.0), id: AnyHashable(0)),
                      GridItem(view: AnyView(builtContent.value.1), id: AnyHashable(1)),
                      GridItem(view: AnyView(builtContent.value.2), id: AnyHashable(2)),
                      GridItem(view: AnyView(builtContent.value.3), id: AnyHashable(3)),
                      GridItem(view: AnyView(builtContent.value.4), id: AnyHashable(4)),
                      GridItem(view: AnyView(builtContent.value.5), id: AnyHashable(5)),
                      GridItem(view: AnyView(builtContent.value.6), id: AnyHashable(6))]
    }

    public init<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View>(@ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2, C3, C4, C5, C6, C7)> {
        let builtContent = content()
        self.items = [GridItem(view: AnyView(builtContent.value.0), id: AnyHashable(0)),
                      GridItem(view: AnyView(builtContent.value.1), id: AnyHashable(1)),
                      GridItem(view: AnyView(builtContent.value.2), id: AnyHashable(2)),
                      GridItem(view: AnyView(builtContent.value.3), id: AnyHashable(3)),
                      GridItem(view: AnyView(builtContent.value.4), id: AnyHashable(4)),
                      GridItem(view: AnyView(builtContent.value.5), id: AnyHashable(5)),
                      GridItem(view: AnyView(builtContent.value.6), id: AnyHashable(6)),
                      GridItem(view: AnyView(builtContent.value.7), id: AnyHashable(7))]
    }

    public init<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View>(@ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8)> {
        let builtContent = content()
        self.items = [GridItem(view: AnyView(builtContent.value.0), id: AnyHashable(0)),
                      GridItem(view: AnyView(builtContent.value.1), id: AnyHashable(1)),
                      GridItem(view: AnyView(builtContent.value.2), id: AnyHashable(2)),
                      GridItem(view: AnyView(builtContent.value.3), id: AnyHashable(3)),
                      GridItem(view: AnyView(builtContent.value.4), id: AnyHashable(4)),
                      GridItem(view: AnyView(builtContent.value.5), id: AnyHashable(5)),
                      GridItem(view: AnyView(builtContent.value.6), id: AnyHashable(6)),
                      GridItem(view: AnyView(builtContent.value.7), id: AnyHashable(7)),
                      GridItem(view: AnyView(builtContent.value.8), id: AnyHashable(8))]
    }

    public init<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View>(@ViewBuilder content: () -> Content) where Content == TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)> {
        let builtContent = content()
        self.items = [GridItem(view: AnyView(builtContent.value.0), id: AnyHashable(0)),
                      GridItem(view: AnyView(builtContent.value.1), id: AnyHashable(1)),
                      GridItem(view: AnyView(builtContent.value.2), id: AnyHashable(2)),
                      GridItem(view: AnyView(builtContent.value.3), id: AnyHashable(3)),
                      GridItem(view: AnyView(builtContent.value.4), id: AnyHashable(4)),
                      GridItem(view: AnyView(builtContent.value.5), id: AnyHashable(5)),
                      GridItem(view: AnyView(builtContent.value.6), id: AnyHashable(6)),
                      GridItem(view: AnyView(builtContent.value.7), id: AnyHashable(7)),
                      GridItem(view: AnyView(builtContent.value.8), id: AnyHashable(8)),
                      GridItem(view: AnyView(builtContent.value.9), id: AnyHashable(9))]
    }
}

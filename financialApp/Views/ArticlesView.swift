import SwiftUI

struct ArticlesView: View {
    @StateObject private var viewModel = ArticlesViewModel()
    private var circleColor: Color { Color("AccentColor").opacity(0.15) }
        
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Статьи")) {
                    ForEach( viewModel.filteredCategories) { category in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(circleColor)
                                    .frame(width: 32, height: 32)
                                Text(String(category.emoji))
                                    .font(.system(size: 16))
                            }
                            Text(category.name)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .searchable(text: $viewModel.searchText, prompt: "Поиск по статьям")
            .navigationTitle("Мои статьи")
            .task {
                await viewModel.loadAll()
            }
        }
    }
}
#Preview {
    ArticlesView()
}


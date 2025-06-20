import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            
            TransactionsListView(direction: .outcome)
                .tabItem {
                    Image("Expenses"); Text("Расходы")
                }
            
            TransactionsListView(direction: .income)
                .tabItem {
                    Image("Income"); Text("Доходы")
                }
            
            CheckView()
                .tabItem {
                    Image("Checks")
                    Text("Чеки")
                }
            
            ArticlesView()
                .tabItem {
                    Image("Articals")
                    Text("Статьи")
                }
            
            SettingsView()
                .tabItem {
                    Image("Settings")
                    Text("Настройки")
                }
        }
    }
}

#Preview {
    TabBarView()
}


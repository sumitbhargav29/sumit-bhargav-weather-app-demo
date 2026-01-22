import SwiftUI

struct TabContainerView: View {
    @State private var selectedTab: Int = 0
    @StateObject private var selectedCityStore = SelectedCityStore()
    @StateObject private var homeVM: HomeViewModel

    init(homeModel: HomeViewModel) {
        _homeVM = StateObject(wrappedValue: homeModel)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(model: homeVM)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            SearchCityView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)

            RadarView()
                .tabItem {
                    Label("Radar", systemImage: "map")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .environmentObject(selectedCityStore)
    }
}

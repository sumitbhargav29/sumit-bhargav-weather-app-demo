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
                    Label(AppConstants.UI.homeTab, systemImage: AppConstants.Symbols.houseFill)
                }
                .tag(0)
            
            SearchCityView(selectedTab: $selectedTab)
                .tabItem {
                    Label(AppConstants.UI.searchTab, systemImage: AppConstants.Symbols.magnifyingglass)
                }
                .tag(1)
            
            RadarView()
                .tabItem {
                    Label(AppConstants.UI.radarTitle, systemImage: AppConstants.Symbols.map)
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label(AppConstants.UI.settingsTitle, systemImage: AppConstants.Symbols.gearshapeFill)
                }
                .tag(3)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .environmentObject(selectedCityStore)
    }
}


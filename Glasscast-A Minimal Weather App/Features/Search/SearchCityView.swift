//
//  SearchCityView.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 21/01/26.
//

import Foundation
import SwiftUI

struct SearchCityView: View {
    
    // MARK: - Dependencies
    @StateObject private var viewModel: SearchCityViewModel
    
    @EnvironmentObject private var favorites: FavoritesStore
    @EnvironmentObject private var selectedCity: SelectedCityStore
    @Environment(\.container) private var container
    
    @Binding var selectedTab: Int
    
    @FocusState private var isSearchFocused: Bool
    
    private let theme: WeatherTheme = .sunny
    
    // MARK: - Init
    init(selectedTab: Binding<Int>, container: AppContainer? = nil) {
        _selectedTab = selectedTab
        let resolved = container ?? AppContainer()
        _viewModel = StateObject(
            wrappedValue: SearchCityViewModel(container: resolved)
        )
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            WeatherBackground(theme: theme).ignoresSafeArea()
            
            GeometryReader { proxy in
                let safeTop = proxy.safeAreaInsets.top
                let safeBottom = proxy.safeAreaInsets.bottom
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        topBar
                        searchField
                        favoritesSection
                        resultsSection
                        
                        if let error = favorites.errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red.opacity(0.9))
                                .padding(.top, 8)
                        }
                    }
                    .padding(.top, max(24, safeTop + 8))
                    .padding(.bottom, max(24, safeBottom + 8))
                    .frame(maxWidth: 700)
                }
            }
        }
        .task {
            await favorites.load()
        }
        .alert(AppConstants.UI.clearAllAlertTitle, isPresented: $viewModel.showClearAllConfirm) {
            Button(AppConstants.UI.cancel, role: .cancel) {}
            Button(AppConstants.UI.clearAll, role: .destructive) {
                HapticFeedback.success()
                Task { await favorites.clearAll() }
            }
        } message: {
            Text(AppConstants.UI.clearAllAlertMessage)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(AppConstants.UI.searchTitle)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                Text(AppConstants.UI.searchSubtitle)
                    .font(.caption)
                    .opacity(0.65)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .foregroundStyle(.primary)
    }
    
    // MARK: - Search Field
    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: AppConstants.Symbols.magnifyingglass)
            
            TextField(AppConstants.UI.searchPlaceholder, text: $viewModel.query)
                .focused($isSearchFocused)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .onSubmit {
                    Task { await viewModel.search() }
                }
            
            if !viewModel.query.isEmpty {
                Button {
                    HapticFeedback.selection()
                    viewModel.clearSearch()
                } label: {
                    Image(systemName: AppConstants.Symbols.closeCircleFill)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .glassEffect()
        .padding(.horizontal, 16)
    }
    
    // MARK: - Favorites Section
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            
            if favorites.favorites.isEmpty {
                Text(AppConstants.UI.favoritesEmpty)
                    .font(.footnote)
                    .opacity(0.7)
                    .padding(.horizontal, 16)
            } else {
                VStack(spacing: 16) {
                    ForEach(favorites.favorites) { fav in
                        Button {
                            HapticFeedback.light()
                            selectedCity.set(city: fav.city)
                            selectedTab = 0
                        } label: {
                            FavoriteCityRow(
                                city: fav,
                                weather: viewModel.favoriteWeather[fav.id],
                                isLoading: viewModel.loadingFavorites.contains(fav.id),
                                onDelete: {
                                    HapticFeedback.medium()
                                    Task {
                                        await favorites.toggle(
                                            city: fav.city,
                                            country: fav.country
                                        )
                                    }
                                }
                            )
                        }
                        .buttonStyle(.plain)
                        .task {
                            await viewModel.loadWeatherForFavorite(fav)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var headerRow: some View {
        HStack {
            Text(AppConstants.UI.favoritesHeader)
                .font(.caption.weight(.semibold))
                .opacity(0.75)
 
            Spacer()
            
            if favorites.isLoading {
                ProgressView()
            } else {
                Button(AppConstants.UI.sync) {
                    HapticFeedback.medium()
                    Task { await favorites.load() }
                }
            }
            
            if !favorites.favorites.isEmpty {
                Divider().frame(height: 12)
                Button(AppConstants.UI.clearAll) {
                    HapticFeedback.warning()
                    viewModel.showClearAllConfirm = true
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Results Section
    private var resultsSection: some View {
        Group {
            if isSearchFocused && !viewModel.results.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(AppConstants.UI.searchResultsHeader)
                        .font(.caption.weight(.semibold))
                        .opacity(0.75)
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 16) {
                        ForEach(viewModel.results) { city in
                            Button {
                                HapticFeedback.light()
                                selectedCity.set(city: city.name)
                                selectedTab = 0
                            } label: {
                                SearchResultRow(
                                    city: city,
                                    weather: viewModel.weatherCache[city.id],
                                    isFavorite: favorites.isFavorite(city.name) != nil,
                                    isLoading: viewModel.loadingResults.contains(city.id),
                                    onToggleFavorite: {
                                        HapticFeedback.selection()
                                        Task {
                                            await favorites.toggle(
                                                city: city.name,
                                                country: city.country,
                                                lat: city.lat,
                                                lon: city.lon
                                            )
                                        }
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                            .task {
                                await viewModel.loadWeatherForResult(city)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchCityView(selectedTab: .constant(1))
            .environmentObject(FavoritesStore())
            .environment(\.container, AppContainer())
            .environmentObject(SelectedCityStore())
    }
}

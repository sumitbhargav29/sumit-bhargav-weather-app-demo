//
//  SearchCityView.swift
//  Glasscast-A Minimal Weather App
//
//  Created by Sam's Mac on 21/01/26.
//

import Foundation
import SwiftUI
import CoreLocation

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
                            // Use any preloaded favorite weather for instant feel
                            let cached = viewModel.favoriteWeather[fav.id]
                            let coord: CLLocationCoordinate2D? = {
                                if let lat = fav.lat, let lon = fav.lon {
                                    return CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                }
                                return nil
                            }()
                            selectedCity.set(city: fav.city, coordinate: coord, cachedWeather: cached)
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
            
            // SYNC button now always visible; shows inline spinner when loading
            Button {
                HapticFeedback.medium()
                Task { await favorites.load() }
            } label: {
                HStack(spacing: 6) {
                    if favorites.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white) // good in dark; gradient foreground covers light
                    } else {
                        Image(systemName: AppConstants.Symbols.arrowClockwiseCircleFill)
                    }
                    Text(AppConstants.UI.sync)
                }
                .font(.caption.weight(.bold))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            LinearGradient(colors: [.cyan.opacity(0.35), .blue.opacity(0.25)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                                .clipShape(Capsule())
                        )
                        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                )
                .foregroundStyle(LinearGradient(colors: [.cyan, .blue],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing))
                .contentShape(Capsule())
            }
            .buttonStyle(ScaleOnPressStyle())
            .disabled(favorites.isLoading) // avoid spamming; keeps UI same
            
            if !favorites.favorites.isEmpty {
                Divider().frame(height: 12)
                // Enhanced CLEAR ALL button (visual only, same action)
                Button {
                    HapticFeedback.warning()
                    viewModel.showClearAllConfirm = true
                } label: {
                    Label(AppConstants.UI.clearAll, systemImage: AppConstants.Symbols.trashFill)
                        .font(.caption.weight(.bold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    LinearGradient(colors: [.pink.opacity(0.35), .red.opacity(0.28)],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                        .clipShape(Capsule())
                                )
                                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                        )
                        .foregroundStyle(LinearGradient(colors: [.pink, .red],
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing))
                        .contentShape(Capsule())
                }
                .buttonStyle(ScaleOnPressStyle())
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
                                // Pull any cached preview weather if available
                                let cached = viewModel.weatherCache[city.id]
                                selectedCity.set(city: city.name,
                                                 coordinate: CLLocationCoordinate2D(latitude: city.lat, longitude: city.lon),
                                                 cachedWeather: cached)
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

// MARK: - Local interactive button style (press scale)
private struct ScaleOnPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
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

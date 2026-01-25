import SwiftUI

struct SettingsAppearanceModeRow: View {
    @ObservedObject var colorSchemeManager: ColorSchemeManager
    let adaptiveForeground: (_ opacity: Double) -> Color
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: colorSchemeManager.isDarkMode ? AppConstants.Symbols.moonFill : colorSchemeManager.isLightMode ? AppConstants.Symbols.sunMaxFill : AppConstants.Symbols.circleLeftHalfFilled)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(adaptiveForeground(0.9))
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(AppConstants.UI.appearanceMode)
                    .foregroundColor(adaptiveForeground(1.0))
                    .font(.subheadline.bold())
                Text(colorSchemeManager.isDarkMode ? AppConstants.UI.darkMode : colorSchemeManager.isLightMode ? AppConstants.UI.lightMode : AppConstants.UI.systemMode)
                    .font(.caption)
                    .foregroundColor(adaptiveForeground(0.65))
            }
            
            Spacer()
            
            Menu {
                Button {
                    HapticFeedback.light()
                    colorSchemeManager.setLightMode()
                } label: {
                    HStack {
                        Text(AppConstants.UI.lightMode)
                        if colorSchemeManager.isLightMode {
                            Image(systemName: AppConstants.Symbols.checkmark)
                        }
                    }
                }
                
                Button {
                    HapticFeedback.light()
                    colorSchemeManager.setDarkMode()
                } label: {
                    HStack {
                        Text(AppConstants.UI.darkMode)
                        if colorSchemeManager.isDarkMode {
                            Image(systemName: AppConstants.Symbols.checkmark)
                        }
                    }
                }
                
                Button {
                    HapticFeedback.light()
                    colorSchemeManager.setSystemMode()
                } label: {
                    HStack {
                        Text(AppConstants.UI.systemMode)
                        if !colorSchemeManager.isDarkMode && !colorSchemeManager.isLightMode {
                            Image(systemName: AppConstants.Symbols.checkmark)
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(colorSchemeManager.isDarkMode ? AppConstants.UI.darkShort : colorSchemeManager.isLightMode ? AppConstants.UI.lightShort : AppConstants.UI.systemMode)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(adaptiveForeground(0.85))
                    Image(systemName: AppConstants.Symbols.chevronDown)
                        .font(.caption2)
                        .foregroundColor(adaptiveForeground(0.65))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                )
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .glassEffect()
    }
}

 

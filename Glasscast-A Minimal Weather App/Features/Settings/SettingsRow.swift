import SwiftUI

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let adaptiveForeground: (_ opacity: Double) -> Color
    @ViewBuilder var trailing: () -> Trailing
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(adaptiveForeground(0.9))
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(adaptiveForeground(1.0))
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(adaptiveForeground(0.65))
            }
            
            Spacer()
            
            trailing()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .glassEffect()
    }
}
 

import SwiftUI

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let adaptiveForeground: (_ opacity: Double) -> Color
    
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
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.cyan)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .glassEffect()
    }
}
 

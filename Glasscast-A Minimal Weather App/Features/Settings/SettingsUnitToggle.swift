import SwiftUI

struct SettingsUnitToggle: View {
    @Binding var isOn: Bool
    let onLabel: String
    let offLabel: String
    let adaptiveForeground: (_ opacity: Double) -> Color
    
    var body: some View {
        VStack(spacing: 6) {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.cyan)
            Text(isOn ? onLabel : offLabel)
                .font(.caption.weight(.semibold))
                .foregroundColor(adaptiveForeground(0.85))
                .frame(minWidth: 40)
        }
    }
}

 

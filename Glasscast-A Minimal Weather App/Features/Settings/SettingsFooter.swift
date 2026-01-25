import SwiftUI

struct SettingsFooter: View {
    let adaptiveForeground: (_ opacity: Double) -> Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(AppConstants.UI.footerName)
                .font(.caption2.weight(.semibold))
                .foregroundColor(adaptiveForeground(0.55))
            Text(AppConstants.UI.footerEmail)
                .font(.caption2)
                .foregroundColor(adaptiveForeground(0.45))
        }
        .padding(.top, 8)
    }
}

 

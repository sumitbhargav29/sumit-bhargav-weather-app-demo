import SwiftUI

struct SettingsSectionHeader: View {
    let title: String
    let adaptiveForeground: (_ opacity: Double) -> Color
    
    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(adaptiveForeground(0.75))
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

 

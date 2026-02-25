import SwiftUI

struct FallbackIcon: View {
    let name: String
    let size: CGFloat
    var body: some View {
        Circle()
            .fill(Color.slateSurfaceVariant)
            .frame(width: size, height: size)
            .overlay(
                Text(String(name.prefix(1)))
                    .font(.title)
                    .foregroundColor(.white)
            )
            .overlay(
                Circle().stroke(Color.tacticalRed, lineWidth: 2)
            )
    }
}

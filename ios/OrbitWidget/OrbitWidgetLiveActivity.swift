import ActivityKit
import WidgetKit
import SwiftUI

// 1. FLUTTER'IN ZORUNLU KÖPRÜ ŞABLONU
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState
    
    // ZORUNLU: Flutter plugini bunu boş gönderir, biz de burada boş bırakmalıyız!
    public struct ContentState: Codable, Hashable {}
    
    var id: String
}

// 2. ANAHTAR YARDIMCISI (Havuzdan veri çekmek için)
extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}

// 3. ORTAK HAVUZ (App Group)
let sharedDefault = UserDefaults(suiteName: "group.orbit.ptt")!

// 4. KİLİT EKRANI TASARIMI
struct OrbitLiveActivityView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    
    // ÇÖZÜM: Verileri artık Flutter'ın yazdığı havuzdan güvenle okuyoruz!
    var callerName: String { sharedDefault.string(forKey: context.attributes.prefixedKey("callerName")) ?? "Bilinmeyen" }
    var statusText: String { sharedDefault.string(forKey: context.attributes.prefixedKey("statusText")) ?? "" }
    var timerText: String { sharedDefault.string(forKey: context.attributes.prefixedKey("timerText")) ?? "" }
    var themeColor: String { sharedDefault.string(forKey: context.attributes.prefixedKey("themeColor")) ?? "cyan" }
    
    var glowColor: Color {
        switch themeColor {
        case "red": return Color.red
        case "green": return Color.green
        case "cyan": return Color.cyan
        default: return Color.cyan
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(glowColor, lineWidth: 2.5)
                        .frame(width: 50, height: 50)
                        .shadow(color: glowColor.opacity(0.8), radius: 8)
                    
                    Text(String(callerName.prefix(1)))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(callerName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(statusText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(glowColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            Circle()
                                .stroke(glowColor, lineWidth: 2)
                                .background(Circle().fill(Color.black))
                                .shadow(color: glowColor.opacity(0.6), radius: 5)
                        )
                    
                    if !timerText.isEmpty {
                        Text(timerText)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(16)
        }
    }
}

// 5. WIDGET BİLDİRİMİ VE DİNAMİK ADA
@main
struct OrbitWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            OrbitLiveActivityView(context: context)
        } dynamicIsland: { context in
            
            let callerName = sharedDefault.string(forKey: context.attributes.prefixedKey("callerName")) ?? "Bilinmeyen"
            let statusText = sharedDefault.string(forKey: context.attributes.prefixedKey("statusText")) ?? ""
            let timerText = sharedDefault.string(forKey: context.attributes.prefixedKey("timerText")) ?? ""
            let themeColor = sharedDefault.string(forKey: context.attributes.prefixedKey("themeColor")) ?? "cyan"
            
            let color = themeColor == "red" ? Color.red : (themeColor == "green" ? Color.green : Color.cyan)
            
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "mic.fill").foregroundColor(color)
                        Text(callerName).font(.headline).foregroundColor(.white)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerText).font(.headline).foregroundColor(.white).monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(statusText)
                        .font(.subheadline).bold()
                        .foregroundColor(color)
                }
            } compactLeading: {
                Image(systemName: "waveform").foregroundColor(color)
            } compactTrailing: {
                Text(timerText).font(.caption2).bold().foregroundColor(color).monospacedDigit()
            } minimal: {
                Image(systemName: "mic.fill").foregroundColor(color)
            }
        }
    }
}

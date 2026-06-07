import WidgetKit
import SwiftUI

// App Group shared with the Flutter app (must match AppConstants.iosAppGroupId
// and be enabled on BOTH the Runner and this widget target).
private let appGroupId = "group.com.example.moneyBird"

struct MoneyBirdEntry: TimelineEntry {
    let date: Date
    let score: Int
    let band: String
    let spentToday: String
    let title: String
    let spentLabel: String
    let tapHint: String
}

private func loadEntry() -> MoneyBirdEntry {
    let defaults = UserDefaults(suiteName: appGroupId)
    let score = defaults?.integer(forKey: "mb_score") ?? 0
    return MoneyBirdEntry(
        date: Date(),
        score: score,
        band: defaults?.string(forKey: "mb_band") ?? "",
        spentToday: defaults?.string(forKey: "mb_spent_today") ?? "฿0",
        title: defaults?.string(forKey: "mb_title") ?? "Financial health",
        spentLabel: defaults?.string(forKey: "mb_spent_label") ?? "Spent today",
        tapHint: defaults?.string(forKey: "mb_tap_hint") ?? "Tap to add"
    )
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MoneyBirdEntry {
        MoneyBirdEntry(date: Date(), score: 72, band: "Good", spentToday: "฿320",
                       title: "Financial health", spentLabel: "Spent today", tapHint: "Tap to add")
    }

    func getSnapshot(in context: Context, completion: @escaping (MoneyBirdEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MoneyBirdEntry>) -> Void) {
        let entry = loadEntry()
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

private func colorForScore(_ score: Int) -> Color {
    switch score {
    case 80...: return Color(red: 0.13, green: 0.77, blue: 0.37)   // green
    case 60..<80: return Color(red: 0.18, green: 0.42, blue: 1.0)  // blue
    case 40..<60: return Color(red: 0.98, green: 0.75, blue: 0.14) // amber
    default: return Color(red: 0.98, green: 0.44, blue: 0.52)      // coral
    }
}

private let mutedColor = Color(red: 0.54, green: 0.58, blue: 0.66)
private let inkColor = Color(red: 0.06, green: 0.09, blue: 0.17)
private let trackColor = Color(red: 0.93, green: 0.95, blue: 0.97)

private struct ScoreRing: View {
    let score: Int
    let accent: Color
    let size: CGFloat
    let lineWidth: CGFloat
    let scoreFont: CGFloat

    var body: some View {
        ZStack {
            Circle().stroke(trackColor, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(score, 0), 100)) / 100)
                .stroke(accent, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(score)")
                .font(.system(size: scoreFont, weight: .bold))
                .foregroundColor(inkColor)
                .minimumScaleFactor(0.7)
        }
        .frame(width: size, height: size)
    }
}

struct MoneyBirdWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: MoneyBirdEntry

    var body: some View {
        let accent = colorForScore(entry.score)
        if family == .systemSmall {
            smallBody(accent)
        } else {
            mediumBody(accent)
        }
    }

    // Compact vertical layout for the small widget.
    private func smallBody(_ accent: Color) -> some View {
        VStack(spacing: 6) {
            Text(entry.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(mutedColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            ScoreRing(score: entry.score, accent: accent, size: 74, lineWidth: 8, scoreFont: 26)
            Text(entry.band)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(accent)
                .lineLimit(1)
            Text(entry.spentToday)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(inkColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
    }

    // Roomier horizontal layout for the medium widget.
    private func mediumBody(_ accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(mutedColor)
                .lineLimit(1)
            HStack(spacing: 16) {
                ScoreRing(score: entry.score, accent: accent, size: 66, lineWidth: 8, scoreFont: 24)
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.band)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(accent)
                        .lineLimit(1)
                    Text(entry.spentLabel)
                        .font(.system(size: 12))
                        .foregroundColor(mutedColor)
                        .lineLimit(1)
                    Text(entry.spentToday)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(inkColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 0)
            }
            Text(entry.tapHint)
                .font(.system(size: 11))
                .foregroundColor(mutedColor)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
    }
}

struct MoneyBirdWidget: Widget {
    let kind: String = "MoneyBirdWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MoneyBirdWidgetEntryView(entry: entry)
                    .containerBackground(.white, for: .widget)
            } else {
                MoneyBirdWidgetEntryView(entry: entry)
                    .background(Color.white)
            }
        }
        .configurationDisplayName("Money Bird")
        .description("Your financial health at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

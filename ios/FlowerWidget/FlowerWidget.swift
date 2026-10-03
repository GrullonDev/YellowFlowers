import SwiftUI
import WidgetKit

// Widget "Flor del día". Lee los datos que escribe HomeWidgetService (Flutter)
// en el App Group compartido. Las frases vienen precalculadas por fecha
// (quote_yyyy-MM-dd), así que cambian a medianoche sin abrir la app.

private let appGroupId = "group.com.grullondev.amarillas"

struct FlowerEntry: TimelineEntry {
    let date: Date
    let quote: String
    let author: String
    let flowers: String
    let streak: String
    let bloomedToday: Bool
}

struct FlowerProvider: TimelineProvider {
    func placeholder(in context: Context) -> FlowerEntry {
        FlowerEntry(date: Date(),
                    quote: "Cada día es una nueva oportunidad para florecer.",
                    author: "", flowers: "7", streak: "3", bloomedToday: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (FlowerEntry) -> Void) {
        completion(entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FlowerEntry>) -> Void) {
        let now = Date()
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: now)!)
        // Una entrada para ahora y otra a medianoche con la frase del día siguiente.
        let entries = [entry(for: now), entry(for: midnight)]
        let next = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        completion(Timeline(entries: entries, policy: .after(next)))
    }

    private func entry(for date: Date) -> FlowerEntry {
        let data = UserDefaults(suiteName: appGroupId)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)

        let quote = data?.string(forKey: "quote_\(key)")
            ?? data?.string(forKey: "quote_fallback")
            ?? "Cada día es una nueva oportunidad para florecer."
        return FlowerEntry(
            date: date,
            quote: quote,
            author: data?.string(forKey: "author_\(key)") ?? "",
            flowers: data?.string(forKey: "flowers") ?? "0",
            streak: data?.string(forKey: "streak") ?? "0",
            bloomedToday: data?.string(forKey: "bloomed_on") == key
        )
    }
}

struct FlowerWidgetView: View {
    var entry: FlowerEntry
    @Environment(\.widgetFamily) var family

    private let gold = Color(red: 1.0, green: 0.84, blue: 0.31)
    private let warmWhite = Color(red: 1.0, green: 0.97, blue: 0.88)

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("FLOR DEL DÍA ☀️")
                .font(.system(size: 10, weight: .heavy))
                .kerning(1.5)
                .foregroundColor(gold)

            Text("“\(entry.quote)”")
                .font(.system(size: family == .systemSmall ? 13 : 15, design: .serif))
                .italic()
                .foregroundColor(warmWhite)
                .lineLimit(family == .systemSmall ? 5 : 4)
                .minimumScaleFactor(0.8)
                .frame(maxHeight: .infinity, alignment: .center)

            if !entry.author.isEmpty && family != .systemSmall {
                Text("— \(entry.author)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(gold)
            }

            Text(entry.bloomedToday
                 ? "🌼 \(entry.flowers) flores · 🔥 \(entry.streak) días"
                 : "🌱 Tu flor de hoy te espera")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(warmWhite.opacity(0.85))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(URL(string: "amarillas://garden?homeWidget"))
        .modifier(LuminousBackground())
    }
}

/// Fondo nocturno luminoso, mismo estilo que LuminousBackground (Flutter).
private struct LuminousBackground: ViewModifier {
    private var gradient: some View {
        LinearGradient(
            colors: [Color(red: 0.11, green: 0.07, blue: 0.21),
                     Color(red: 0.23, green: 0.11, blue: 0.2),
                     Color(red: 0.42, green: 0.23, blue: 0.07)],
            startPoint: .top, endPoint: .bottom)
    }

    func body(content: Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content.containerBackground(for: .widget) { gradient }
        } else {
            content.padding().background(gradient)
        }
    }
}

@main
struct FlowerWidget: Widget {
    let kind = "FlowerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FlowerProvider()) { entry in
            FlowerWidgetView(entry: entry)
        }
        .configurationDisplayName("Flor del día")
        .description("Tu frase del día y el progreso de tu jardín.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

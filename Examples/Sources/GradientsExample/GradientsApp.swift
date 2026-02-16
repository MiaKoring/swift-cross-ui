import DefaultBackend
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@HotReloadable
@main
struct GradientsApp: App {
    static let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]

    static let stops: [Gradient.Stop] = [
        .init(color: .red, location: 0), .init(color: .blue, location: 0.25),
        .init(color: .purple, location: 1),
    ]

    @State var gradientType: GradientType = .linear

    var body: some Scene {
        WindowGroup("Gradients Example") {
            HStack {
                ForEach(GradientType.allCases, id: \.rawValue) { type in
                    Button(type.rawValue) {
                        gradientType = type
                    }
                    .disabled(gradientType == type)
                }
            }
            ScrollView {
                switch gradientType {
                    case .linear:
                        LinearGradientView()
                    case .radial:
                        RadialGradientView()
                    case .angular:
                        AngularGradientView()
                }
            }
        }
    }
}

enum GradientType: String, CaseIterable {
    case linear
    case radial
    case angular
}

struct LinearGradientView: View {
    var colors: [Color] { GradientsApp.colors }
    var stops: [Gradient.Stop] { GradientsApp.stops }

    var body: some View {
        VStack {
            HStack {
                LinearGradient(
                    colors: colors,
                    startPoint: .trailing,
                    endPoint: .leading
                )

                LinearGradient(
                    colors: colors,
                    startPoint: .top,
                    endPoint: .bottom
                )

                LinearGradient(
                    colors: colors,
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            }
            .frame(height: 100)

            HStack {
                LinearGradient(
                    colors: colors,
                    startPoint: .leading,
                    endPoint: .trailing
                )

                LinearGradient(
                    colors: colors,
                    startPoint: .bottom,
                    endPoint: .top
                )

                LinearGradient(
                    colors: colors,
                    startPoint: .bottomTrailing,
                    endPoint: .topLeading
                )
            }
            .frame(height: 100)
        }

        LinearGradient(stops: stops, startPoint: .leading, endPoint: .trailing)
            .frame(height: 100)
    }
}

struct RadialGradientView: View {
    var colors: [Color] { GradientsApp.colors }
    var stops: [Gradient.Stop] { GradientsApp.stops }

    var body: some View {
        VStack {
            HStack {
                RadialGradient(
                    colors: colors,
                    center: .center,
                    startRadius: 0,
                    endRadius: 150
                )

                RadialGradient(
                    colors: colors,
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 300
                )

                RadialGradient(
                    stops: stops,
                    center: .bottom,
                    startRadius: 0,
                    endRadius: 300
                )
            }
            .frame(height: 300)
        }
    }
}

struct AngularGradientView: View {
    var colors: [Color] { GradientsApp.colors }
    var stops: [Gradient.Stop] { GradientsApp.stops }

    var specialStops: [Gradient.Stop] = [
        .init(color: .red, location: 1 / 12),
        .init(color: .orange, location: 3 / 12),
        .init(color: .yellow, location: 5 / 12),
        .init(color: .green, location: 7 / 12),
        .init(color: .blue, location: 9 / 12),
        .init(color: .purple, location: 11 / 12),
        .init(color: .red, location: 1),
    ]

    var body: some View {
        VStack {
            HStack {
                AngularGradient(
                    colors: colors,
                    center: .center
                )
                .frame(width: 300)

                AngularGradient(
                    stops: stops,
                    center: .center
                )
                .frame(width: 300)

                AngularGradient(
                    stops: specialStops,
                    center: .center
                )
                .frame(width: 300)
            }
            .frame(height: 300)
        }
    }
}

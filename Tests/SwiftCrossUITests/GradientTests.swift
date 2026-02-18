import Testing
@testable import SwiftCrossUI

@Suite("Test Gradients")
@MainActor
struct GradientTests {
    @Test("Automatic equal distribution of color")
    func testAutomaticColorDistribution() async throws {
        let gradient = Gradient(colors: .init(repeating: .red, count: 12))
        let gradient1 = Gradient(colors: .init(repeating: .green, count: 3))
        
        checkExpectations(gradient: gradient)
        checkExpectations(gradient: gradient1)
        
        func checkExpectations(gradient: Gradient) {
            let count = Double(gradient.stops.count) - 1
    
            for (i, stop) in gradient.stops.enumerated() {
                #expect(stop.location ~= (Double(i) / count))
            }
        }
    }
    
    @Test("Empty array creates transparent stops")
    func testEmptyArrayCreatesTransparentStops() async throws {
        let gradient = Gradient(colors: [])
        
        #expect(gradient.stops.count == 2)
        #expect(gradient.stops.first!.color.opacityMultiplier == 0)
        #expect(gradient.stops.first!.location == 0)
        #expect(gradient.stops.last!.color.opacityMultiplier == 0)
        #expect(gradient.stops.last!.location == 1)
    }
    
    @Test("Single color array creates 2 stops of color")
    func testSingleColorArrayCreates2Stops() async throws {
        let gradient = Gradient(colors: [.red])
        
        #expect(gradient.stops.count == 2)
        #expect(gradient.stops.first!.color == .red)
        #expect(gradient.stops.first!.location == 0)
        #expect(gradient.stops.last!.color == .red)
        #expect(gradient.stops.last!.location == 1)
    }
    
    @Test("Color order stays the same")
    func testColorOrderStays() async throws {
        let colors: [Color] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let gradient = Gradient(colors: colors)
        
        for (i, stop) in gradient.stops.enumerated() {
            #expect(colors[i] == stop.color)
        }
    }
    
    @Test("AngularGradient: Unspecified end angle returns original stops")
    func nilEndAngleReturnsOriginalStops() async throws {
        let gradient = AngularGradient(
            stops: [
                .init(color: .red, location: 0),
                .init(color: .blue, location: 1)
            ],
            center: .center,
            angle: .degrees(45)
        )
        
        let result = gradient.adjustedStops
        
        #expect(gradient.endAngle == nil)
        #expect(result == gradient.gradient.stops)
    }
    
    @Test("AngularGradient: Positive range scales correctly")
    func positiveRangeScalesCorrectly() async throws {
        let gradient = AngularGradient(
            stops: [
                .init(color: .red, location: 0),
                .init(color: .blue, location: 0.5),
                .init(color: .green, location: 1)
            ],
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(180)
        )
        
        let result = gradient.adjustedStops
        
        #expect(result[0].location == 0)
        #expect(result[1].location ~= 0.25)
        #expect(result[2].location ~= 0.5)
    }
    
    @Test("AngularGradient: Negative range inverts locations")
    func negativeRangeReversesAndInverts() async throws {
        let gradient = AngularGradient(
            stops: [
                .init(color: .red, location: 0),
                .init(color: .blue, location: 0.5),
                .init(color: .green, location: 1)
            ],
            center: .center,
            startAngle: .degrees(180),
            endAngle: .degrees(0)
        )
        
        let result = gradient.adjustedStops
        
        #expect(result[0].color == .green)
        #expect(result[0].location ~= 0)
        #expect(result[1].location ~= 0.25)
        #expect(result[2].location ~= 0.5)
    }
    
    @Test("AngularGradient: Full circle range")
    func fullCircleRange() async throws {
        let gradient = AngularGradient(
            stops: [
                .init(color: .red, location: 0),
                .init(color: .blue, location: 1)
            ],
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
        
        let result = gradient.adjustedStops
        
        #expect(result[0].location == 0)
        #expect(result[1].location ~= 1.0)
    }
    
    @Test("Final Color matches last Original")
    func finalColorMatchesLastOriginal() async throws {
        let gradient = AngularGradient(
            stops: [
                .init(color: .red, location: 0),
                .init(color: .blue, location: 1)
            ],
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(180)
        )
        
        let result = gradient.adjustedStops
        
        #expect(result.last?.color == .blue)
    }
}

fileprivate extension Double {
    static func ~= (lhs: Self, rhs: Self) -> Bool {
        Int(lhs * 1_000_000_000) ==
        Int(rhs * 1_000_000_000)
    }
}

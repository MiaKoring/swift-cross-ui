import Testing
@testable import SwiftCrossUI

@Suite("Test Gradients")
struct GradientTests {
    @Test("Automatic equal distribution of color")
    func testAutomaticColorDistribution() async throws {
        let gradient = Gradient(colors: .init(repeating: .red, count: 12))
        let gradient1 = Gradient(colors: .init(repeating: .green, count: 3))
        
        checkExpectations(gradient: gradient)
        checkExpectations(gradient: gradient1)
        
        func checkExpectations(gradient: Gradient) {
            let count = Double(gradient.stops.count) - 1
            print(count)
            for (i, stop) in gradient.stops.enumerated() {
                // Multiplied by 1 million before converting to Int
                // to avoid floating point calculation/rounding errors
                #expect(
                        Int(stop.location * 1_000_000) ==
                        Int((Double(i) / count) * 1_000_000)
                    )
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
        
        print(gradient.stops)
        
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
}

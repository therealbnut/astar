import XCTest
@testable import AStar

let smallMaze = ExampleState("""
    ⬛⬛⬛⬛⬛⬛⬛
    ⬛⬛⬜⬜🌷⬛⬛
    ⬛⬜⬜⬛⬛⬜⬛
    ⬛⬛⬜⬜⬛⬜⬛
    ⬛🥀⬛⬜⬜🐝⬛
    ⬛⬛⬛⬛⬛⬛⬛
    """)

final class AStarSearchableTests: XCTestCase {

    func testEmptyPathWhenStartIsGoal() {
        let path = smallMaze.findPath(from: "🐝", to: "🐝")
        XCTAssertEqual(stringify(path), "")
    }

    func testGoalIsReachable() {
        let path = smallMaze.findPath(from: "🐝", to: "🌷")
        XCTAssertEqual(stringify(path), "←←↑←↑↑→→")
    }

    func testNonEuclideanGoalReachable() {
        let path = largeMaze.findPath(from: "🐝", to: "🌻")
        XCTAssertEqual(stringify(path), "→→💙←←")
    }

    func testGoalIsUnreachable() {
        let path = smallMaze.findPath(from: "🐝", to: "🥀")
        XCTAssertNil(stringify(path))
    }

    func testPerformance() {
        self.measure {
            let path🌺 = largeMaze.findPath(from: "🐝", to: "🌺")
            XCTAssertGreaterThan(path🌺?.count ?? -1, 0)

            let path🌼 = largeMaze.findPath(from: "🐝", to: "🌼")
            XCTAssertGreaterThan(path🌼?.count ?? -1, 0)

            let path🌻 = largeMaze.findPath(from: "🐝", to: "🌻")
            XCTAssertGreaterThan(path🌻?.count ?? -1, 0)

            let path🌸 = largeMaze.findPath(from: "🐝", to: "🌸")
            XCTAssertGreaterThan(path🌸?.count ?? -1, 0)

            let path🌷 = largeMaze.findPath(from: "🐝", to: "🌷")
            XCTAssertGreaterThan(path🌷?.count ?? -1, 0)
        }
    }

    func testUnreachablePerformance() {
        self.measure {
            for _ in 1 ... 5 {
                let path🥀 = largeMaze.findPath(from: "🐝", to: "🥀")
                XCTAssertNil(path🥀)
            }
        }
    }

    func testAlreadyFoundPerformance() {
        self.measure {
            for _ in 1 ... 25 {
                let path🐝 = largeMaze.findPath(from: "🐝", to: "🐝")
                XCTAssertEqual(path🐝?.count, 0)
            }
        }
    }

    static var allTests = [
        ("testEmptyPathWhenStartIsGoal", testEmptyPathWhenStartIsGoal),
        ("testGoalIsReachable", testGoalIsReachable),
        ("testGoalIsUnreachable", testGoalIsUnreachable),
        ("testPerformance", testPerformance),
        ("testUnreachablePerformance", testUnreachablePerformance),
        ("testAlreadyFoundPerformance", testAlreadyFoundPerformance),
    ]

}

private func stringify(_ path: [ExampleState.Edge]?) -> String? {
    return path?.map {
        switch $0 {
        case .left: return "←"
        case .right: return "→"
        case .up: return "↑"
        case .down: return "↓"
        case .teleport(let destination): return String(destination)
        }
    }.joined()
}

struct ExampleState {
    enum Edge: Hashable {
        case left, right, up, down
        case teleport(Character)
    }
    typealias Cost = Double
    typealias Node = Int
    typealias EdgeList = [(edge: Edge, cost: Cost, neighbor: Node)]

    private let characters: [Character]
    private let width: Int

    init(_ string: String) {
        self.width = string.prefix(while: { $0 != "\n" }).count + 1
        self.characters = Array(string)
    }

    private func node(for character: Character) -> Node? {
        return characters.index(of: character)
    }

    func findPath(from start: Character, to goal: Character)
        -> [ExampleState.Edge]?
    {
        guard let start = node(for: start), let goal = node(for: goal) else {
            XCTFail("Start or goal not found!")
            return nil
        }
        return findPath(from: start, to: goal)
    }
}

extension ExampleState: AStarSearchable {

    func approximateCost(from start: Node, to goal: Node) -> Double {
        let sX = Double(start % width), sY = Double(start / width)
        let gX = Double(goal % width), gY = Double(goal / width)
        let dX = sX - gX, dY = sY - gY
        return sqrt(dX * dX + dY * dY)
    }

    func edges(at node: Node) -> EdgeList {
        var list: EdgeList = []
        var nextNodes: [Edge: Node] = [
            .left: node - 1,
            .right: node + 1,
            .up: node - width,
            .down: node + width
        ]
        let linked: [Character: Character] = ["💙": "🧡", "🧡": "💙"]
        if let to = linked[characters[node]], let next = self.node(for: to) {
            nextNodes[.teleport(to)] = next
        }
        for (edge, next) in nextNodes {
            if characters[next] != "⬛" {
                list.append((edge: edge, cost: 1, neighbor: next))
            }
        }
        return list
    }
}

let largeMaze = ExampleState("""
    ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛
    ⬛🌺⬜⬜⬜⬜⬛⬜⬜⬜⬜⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜🌼⬛
    ⬛⬜⬛⬛⬛⬜⬛⬜⬛⬛⬛⬛⬛⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬛⬛⬛⬛⬛⬛⬛⬜⬛
    ⬛⬜⬜⬜⬛⬜⬜⬜⬛⬜⬜⬜⬜⬜⬛⬜⬜⬜⬛⬜⬜⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬜⬜⬛⬜⬜⬜⬜⬜⬛
    ⬛⬛⬛⬜⬛⬜⬛⬛⬛⬜⬛⬛⬛⬛⬛⬜⬛⬜⬛⬜⬛⬜⬛⬜⬛⬛⬛⬛⬛⬛⬛⬜⬛⬛⬛⬜⬛⬜⬛⬛⬛⬛⬛
    ⬛⬜⬜⬜⬛⬜⬛⬜⬜⬜⬛⬜⬜⬜⬜⬜⬛⬜⬜⬜⬛⬜⬛⬜⬜⬜⬜⬜⬛⬜⬛⬜⬛⬜⬜⬜⬛⬜⬜⬜⬛⬜⬛
    ⬛⬜⬛⬛⬛⬜⬛⬜⬛⬛⬛⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬛⬛⬛⬜⬛⬜⬛⬛⬛⬛⬛⬜⬛⬜⬛⬜⬛
    ⬛⬜⬛⬜⬜⬜⬛⬜⬛⬜⬛⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬛⬜⬛⬜⬜⬜⬛⬜⬜⬜⬜⬜⬛⬜⬛⬜⬜⬜⬛
    ⬛⬜⬛⬛⬛⬛⬛⬜⬛⬜⬛⬜⬛⬜⬛⬛⬛⬛⬛⬛⬛⬜⬛⬜⬛⬜⬛⬜⬛⬜⬛⬛⬛⬜⬛⬜⬛⬛⬛⬛⬛⬜⬛
    ⬛⬜⬜⬜⬜⬜⬛⬜⬛⬜⬜⬜⬛⬜⬜⬜⬛⬜⬜⬜⬛⬜⬛⬜⬛⬜⬜🌸⬛⬜⬜⬜⬛⬜⬛⬜⬜⬜⬜⬜⬜⬜⬛
    ⬛⬜⬛⬛⬛⬜⬛⬜⬛⬜⬛⬛⬛⬛⬛⬜⬛⬛⬛⬜⬛⬜⬛⬜⬛⬛⬛⬛⬛⬛⬛⬜⬛⬜⬛⬛⬛⬛⬛⬛⬛⬜⬛
    ⬛⬜⬛⬜⬜⬜⬛⬜⬛⬜⬜⬜⬛🥀⬛⬜⬜⬜⬛⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬛⬜⬜⬜⬜⬜⬜⬜⬛⬜⬛
    ⬛⬜⬛⬜⬛⬛⬛⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬛⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬛⬜⬛⬛⬛⬜⬛⬛⬛⬜⬛⬛⬛
    ⬛⬜⬛⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬛⬜⬜⬜⬛⬜⬛⬜⬛⬜⬜⬜⬛
    ⬛⬜⬛⬜⬛⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬛⬛⬛⬛⬛⬜⬛⬜⬛⬛⬛⬜⬛⬜⬛⬜⬛⬛⬛⬜⬛
    ⬛⬜⬛⬜⬜⬜⬜⬜⬛⬜⬜⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬛⬜⬜⬜⬛⬜⬛⬜⬜⬜⬛⬜⬜⬜⬛
    ⬛⬜⬛⬛⬛⬛⬛⬜⬛⬜⬛⬜⬛⬜⬛⬛⬛⬜⬛⬛⬛⬛⬛⬜⬛⬛⬛⬛⬛⬜⬛⬜⬛⬜⬛⬛⬛⬜⬛⬜⬛⬛⬛
    ⬛⬜⬛⬜⬜⬜⬜⬜⬛⬜⬛⬜⬛⬜⬜⬜⬛⬜⬜⬜⬜⬜⬛⬜⬛⬜⬜⬜⬜⬜⬛⬜⬛⬜⬛⬜⬛⬜⬛⬜⬜⬜⬛
    ⬛⬜⬛⬜⬛⬛⬛⬛⬛⬜⬛⬜⬛⬛⬛⬜⬛⬜⬛⬛⬛⬛⬛⬛⬛⬜⬛⬛⬛⬛⬛⬛⬛⬜⬛⬜⬛⬜⬛⬛⬛⬜⬛
    ⬛⬜⬛⬜⬛⬜⬜⬜⬜⬜⬛⬜⬜⬜⬛⬜⬛⬜⬜⬜⬛⬜⬜⬜⬛⬜⬜⬜⬜⬜⬜⬜⬛⬜⬛⬜⬜⬜⬛⬜⬛⬜⬛
    ⬛⬜⬛⬜⬛⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬛⬛⬛⬜⬛⬜⬛⬛⬛⬜⬛⬛⬛⬛⬛⬜⬛⬜⬛⬛⬛⬛⬛⬜⬜⬜⬛
    ⬛⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬛⬜⬜⬜⬛⬜⬛⬜⬛⬜⬜⬜⬛⬜⬜⬜⬜⬜⬛⬜⬛⬜⬛
    ⬛⬜⬛⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬛⬜⬛⬜⬛⬜⬛⬜⬛⬛⬛⬛⬛⬛⬛⬜⬛⬛⬛⬜⬛
    ⬛⬜⬛⬜⬜⬜⬜⬜⬛⬜⬜⬜⬛⬜⬛⬜⬜⬜⬜⬜⬛⬜⬛⬜⬛⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬛⬜⬜⬜⬛
    ⬛⬛⬛⬛⬛⬛⬛⬜⬛⬜⬛⬜⬛⬜⬛⬜⬛⬛⬛⬜⬛⬛⬛⬜⬛⬜⬛⬜⬛⬛⬛⬜⬛⬛⬛⬛⬛⬜⬛⬜⬛⬛⬛
    ⬛⬜⬜⬜⬛⬜⬜⬜⬛⬜⬛⬜⬛⬜⬛⬜⬛⬜⬛⬜⬜⬜⬜⬜⬛⬜⬛⬜⬛⬜⬜⬜⬛⬜⬜⬜⬛⬜⬛⬜⬜⬜⬛
    ⬛⬛⬛⬜⬛⬜⬛⬛⬛⬜⬛⬜⬛⬜⬛⬜⬛⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬛⬜⬛⬛⬛⬜⬛⬜⬛⬜⬛⬛⬛⬛⬛
    ⬛⬜⬜⬜⬛🌻⬜💙⬛⬜⬛⬜⬛⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬛⬜⬜⬜⬜⬜⬛⬜⬛⬜⬜⬜⬜⬜⬛
    ⬛⬜⬛⬛⬛⬛⬛⬜⬛⬛⬛⬜⬛⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬛⬜⬛⬜⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬛
    ⬛🐝⬜🧡⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬜⬜⬛⬜⬜⬜⬜⬜⬜⬜⬜⬜⬛⬜⬜🌷⬛
    ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛
    """)

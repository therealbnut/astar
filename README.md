![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)

# ✭ A-Star ✭

An implementation of A-Star in Swift.

```swift
let state = State("""
    ⬛⬛⬛⬛⬛⬛⬛
    ⬛⬛⬜⬜🌷⬛⬛
    ⬛⬜⬜⬛⬛⬜⬛
    ⬛⬛⬜⬜⬛⬜⬛
    ⬛🥀⬛⬜⬜🐝⬛
    ⬛⬛⬛⬛⬛⬛⬛
    """)
let path = state.findPath(from: "🐝", to: "🌷")
print(path.map{"\($0)"}.joined()) // "←←↑←↑↑→→"

extension ExampleState: AStarSearchable {

    func approximateCost(from start: Coord, to goal: Coord) -> Double {
        return start.distance(to: goal)
    }

    func edges(at coord: Coord) -> [EdgeListElement] {
        var list: [EdgeListElement] = []
        for direction in Direction.allCases {
            let next = coord.move(direction: direction)
            if self.canMove(to: next) {
                list.append((edge: direction, cost: 1, neighbor: next))
            }
        }
        return list
    }

}
```

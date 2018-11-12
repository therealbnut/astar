// AStar.

public struct AStarEdgeListElement<Edge, Cost, Node> {
    public var edge: Edge
    public var cost: Cost
    public var neighbor: Node

    public init(edge: Edge, cost: Cost, neighbor: Node) {
        self.edge = edge
        self.cost = cost
        self.neighbor = neighbor
    }
}

public protocol AStarSearchable {
    associatedtype Cost: Comparable & Numeric
    associatedtype Node: Hashable
    associatedtype Edge
    associatedtype EdgeList: Sequence
        where EdgeList.Element == AStarEdgeListElement<Edge, Cost, Node>

    func approximateCost(from start: Node, to goal: Node) -> Cost
    func edges(at node: Node) -> EdgeList
}

extension AStarSearchable {
    public typealias EdgeListElement = AStarEdgeListElement<Edge, Cost, Node>

    public func findPath(from start: Node, to goal: Node) -> [Edge]? {
        typealias NodeInfo = (baseCost: Cost, approxRemainder: Cost)
        typealias CameFrom = (source: Node, edge: Edge)

        var cameFrom: [Node: CameFrom] = [:]
        var nodes: [Node: NodeInfo] = [:]
        var stack: [Node] = [start]

        nodes[start] = NodeInfo(baseCost: 0,
                                approxRemainder: approximateCost(from: start,
                                                                 to: goal))

        func sortStack(lhs: Node, rhs: Node) -> Bool {
            if let lhs = nodes[lhs] {
                if let rhs = nodes[rhs] {
                    let lhsCost = lhs.baseCost + lhs.approxRemainder
                    let rhsCost = rhs.baseCost + rhs.approxRemainder
                    return lhsCost > rhsCost
                }
                return true
            }
            return false
        }

        func reconstructPath(to current: Node) -> [Edge] {
            var current = current, path: [Edge] = []
            while let from = cameFrom[current] {
                path.append(from.edge)
                current = from.source
            }
            path.reverse()
            return path
        }

        while let node = stack.popLast(), let nodeInfo = nodes[node] {
            guard node != goal else {
                return reconstructPath(to: node)
            }

            let sortStartIndex = stack.endIndex
            for next in edges(at: node) {
                let newGScore = nodeInfo.baseCost + next.cost
                if var info = nodes[next.neighbor] {
                    guard newGScore < info.baseCost else {
                        continue
                    }
                    info.baseCost = newGScore
                    cameFrom[next.neighbor] = (node, next.edge)
                    nodes[next.neighbor] = info
                }
                else {
                    let approxCost = approximateCost(from: next.neighbor,
                                                     to: goal)
                    cameFrom[next.neighbor] = (node, next.edge)
                    nodes[next.neighbor] = NodeInfo(baseCost: newGScore,
                                                    approxRemainder: approxCost)
                    stack.append(next.neighbor)
                }
            }

            // Can be replaced with a single merge sortstep, or priority queue.
            stack[sortStartIndex...].sort(by: sortStack)
            stack.sort(by: sortStack)
        }

        return nil
    }

}

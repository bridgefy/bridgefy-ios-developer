//
//  Copyright © 2020 Bridgefy. All rights reserved.
//

import UIKit

protocol TTTBoardViewDelegate: class {
    func boardView(_ boardView: TTTBoardView, didPlayAtPosition positionX: Int, _ positionY: Int)
}

protocol TTTBoardViewDataSource: class {
    func boardPositions(in boardView: TTTBoardView) -> [[TTTSymbol]]
}


class TTTBoardView: UIView {

    weak var delegate: TTTBoardViewDelegate?
    weak var dataSource: TTTBoardViewDataSource?

    var side: CGFloat = 0
    var squareSize: CGFloat = 0

    override func draw(_ rect: CGRect) {
        // Calculate locations of lines
        let width = bounds.width
        let height = bounds.height
        side = min(width, height)
        squareSize = side / 3

        let context = UIGraphicsGetCurrentContext()!
        context.setLineWidth(7.0)

        context.setStrokeColor(UIColor.darkGray.cgColor)
        for i in 1...2 {
            // Draw vertical line
            var x: CGFloat = squareSize * CGFloat(i)
            var y: CGFloat = 0
            var endX: CGFloat = x
            var endY: CGFloat = side
            drawLine(startX: x, startY: y, endX: endX, endY: endY, context: context)

            // Draw horizontal line
            x = 0
            y = squareSize * CGFloat(i)
            endX = side
            endY = y
            drawLine(startX: x, startY: y, endX: endX, endY: endY, context: context)
        }

        guard let boardPositions = dataSource?.boardPositions(in: self) else {
            return
        }
        // Drawing code of the symbols
        var boardArray: [TTTSymbol] = []
        for rowPositions in boardPositions {
            boardArray.append(contentsOf: rowPositions)
        }

        for (index, move) in boardArray.enumerated() {
            switch move {
            case TTTSymbol.cross:
                drawX(index, context: context)
            case TTTSymbol.ball:
                drawO(index, context: context)
            default: ()
            }
        }
    }

    func drawX(_ position: Int, context: CGContext) {
        // Draw an X (two lines)
        let coordinates = getCoordinates(in: position)
        context.setStrokeColor(UIColor.gray.cgColor)
        drawLine(startX: coordinates.startX, startY: coordinates.startY, endX: coordinates.endX, endY: coordinates.endY, context: context)
        drawLine(startX: coordinates.endX, startY: coordinates.startY, endX: coordinates.startX, endY: coordinates.endY, context: context)
    }

    func drawO(_ position: Int, context: CGContext) {
        // Draw a circle
        let coordinates = getCoordinates(in: position)
        context.setStrokeColor(UIColor.gray.cgColor)
        let rect = CGRect(x: coordinates.startX, y: coordinates.startY,
                          width: coordinates.endX - coordinates.startX,
                          height: coordinates.endY - coordinates.startY)
        context.addEllipse(in: rect)
        context.strokePath()
    }

    func drawLine(startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat, context: CGContext) {
        context.move(to: CGPoint(x: startX, y: startY))
        context.addLine(to: CGPoint(x: endX, y: endY))
        context.strokePath()
    }

    func getCoordinates(in position: Int) -> (startX: CGFloat, endX: CGFloat, startY: CGFloat, endY: CGFloat) {
        let row = position / 3
        let col = position % 3
        let padding: CGFloat = 10

        let startX = padding + CGFloat(col) * squareSize
        let endX = startX + squareSize - 2 * padding

        let startY = padding + CGFloat(row) * squareSize
        let endY = startY + squareSize - 2 * padding

        return (startX, endX, startY, endY)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            if let point = touches.first?.location(in: self) {
                let position = convertPointToPosition(point)
                let x = position % 3
                let y = Int(position / 3)
                delegate?.boardView(self, didPlayAtPosition: x, y)
            }
        }
    }

    func convertPointToPosition(_ point: CGPoint) -> Int {
        let col: Int = Int(point.x / squareSize)
        let row: Int = Int(point.y / squareSize)
        let square = row * 3 + col
        return square
    }
}

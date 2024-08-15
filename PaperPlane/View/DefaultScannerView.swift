import UIKit

class DefaultScannerView: ScannerView {
    override func setupUI() {
        targetView = DefaultTargetView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        super.setupUI()
    }

    override func draw(_ rect: CGRect) {
        let windowWidth = frame.size.width
        let windowHeight = frame.size.height
        let frameRect = CGRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        let areaWidth = windowWidth / 4
        let areaHeight = windowHeight / 4
        let areaCenter = CGPoint(x: (windowWidth - areaWidth) / 2, y: (windowHeight - areaHeight) / 2)
        let areaRect = CGRect(origin: areaCenter, size: CGSize(width: areaWidth, height: areaHeight))
        
        if let context =  UIGraphicsGetCurrentContext(){
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(2)
            
            context.stroke(frameRect)
            context.stroke(areaRect)
        }
    }
}

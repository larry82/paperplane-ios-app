import UIKit
import LiGScannerKit

class ScannerView: UIView{
    lazy var targetView: TargetView = {
//        let v = DefaultTargetView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let v = ImageTargetView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        if let size = v.unknownImage?.size {
            v.frame.size = size
        }
        
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
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
    
    private func setupUI(){
        addSubview(targetView)
        targetView.frame.origin = CGPoint(x: 0, y: 0)
        targetView.isHidden = true
    }
    
    open func syncTargetView(_ lightID: LightID){
        
        DispatchQueue.main.async {
            let windowWidth = Float(self.frame.width)
            let windowHeight = Float(self.frame.height.native)
            let aimPosX = CGFloat(windowWidth * lightID.coordinateX)
            let aimPosY = CGFloat(windowHeight * lightID.coordinateY)
            
            self.targetView.isHidden = false
            self.targetView.update(device: lightID)
            self.targetView.center.x = aimPosX
            self.targetView.center.y = aimPosY
        }
    }
}

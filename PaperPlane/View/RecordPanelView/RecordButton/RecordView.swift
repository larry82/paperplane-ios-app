import Foundation
import UIKit

class RoundView: UIView{
    var color: UIColor? {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    private var isShadow: Bool
    
    init(frame: CGRect, color: UIColor, isShadow: Bool = false) {
        self.isShadow = isShadow
        self.color = color
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let val = 8.0
        context.addEllipse(in: CGRect(x: rect.origin.x + (val / 2),
                                      y: rect.origin.y + (val / 2),
                                      width: rect.width - val,
                                      height: rect.height - val))
        if isShadow{
            context.setShadow(offset: CGSize(width: 0, height: 2),
                              blur: 5,
                              color: UIColor.black.withAlphaComponent(0.7).cgColor)
        }
        context.setFillColor(color?.cgColor ?? UIColor.white.cgColor)
        context.fillPath()
    }
}

class RecordView: UIView{
    private var borderRound: RoundView?
    private var contentRound: RoundView?
    
    private var mode: ButtonMode
    
    init(frame: CGRect, mode: ButtonMode) {
        self.mode = mode
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let b = RoundView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height),
                                color: .white,
                                isShadow: true)
        let c = RoundView(frame: CGRect(x: 0, y: 0, width: b.bounds.width-14, height: b.bounds.height-14),
                                 color: mode.color)
        b.addSubview(c)
        addSubview(b)
        
        c.center = b.convert(b.center, from: self)
        
        borderRound = b
        contentRound = c
    }
    
    func changeColor(mode: ButtonMode){
        contentRound?.color = mode.color
    }
}

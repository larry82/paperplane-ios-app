import CoreGraphics
import UIKit

class VideoRecorderButtonWindow: UIWindow{
    var didTouched: (() -> Void)?
    var stopView: StopRecordingView
    
    override var frame: CGRect{
        didSet{
            let xOffset: CGFloat = 20
            stopView.frame.size = CGSize(width: frame.width + xOffset, height: frame.height)
        }
    }
    
    init(windowScene: UIWindowScene, frame: CGRect) {
        stopView = StopRecordingView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        super.init(windowScene: windowScene)
        
        self.addSubview(stopView)
        windowLevel = .alert + 1
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(stopRecording))
        addGestureRecognizer(gesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startCounting(){
        stopView.countingActivate()
    }
    
    func stopCounting(){
        stopView.stopTimer()
    }
    
    @objc func stopRecording() {
        stopCounting()
        didTouched?()
    }
}

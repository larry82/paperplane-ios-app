import UIKit

enum ButtonMode{
    case isCamera
    case isRecorder
    
    var color: UIColor{
        switch self{
        case .isCamera:
            return UIColor(red: 46.0/255.0, green: 182.0/255.0, blue: 199.0/255.0, alpha: 1)
        case .isRecorder:
            return UIColor(red: 245.0/255.0, green: 82.0/255.0, blue: 59.0/255.0, alpha: 1)
        }
    }
}

class RecordButton: UIButton{
    var recordButtonView: RecordView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI(){
        self.setTitle("", for: .normal)
        let val = 80.0
        let v = RecordView(frame: CGRect(x: (self.frame.width - val)/2, y: (self.frame.height - val)/2, width: val, height: val),
                           mode: .isCamera)
        v.isUserInteractionEnabled = false
        self.addSubview(v)
        
        recordButtonView = v
    }
    
    func changeColor(mode: ButtonMode){
        recordButtonView?.changeColor(mode: mode)
    }
}

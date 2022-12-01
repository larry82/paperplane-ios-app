import UIKit

class TargetView: UIView {

    lazy var circleView: UIView = {
       let v = UIView()
        v.layer.cornerRadius = 25
        v.clipsToBounds = true
        v.backgroundColor = .yellow
        
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var targetLabel: UILabel = {
        let v = UILabel()
        v.text = "<UnKnown>"
        v.numberOfLines = 0
        v.textAlignment = .center
        v.sizeToFit()
        v.textColor = .red
        
        v.translatesAutoresizingMaskIntoConstraints = false
        return  v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    private func setupUI(){
        self.backgroundColor = .clear
        
        addSubview(circleView)
        circleView.layer.cornerRadius = self.frame.width / 2
        addSubview(targetLabel)
        setConstraints()
        
        func setConstraints(){
            circleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            circleView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            circleView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor, multiplier: 1).isActive = true
            
            targetLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            targetLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            targetLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor).isActive = true
            targetLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor).isActive = true
        }
    }
    
    open func updateUI(isDetected: Bool = false, isReady: Bool = false, id: String = ""){        
        if isDetected{
            targetLabel.isHidden = false
            targetLabel.text = id
        }else{
            targetLabel.isHidden = true
        }
        
        if isReady{
            circleView.backgroundColor = .green
        }else{
            circleView.backgroundColor = .yellow
        }
    }
}

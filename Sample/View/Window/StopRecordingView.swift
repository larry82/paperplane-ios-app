import Foundation
import UIKit

class StopRecordingView: UIView{

    lazy var recordingButton: RecordView = {
        let v = RecordView(frame: frame, mode: .isRecorder)
        
        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()
    
    var countingLabel: UILabel = {
        let v = UILabel()
        v.text = "00:00"
        v.numberOfLines = 1
        v.textColor = .white
        v.textAlignment = .center
        v.sizeToFit()
        v.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var timer: Timer?
    var second: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        self.backgroundColor = .clear
                
        self.addSubview(recordingButton)
        self.addSubview(countingLabel)
                
        setConstraints()
        
        func setConstraints(){
            //recordingButton
            let viewTopConst = NSLayoutConstraint(item: recordingButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
            let viewLeadingConst = NSLayoutConstraint(item: recordingButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
            let viewWidthConst = NSLayoutConstraint(item: recordingButton, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
            let viewHeightConst = NSLayoutConstraint(item: recordingButton, attribute: .height, relatedBy: .equal, toItem: recordingButton, attribute: .width, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([viewTopConst, viewLeadingConst, viewWidthConst, viewHeightConst])
            
            //countingLabel
            let labelTopConst = NSLayoutConstraint(item: countingLabel, attribute: .top, relatedBy: .equal, toItem: recordingButton, attribute: .bottom, multiplier: 1, constant: 4)
            let labelXCenterConst = NSLayoutConstraint(item: countingLabel, attribute: .centerX, relatedBy: .equal, toItem: recordingButton, attribute: .centerX, multiplier: 1, constant: -10)
            NSLayoutConstraint.activate([labelTopConst,labelXCenterConst])
        }
    }
    
    func countingActivate(){
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.second += 1
            self.countingLabel.text = timeString(timeInterval: TimeInterval(self.second))
        })
        
        func timeString(timeInterval: TimeInterval) -> String{
            let minutes = Int(timeInterval) / 60 % 60
            let seconds = Int(timeInterval) % 60
            
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
    
    func stopTimer(){
        timer?.invalidate()
        second = 0
        countingLabel.text = "00:00"
    }
}

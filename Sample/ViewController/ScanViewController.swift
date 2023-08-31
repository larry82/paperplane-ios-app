import UIKit
import LiGScannerKit

protocol ScanViewControllerDelegate {
    func scannerDidStart()
}

class ScanViewController: UIViewController {
    
//    MARK: - Declare
    var arViewController: ARViewController?
    var scanner: LiGScanner?
    var delegate: ScanViewControllerDelegate?

//    MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initARViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScan()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopScan()
    }
    
//    MARK: - functions
    private func initARViewController(){
        if let storyboard = storyboard{
            let vc  = storyboard.instantiateViewController(identifier: "ARViewController") as! ARViewController
            vc.modalPresentationStyle = .fullScreen
            
            arViewController = vc
        }
    }
    
    open func setupUI() {
    }

    //MARK: - Scanner related
    func startScan(){
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let self = self else { return }
            if self.scanner == nil {
                self.scanner = LiGScanner.sharedInstance()
            }

            self.scanner?.delegate = self.getScannerDelegate()
            self.delegate?.scannerDidStart()
            self.scanner?.start()
        }
    }
    
    open func getScannerDelegate() -> LiGScannerDelegate? {
        return nil
    }

    func stopScan(){
        self.scanner?.stop()
        self.scanner?.delegate = nil
        self.scanner = nil
    }
}

//MARK: - LiGScanner delegate
enum ScanHintType: Int {
    case prepare = 0, detected, success
}

extension ScanHintType {
    var description: String {
        switch self {
        case .prepare:
            return "將鏡頭瞄準Light Code機器\n並移動手機，使畫面出現感應盤"
        case .detected:
            return "發現感應盤!! 移動手機\n將感應盤放入圓環中"
        case .success:
            return "掃描成功!!\nAR讀取中...請保持不動"
        }
    }
}

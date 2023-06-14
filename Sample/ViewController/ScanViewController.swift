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



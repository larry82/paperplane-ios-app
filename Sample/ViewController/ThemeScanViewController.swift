import UIKit
import LiGScannerKit

class ThemeScanViewController: ScanViewController {
    @IBOutlet weak var scannerView: ThemeScannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bgImage = UIImage(named: "bg") {
            view.backgroundColor = UIColor(patternImage: bgImage)
        }
        
        delegate = self
    }
    
    override func getScannerDelegate() -> LiGScannerDelegate? {
        return self
    }
}

extension ThemeScanViewController: ScanViewControllerDelegate {
    func scannerDidStart() {
    }
}

extension ThemeScanViewController: LiGScannerDelegate {
    func scannerStatus(_ status: ScannerStatus) {
        print(status)
    }
    
    func scannerResult(_ ids: [LightID]) {
        let count = ids.count
        if (count > 0) {
            let lightId = ids[0]
            scannerView.update(device: lightId)
            
            // go to AR scene
            if lightId.isReady {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.stopScan()

                    // stop scan and enter a AR page
                    if let vc = self.arViewController{
                        vc.lightId = lightId.deviceId
                        vc.lightIdTransform = lightId.transform
                        
                        self.present(vc, animated: true)
                    }
                }
            }
        }
    }
}

import UIKit
import LiGScannerKit

class ThemeScanViewController: ScanViewController {
    @IBOutlet weak var scannerView: ThemeScannerView!

    var guideView: GuideView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bgImage = UIImage(named: "bg") {
            view.backgroundColor = UIColor(patternImage: bgImage)
        }
        
        delegate = self
        
        guideViewSetup()
    }
    
    func guideViewSetup() {
        let guideView = GuideView()
        view.addSubview(guideView)
        guideView.translatesAutoresizingMaskIntoConstraints = false
        guideView.widthAnchor.constraint(equalToConstant: 322.0).isActive = true
        guideView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        guideView.topAnchor.constraint(equalToSystemSpacingBelow: scannerView!.bottomAnchor, multiplier: 1).isActive = true
        guideView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -78.0).isActive = true

        guideView.setContent(status: .prepare)
        
        self.guideView = guideView
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
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                let type: ScanHintType = (lightId.isReady) ? .success : .detected
                self.guideView?.setContent(status: type)

                // go to AR scene
                if lightId.isReady {
                    self.stopScan()

                    // stop scan and enter a AR page
                    if let vc = self.arViewController{
                        vc.lightId = lightId.deviceId
                        vc.lightIdTransform = lightId.transform
                        
                        self.present(vc, animated: true)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.guideView?.setContent(status: .prepare)
            }
        }
    }
}

import UIKit
import LiGScannerKit

class ScanViewController: UIViewController {
    
//    MARK: - Declare
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var scannerView: ScannerView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var lightIDMessageTextView: UITextView!
    
    var arViewController: ARViewController?
    
    var scanner: LiGScanner?
    var isARActivated: Bool = false
    
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
        messageTextView.text = ""
        startScan()
        isARActivated = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

//    MARK: - functions
    private func initARViewController(){
        if let storyboard = storyboard{
            let vc  = storyboard.instantiateViewController(identifier: "ARViewController") as! ARViewController
            vc.modalPresentationStyle = .fullScreen
            
            arViewController = vc
        }
    }
    
    private func setupUI(){
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        scannerView.backgroundColor = .clear
        versionLabel.text = version
        
        messageTextView.text = ""
        lightIDMessageTextView.text = ""
    }
    
    private func updateLightIDMessage(with id: LightID){
        var text = String()
        var status = String()
        
        switch id.status{
        case .ready:                          status = "READY"
        case .notDetected:                    status = "NOT_DETECTED"
        case .notDecoded:                     status = "NOT_DECODED"
        case .invalidPosition:                status = "INVALID_POSITION"
        case .notRegistered:                  status = "NOT_REGISTER"
        case .invalidPositionTooClose:        status = "INVALID_POSITION_TOO_CLOSE"
        case .distanceRangeRestrictionNear:   status = "DISTANCE_RANGE_RESTRICTION_NEAR"
        case .distanceRangeRestrictionFar:    status = "DISTANCE_RANGE_RESTRUCTION_FAR"
        case .invalidPositionUnknown:         status = "INVALID_POSITION_UNKNOWN"
        default:                              status = "UNKNOWN VALUE (\(id.status.rawValue)"
        }
        
        text.append("Status: \(status)\n")
        text.append("Coordinate: \(id.coordinateX), \(id.coordinateY)\n")
        
        if id.isDetected{
            text.append(contentsOf: "Detection: \(id.detectionTime) ms\n")
            text.append(contentsOf: "Decoded: \(id.decodedTime) ms\n")
        }
        
        if id.isReady{
            text.append(String(format: "Rotation: [ %.2f, %.2f, %.2f ]\n", id.rotation.x, id.rotation.y, id.rotation.z))
            text.append(String(format: "Translation: [ %.2f, %.2f, %.2f ]\n", id.translation.x / 1000, id.translation.y / 1000, id.translation.z / 1000))
            text.append(String(format: "Position: [ %.2f, %.2f, %.2f ]", id.position.x / 1000, id.position.y / 1000, id.position.z / 1000))
        }
        
        DispatchQueue.main.async {
            self.lightIDMessageTextView.text = text
        }
    }
    
    private func updateCommandTextView(msg: String){
        
        DispatchQueue.main.async {
            if let origin = self.messageTextView.text{
                self.messageTextView.text = "\(origin)\n\(msg)"
            }
        }
    }
    
    //MARK: - Scanner related
    private func startScan(){
        if self.scanner == nil{
            self.scanner = LiGScanner.sharedInstance()
            
            self.scanner?.delegate = self
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {

            
            self.updateCommandTextView(msg: "UUID: \(self.scanner?.uuid ?? "0")")
            self.updateCommandTextView(msg: "SDK Ver: \(self.scanner?.version ?? "0")")
            self.scanner?.start()
        }
    }

    private func stopScan(){
        if scanner != nil{
            self.scanner?.stop()
            self.scanner?.delegate = nil
            self.scanner = nil
        }
    }
}

//MARK: - LiGScanner delegate
extension ScanViewController: LiGScannerDelegate{
    func scannerStatus(_ status: ScannerStatus) {
        
        var msg = "Scanner Status: ";
        switch (status) {
        case .noCameraPermission:          msg.append("No Camera Permission")
        case .noNetworkPermission:         msg.append("No Network Permission")
        case .deviceNotSupported:          msg.append("Device Not Supported")
        case .configFileError:             msg.append("Config File Error")
        case .cameraRunningError:          msg.append("Camera Running Error")
        case .sdkNotSupported:             msg.append("SDK Not Supported")
        case .sdkUnknow:                   msg.append("SDK Support Unknown")
        case .authenticationFailed:        msg.append("Authentication Failed")
        case .authenticationTimeout:       msg.append("Authentication Timeout")
        case .authenticationInterrupted:   msg.append("Authentication Interrupted")
        case .authenticationOk:            msg.append("Authentication OK")
        default:                           msg.append("Other Status (\(status.rawValue))")
        }
        
        updateCommandTextView(msg: msg)
    }
    
    func scannerResult(_ ids: [LightID]) {
        let count = ids.count
        if (count > 0) {
            let lightId = ids[0]
            updateLightIDMessage(with: lightId)
            scannerView.syncTargetView(lightId)
            
            // go to AR scene
            if !isARActivated && lightId.isReady {
                isARActivated = true

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



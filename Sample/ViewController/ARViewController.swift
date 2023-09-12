import UIKit
import ARKit
import SceneKit
import LiGScannerKit
import LiGPlayerKit
import ReplayKit

class ARViewController: UIViewController {
    
    //    MARK: - Declare
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var recordButton: RecordButton!
    @IBOutlet weak var toVideoButton: UIButton!
    @IBOutlet weak var toCameraButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func action1DidClick(_ sender: Any) {
        if let context = arContext {
            Task.detached {
                do {
                    let user = try await context.userProfile()
                    if let coins = user.coins {
                        print(coins)
                    } else {
                        print("NO COINS")
                    }
                    
                    if let vouchers = user.vouchers {
                        print(vouchers)
                    } else {
                        print("NO VOUCHERS")
                    }
                } catch {
                    print(error)
                }
            }
        }
    }

    var videoBtnWindow: VideoRecorderButtonWindow?
    
    ///螢幕錄製器
    let recorder = RPScreenRecorder.shared()
    
    var arContext: SceneKitContext?
        
    var lightIdTransform: matrix_float4x4 = matrix_float4x4()

    var lightId: Int = 0
    
    var buttonMode: ButtonMode?{
        didSet{
            if let mode = buttonMode{
                changeButtonMode(mode: mode)
            }
        }
    }
    
    ///是否為錄影狀態
    var isRecording = false {
        didSet {
            changeReplayButtonUi(isRecording: isRecording)
        }
    }
    
    //    MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        arContext = LiGPlayer.sharedContext
        initSceneView()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let config = ARWorldTrackingConfiguration()
        config.isLightEstimationEnabled = true
        config.environmentTexturing = .automatic
        
        if let context = arContext{
            
            context.sceneView = sceneView
            context.config = config
            context.delegate = self
            context.gestureDelegate = self
            
            // Run AR Session configured with `sceneView` and `config` given
            context.run()
            
            // Utilize 6DoF retrieved from LiGScannerKit (`lightId`) and position the worldOrigin
            LiGCoordinateSystem.getLightTagTransform(LightID: lightId, LightIDTransform: lightIdTransform) { matrix in
                self.sceneView.session.setWorldOrigin(relativeTransform: matrix)
            }
            
            let token = LiGScanner.sharedInstance().accessToken
            
            // Register User
            Task.detached {
                do {
                    // Load scene information from LiG Cloud
                    let coordinateSystem = try await context.loadCoordinateSystemFrom(lightId: self.lightId, accessToken: token)
                    // We could configure more than one scenes to a specific LigTag (lightId)
                    // Within `context.loadScenes()` call, context.ligScene will be set to first of scenes if not empty
                    if let cs = coordinateSystem, let scenes = cs.scenes, let scene = scenes.first {
                        // Put `scene` as `context.ligScene`
                        context.ligScene = LiGScene(scene: scene)
                        // Context will try to load AR objects in `context.ligScene`
                        context.load()
                    }

                    // Regisiter your user with primary key (ex. "Plain002") in Lig Cloud, user token will be saved in `context` object
                    try await context.registerUser(userID: "Plain002", accessToken: token)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        errorDidOccur()
    }
    //    MARK: - actions
    
    @IBAction func backClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func recordClicked(_ sender: RecordButton) {
        switch buttonMode {
        case .isCamera:
            saveImage()
        case .isRecorder:
            switchButtonsVisibility(isHidden: true)
            self.startScreenRecording()
        default:
            break
        }
    }
    
    @IBAction func captureModeClicked(_ sender: UIButton) {
        enum ButtonTag: Int{
            case camera = 101
            case video = 102
        }
        switch sender.tag{
        case ButtonTag.camera.rawValue:
            buttonMode = .isCamera
        case ButtonTag.video.rawValue:
            buttonMode = .isRecorder
        default:
            break
        }
    }
    
//    MARK: - UI related
    
    private func setupUI(){
        recordButton.backgroundColor = .clear
        initButtonUI()
        buttonMode = .isCamera
        
        setupRecordWindow()
    }
    
    private func initButtonUI(){
        let highLightAtt: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .black)]
        let normalAtt: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)]
        
        toCameraButton.setShadow()
        toCameraButton.setAttributedTitle(NSAttributedString(string: "拍照", attributes: highLightAtt),
                                          for: .selected)
        toCameraButton.setAttributedTitle(NSAttributedString(string: "拍照", attributes: normalAtt),
                                          for: .normal)
        
        toVideoButton.setShadow()
        toVideoButton.setAttributedTitle(NSAttributedString(string: "錄影", attributes: highLightAtt),
                                          for: .selected)
        toVideoButton.setAttributedTitle(NSAttributedString(string: "錄影", attributes: normalAtt),
                                          for: .normal)
    }
    
    private func changeButtonMode(mode: ButtonMode){
        recordButton.changeColor(mode: mode)
        changeButtonUI(mode: mode)
    }
    
    private func changeButtonUI(mode: ButtonMode){
        switch mode{
        case .isCamera:
            toCameraButton.isSelected = true
            toVideoButton.isSelected = false
        case .isRecorder:
            toCameraButton.isSelected = false
            toVideoButton.isSelected = true
            
            if let videoButtonPos = recordButton.superview?.convert(recordButton.frame.origin, to: nil) {
                var frame = recordButton.frame
                frame.origin = videoButtonPos
                videoBtnWindow?.frame = frame
            }
        }
    }
    
    internal func switchButtonsVisibility(isHidden: Bool){
        recordButton.isHidden = isHidden ? true : false
        toVideoButton.isHidden = isHidden ? true : false
        toCameraButton.isHidden = isHidden ? true: false
        backButton.isHidden = isHidden ? true : false
    }
    
    private func setupRecordWindow(){
        if let s = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene {
            videoBtnWindow = VideoRecorderButtonWindow(windowScene: s, frame: recordButton.frame)
        }
    }
    
//    MARK: - AR related
    private func initSceneView(){
        sceneView.delegate = self
        sceneView.scene.rootNode.light = getDefaultLight()
        
        func getDefaultLight() -> SCNLight{
            let light = SCNLight()
            light.type = .ambient
            light.color = UIColor.white
            light.intensity = 500
            light.name = "DefaultLight"
            
            return light
        }
    }
    
    private func errorDidOccur(){
        arContext?.destroy()
        arContext = nil
    }
    
//    MARK: - photo and video related
    ///將ar場景的view 轉成imag
    func arViewChangeToImage() -> UIImage {
        guard let sceneView = arContext?.sceneView else {
            print("ARViewController ArViewChangeToImage Get sceneView Fail")
            return UIImage()
        }

        return sceneView.snapshot()
    }
    
    ///儲存合成後的照片
    func saveImage() {
        let image = arViewChangeToImage()
        //判斷是否有開啟相簿權限
        photoLibraryPermissions {[weak self] (canSave) in
            if canSave {
                self?.savePhoto(image: image)
            } else {
                self?.presentSettingPage()
            }
        }
    }
}

//MARK: - SceneView delegate
extension ARViewController: ARSCNViewDelegate, ARSessionDelegate{
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        LiGScanner.sharedInstance().calibration(frame.camera)
    }
}

//MARK: - SceneKitContext delegate
extension ARViewController: SceneKitContextDelegate{
    func nodeDidCallNonLiGAction(objectID: Int, action: LiGPlayerKit.Action) {
        // Called when non-lig action is invoked on objectID
        
    }
    
    func gameTypeAction(gameType: LiGPlayerKit.GameType, value: LiGPlayerKit.GameResponse) {
        // Game-event is sent!
        print("Game Type: \(gameType)")
        print("Game Data: \(value)")
        
        // `value.data` is the reponse data after processing the rule of a game
        // `coin_quantity` is the point configured at CMS web site
        if let coin = value.data?.coin_quantity, gameType == .coinGame {
            // An AR object is touched and configured to execute a COIN-GIVEN game
            print("User got \(coin) points!")
        }
    }
    
    func didLoaded() {
        // Called when task that loads all AR objects is completed
        print("Loading task is completed.")
    }
}

extension ARViewController: SceneKitContextGestureDelegate {
    func nodeDidTap(node: LiGPlayerKit.LiGBaseNode) -> Bool {
        // Called when LiG-managed node is touched
        // Return false to continue execute of Event-Action settings from LiG Cloud
        return false
    }
    
    func sceneViewDidTapped(gesture: UITapGestureRecognizer) -> Bool {
        // Called when touch event occured
        // Return false to continue execution of Event-Action settings from LiG Cloud
        return false
    }
}

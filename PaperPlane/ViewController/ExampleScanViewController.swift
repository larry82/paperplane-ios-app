//
//  ScanViewController.swift
//  AR study
//
//  Created by RobertWu on 2019/12/2.
//  Copyright © 2019 RobertWu. All rights reserved.
//

import UIKit
import AudioUnit

class ExampleScanViewController: UIViewController {
    // BaseVC
    var isArSupport: Bool = false
    var isReversePositionSupport: Bool = false
    var isDistanceSupport: Bool = false
    
    var iconWidth: Float?
    var resultViewTop: Float?
    var heightCoefficient: Float?
    var heightOffset: Float?
    
    var loadingView: LoadingView!
    var bottomView: UIView!
    var segmented: UISegmentedControl!
    var startTime: CFAbsoluteTime!
    var endTime: CFAbsoluteTime!
    var messageLabel: UILabel?
    var timer: DispatchSourceTimer?
    var debugLabel: UILabel?
    var guideButton: UIButton?
    var guideView: GuideView?
    var glowView: UIImageView?
    var glowCenterView: UIImageView?
    var crossView: UIView!
    var hintLabel: UILabel?
    var isFirstIn: Bool = false
    var isMissionMode: Bool = false
    var firstDetect: Bool = true
//    var activityID: Int?
    var campaignSource: Activity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        crossHairSetup()
        scanSetting()
//        labelSetup()
//        versionLabelSetup()
//        helpLabelSetup()
        glowViewSetup()
        guideButtonSetup()
        guideViewSetup()
        topBarViewSetup()
        hintLabelSetup()
        loadingViewSetup()
        if debugMode {
            debugLabelSetup()
        }
        guideSetup()
//        gameResetBtnSetup()
        presentTo()
    }
    
    //跳轉至同意書頁面
    func presentTo() {
        
        if !ActivityUserDefault.getChristmasIsFirstIn(), campaignSource?.id == 10 {
            let controller = ConsentPageViewController()
            show(controller, sender: nil)
        }
    }

    func scanSetting() {
//        debugMode = true
        heightOffset = -(UIScreen.main.bounds.height * 0.3)
        heightCoefficient = 1.5
        resultViewTop = CGFloat.convertHeight(60)
        iconWidth = CGFloat.convertWidth(130)
        lightHost = NetworkBaseAddress.shared.serverHost
        detectingImageName = "scanIconNormal"
        detectedImageName = "scanIconLight"
    }

    func crossHairSetup() {
        let crossHairSize: CGFloat = CGFloat.convertWidth(230)
        let crossView = UIView(frame: CGRect(x: 0, y: 0, width: crossHairSize, height: crossHairSize))
        let crossHair: UIImageView = UIImageView()
        crossHair.contentMode = .scaleAspectFit
        crossHair.image = UIImage(named: "scanBox")
        crossView.addSubview(crossHair)
        LayoutClass.viewLayoutUsingFullView(view: crossHair, superView: crossView)
        let crossCenter: UIImageView = UIImageView()
        crossCenter.contentMode = .scaleAspectFit
        crossCenter.image = UIImage(named: "scanBoxCenter")
        crossView.addSubview(crossCenter)
        LayoutClass.viewLayoutUsingSizeInCenter(view: crossCenter, width: CGFloat.convertWidth(130), height: CGFloat.convertWidth(130), isInCenterX:  true, isInCenterY:  true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(popoverHint))
        crossCenter.addGestureRecognizer(tapGesture)
        crossCenter.isUserInteractionEnabled = true
        
        setCrossHair(crossView)
        self.crossView = crossView
        
        setBackground { (backgroundView) in
            backgroundView.image = UIImage(named: "bg")
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(clearCache))
        tap.numberOfTapsRequired = 5
        crossView.addGestureRecognizer(tap)
    }

    @objc func clearCache() {
        Downloader.deleteData()
    }

    func labelSetup() {
        let label = UILabel()
        label.numberOfLines = 0
        if let font = UIFont(name: "PingFangTC-Regular", size: 24.0) {
            label.font = font
        } else {
            print("Scan Label Font Not Found")
            label.font = UIFont.systemFont(ofSize: 24)
        }
        label.textColor = UIColor.paleMagenta2
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        view.addSubview(label)
        view.bringSubviewToFront(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: CGFloat.convertWidth(237)).isActive = true
        label.topAnchor.constraint(equalTo: resultView.bottomAnchor, constant: CGFloat.convertHeight(20)).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.sizeToFit()
        self.messageLabel = label
    }

    func versionLabelSetup() {
        let versionLabel = UILabel()
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        versionLabel.text = "\(version).\(build)"
        versionLabel.font = UIFont.systemFont(ofSize: 14)
        versionLabel.textColor = UIColor.white
        versionLabel.textAlignment = .center
        versionLabel.backgroundColor = UIColor.clear
        view.addSubview(versionLabel)
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.heightAnchor.constraint(equalToConstant: CGFloat.convertHeight(29)).isActive = true
        versionLabel.widthAnchor.constraint(equalToConstant: CGFloat.convertWidth(237)).isActive = true
//        versionLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: CGFloat.convertHeight(20)).isActive = true
        versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func guideSetup() {
        guard Default.shared.getIsFirstIn() == nil else {
            return
        }
        Default.shared.saveIsFirstIn(isFirstIn: true)
        isFirstIn = true
        presentGuide()
    }

    func helpLabelSetup() {
        let label = UILabel()
        label.numberOfLines = 0
        if let font = UIFont(name: "PingFangTC-Medium", size: 16.0) {
            label.font = font
        } else {
            print("Help Label Font Not Found")
            label.font = UIFont.systemFont(ofSize: 16)
        }
        label.text = "光標籤掃描教學"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        view.addSubview(label)
        view.bringSubviewToFront(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: CGFloat.convertHeight(-31)).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.sizeToFit()

        let tap = UITapGestureRecognizer(target: self, action: #selector(helpLabelTap))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true

        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.white
        label.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: CGFloat.convertHeight(-3)).isActive = true
        bottomView.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func guideViewSetup() {
        let guideView = GuideView()
        view.addSubview(guideView)
        guideView.translatesAutoresizingMaskIntoConstraints = false
        guideView.widthAnchor.constraint(equalToConstant: CGFloat.convertWidth(322)).isActive = true
        guideView.heightAnchor.constraint(equalToConstant: CGFloat.convertHeight(295)).isActive = true
        guideView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        if let guideButton = guideButton {
            guideView.bottomAnchor.constraint(equalTo: guideButton.topAnchor, constant: CGFloat.convertHeight(-15)).isActive = true
        } else {
            guideView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: CGFloat.convertHeight(-78)).isActive = true
        }
        
        guideView.setContent(scanStatus: .prepare)
        
        // GA swipe gesture ->
        let verticalSwipe = UISwipeGestureRecognizer(target: self, action: #selector(guideViewSwipeVertical(_:)))
        verticalSwipe.direction = [.up, .down]
        guideView.addGestureRecognizer(verticalSwipe)
        
        let horizontalSwipe = UISwipeGestureRecognizer(target: self, action: #selector(guideViewSwipeHorizontal(_:)))
        horizontalSwipe.direction = [.left, .right]
        guideView.addGestureRecognizer(horizontalSwipe)
        // <- GA swipe gesture
        
        self.guideView = guideView
    }
    
    @objc func guideViewSwipeVertical(_ sender: UISwipeGestureRecognizer) {
        GoogleAnalytics.logEvent(event: .guideSwipeVertical)
    }
    
    @objc func guideViewSwipeHorizontal(_ sender: UISwipeGestureRecognizer) {
        GoogleAnalytics.logEvent(event: .guideSwipeHorizontal)
    }
    
    func setGuideViewDetected() {
        guard firstDetect else {return}
        firstDetect = false
        guideView?.setContent(scanStatus: .detected)
    }
    
    func guideViewReset() {
        guideButton?.isSelected = false
        guideView?.setContent(scanStatus: .prepare)
        firstDetect = true
    }
    
    func glowViewSetup() {
        let glow = UIImageView(image: UIImage(named: "scanGlow"))
        crossView.addSubview(glow)
        glow.translatesAutoresizingMaskIntoConstraints = false
        glow.widthAnchor.constraint(equalToConstant: CGFloat.convertWidth(394)).isActive = true
        glow.heightAnchor.constraint(equalToConstant: CGFloat.convertWidth(394)).isActive = true
        glow.centerYAnchor.constraint(equalTo: crossView.centerYAnchor).isActive = true
        glow.centerXAnchor.constraint(equalTo: crossView.centerXAnchor).isActive = true
        
        let glowCenter = UIImageView(image: UIImage(named: detectedImageName))
        crossView.addSubview(glowCenter)
        glowCenter.translatesAutoresizingMaskIntoConstraints = false
        glowCenter.widthAnchor.constraint(equalToConstant: CGFloat.convertWidth(130)).isActive = true
        glowCenter.heightAnchor.constraint(equalToConstant: CGFloat.convertWidth(130)).isActive = true
        glowCenter.centerYAnchor.constraint(equalTo: crossView.centerYAnchor).isActive = true
        glowCenter.centerXAnchor.constraint(equalTo: crossView.centerXAnchor).isActive = true
        
        glow.alpha = 0
        glowCenter.alpha = 0
        glowView = glow
        glowCenterView = glowCenter
    }
    
    func glowViewGlows(completion: (()->Void)? = nil) {
        UIView.animate(withDuration: 0.3) {
            self.glowView?.alpha = 1
        } completion: { (_) in
            ScanProgress.shared.tempImage = TakePictureModule.snapshotShard(scale: 1)
            ScanProgress.shared.tempImageViewSetup()
            completion?()
        }
    }
    
    func guideButtonSetup() {
        let button = UIButton()
        button.setImage(UIImage(named: "teachBtn"), for: .normal)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: CGFloat.convertWidth(294)).isActive = true
        button.heightAnchor.constraint(equalToConstant: CGFloat.convertWidth(50)).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: CGFloat.convertHeight(-17)).isActive = true
        
        button.addTarget(self, action: #selector(presentGuide), for: .touchUpInside)
        guideButton = button
    }
    
    func hintLabelSetup() {
        let label = UILabel()
        label.text = "圓環不能點喔"
        label.textColor = .tomato
        label.font = UIFont.helveticaNeueFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = UIColor(white: 1, alpha: 0.9)
        label.alpha = 0
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: CGFloat.convertWidth(166)).isActive = true
        label.heightAnchor.constraint(equalToConstant: CGFloat.convertWidth(47)).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: CGFloat.convertHeight(46)).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.layer.cornerRadius = CGFloat.convertWidth(47) / 2
        label.clipsToBounds = true
        hintLabel = label
    }
    
    func topBarViewSetup() {
        let topBar = TopBarView()
        topBar.setBackground(color: UIColor(white: 1, alpha: 0.1), imageName: nil)
        topBar.setTitle(title: "AR掃描頁", textColor: .white)
        topBar.rightButtonSetup(imageName: "cancelpageIcon") { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        view.addSubview(topBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: CGFloat.convertHeight(83)).isActive = true
    }
    
    @objc func popoverHint() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.hintLabel?.alpha = 1
        } completion: { [weak self] (_) in
            self?.dismissHint()
        }
        GoogleAnalytics.logEvent(event: .scanCenterClick)
    }
    
    func dismissHint() {
        UIView.animate(withDuration: 0.3, delay: 0.6, options: .curveEaseIn, animations: { [weak self] in
            self?.hintLabel?.alpha = 0
        }, completion: nil)
    }

    func loadingViewSetup() {
        let loadingView = LoadingView()
        view.addSubview(loadingView)
        self.loadingView = loadingView
    }

    @objc func helpLabelTap() {
        presentGuide()
    }

    func debugLabelSetup() {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat.convertHeight(10)).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.sizeToFit()
        debugLabel = label
    }

    @objc func presentGuide() {
        let pageViewController = GuidePageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.modalPresentationStyle = .overFullScreen
        present(pageViewController, animated: true, completion: nil)
    }

    @objc func tapped(tap: UITapGestureRecognizer) {
        tap.view?.removeFromSuperview()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isFirstIn {
            loadingView.startAnimating()
        } else {
            isFirstIn = false
        }

        messageLabel?.text = "掃描光標籤，發現世界的驚喜～"
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startTime = CFAbsoluteTimeGetCurrent()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        glowView?.alpha = 0
        glowCenterView?.alpha = 0
        guideViewReset()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func showSystemMessage(message: String)  {
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertViewController.addAction(action)
        present(alertViewController, animated: true, completion: nil)
    }
}

extension ScanViewController {
    
    ///取得掃描座標，回傳後端
    private func postScanCoordinate(model: PassVCModel) {
        let coordinate = ScanCoordinate(lightID: model.lid_item?.quicmo ?? 0, locationX: Double(model.lid_item.x), locationZ: Double(model.lid_item.z))
        
        //打api將位置回傳
        NetworkService.postWithUrl(NetworkBaseAddress.shared.serverHost, url: kScanCoordinates, param: coordinate.convertToParameters()) { data in
            
        } failure: { error in
            print(error as Any)
        }
    }
    
    override func getViewModel(_ model: PassVCModel) {
        endTime = CFAbsoluteTimeGetCurrent()
        let scanTime = endTime - startTime
        print("Scan time: \(scanTime)")
        
        GoogleAnalytics.logEvent(event: .intoAr, parameters: ["ID" : "\(model.lid_item?.quicmo ?? 0)"])
        GoogleAnalytics.logEvent(event: .scanTime, parameters: ["time" : String(format: "%.f", scanTime)])
        GoogleAnalytics.logEvent(event: .scanMainHitDecode, parameters: ["value" : Double(model.lid_item.timeNetworkDecode).placeHolderForDouble(.timeNetworkDecode)])
        GoogleAnalytics.logEvent(event: .scanMainHitDetection, parameters: ["value" : Double(model.lid_item.timeDetection).placeHolderForDouble(.timeDetection)])
        postScanCoordinate(model: model)
        
        glowViewGlows { [weak self] in
            guard let self = self else { return }
            let vc = NewARViewController(model: model, campaignSource: self.campaignSource)
//            let controller = ARViewController()
            if let guideViewTop = self.guideView?.frame.minY {
                let resultViewBottom = self.resultView.frame.maxY
//                controller.progressPositionY = (resultViewBottom + guideViewTop) / 2 - 16
            }
//            controller.model = model
//            controller.campaignSource = self.campaignSource
//            self.navigationController?.pushViewController(controller, animated: true)
            self.navigationController?.pushViewController(vc, animated: true)
            ScanProgress.shared.removeTempImageView()
        }
    }
    
    override func scanStatusChange(_ scanStatus: ScanStatus) {
        DispatchQueue.main.async {
            switch scanStatus {
            case .sdkInit:
                print("sdkInit")
            case .sdkStart:
                self.loadingView.stopAnimating()
                print("sdkStart")
            case .sdkFail:
                self.loadingView.stopAnimating()
                print("sdkFail")
                self.showSystemMessage(message: "SDK Fail")
            case .cameraNotDetermined:
                print("cameraNotDetermined")
            case .cameraDenied:
                self.loadingView.stopAnimating()
                print("cameraDenied")
                self.showSystemMessage(message: "沒有相機權限")
            case .notReachable:
                self.loadingView.stopAnimating()
                print("notReachable")
                self.showSystemMessage(message: "沒有網路")
                ScanProgress.shared.removeTempImageView()
            case .detecting:
                self.setGuideViewDetected()
            case .detected:
                self.setGuideViewDetected()
            case .hitTarget:
                self.guideView?.setContent(scanStatus: .success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
                    self.glowCenterView?.alpha = 1
                }
            case .buildingTransformDecodeError:
                print("buildingTransformDecodeError")
                self.showSystemMessage(message: "轉置矩陣解析錯誤")
                ScanProgress.shared.removeTempImageView()
            case .buildingTransformNetworkError:
                self.loadingView.stopAnimating()
                print("buildingTransformNetworkError")
                self.showSystemMessage(message: "轉置矩陣連線錯誤")
            case .buildingTransformWait:
//                self.loadingView.startAnimating()
                print("buildingTransformWait")
            case .buildingTransformDone:
//                self.loadingView.stopAnimating()
                print("buildingTransformDone")
            @unknown default:
                print("unknown")
                self.showSystemMessage(message: "未知錯誤")
            }
        }
    }
}

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

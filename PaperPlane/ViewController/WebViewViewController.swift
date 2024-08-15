import UIKit
import WebKit
import AVFoundation

class WebViewViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, AVCaptureMetadataOutputObjectsDelegate {
    // MARK: - Properties

    @IBOutlet var webView: WKWebView!
    
    private var uri: URL
    private var loadingIndicator: UIActivityIndicatorView!
    private var qrScannerButton: UIButton!

    private var lineAccessToken: String?
    private var lineName: String?
    private var lineUserID: String?
    
    private var hasInjectedLoginInfo = false

    // MARK: - Initialization

    init(url: URL, lineAccessToken: String? = nil, lineName: String? = nil, lineEmail: String? = nil, lineUserID: String? = nil) {
        self.uri = url
        self.lineAccessToken = lineAccessToken
        self.lineName = lineName
        self.lineUserID = lineUserID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.uri = URL(string: "https://flyingclub.io")!
        super.init(coder: coder)
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupLoadingIndicator()
        setupQRScannerButton()
        loadWebPage()
    }

    // MARK: - Private Methods

    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        configuration.websiteDataStore = .default()

        let contentController = WKUserContentController()
        contentController.add(self, name: "loginComplete")
        configuration.userContentController = contentController

        if webView == nil {
            webView = WKWebView(frame: view.bounds, configuration: configuration)
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(webView)
        } else {
            webView.configuration.userContentController = contentController
        }
        webView.navigationDelegate = self
    }

    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
    }
    
    private func setupQRScannerButton() {
        qrScannerButton = UIButton(type: .system)
        qrScannerButton.setImage(UIImage(systemName: "qrcode.viewfinder")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        qrScannerButton.addTarget(self, action: #selector(openQRScanner), for: .touchUpInside)
        
        view.addSubview(qrScannerButton)
        
        qrScannerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            qrScannerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            qrScannerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            qrScannerButton.widthAnchor.constraint(equalToConstant: 44),
            qrScannerButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        view.bringSubviewToFront(qrScannerButton)
    }

    @objc private func openQRScanner() {
        let scannerVC = QRScannerViewController()
        scannerVC.delegate = self
        present(scannerVC, animated: true, completion: nil)
    }

    private func loadWebPage() {
        loadingIndicator.startAnimating()
        let request = URLRequest(url: uri)
        webView.load(request)
    }

    private func injectLoginInfoAndRedirect() {
        guard !hasInjectedLoginInfo,
              let accessToken = UserSession.shared.accessToken,
              let userID = UserSession.shared.userID else {
            return
        }

        let script = """
            window.localStorage.setItem('line_access_token', '\(accessToken)');
            window.localStorage.setItem('line_user_id', '\(userID)');
            window.location.href = 'https://flyingclub.io/webview/auth';
        """

        webView.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("Error injecting LINE login info and redirecting: \(error.localizedDescription)")
            } else {
                print("Successfully injected LINE login info and redirected")
                self.hasInjectedLoginInfo = true
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
        print("網頁載入完成")
        if !hasInjectedLoginInfo && UserSession.shared.accessToken != nil {
            injectLoginInfoAndRedirect()
        }
        
        // 顯示 localStorage 內容
        getLocalStorageContent()
        
        // 顯示 cookies
        getCookies()
    }

    private func getLocalStorageContent() {
        let script = """
        (function() {
            var storage = {};
            for (var i = 0; i < localStorage.length; i++) {
                var key = localStorage.key(i);
                var value = localStorage.getItem(key);
                storage[key] = value;
            }
            return JSON.stringify(storage);
        })()
        """
        
        webView.evaluateJavaScript(script) { (result, error) in
            if let error = error {
                print("Error fetching localStorage: \(error.localizedDescription)")
            } else if let storageString = result as? String,
                      let data = storageString.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                print("localStorage 內容:")
                for (key, value) in json {
                    print("Key: \(key), Value: \(value)")
                }
            } else {
                print("localStorage 為空")
            }
        }
    }

    private func getCookies() {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            print("\nCookies:")
            if cookies.isEmpty {
                print("沒有找到 cookies")
            } else {
                for cookie in cookies {
                    print("Name: \(cookie.name), Value: \(cookie.value), Domain: \(cookie.domain), Path: \(cookie.path)")
                }
            }
        }
    }

    // MARK: - WKScriptMessageHandler 方法

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "loginComplete" {
            print("Login completed")
            // TODO: 根據需要添加額外的處理邏輯
        }
    }
    
    // MARK: - QR Scanner Delegate Method

    func qrScannerDidScan(_ url: URL) {
        dismiss(animated: true) {
            self.loadURL(url)
        }
    }

    private func loadURL(_ url: URL) {
        uri = url
        let request = URLRequest(url: uri)
        webView.load(request)
    }
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    weak var delegate: WebViewViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }

    func found(code: String) {
        if let url = URL(string: code) {
            delegate?.qrScannerDidScan(url)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

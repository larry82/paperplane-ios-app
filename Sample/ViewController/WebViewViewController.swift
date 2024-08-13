import UIKit
import WebKit

class WebViewViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    // MARK: - 屬性

    @IBOutlet var webView: WKWebView!
    
    private var uri: URL
    private var loadingIndicator: UIActivityIndicatorView!

    private var lineAccessToken: String?
    private var lineName: String?
    private var lineUserID: String?
    
    private var hasInjectedLoginInfo = false

    // MARK: - 初始化方法

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

    // MARK: - 生命週期方法

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupLoadingIndicator()
        loadWebPage()
    }

    // MARK: - 私有方法

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
        }

    // MARK: - WKScriptMessageHandler 方法

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "loginComplete" {
            print("Login completed")
            // TODO: 根據需要添加額外的處理邏輯
        }
    }
}

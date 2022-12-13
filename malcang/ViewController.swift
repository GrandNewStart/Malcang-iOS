import UIKit
import WebKit
import SafariServices
import KakaoSDKTalk

class ViewController: UIViewController {
    
    private let homeURL = URL(string: "https://www.malcang.com/main")!
    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }
    
    func setupWebView() {
        clearHistory()
        let config = WKWebViewConfiguration()
        let prefs = WKPreferences()
        let contentController = WKUserContentController()
        prefs.javaScriptEnabled = true
        prefs.javaScriptCanOpenWindowsAutomatically = true
        contentController.add(self, name: "provideJWT")
        contentController.add(self, name: "removeJWT")
        contentController.add(self, name: "openKakaoChannel")
        contentController.add(self, name: "openExternalLink")
        config.userContentController = contentController
        config.preferences = prefs
        webView = WKWebView(frame: view.safeAreaLayoutGuide.layoutFrame, configuration: config)
        webView.customUserAgent = "malcangApp/iOS"
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.allowsBackForwardNavigationGestures = true
        if let jwt = AppStorage.jwt {
            webView.evaluateJavaScript("javascript:localStorage.setItem('X-Access-Token','\(jwt)')")
        }
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        webView.load(URLRequest(url: homeURL))
    }
    
    func clearHistory() {
        let dataStore = WKWebsiteDataStore.default()
        let allTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        dataStore.fetchDataRecords(ofTypes: allTypes) { records in
            for record in records {
                dataStore.removeData(ofTypes: record.dataTypes, for: [record]) {}
            }
        }
    }

}

extension ViewController: WKScriptMessageHandler {
    
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        print("webview interface call: \(message.name)")
        switch message.name {
        case "provideJWT":
            guard let jwt = message.body as? String else { return }
            clearHistory()
            AppStorage.jwt = jwt
            webView.evaluateJavaScript("javascript:localStorage.setItem('X-Access-Token','\(jwt)')")
        case "removeJWT":
            AppStorage.jwt = nil
            clearHistory()
            webView.evaluateJavaScript("javascript:localStorage.removeItem('X-Access-Token')")
        case "openKakaoChannel":
            let vc = SFSafariViewController(url: TalkApi.shared.makeUrlForChannelChat(channelPublicId: "_kWSLb")!)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true)
        case "openExternalLink":
            guard let string = message.body as? String,
                  let url = URL(string: string) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        default:
            break
        }
    }
    
}

extension ViewController: WKUIDelegate {
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let url = navigationAction.request.url {
            if ["kakaokompassauth", "kakaolink", "kakaoplus", "pf.kakao"].contains(url.scheme) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("(DEBUG) webView didCommit: \(webView.url!.absoluteString)")
        if let jwt = AppStorage.jwt{
            webView.evaluateJavaScript("javascript:localStorage.setItem('X-Access-Token','\(jwt)')")
        } else {
            webView.evaluateJavaScript("javascript:localStorage.removeItem('X-Access-Token')")
        }
        if webView.url!.absoluteString == "https://www.malcang.com/gene/roulette" {
            webView.allowsBackForwardNavigationGestures = false
        } else {
            webView.allowsBackForwardNavigationGestures = true
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("(DEBUG) webView didFinish: \(webView.url!.absoluteString)")
    }
    
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        let webView = WKWebView(frame: view.frame, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.customUserAgent = "malcangApp/iOS"
        webView.scrollView.bounces = false
        webView.scrollView.alwaysBounceHorizontal = false
        let viewController = UIViewController()
        viewController.view = webView
        DispatchQueue.main.async {
            self.present(viewController, animated: true)
        }
        return webView
    }
    
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let cancelAction    = UIAlertAction(title: "확인", style: .cancel) { _ in completionHandler() }
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void) {
            let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
            let confirmAction   = UIAlertAction(title: "확인", style: .default) { _ in completionHandler(true) }
            let cancelAction    = UIAlertAction(title: "취소", style: .cancel) { _ in completionHandler(false) }
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
    }
    
    func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (String?) -> Void
    ) {
        let alertController = UIAlertController(title: prompt, message: nil, preferredStyle: .alert)
        var inputTextField: UITextField?
        alertController.addTextField() { textField in
            inputTextField = textField
            textField.text = defaultText
        }
        let confirmAction = UIAlertAction(title: "확인", style: .cancel) { _ in
            completionHandler(inputTextField?.text)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(nil)
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}

extension ViewController: WKNavigationDelegate {}

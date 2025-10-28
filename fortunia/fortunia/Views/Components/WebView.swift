//
//  WebView.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import SwiftUI
import WebKit

struct WebView: UIViewControllerRepresentable {
    let url: String
    
    func makeUIViewController(context: Context) -> WKWebViewController {
        let viewController = WKWebViewController()
        if let url = URL(string: url) {
            viewController.webView.load(URLRequest(url: url))
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: WKWebViewController, context: Context) {
        // No updates needed
    }
}

// Wrapper class to hold WKWebView in a UIViewController
class WKWebViewController: UIViewController {
    let webView = WKWebView()
    
    override func loadView() {
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
    }
}

extension WKWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Loading started
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Loading finished
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Loading failed
        print("WebView error: \(error.localizedDescription)")
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: "https://fortunia.app/privacy")
            .preferredColorScheme(.dark)
    }
}


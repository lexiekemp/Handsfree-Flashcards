//
//  QuizletViewController.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 4/1/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//

import UIKit
import WebKit

class QuizletViewController: RootViewController, WKUIDelegate {

    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let myURL = URL(string: "https://quizlet.com" ) {
            let myRequest = URLRequest(url: myURL)
            webView.load(myRequest)
        }
        else {
            errorAlert(message: "Error loading quizlet.com")
        }
    }

}

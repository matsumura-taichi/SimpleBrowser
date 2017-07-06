//
//  ViewController.swift
//  SimpleBrowser
//
//  Created by 松村泰地 on 2017/03/08.
//  Copyright © 2017年 松村泰地. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //起動時に開くURL
    let homeUrlStr = "http://www.yahoo.co.jp"
    
    //検索機能で使うURL
    let searchUrlStr = "http://search.yahoo.co.jp/search?p="
    
    //URLのホワイトリスト
    let whiteList = [
        "https?://.*\\.yahoo\\.co\\.jp",
        "https?://.*\\.yahoo\\.com"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        open(urlStr: homeUrlStr);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //文字列で指定されたURLをWeb Viewで開く
    func open(urlStr: String){
        let url = URL(string: urlStr)
        let urlRequest = URLRequest(url: url!)
        webView.loadRequest(urlRequest)
    }

    //文字列で指定されたURLをSafariで開く
    func openInSafari(urlStr: String){
        if let nsUrl = URL(string: urlStr) {
            UIApplication.shared.open(nsUrl)
        }
    }
    
    //読み込み完了時の処理
    func stopLoading(){
        activityIndicator.alpha = 0
        activityIndicator.stopAnimating()
        backButton.isEnabled = self.webView.canGoBack
        reloadButton.isEnabled = true
        stopButton.isEnabled = false
    }
    
    // MARK: - UIWebViewDelegate
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
        backButton.isEnabled = false
        reloadButton.isEnabled = false
        stopButton.isEnabled = true
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        stopLoading()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //ユーザの操作によるリクエストでなければ非表示
        if navigationType == UIWebViewNavigationType.other {
            return true;
        }
        
        //現在表示中のURLを取得
        var theUrl: String
        if let unwrappedUrl = request.url?.absoluteString {
            theUrl = unwrappedUrl
        } else {
            //現在表示中のURLが取得できない場合、表示不許可
            stopLoading()
            return false;
        }
        
        //ホワイトリストでループしてURLがリスト内にあるかチェック
        var canStayInApp = false;
        for url in whiteList {
            if theUrl.range(of: url, options: NSString.CompareOptions.regularExpression) != nil {
                canStayInApp = true;
                break;
            }
        }
        
        //ホワイトリスト内になければsafariで開く
        if !canStayInApp {
            openInSafari(urlStr: theUrl)
            stopLoading()
            return false;
        }
        
        return true
    }

    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        guard let searchText = searchBar.text else { return }
        guard let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return }
        
        let urlStr = searchUrlStr + encodedText
        open(urlStr: urlStr)
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: - IBAction
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func reloadButtonTapped(_ sender: UIBarButtonItem) {
        webView.reload()
    }
    
    @IBAction func stopButtonTapped(_ sender: UIBarButtonItem) {
        webView.stopLoading()
    }
}


//
//  WKWebviewController.swift
//  SwiftForKzkj-OCR
//
//  Created by YYKit on 2017/8/29.
//  Copyright © 2017年 kzkj. All rights reserved.
//

import UIKit
import WebKit

//MARK: 是否为刘海屏系列
public var iPhoneXSerial:Bool{
    if #available(iOS 11.0, *) {
        let bottom:CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }else{ return false }
}

//MARK: -  status_bar
public let StatusBarHeight:CGFloat = iPhoneXSerial ? 44 : 20
//MARK: -  TopHeight
public let TopHeight:CGFloat = StatusBarHeight+44
//MARK: -  BottomHeight
public let BottomHeight:CGFloat = iPhoneXSerial ? 83 : 49
//MARK: -  BottomSafeEdge
public let BottomSafeEdge:CGFloat = iPhoneXSerial ? 37:0
//MARK: -  ScreenWidth
public let ScreenWidth:CGFloat = UIScreen.main.bounds.size.width
//MARK: -  ScreenHeight
public let ScreenHeight:CGFloat = UIScreen.main.bounds.size.height

class WKWebviewController: UIViewController,WKUIDelegate,WKNavigationDelegate{
    
    enum URLType {
        /// 在线
        case online
        /// 本地文件
        case localFile
    }
    
    //MARK: - 需要加载的地址
    public var urlString:String?
    //MARK: - 加载的地址类型
    public var urlType:URLType = .online
    
    //MARK: - 返回或关闭Item
    fileprivate lazy var backItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(named: "back_item"),
            style: .plain,
            target:self,
            action:  #selector(selectedToBack)
        )
        return item
    }()
    //MARK: - 关闭item
    fileprivate lazy var closeItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(named: "close_item"),
            style: .plain,
            target:self,
            action:  #selector(selectedToClose)
        )
        item.imageInsets = UIEdgeInsets(top: 0, left: -22, bottom: 0, right: 0)
        return item
    }()
    
    //MARK: - WKWebView对象
    fileprivate lazy var wkWebview: WKWebView = {
        let tempWebView = WKWebView.init(frame: CGRect(origin: CGPoint(x: 0, y: TopHeight), size: self.view.frame.size))
        tempWebView.uiDelegate = self
        tempWebView.navigationDelegate = self
        tempWebView.backgroundColor = UIColor.white
        tempWebView.autoresizingMask = UIView.AutoresizingMask.init(rawValue: 1|4)
        tempWebView.isMultipleTouchEnabled = true
        tempWebView.autoresizesSubviews = true
        tempWebView.scrollView.alwaysBounceVertical = true
        tempWebView.allowsBackForwardNavigationGestures = true
        return tempWebView
    }()

    //MARK: - UIProgressView进度条对象
    fileprivate lazy var progress: UIProgressView = {
        let rect:CGRect = CGRect.init(x: 0, y: TopHeight + 1, width: ScreenWidth, height: 2.0)
        let tempProgressView = UIProgressView.init(frame: rect)
        tempProgressView.tintColor = UIColor.red
        tempProgressView.backgroundColor = UIColor.gray
        return tempProgressView
    }()

    //MARK: - UIBarButtonItem
    fileprivate func setupBarButtonItem(){
        self.navigationItem.leftBarButtonItems = [backItem]
    }

    //MARK: - 设置UI部分
    fileprivate func setupUI(){
        self.setupBarButtonItem()
        self.view.addSubview(self.wkWebview)
        self.view.addSubview(self.progress)
    }

    //MARK: - 加载地址
    fileprivate func loadRequest(){
        if let urlString = self.urlString ,let url = URL(string: urlString){
            if urlType == .online {
                self.wkWebview.load(URLRequest(url: url))
            }else{
                self.wkWebview.loadFileURL(url, allowingReadAccessTo: url)
            }
        }
    }

    //MARK: - 添加观察者
    fileprivate func addKVOObserver(){
        self.wkWebview.addObserver(
            self,
            forKeyPath: "estimatedProgress",
            options: [NSKeyValueObservingOptions.new,NSKeyValueObservingOptions.old],
            context: nil
        )
        self.wkWebview.addObserver(
            self,
            forKeyPath: "canGoBack",
            options:[NSKeyValueObservingOptions.new,NSKeyValueObservingOptions.old],
            context: nil
        )
        self.wkWebview.addObserver(
            self,
            forKeyPath: "title",
            options: [NSKeyValueObservingOptions.new,NSKeyValueObservingOptions.old],
            context: nil
        )
    }
    
    //MARK: - 移除观察者,观察者的创建和移除一定要成对出现
    deinit{
        self.wkWebview.removeObserver(self, forKeyPath: "estimatedProgress")
        self.wkWebview.removeObserver(self, forKeyPath: "canGoBack")
        self.wkWebview.removeObserver(self, forKeyPath: "title")
    }

    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.loadRequest()
        self.addKVOObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

//MARK: - Actions
@objc
extension WKWebviewController{

    //MARK: - 返回按钮执行事件
    fileprivate func selectedToBack(){
        if (self.wkWebview.canGoBack){
            self.wkWebview.goBack()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }

    //MARK: - 关闭按钮执行事件
    fileprivate func selectedToClose(){
        self.navigationController?.popViewController(animated: true)
    }
}


//MARK: - KVO
extension WKWebviewController{
    //MARK: - 观察者的监听方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){

        if keyPath == "estimatedProgress"{
            print(self.progress.progress)
            self.progress.alpha = 1.0
            self.progress .setProgress(Float(self.wkWebview.estimatedProgress), animated: true)
            if self.wkWebview.estimatedProgress >= 1{
                UIView.animate(withDuration: 1.0, animations: {
                    self.progress.alpha = 0
                }, completion: { (finished) in
                    self.progress .setProgress(0.0, animated: false)
                })
            }
        }else if keyPath == "title"{
            self.navigationItem.title = self.wkWebview.title
        }else if keyPath == "canGoBack"{
            self.navigationItem.leftBarButtonItems = self.wkWebview.canGoBack ? [backItem,closeItem]:[backItem]
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

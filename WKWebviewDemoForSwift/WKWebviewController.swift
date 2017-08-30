//
//  WKWebviewController.swift
//  SwiftForKzkj-OCR
//
//  Created by YYKit on 2017/8/29.
//  Copyright © 2017年 kzkj. All rights reserved.
//

import UIKit
import WebKit

class WKWebviewController: UIViewController,WKUIDelegate,WKNavigationDelegate
{
    var urlString:String?

    private var leftBarButton:UIBarButtonItem?
    private var leftBarButtonSecond:UIBarButtonItem?
    private var negativeSpacer:UIBarButtonItem?

    /*
     *加载WKWebView对象
     */
    lazy var wkWebview:WKWebView =
    {
        () -> WKWebView in
        var tempWebView = WKWebView.init(frame: self.view.bounds)
        tempWebView.uiDelegate = self
        tempWebView.navigationDelegate = self
        tempWebView.backgroundColor = UIColor.white
        tempWebView.autoresizingMask = UIViewAutoresizing.init(rawValue: 1|4)
        tempWebView.isMultipleTouchEnabled = true
        tempWebView.autoresizesSubviews = true
        tempWebView.scrollView.alwaysBounceVertical = true
        tempWebView.allowsBackForwardNavigationGestures = true
        return tempWebView
    }()


    /*
     *懒加载UIProgressView进度条对象
     */
    lazy var progress:UIProgressView =
    {
        () -> UIProgressView in
        var rect:CGRect = CGRect.init(x: 0, y: 64, width: Width, height: 2.0)
        let tempProgressView = UIProgressView.init(frame: rect)
        tempProgressView.tintColor = UIColor.red
        tempProgressView.backgroundColor = UIColor.gray
        return tempProgressView
    }()

    /*
     *创建BarButtonItem
     */

    func setupBarButtonItem()
    {
        self.leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "back_item"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(WKWebviewController.selectedToBack))
        self.negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        self.negativeSpacer?.width = -5
        self.leftBarButtonSecond = UIBarButtonItem.init(image: UIImage.init(named: "close_item"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(WKWebviewController.selectedToClose))
        self.leftBarButtonSecond?.imageInsets = UIEdgeInsetsMake(0, -20, 0, 20)

        let items = [self.negativeSpacer,self.leftBarButton]
        self.navigationItem.leftBarButtonItems = items as? [UIBarButtonItem]
    }

    /*
     *设置UI部分
     */
    func setupUI()
    {
        self.setupBarButtonItem()
        self.view.addSubview(self.wkWebview)
        self.view.addSubview(self.progress)
    }

    /*
     *加载网页 request
     */
    func loadRequest()
    {
        self.wkWebview.load(NSURLRequest.init(url: NSURL.init(string: self.urlString!)! as URL) as URLRequest)
    }

    /*
     *添加观察者
     *作用：监听 加载进度值estimatedProgress、是否可以返回上一网页canGoBack、页面title
     */
    func addKVOObserver()
    {
        self.wkWebview.addObserver(self, forKeyPath: "estimatedProgress", options: [NSKeyValueObservingOptions.new,NSKeyValueObservingOptions.old], context: nil)
        self.wkWebview.addObserver(self, forKeyPath: "canGoBack", options:[NSKeyValueObservingOptions.new,NSKeyValueObservingOptions.old], context: nil)
        self.wkWebview.addObserver(self, forKeyPath: "title", options: [NSKeyValueObservingOptions.new,NSKeyValueObservingOptions.old], context: nil)
    }

    /*
     *移除观察者,类似OC中的dealloc
     *观察者的创建和移除一定要成对出现
     */
    deinit
    {
        self.wkWebview.removeObserver(self, forKeyPath: "estimatedProgress")
        self.wkWebview.removeObserver(self, forKeyPath: "canGoBack")
        self.wkWebview.removeObserver(self, forKeyPath: "title")
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.setupUI()
        self.loadRequest()
        self.addKVOObserver()
    }



    /*
     *返回按钮执行事件
     */
    func selectedToBack()
    {
        if (self.wkWebview.canGoBack == true)
        {
            self.wkWebview.goBack()
        }
        else
        {
            self.navigationController?.popViewController(animated: false)
        }
    }

    /*
     *关闭按钮执行事件
     */
    func selectedToClose()
    {
        self.navigationController?.popViewController(animated: false)
    }


    /*
     *观察者的监听方法
     */
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {

        if keyPath == "estimatedProgress"
        {
            print(self.progress.progress)
            self.progress.alpha = 1.0
            self.progress .setProgress(Float(self.wkWebview.estimatedProgress), animated: true)
            if self.wkWebview.estimatedProgress >= 1
            {
                UIView.animate(withDuration: 1.0, animations: {
                    self.progress.alpha = 0
                }, completion: { (finished) in
                    self.progress .setProgress(0.0, animated: false)
                })
            }
        }
        else if keyPath == "title"
        {
            self.navigationItem.title = self.wkWebview.title
        }
        else if keyPath == "canGoBack"
        {
            if self.wkWebview.canGoBack == true
            {
                let items = [self.negativeSpacer,self.leftBarButton,self.leftBarButtonSecond]
                self.navigationItem.leftBarButtonItems = items as? [UIBarButtonItem]
            }
            else
            {
                let items = [self.negativeSpacer,self.leftBarButton]
                self.navigationItem.leftBarButtonItems = items as? [UIBarButtonItem]
            }
        }
        else
        {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

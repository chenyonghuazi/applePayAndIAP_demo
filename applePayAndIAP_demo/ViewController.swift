//
//  ViewController.swift
//  applePayAndIAP_demo
//
//  Created by Edwin on 2018/8/18.
//  Copyright © 2018 Edwin. All rights reserved.
//

import UIKit
import PassKit
import StoreKit

class ViewController: UIViewController,PKPaymentAuthorizationViewControllerDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        <#code#>
    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        <#code#>
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    var coinsLable:UILabel = {
       let a = UILabel()
        a.text = "0"
        a.textColor = UIColor.black
        return a
    }()
    let qqCoinsPaymentIdentifier = "com.applePayAndIAP.consumable"
    var tenQQCoinsPayment:UIButton = {
       let a = UIButton()
        a.setTitle("10Q币", for: UIControlState.normal)
        a.setTitleColor(UIColor.white, for: UIControlState.normal)
        a.backgroundColor = UIColor.orange
        a.frame = CGRect(x: (UIScreen.main.bounds.width - 200) / 2, y: 30, width: 200, height: 80)
        return a
    }()
    let qqVipPaymentIdentifier = "com.applePayAndIAP.nonConsumable"
    var QQVip:UIButton = {
        let a = UIButton()
        a.setTitle("QQ终身会员", for: UIControlState.normal)
        a.setTitleColor(UIColor.white, for: UIControlState.normal)
        a.backgroundColor = UIColor.purple
        a.frame = CGRect(x: (UIScreen.main.bounds.width - 200) / 2, y: 120, width: 200, height: 80)
        return a
    }()
    
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var nonConsumablePurchaseMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseMade")
    var coins = UserDefaults.standard.integer(forKey: "coins")
    
    var SupportedCard:[PKPaymentNetwork] = [PKPaymentNetwork]()
    
    var PaymentButton:UIButton = {
        let a = UIButton()
        a.setTitle("Pay the order", for: UIControlState.normal)
        a.setTitleColor(UIColor.black, for: UIControlState.normal)
        return a
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupPaymentButton()
        view.addSubview(tenQQCoinsPayment)
        view.addSubview(QQVip)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setProducts(){
        let products = NSSet(objects:qqVipPaymentIdentifier,qqCoinsPaymentIdentifier ) as! Set<String>
        productsRequest = SKProductsRequest(productIdentifiers: products)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    fileprivate func setupPaymentButton(){
        PaymentButton.frame = CGRect(origin: CGPoint(x: (view.frame.width - 150) / 2, y: (view.frame.height - 60) / 2), size: CGSize(width: 150, height: 60))
        view.addSubview(PaymentButton)
        PaymentButton.addTarget(self, action: #selector(hanldePayment), for: UIControlEvents.touchUpInside)
    }
    
    @objc func hanldePayment(){
        //check for os system for payment
        if !PKPaymentAuthorizationViewController.canMakePayments(){
            print("error,don't support apple pay!")
            return
        }
        //check for card support
        if #available(iOS 9.2, *){
            SupportedCard.append(PKPaymentNetwork.chinaUnionPay)
            
        }
        SupportedCard.append(PKPaymentNetwork.amex)
        
        SupportedCard.append(PKPaymentNetwork.visa)
        SupportedCard.append(PKPaymentNetwork.masterCard)
        
        //check for device
//        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: SupportedCard){
//            print("error,device don't support cards like visa mastercard and amex")
//            return
//        }
        
        let purchaseRequest = PKPaymentRequest()
        purchaseRequest.countryCode = "CA"
        purchaseRequest.currencyCode = "CAD"
        purchaseRequest.merchantCapabilities = .capability3DS
        purchaseRequest.merchantIdentifier = "merchant.com.Edwin.merchantDemo"
        purchaseRequest.supportedNetworks = SupportedCard
        
        let item1 = PKPaymentSummaryItem(label: "麻婆豆腐", amount: 7.99)
        let item2 = PKPaymentSummaryItem(label: "上海汤汁小笼包", amount: 10.99)
        let item3 = PKPaymentSummaryItem(label: "宫保鸡丁", amount: 8.99)
        let gst = PKPaymentSummaryItem(label: "HST", amount: 3.63)
        let item4 = PKPaymentSummaryItem(label: "总共", amount: 31.6061)
        
        purchaseRequest.paymentSummaryItems = [item1,item2,item3,gst,item4]
        
        guard let paymentVC = PKPaymentAuthorizationViewController.init(paymentRequest: purchaseRequest) else{return}
        paymentVC.delegate = self
        present(paymentVC, animated: true, completion: nil)
        
    }

}


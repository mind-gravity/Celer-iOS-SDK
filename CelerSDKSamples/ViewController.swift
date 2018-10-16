//
//  ViewController.swift
//  CelerSDKSamples
//
//  Created by Jinyao Li on 10/15/18.
//

import UIKit
import Mobile

class ViewController: UIViewController {
  
  // TODO: Add your own keystore and its password here. Put your receiver addr
  private var keyStoreString = ""
  private var password = ""
  private var receiverAddr = ""
  
  let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  
  private var clientSideAmount: String = "500000000000000000" // 0.5 cETH
  private var serverSideAmount: String = "1500000000000000000" // 1.5 cETH
  private var transferAmount: String = "30000000000000000" // 0.03 ETH
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    newClient()
  }
  
  private func newClient() {
    
    keyStoreString = KeyStoreHelper.shared.getKeyStoreString()
    
    password = KeyStoreHelper.shared.getPassword()
    
    let config = "{\"ETHInstance\": \"wss://ropsten.infura.io/ws\", \"SvrRPC\": \"osp1-hack-ropsten.celer.app:10000\", \"StoreDir\": \"\(datadir)\", \"SvrETHAddr\": \"f805979adde8d63d08490c7c965ee5c1df0aaae2\", \"ChanAddr\": \"011b1fa33797be5fcf7f7e6bf436cf99683c186d\", \"ResolverAddr\": \"cf8938ae21a21a7ffb2d47a69742ef5ce7a669cc\", \"DepositPoolAddr\": \"658333a4ea7dd461b56592ed62839afc18d54a42\", \"HTLRegistryAddr\": \"a41bf533110e0b778f6757e04cf7c6d2a8e294b1\"}"
    
    do {
      var error: NSError?
      
      let client = MobileNewClient(keyStoreString, password, config, &error)
      
      if let error = error {
        throw error
      }
      
      try client?.joinCeler("0x0", amtWei: clientSideAmount, peerAmtWei: serverSideAmount)
      
      receiverAddr = "0x2718aaa01fc6fa27dd4d6d06cc569c4a0f34d399"
      
      let maxReceivingCapacity = try client?.hasJoinedCeler(receiverAddr)
      print(maxReceivingCapacity ?? "No response")
      
      try client?.sendPay(receiverAddr, amtWei: transferAmount)
      print(client?.getBalance(1)?.available() ?? "No available balance")
    } catch {
      print(error.localizedDescription)
    }
  }
}


//
//  CelerClientAPIHelper.swift
//  Celer Network
//
//  Created by Jinyao Li on 11/29/18.
//  Copyright (c) 2018, Celer Network. All rights reserved.
//

import Celer

final class CelerClientAPIHelper {
  
  static let shared = CelerClientAPIHelper()
  
  private var client: CelerClient?
  
  private let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  
  private init() {}
  
  func initCelerClient(keyStoreString: String, password: String) -> String {
    let profile = "{\"ETHInstance\": \"wss://ropsten.infura.io/ws\", \"SvrRPC\": \"osp1-hack-ropsten.celer.app:10000\", \"StoreDir\": \"\(datadir)\", \"SvrETHAddr\": \"f805979adde8d63d08490c7c965ee5c1df0aaae2\", \"ChanAddr\": \"011b1fa33797be5fcf7f7e6bf436cf99683c186d\", \"ResolverAddr\": \"cf8938ae21a21a7ffb2d47a69742ef5ce7a669cc\", \"DepositPoolAddr\": \"658333a4ea7dd461b56592ed62839afc18d54a42\", \"HTLRegistryAddr\": \"a41bf533110e0b778f6757e04cf7c6d2a8e294b1\", \"NoBlockDelay\": true}"
    
    do {
      client = try CelerClient(keyStore: keyStoreString, password: password, config: profile)
      return "Celer client created!\n"
    } catch {
      return "Create celer client error: \(error.localizedDescription)"
    }
  }
  
  // Join Celer, "0x0" means ether token
  func joinCeler(clientSideDepositAmount: String, serverSideDepositAmount: String) -> String {
    do {
      try client?.joinCeler(basedOnToken: "0x0", providing: clientSideDepositAmount, requiring: serverSideDepositAmount)
      return "Join celer success"
    } catch {
      return "Join celer error: \(error.localizedDescription)"
    }
  }
  
  func checkBalance() -> (String, Bool) {
    guard let balance = client?.getAvailableBalance() else {
      return ("Empty wallet", true)
    }
    return ("Available balance: \(balance) wei", balance == "0")
  }
  
  func sendPayment(receiverAddress: String, transferAmount: String) -> String {
    do {
      try client?.pay(receiver: receiverAddress, amount: transferAmount)
      return "Send payment sucessfully"
    } catch {
      return "Send payment error: \(error.localizedDescription)"
    }
  }
  
  func getClient() -> CelerClient? {
    return client
  }
}

// MARK: - Delegate

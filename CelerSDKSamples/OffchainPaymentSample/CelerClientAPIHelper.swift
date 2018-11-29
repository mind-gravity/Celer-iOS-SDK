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
    let profile = "{\"ETHInstance\": \"ws://osp1-test-priv.celer.app:8546\", \"SvrRPC\": \"osp1-test-priv.celer.app:10000\", \"StoreDir\": \"\(datadir)\", \"SvrETHAddr\": \"5963e46cf9f9700e70d4d1bc09210711ab4a20b4\", \"ChanAddr\": \"189908e83d9245d89f0859e8361342b634785956\", \"ResolverAddr\": \"1e92cd8c8af5ab6cf5a93824e7f24532fccab5d8\", \"DepositPoolAddr\": \"b9353a8413189e3c6c4fce8c48c9b4bd6e5be814\", \"HTLRegistryAddr\": \"869ef00c827f91ca115bfe25427b75d970b8d95d\"}"
    
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

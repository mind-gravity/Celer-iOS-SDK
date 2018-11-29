//
//  KeyStoreHelper.swift
//  CelerSDKSamples
//
//  Created by Jinyao Li on 10/23/18.
//

import Foundation
import Celersdk
import Celer

public class KeyStoreHelper {
  
  public static let shared = KeyStoreHelper()
  
  private let keyStore: GethKeyStore
  private var account: GethAccount?
  private var keyStoreString: String = ""
  private var accountAddress: String = ""
  
  private let createPassword: String = "CelerNetwork"
  private let exportPassword: String = "CelerNetwork"
  
  private var celerClient: CelerClient? = nil
  
  let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  
  
  private init () {
    keyStore = GethNewKeyStore("\(datadir)/gethKeyStore", GethLightScryptN, GethLightScryptP)
    
    do {
      if let size = keyStore.getAccounts()?.size(), size > 0 {
        account = try keyStore.getAccounts()?.get(0)
      } else {
        account = try keyStore.newAccount(createPassword)
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func getKeyStoreString() -> String {
    if keyStoreString.isEmpty {
      generateKeyStoreString()
    }
    
    return keyStoreString
  }

  func getAccountAddress() -> String {
    if accountAddress.isEmpty {
      generateKeyStoreString()
    }
    
    return accountAddress
  }
  
  func getPassword() -> String {
    return exportPassword
  }
  
  private func generateKeyStoreString() {
    guard let account = account else {
      fatalError("Empty gethAccount")
    }
    accountAddress = account.getAddress().getHex()
    do {
      let jsonKeyData = try keyStore.exportKey(account, passphrase: createPassword, newPassphrase: exportPassword)
      if let jsonKeyString = String(data: jsonKeyData, encoding: .utf8) {
        keyStoreString = jsonKeyString
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
//  public func fuelTheAccount(userType: UserType, resultHandler: @escaping (String) -> Void) {
//    let address = gethAccountAddresses[userType.rawValue]
//    
//    if (address.isEmpty) {
//      generateKeyStoreString(userType)
//      resultHandler("Generating keystore, please try again")
//    } else {
//      FaucetHelper.shared.getAvailableToken(for: address) { result in
//        switch (result) {
//        case .failure:
//          resultHandler("Failed to get token for address: \(address)")
//        case .success:
//          resultHandler("Token has been sent to address: \(address), please wait for onchain transaction.")
//        }
//      }
//    }
//  }
//  
//  func getCelerClient() -> (String, CelerClient?) {
//    guard celerClient == nil else {
//      return ("\n\nCeler Client created.", celerClient)
//    }
//    
//    print("No client, create a new one")
//    
//    let config = "{\"ETHInstance\": \"ws://osp1-test-priv.celer.app:8546\", \"SvrRPC\": \"osp1-test-priv.celer.app:10000\", \"StoreDir\": \"\(datadir)\", \"SvrETHAddr\": \"5963e46cf9f9700e70d4d1bc09210711ab4a20b4\", \"ChanAddr\": \"189908e83d9245d89f0859e8361342b634785956\", \"ResolverAddr\": \"1e92cd8c8af5ab6cf5a93824e7f24532fccab5d8\", \"DepositPoolAddr\": \"b9353a8413189e3c6c4fce8c48c9b4bd6e5be814\", \"HTLRegistryAddr\": \"869ef00c827f91ca115bfe25427b75d970b8d95d\"}"
//    do {
//      celerClient = try CelerClient(keyStore: KeyStoreHelper.shared.getKeyStoreString(userType: .Player1), password: KeyStoreHelper.shared.getPassword(), config: config)
//      return ("\n\nCeler Client created.", celerClient)
//    } catch {
//      celerClient = nil
//      return (error.localizedDescription, celerClient)
//    }
//  }
}


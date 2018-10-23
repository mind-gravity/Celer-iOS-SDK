//
//  KeyStoreHelper.swift
//  CelerSDKSamples
//
//  Created by Jinyao Li on 10/23/18.
//

import Foundation
import Celersdk
import Celer

public enum UserType: Int {
  case Judge = 0
  case Player1 = 1
  case Player2 = 2
}

public class KeyStoreHelper {
  
  public static let shared = KeyStoreHelper()
  
  private let gethKeyStore: GethKeyStore
  private var gethAccounts: [GethAccount?] = [nil, nil, nil]
  private var gethKeyStoreStrings: [String] = ["", "", ""]
  private var gethAccountAddresses: [String] = ["", "", ""]
  
  private let createPassword: String = "CelerNetwork"
  private let exportPassword: String = "CelerNetwork"
  
  private var celerClient: CelerClient? = nil
  
  let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  
  
  private init () {
    gethKeyStore = GethNewKeyStore("\(datadir)/gethKeyStore", GethLightScryptN, GethLightScryptP)
    
    do {
      if let size = gethKeyStore.getAccounts()?.size(), size > 2 {
        for i in 0 ... 2 {
          gethAccounts[i] = try gethKeyStore.getAccounts()?.get(i)
        }
      } else {
        for i in 0 ... 2 {
          gethAccounts[i] = try gethKeyStore.newAccount(createPassword)
        }
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  public func getKeyStoreString(userType: UserType) -> String {
    if gethKeyStoreStrings[userType.rawValue].isEmpty {
      generateKeyStoreString(userType)
    }
    
    return gethKeyStoreStrings[userType.rawValue]
  }
  
  public func getAccountAddress(userType: UserType) -> String {
    if gethAccountAddresses[userType.rawValue].isEmpty {
      generateKeyStoreString(userType)
    }
    
    return gethAccountAddresses[userType.rawValue]
  }
  
  public func getPassword() -> String {
    return exportPassword
  }
  
  private func generateKeyStoreString(_ userType: UserType) {
    guard let gethAccount = gethAccounts[userType.rawValue] else {
      fatalError("Empty gethAccount")
    }
    gethAccountAddresses[userType.rawValue] = gethAccount.getAddress().getHex()
    do {
      let jsonKeyData = try gethKeyStore.exportKey(gethAccount, passphrase: createPassword, newPassphrase: exportPassword)
      if let jsonKeyString = String(data: jsonKeyData, encoding: .utf8) {
        gethKeyStoreStrings[userType.rawValue] = jsonKeyString
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  public func fuelTheAccount(userType: UserType, resultHandler: @escaping (String) -> Void) {
    let address = gethAccountAddresses[userType.rawValue]
    
    if (address.isEmpty) {
      generateKeyStoreString(userType)
      resultHandler("Generating keystore, please try again")
    } else {
      FaucetHelper.shared.getAvailableToken(for: address) { result in
        switch (result) {
        case .failure:
          resultHandler("Failed to get token for address: \(address)")
        case .success:
          resultHandler("Token has been sent to address: \(address), please wait for onchain transaction.")
        }
      }
    }
  }
  
  func getCelerClient() -> (String, CelerClient?) {
    guard celerClient == nil else {
      return ("\n\nCeler Client created.", celerClient)
    }
    
    print("No client, create a new one")
    
    let config = "{\"ETHInstance\": \"ws://osp1-test-priv.celer.app:8546\", \"SvrRPC\": \"osp1-test-priv.celer.app:10000\", \"StoreDir\": \"\(datadir)\", \"SvrETHAddr\": \"5963e46cf9f9700e70d4d1bc09210711ab4a20b4\", \"ChanAddr\": \"189908e83d9245d89f0859e8361342b634785956\", \"ResolverAddr\": \"1e92cd8c8af5ab6cf5a93824e7f24532fccab5d8\", \"DepositPoolAddr\": \"b9353a8413189e3c6c4fce8c48c9b4bd6e5be814\", \"HTLRegistryAddr\": \"869ef00c827f91ca115bfe25427b75d970b8d95d\"}"
    do {
      celerClient = try CelerClient(keyStore: KeyStoreHelper.shared.getKeyStoreString(userType: .Player1), password: KeyStoreHelper.shared.getPassword(), config: config)
      return ("\n\nCeler Client created.", celerClient)
    } catch {
      celerClient = nil
      return (error.localizedDescription, celerClient)
    }
  }
}


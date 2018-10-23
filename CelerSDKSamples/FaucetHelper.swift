//
//  FaucetHelper.swift
//  CelerSDKSamples
//
//  Created by Jinyao Li on 10/23/18.
//

import Foundation

public enum FaucetResult {
  case success
  case failure
}

final public class FaucetHelper {
  
  public static let shared = FaucetHelper()
  private init() {}
  
  public func getAvailableToken(for accountAddress: String, from faucetAddress: String = "http://54.188.217.246:3008/donate/", resultHandler: @escaping (FaucetResult) -> Void) {
    URLSession.shared.dataTask(with: URL(string: "\(faucetAddress)\(accountAddress)")!) { data, response, error in
      guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        resultHandler(.failure)
        return
      }
      resultHandler(.success)
      }.resume()
  }
}

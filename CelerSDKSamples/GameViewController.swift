//
//  GameViewController.swift
//  CelerSDKSamples
//
//  Created by Jinyao Li on 10/23/18.
//

import UIKit
import Celer

class GameViewController: UIViewController {
  
  let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  
  private var myScore: Int = 0
  private var maxScore: Int = 80
  private var myIndex = -1
  private var opponentScore: Int = 0
  private var opponentFinalScore: Int = 0
  private var myFinalScore: Int = 0
  private var remainingTime: Int = 20
  private var finalized = false
  
  var groupResponse: CelerGroupResponse? = nil {
    didSet{
      initNewSession()
    }
  }
  
  var client: CelerClient? = nil {
    didSet {
      initNewSession()
    }
  }
  
  private var opponentAddress: String = ""
  private var identifier: String = ""
  
  private lazy var clickButton: UIButton = {
    let button = UIButton(type: .system)
    button.addTarget(self, action: #selector(didTapClick), for: .touchUpInside)
    button.setAttributedTitle(NSAttributedString(string: "Tap to get score",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
                                                              NSAttributedString.Key.foregroundColor: UIColor.white]), for: .normal)
    button.backgroundColor = UIColor.blue
    return button
  }()
  
  private let opponentScoreLabel = UILabel()
  private var opponentScoreProgressView: UIProgressView = {
    let progressView = UIProgressView(progressViewStyle: UIProgressView.Style.bar)
    progressView.progressTintColor = UIColor.red
    return progressView
  }()
  
  private let myScoreLabel = UILabel()
  private var myScoreProgressView: UIProgressView = {
    let progressView = UIProgressView(progressViewStyle: UIProgressView.Style.bar)
    progressView.progressTintColor = UIColor.red
    return progressView
  }()
  
  private let countDownLabel = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    navigationItem.title = "Who Clicks Faster"
    let (_, client) = KeyStoreHelper.shared.getCelerClient()
    self.client = client
    
    [clickButton, myScoreLabel, myScoreProgressView, opponentScoreLabel, opponentScoreProgressView, countDownLabel].forEach {
      view.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
    }
    
    opponentScoreLabel.text = "Opponent score: 0"
    opponentScoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    opponentScoreProgressView.topAnchor.constraint(equalTo: opponentScoreLabel.bottomAnchor, constant: 10).isActive = true
    opponentScoreProgressView.heightAnchor.constraint(equalToConstant: 4).isActive = true
    opponentScoreProgressView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    
    myScoreLabel.text = "My score: 0"
    myScoreLabel.topAnchor.constraint(equalTo: opponentScoreProgressView.bottomAnchor, constant: 15).isActive = true
    myScoreProgressView.topAnchor.constraint(equalTo: myScoreLabel.bottomAnchor, constant: 10).isActive = true
    myScoreProgressView.heightAnchor.constraint(equalToConstant: 4).isActive = true
    myScoreProgressView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    
    clickButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    clickButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
    clickButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    
    countDownLabel.text = "Time Remaining: 5"
    countDownLabel.font = UIFont.systemFont(ofSize: 20)
    countDownLabel.bottomAnchor.constraint(equalTo: clickButton.topAnchor, constant: -20).isActive = true
    countDownLabel.textAlignment = .center
    countDownLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
      if self.remainingTime == 0 {
        timer.invalidate()
        return
      }
      self.remainingTime -= 1
      self.finalized = self.remainingTime == 0
      DispatchQueue.main.async {
        self.countDownLabel.text = self.remainingTime > 0 ? "Time Remaining: \(self.remainingTime)" : "Finished"
      }
      
      if (self.finalized) {
        self.clickButton.isEnabled = false
        self.myScore -= 1
        self.didTapClick()
      }
    }
  }
  
  deinit {
    print("GameViewController deinit")
  }
  
  private func initNewSession() {
    guard let groupResponse = groupResponse, let client = client else {
      return
    }
    let users = groupResponse.getUsers().components(separatedBy: ",")
    print(users)
    print(KeyStoreHelper.shared.getAccountAddress(userType: .Player1))
    if (users[0].lowercased() == KeyStoreHelper.shared.getAccountAddress(userType: .Player1).lowercased()) {
      myIndex = 1
      opponentAddress = users[1]
    } else {
      myIndex = 2
      opponentAddress = users[0]
    }
    
    print("My Index: \(myIndex)")
    
    client.delegate = self
    identifier = client.initNewSession(groupResponse: groupResponse) { error in
      print(error.localizedDescription)
    }
    print(identifier)
  }
  
  @objc private func didTapClick() {
    myScore += 1
    myScoreLabel.text = "My Score: \(Int(myScore))"
    
    myScoreProgressView.setProgress(Float(myScore) / Float(maxScore), animated: true)
    var myScoreHex = String(Int(myScore), radix: 16)
    myScoreHex = myScoreHex.count == 1 ? "0\(myScoreHex)" : myScoreHex
    var opponentScoreHex = String(Int(opponentScore), radix: 16)
    opponentScoreHex = opponentScoreHex.count == 1 ? "0\(opponentScoreHex)" : opponentScoreHex
    myFinalScore = finalized ? myScore : 0
    opponentFinalScore = finalized ? opponentScore : 0
    var myFinalScoreHex = String(Int(myFinalScore), radix: 16)
    myFinalScoreHex = myFinalScoreHex.count == 1 ? "0\(myFinalScoreHex)" : myFinalScoreHex
    var opponentFinalScoreHex = String(Int(opponentFinalScore), radix: 16)
    opponentFinalScoreHex = opponentFinalScoreHex.count == 1 ? "0\(opponentFinalScoreHex)" : opponentFinalScoreHex
    
    
    let stateString = myIndex == 1 ? "\(myScoreHex)\(opponentScoreHex)\(myFinalScoreHex)\(opponentFinalScoreHex)" : "\(opponentScoreHex)\(myScoreHex)\(opponentFinalScoreHex)\(myFinalScoreHex)"
    //    print(stateString)
    guard let data = stateString.hexadecimal else {
      return
    }
    
    client?.sendState(sessionId: identifier, opponentAddress: opponentAddress, state: data)
  }
}

extension GameViewController: CelerClientDelegate {
  func didReceiveNewStatus(newState: Int) {
  }
  
  func didReceiveGameState(data: Data) {
    print("Data hex: \(data.hexadecimal)")
    let hex = data.hexadecimal
    let startIndex = hex.index(hex.startIndex, offsetBy: 2)
    let endIndex = hex.index(hex.startIndex, offsetBy: 3)
    let opponentSub = myIndex == 2 ? hex.prefix(2) : hex[startIndex ... endIndex]
    opponentScore = Int(opponentSub, radix: 16) ?? 0
    print("Opponent Score: \(opponentScore)")
    DispatchQueue.main.async {
      self.opponentScoreLabel.text = "Opponent score: \(self.opponentScore)"
      self.opponentScoreProgressView.setProgress(Float(self.opponentScore) / Float(self.maxScore), animated: true)
    }
  }
}

extension Data {
  var hexadecimal: String {
    return map { String(format: "%02x", $0) }
      .joined()
  }
}

extension String {
  var hexadecimal: Data? {
    var data = Data(capacity: count / 2)
    
    let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
    regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
      let byteString = (self as NSString).substring(with: match!.range)
      let num = UInt8(byteString, radix: 16)!
      data.append(num)
    }
    
    guard data.count > 0 else { return nil }
    
    return data
  }
}


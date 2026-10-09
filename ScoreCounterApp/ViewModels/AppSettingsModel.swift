//
//  AppSettingsModel.swift
//  ScoreCounterApp
//
//  Created by Rafał Mazurek on 8/5/25.
//

import Foundation
import SwiftUI

class AppSettingsModel: ObservableObject {
    @Published var showTimer: Bool = true
    
    @Published var useScoreToWin: Bool = false
    @Published var minPossibleScoreToWin = 1
    @Published var maxPossibleScoreToWin = 999
    @Published var scoreToWin: Int = 10 {
        didSet {
            guard scoreToWin >= minPossibleScoreToWin else {
                scoreToWin = minPossibleScoreToWin
                return
            }
            guard scoreToWin <= maxPossibleScoreToWin else {
                scoreToWin = maxPossibleScoreToWin
                return
            }
        }
    }
    @Published var isThereAWinner: Bool = false
    
    func announceVictory(){
        guard !isThereAWinner else { return }
        isThereAWinner = true
    }
    
    func withdrawAnnouncementOfVictory(){
        guard isThereAWinner else { return }
        isThereAWinner = false
    }
    
    init () {}
}

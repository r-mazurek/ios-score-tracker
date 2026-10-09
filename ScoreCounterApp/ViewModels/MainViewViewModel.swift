//
//  MainViewViewModel.swift
//  ScoreCounterApp
//
//  Created by Rafał Mazurek on 8/4/25.
//

import Foundation
import Combine
import SwiftUI

class GameTimer: ObservableObject {
    @Published var timerString: String = "00:00"
    
    private var startDate: Date?
    private var pausedTime: TimeInterval = 0
    private var cancellable: Cancellable?
    
    @Published var isRunning: Bool = false
    
    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        startDate = Date()
        pausedTime = 0
        
        cancellable = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] currentDate in
                self?.updateTime(currentDate)
            }
    }
    
    func stopTimer() {
        guard isRunning else { return }
        isRunning = false
        pausedTime += Date().timeIntervalSince(startDate ?? Date())
        cancellable?.cancel()
    }
    
    func resumeTimer() {
        guard !isRunning else { return }
        isRunning = true
        startDate = Date()
        
        cancellable = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] currentDate in
                self?.updateTime(currentDate)
            }
    }
    
    func resetTimer() {
        isRunning = false
        startDate = nil
        pausedTime = 0
        cancellable?.cancel()
        timerString = "00:00"
    }
    
    private func updateTime(_ currentDate: Date) {
        guard let start = startDate else { return }
        let elapsed = currentDate.timeIntervalSince(start) + pausedTime
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        timerString = String(format: "%02d:%02d", minutes, seconds)
    }
}

class ScoreCounter: ObservableObject {
    @Published var scoreBlue: Int = 0
    @Published var scoreRed: Int = 0
    
    init() {}
    
    func getScore(teamColor: Color) -> Int {
        switch(teamColor) {
            case .blue:
                return scoreBlue
            case .red:
                return scoreRed
            default :
                print("Invalid color provided for getScore function")
                return 0
        }
    }
    
    func incrementScore(teamColor: Color) {
        switch(teamColor) {
            case .blue:
                scoreBlue += 1
            case .red:
                scoreRed += 1
            default :
                print("Invalid color provided for incrementScore function")
                break
        }
    }
    
    func decrementScore(teamColor: Color) {
        switch(teamColor) {
            case .blue:
                guard scoreBlue >= 1 else { return }
                scoreBlue -= 1
            case .red:
                guard scoreRed >= 1 else { return }
                scoreRed -= 1
            default :
                print("Invalid color provided for decrementScore function")
                break
        }
    }
    
    func setScore(teamColor: Color, value: Int){
        guard value >= 0 else { return }
        
        switch(teamColor) {
            case .blue:
                scoreBlue = value
            case .red:
                scoreRed = value
            default :
                print("Invalid color provided for setScore function")
                break
        }
    }
    
    func resetScoreForTeam(teamColor: Color) {
        switch(teamColor) {
            case .blue:
                scoreBlue = 0
            case .red:
                scoreRed = 0
            default :
                print("Invalid color provided for resetScoreForTeam function")
                break
        }
    }
    
    func resetScores() {
        scoreBlue = 0
        scoreRed = 0
    }
}

class TeamProperties: ObservableObject {
    @Published var teamNameBlue: String = "Blue"
    @Published var teamNameRed: String = "Red"
    
    init () {}
}

class MainViewViewModel: ObservableObject {
    
    @Published var scoreCounter: ScoreCounter = ScoreCounter()
    @Published var timerObject: GameTimer = GameTimer()
    @Published var teamProperties: TeamProperties = TeamProperties()
    
    init() {}
    
    
}

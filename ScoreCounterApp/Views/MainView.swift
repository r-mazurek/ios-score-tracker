//
//  MainView.swift
//  ScoreCounterApp
//
//  Created by Rafał Mazurek on 8/4/25.
//

import SwiftUI
import ConfettiSwiftUI

class HapticManager {
    static let instance = HapticManager() // Singleton
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()
    @StateObject var appSettings = AppSettingsModel()

    @State var isAppSettingsVisible: Bool = false
        
    struct TeamScoreCounter: View {
        let teamColor: Color
        @ObservedObject var scoreCounter: ScoreCounter
        @ObservedObject var teamProperties: TeamProperties
        @ObservedObject var appSettings: AppSettingsModel
        @State var showingTeamSettings: Bool = false
        @State var isWinner: Bool = false
        @State var fireConfetti: Int = 0
        
        var teamName: Binding<String> {
            if teamColor == .blue {
                return $teamProperties.teamNameBlue
            } else {
                return $teamProperties.teamNameRed
            }
        }
        
        var body: some View {
            ZStack {
                Rectangle()
                    .fill(teamColor)
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    if isWinner {
                        HStack{
                            Text("Winner!")
                                .font(.system(size: 30,
                                              weight: .bold))
                            Image(systemName: "star.fill")
                                .font(.system(size: 30))
                        }
                        .padding()
                    }
                    
                    Text(teamName.wrappedValue)
                        .font(.system(size: 32,
                                      weight: .light,
                                      design: .default))
                    
                    
                    Text(String(scoreCounter.getScore(
                        teamColor: teamColor)))
                        .font(.system(size: 72,
                                      weight: .bold,
                                      design: .default))
                    
                    if appSettings.useScoreToWin {
                        Text(String(appSettings.scoreToWin))
                            .opacity(0.8)
                    }
                }
                .confettiCannon(trigger: $fireConfetti,
                                num: 40,
                                radius: 250,
                                hapticFeedback: true)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                guard !appSettings.isThereAWinner else {
                    HapticManager.instance.notification(type: .error)
                    return
                }
                
                scoreCounter.incrementScore(teamColor: teamColor)
                
                guard !appSettings.useScoreToWin || scoreCounter.getScore(teamColor: teamColor) < appSettings.scoreToWin else {
                    isWinner = true
                    fireConfetti += 1
                    appSettings.announceVictory()
                    return
                }
                
                HapticManager.instance.notification(type: .success)
            }
            .onTapGesture(count: 2) {
                showingTeamSettings.toggle()
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        if value.translation.height > 50 {
                            scoreCounter.decrementScore(teamColor: teamColor)
                            HapticManager.instance.notification(type: .warning)
                        }
                    }
            )
            .onChange(of: appSettings.scoreToWin){ _, newValue in
                if scoreCounter.getScore(teamColor: teamColor) < newValue {
                    isWinner = false
                    appSettings.withdrawAnnouncementOfVictory()
                }
            }
            .onChange(of: teamColor == .blue ? scoreCounter.scoreBlue : scoreCounter.scoreRed){ _, newValue in
                guard isWinner && appSettings.useScoreToWin else { return }
                if newValue < appSettings.scoreToWin {
                    isWinner = false
                    appSettings.withdrawAnnouncementOfVictory()
                }
                
            }
            .fullScreenCover(
                isPresented: $showingTeamSettings,
                content: {
                    TeamSettingsView(
                        teamProperties: teamProperties,
                        scoreCounter: scoreCounter,
                        bgColor: teamColor)}
            )
            
        }
    }
    
    struct TimerBarView: View {
        @ObservedObject var timerObject: GameTimer
        
        struct TimerButton: View {
            let buttonText: String
            let buttonFunction: () -> Void
            
            var body: some View {
                Button(action: buttonFunction) {
                    Text(buttonText)
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .offset(y: 5)
                        .foregroundStyle(.cyan)
                }
            }
        }
        
        struct TimerView: View {
            @ObservedObject var timerObject: GameTimer
            
            var body: some View {
                Text(timerObject.timerString)
                    .font(.system(size: 32, weight: .bold, design: .default))
            }
        }
        
        struct DynamicTimerButtonsView: View {
            @ObservedObject var timerObject: GameTimer
            
            var body: some View {
                if timerObject.isRunning {
                    TimerButton(buttonText: "Stop timer") {
                        timerObject.stopTimer()
                    }
                } else {
                    if timerObject.timerString == "00:00" {
                        TimerButton(buttonText: "Start timer") {
                            timerObject.startTimer()
                        }
                    } else {
                        HStack {
                            TimerButton(buttonText: "Resume") {
                                timerObject.resumeTimer()
                            }
                            .padding(.horizontal, 8)
                            TimerButton(buttonText: "Reset") {
                                timerObject.resetTimer()
                            }
                        }
                    }
                }
            }
        }
        
        var body: some View {
            HStack {
                VStack {
                    TimerView(timerObject: timerObject)
                    
                    DynamicTimerButtonsView(timerObject: timerObject)
                        .padding(.bottom, 8)
                }
            }
            .frame(width: 180, height: 80)
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            
        }
    }
    
    struct SettingsButtonView: View {
        @Binding var isAppSettingsVisible: Bool

        var body: some View {
            Button {
                if isAppSettingsVisible {
                    isAppSettingsVisible = false
                } else {
                    withAnimation{
                        isAppSettingsVisible = true
                    }
                }
            } label: {
                Image(systemName: "gearshape.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 36))
            }
            .padding(.top, 25)
            .padding(.horizontal, -20)
        }
    }

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    TeamScoreCounter(
                        teamColor: .red,
                        scoreCounter: viewModel.scoreCounter,
                        teamProperties: viewModel.teamProperties,
                        appSettings: appSettings)
                    
                    TeamScoreCounter(
                        teamColor: .blue,
                        scoreCounter: viewModel.scoreCounter,
                        teamProperties: viewModel.teamProperties,
                        appSettings: appSettings)
                }
            }
       
            VStack {
                HStack {
                    Spacer()
                    SettingsButtonView(
                    isAppSettingsVisible: $isAppSettingsVisible)
                }
                
                Spacer()
                
                TimerBarView(timerObject: viewModel.timerObject)
                    .opacity((appSettings.showTimer) ? 1 : 0)
                    .animation(.easeInOut(duration: 0.25), value: appSettings.showTimer)
            }
            
            if isAppSettingsVisible {
                AppSettingsView(appSettings: appSettings,
                                scoreCounter: viewModel.scoreCounter)
                    .ignoresSafeArea(.all)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .move(edge: .bottom)
                        )
                    )
            }
        }
    }
}

#Preview {
    MainView()
}

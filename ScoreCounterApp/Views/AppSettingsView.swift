//
//  AppSettingsView.swift
//  ScoreCounterApp
//
//  Created by Rafał Mazurek on 8/5/25.
//

import SwiftUI

func bindingString(from intBinding: Binding<Int>) -> Binding<String> {
    return Binding<String>(
        get: {
            String(intBinding.wrappedValue)
        },
        set: { newValue in
            if let intValue = Int(newValue) {
                intBinding.wrappedValue = intValue
            }
        }
    )
}



struct AppSettingsView: View {
    @ObservedObject var appSettings: AppSettingsModel
    @ObservedObject var scoreCounter: ScoreCounter
    
    struct CheckboxSetting: View {
        var checkboxTitle: String = "Example Checkbox"
        @Binding var checkboxValue: Bool
        
        var body: some View {
            HStack {
                Toggle(checkboxTitle, isOn: $checkboxValue)
                    .frame(width: 450)
            }
            .padding(.bottom, 2)
        }
    }
    
    struct InputSetting: View {
        var inputTitle: String
        var textValue: Binding<String>
        
        var body: some View {
            HStack{
                Text(inputTitle)
                
                Spacer()
                
                TextField("", text: textValue)
                    .padding()
                    .frame(width: 70, height: 35)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                
            }
            .frame(width: 450)
            .padding(.bottom, 2)
        }
    }
    
    struct ResetScoresButton: View {
        var title: String
        var scoreCounter: ScoreCounter
        
        var body: some View {
            
            Button {
                scoreCounter.resetScores()
            } label: {
                Text(title)
                    .foregroundStyle(.white)
                    .font(.system(size: 18,
                                  weight: .bold))
                    .frame(width: 200, height: 30)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .frame(width: 450)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("App Settings")
                    .font(.title)
                    .padding(20)
                    .padding(.bottom, -15)
                    .bold()
                
                Text("Double tap anywhere on the main screen for team settings.")
                    .padding(.bottom, 20)
                    .opacity(0.8)
                
                CheckboxSetting(
                    checkboxTitle: "Show Timer Window",
                    checkboxValue: $appSettings.showTimer)
                
                CheckboxSetting(
                    checkboxTitle: "Use Score To Win",
                    checkboxValue: $appSettings.useScoreToWin)
                
                if appSettings.useScoreToWin {
                    InputSetting(inputTitle: "Score To Win",
                                 textValue: bindingString(from: $appSettings.scoreToWin))
                }
                
                ResetScoresButton(title: "Reset all scores",
                                  scoreCounter: scoreCounter)
                .offset(x: 125,
                        y: appSettings.useScoreToWin ? 71.5 : 115)
                
                Spacer()
            }
            .frame(width: geometry.size.width * 0.75,
                   height: geometry.size.height * 0.95)
            .background(
                .ultraThinMaterial
            )
            .cornerRadius(20)
            .position(x: geometry.size.width / 2,
                      y: geometry.size.height / 2)
        }
    }
}

#Preview {
    AppSettingsView(appSettings: AppSettingsModel(),
                    scoreCounter: ScoreCounter())
}

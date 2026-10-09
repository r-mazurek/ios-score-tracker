//
//  TeamSettingsView.swift
//  ScoreCounterApp
//
//  Created by Rafał Mazurek on 8/4/25.
//

import SwiftUI

struct TeamSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = TeamSettingsViewModel()
    @ObservedObject var teamProperties: TeamProperties
    @ObservedObject var scoreCounter: ScoreCounter
    
    @State var bgColor: Color = .blue
    @State private var scoreInputHeight: CGFloat = 40
    
    struct settingsTextLabel: View {
        var title: String
        var placeholder: String
        var text: Binding<String>
        var customLabelWidthChange: CGFloat?
        var scoreLabelFrameHeightInfo: Binding<CGFloat>?
        var numericOnly: Bool?
        
        var labelWidth: CGFloat = 180

        @FocusState private var isFocused: Bool
        @State private var backgroundOpacity: CGFloat = 0.2
        @State private var titleTextSize: CGFloat = 20
        @State private var titleTextWeight: Font.Weight = .semibold
        @State private var labelFrameHeight: CGFloat = 40
        @State private var labelTextBold: Bool = false
        
        var body: some View {
            
            HStack{
                Text(title)
                    .frame(width: 180, alignment: .leading)
                    .font(.system(size: titleTextSize,
                                  weight: titleTextWeight,
                                  design: .default))
                    
                    
                TextField(placeholder,
                          text: text)
                .focused($isFocused)
                .frame(width: labelWidth + (customLabelWidthChange ?? 0), height: labelFrameHeight)
                .padding(.horizontal)
                .background(Color.black.opacity(backgroundOpacity))
                .cornerRadius(10)
                .bold(labelTextBold)
                .onChange(of: isFocused, { _, newValue in
                    withAnimation(.easeOut(duration: 0.3)) {
                        backgroundOpacity = newValue ? 0.4 : 0.2
                        titleTextSize = newValue ? 22 : 20
                        titleTextWeight = newValue ? .heavy : .semibold
                        labelFrameHeight = newValue ? 45 : 40
                        labelTextBold = newValue
                    }
                })
                .onChange(of: labelFrameHeight) { _, newValue in
                    withAnimation{
                        scoreLabelFrameHeightInfo?.wrappedValue = newValue
                    }
                }
                .keyboardType((numericOnly ?? false) ? .numberPad : .default)
            }
        }
    }
    
    struct ResetCurrentScoreButton: View {
        var title: String = "Reset"
        static var width: CGFloat = 70
        @Binding var scoreInputHeight: CGFloat
        @Binding var bgColor: Color
        @ObservedObject var scoreCounter: ScoreCounter
        
        var body: some View {
            Button {
                guard bgColor == .red || bgColor == .blue else {
                    print("Tried to reset the score for an unknown team")
                    return
                }
                
                if bgColor == .red {
                    scoreCounter.scoreRed = 0
                } else {
                    scoreCounter.scoreBlue = 0
                }
                
            } label: {
                Text("Reset")
            }
            .foregroundStyle(.white)
            .font(.system(size: 16,
                          weight: .bold))
            .frame(width: TeamSettingsView.ResetCurrentScoreButton.width, height: scoreInputHeight)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
        }
    }
    
    var teamNameBinding: Binding<String> {
        bgColor == .red
        ? $teamProperties.teamNameRed
        : $teamProperties.teamNameBlue
    }
    
    var teamScoreBinding: Binding<String> {
        Binding<String>(
            get: {
                String(bgColor == .red
                       ? scoreCounter.scoreRed
                       : scoreCounter.scoreBlue)
            },
            set: { newValue in
                if bgColor == .red {
                    scoreCounter.scoreRed = Int(newValue) ?? 0
                } else {
                    scoreCounter.scoreBlue = Int(newValue) ?? 0
                }
            }
        )
    }

    
    var body: some View {
        NavigationView {
            ZStack {
                bgColor
                    .ignoresSafeArea(.all)
                    .animation(.easeOut(duration: 0.5),
                               value: bgColor)
                
                VStack {
                    VStack(spacing: 16) {
                        settingsTextLabel(title: "Team Name: ",
                                          placeholder: "Provide a team name",
                                          text: teamNameBinding)
                        HStack{
                            settingsTextLabel(title: "Current Points: ",
                                              placeholder: "Input points",
                                              text: teamScoreBinding,
                                              customLabelWidthChange: -ResetCurrentScoreButton.width,
                                              scoreLabelFrameHeightInfo: $scoreInputHeight,
                                              numericOnly: true)
                            
                            ResetCurrentScoreButton(
                                scoreInputHeight: $scoreInputHeight,
                                bgColor: $bgColor,
                                scoreCounter: scoreCounter
                            )
                        }
                        

                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                            Text("Save")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .frame(width: 150, height: 40)
                        .padding(.top, 50)

                            
                    }
                }
                
            }
            .safeAreaInset(edge: .top){
                HStack{
                    Button {
                        bgColor = bgColor == .blue ? .red : .blue
                    } label: {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(bgColor == .blue ? .red : .blue)
                        .frame(width: 45, height: 45)
                        .cornerRadius(25)
                        .overlay {
                            Circle()
                                .stroke(style: StrokeStyle(lineWidth: 5))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    Text(bgColor == .red ? "Red Team Settings" : "Blue Team Settings")
                        .font(.system(size: 36,
                                      weight: .bold,
                                      design: .default))
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .font(.system(size: 36,
                                  weight: .bold))
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.white)
                }
                .padding(.top, 30)
                

            }
        }
    }
}

#Preview {
    TeamSettingsView(teamProperties: TeamProperties(),
                     scoreCounter: ScoreCounter())
}

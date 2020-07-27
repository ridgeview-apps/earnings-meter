//
//  MeterView.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 16/01/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import SwiftUI
import Combine

struct MeterView: View {
    
    @ObservedObject private var viewModel: MeterViewModel
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    init(appEnvironment: AppEnvironment,
         onTappedSettings: @escaping ActionHandler = {}) {
        viewModel = MeterViewModel(appState: appEnvironment.appState,
                                   actionHandlers: .init(onTappedSettings: onTappedSettings))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(viewModel.backgroundImage)
                    .overlay(meterContainerView)
                    .onAppear(perform: viewModel.inputs.appear)
                    .navigationBarItems(trailing: settingsButton)
                    .offset(y: -64)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
    
    private var meterContainerView: some View {
        VStack {
            titleView
            Spacer()
            VStack(spacing: horizontalSizeClass == .regular ? 40 : 10) {
                MeterDigitsView(amount: viewModel.currentReading.amountEarned,
                                isEnabled: viewModel.currentReading.progress > 0,
                                formatter: .decimalStyle)
                    .animation(.none)
                hireStatusView
            }
            Spacer()
            ProgressBarView(leftLabelText: viewModel.progressBarStartTimeText,
                            rightLabelText: viewModel.progressBarEndTimeText,
                            value: viewModel.currentReading.progress,
                            enabledTextColor: .white,
                            fontSize: 4,
                            isEnabled: viewModel.currentReading.progress > 0)
                .frame(maxWidth: 500)

        }
        .padding([.top, .leading, .trailing],
                 horizontalSizeClass == .regular ? 40 : 20)
        .padding(.bottom,
                 horizontalSizeClass == .regular ? 70 : 45)

    }
    
    private var titleView: some View {
        HStack {
            Rectangle()
                .frame(height: 2)
                .padding(.leading, 20)
            Text(viewModel.headerTextKey)
                .font(Font.body.smallCaps())
                .layoutPriority(1)
            Rectangle()
                .frame(height: 2)
                .padding(.trailing, 20)
        }
        .foregroundColor(.white)
    }
    
    private var hireStatusView: some View {
        HStack(spacing: 20) {
            ForEach(viewModel.hireStatusPickerItems) { item in
                Text(item.textLocalizedKey)
                    .font(Font.headline.smallCaps())
                    .fontWeight(item.isSelected ? .bold : .regular)
                    .foregroundColor(item.isSelected ? .white : .disabledText)
                    .minimumScaleFactor(0.9)
            }
        }
    }
    
    private var settingsButton: some View {
        Button(action: viewModel.inputs.tapSettingsButton) {
            Image(systemName: "gear")
                .imageScale(.large)
                .padding([.top, .bottom, .leading])
        }
    }
}

struct MeterView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            meterOffDuty
            UIElementPreview(meterRunningPreview)
        }
    }
    
    static var meterRunningPreview: MeterView {
        let appEnvironment = AppEnvironment.preview
        appEnvironment.appState.userData.meterSettings = .fake(runAtWeekends: true)
        return MeterView(appEnvironment: .preview)
    }
    
    static var meterOffDuty: MeterView {
        let appEnvironment = AppEnvironment.preview
        appEnvironment.appState.userData.meterSettings = .fake(runAtWeekends: false)
        return MeterView(appEnvironment: .preview)
    }
}

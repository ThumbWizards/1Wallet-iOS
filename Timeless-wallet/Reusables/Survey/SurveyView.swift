//
//  SurveyView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 3/8/22.
//

import SwiftUI

struct SurveyView {
    @AppStorage(ASSettings.Survey.selected.key)
    private var selectedSurvey = ASSettings.Survey.selected.defaultValue
    var surveyModel: SurveyModel
    @State private var renderVideo = false
}

extension SurveyView: View {
    var body: some View {
        contentView
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                renderVideo.toggle()
            }
    }
}

extension SurveyView {
    private var contentView: some View {
        VStack(spacing: 0) {
            titleView
                .padding(.leading, 26)
                .padding(.trailing, 54)
                .padding(.bottom, 25)
            let mediaResource = MediaResourceModel(path: surveyModel.urlImage,
                                                   altText: nil,
                                                   pathPrefix: nil,
                                                   mediaType: "mp4",
                                                   thumbnail: nil)
            MediaResourceView(for: MediaResource(for: mediaResource), isPlaying: .constant(true))
                .scaledToFill()
                .background(Color.black)
                .padding(.bottom, 34)
                .id(renderVideo)
            surveyView
                .padding(.horizontal, 26)
        }
        .padding(.bottom, 40)
    }

    private var titleView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(surveyModel.title)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color.white)
                Text(surveyModel.description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color.white40)
            }
            Spacer()
        }
    }

    private var surveyView: some View {
        VStack(spacing: 10) {
            ForEach(surveyModel.options, id: \.self) { text in
                Button(action: {
                    withAnimation {
                        selectedSurvey = true
                    }
                }) {
                    HStack {
                        Text(text)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color.white87)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .frame(height: 48, alignment: .leading)
                    .background(Color.surveyBG)
                    .cornerRadius(10)
                }
            }
        }
    }
}

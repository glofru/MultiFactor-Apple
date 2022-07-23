//
//  AuthCodeView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 21/07/22.
//

import SwiftUI

struct AuthCodeView: View {
    static private let cornerRadius = 12.0

    @State private var code = AuthCode(issuer: "Google", account: "gianluca.lofrumento@gmail.com")

    var body: some View {
        Button(action: {

        }, label: {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image("google")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .frame(width: 40, height: 40)
                        .background(.red)
                        .cornerRadius(AuthCodeView.cornerRadius)
                        .shadow(color: .red.opacity(0.4), radius: 3, y: 2)

                    VStack(alignment: .leading) {
                        Text(code.issuer)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(code.account)
                            .font(.caption2)
                    }

                    Spacer()

                    LoadingSpinner()
                        .frame(width: 35, height: 35)
                }.frame(height: 40)

                HStack {
                    ForEach(0..<6) { index in
                        Text(String(code.code[index].rawValue))
                            .fontWeight(.bold)
                            .font(.title)
                            .frame(width: 30)
                            .glassBackground(.background)
                            .cornerRadius(8)
                        if index != 5 {
                            Spacer()
                        }
                    }
                }
            }
            .padding()
            .glassBackground(.element, intensity: .strong)
            .frame(maxWidth: 400)
            .cornerRadius(AuthCodeView.cornerRadius)
            #if os(iOS)
            .foregroundColor(Color(uiColor: .label))
            #endif
        })
    }
}

struct LoadingSpinner: View {
    private let loadingTime = 30.0

    @State private var loaded = 1.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .foregroundColor(Color.gray.opacity(0.1))
            Circle()
                .trim(from: 0, to: loaded)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotation(.degrees(-90))
                .foregroundColor(loaded > 0.8 ? Color.green : Color.red)
                .onAppear {
                    withAnimation(.easeIn(duration: loadingTime).repeatForever(autoreverses: false)) {
                        loaded = 0
                    }
                }
        }
    }
}

struct AuthCode {
    let issuer: String
    let account: String

    let logo = "google"
    let code = [Number.one, .two, .three, .four, .five, .six]

    enum Number: Int {
        case one = 1, two, three, four, five, six, seven, eight, nine, ten
    }
}

struct AuthCodeView_Previews: PreviewProvider {
    static var previews: some View {
        AuthCodeView()
    }
}

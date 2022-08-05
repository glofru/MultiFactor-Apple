//
//  AuthCodeView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 21/07/22.
//

import SwiftUI

struct OTPView: View {
    static private let cornerRadius = 12.0

    @Namespace private var namespace

    @EnvironmentObject private var homeViewModel: HomeViewModel
    @StateObject private var totpViewModel: TOTPViewModel

    init(encryptedOTP: EncryptedOTP) {
        _totpViewModel = StateObject(wrappedValue: TOTPViewModel.getInstance(otp: encryptedOTP))
    }

    var body: some View {
        Button(action: {

        }, label: {
            HStack {
                if let knownProvider = KnowProviders(rawValue: (totpViewModel.issuer ?? "").lowercased()) {
                    Image(knownProvider.rawValue)
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .frame(width: 40, height: 40)
                        .background(knownProvider.color)
                        .cornerRadius(OTPView.cornerRadius)
                        .shadow(color: knownProvider.color.opacity(0.4), radius: 3, y: 2)
                        .privacySensitive()
                } else {
                    Text(String(totpViewModel.issuer?.first ?? totpViewModel.label?.first ?? " "))
                        .frame(width: 30, height: 30, alignment: .center)
                        .frame(width: 40, height: 40)
                        .background(.white) //TODO: random
                        .cornerRadius(OTPView.cornerRadius)
                        .shadow(color: .white.opacity(0.4), radius: 3, y: 2)
                        .privacySensitive()
                }

                VStack(alignment: .leading) {
                    Text(totpViewModel.issuer ?? "No issuer")
                        .font(.title2)
                        .bold()
                    Text(totpViewModel.label ?? "No label")
                        .font(.caption2)
                }
                .privacySensitive()

                Spacer()

                Text(totpViewModel.code)
                    .font(.custom("American Typewriter", size: 20))
                    .bold()
//                    .frame(width: 30)
//                    .glassBackground(.background)
                    .cornerRadius(8)
                    .onReceive(MFClock.shared.$time) { time in
                        totpViewModel.generateCode(for: time)
                    }
                    .onAppear {
                        totpViewModel.generateCode(for: .now)
                    }
                    .privacySensitive()

                LoadingSpinner(period: totpViewModel.period)
                    .frame(width: 25)
            }
            .padding(10)
            .glassBackground(.element, intensity: .strong)
            .frame(maxWidth: 400)
            .cornerRadius(OTPView.cornerRadius)
            #if os(iOS)
            .foregroundColor(Color(uiColor: .label))
            #endif
        })
        .frame(height: 40)
        .matchedGeometryEffect(id: totpViewModel.id, in: namespace)
        .contextMenu {
            Button(action: {
                print("Copy")
            }, label: {
                Label("Copy", systemImage: "doc.on.doc")
            })

            Button(action: {
                print("Share")
            }, label: {
                Label("Share", systemImage: "square.and.arrow.up")
            })

            Button(role: .destructive, action: {
                Task {
                    try? await Task.sleep(nanoseconds: 400_000)
                    await homeViewModel.deleteOTP(totpViewModel.id)
                }
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        }
    }
}

struct LoadingSpinner: View {

    private let period: Double

    @ObservedObject private var clock = MFClock.shared

    init(period: DecryptedOTP.Period) {
        self.period = Double(period.rawValue)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .foregroundColor(Color.gray.opacity(0.1))
            Circle()
                .trim(from: 0, to: clock.loaded)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotation(.degrees(-90))
                .foregroundColor(clock.loaded > 0.3 ? Color.green : clock.loaded > 0.1 ? Color.yellow : Color.red)
                .animation(.linear(duration: 1), value: clock.loaded)
        }
    }
}

struct OTPView_Previews: PreviewProvider {
    static var previews: some View {
        return OTPView(encryptedOTP: EncryptedOTP(context: PersistenceController.shared.context))
            .padding()
    }
}

private enum KnowProviders: String {
    case amazon
    case autodesk
    case binance
    case discord
    case dropbox
    case facebook
    case github
    case google
    case instagram
    case jetbrains
    case netflix
    case paypal
    case reddit
    case twitter

    var color: Color {
        switch self {
        case .amazon:
            return .white
        case .autodesk:
            return .white
        case .binance:
            return Color(.sRGB, red: 34/255, green: 34/255, blue: 34/255)
        case .discord:
            return Color(.sRGB, red: 77/255, green: 96/255, blue: 233/255)
        case .dropbox:
            return Color(.sRGB, red: 13/255, green: 35/255, blue: 129/255)
        case .facebook:
            return Color(.sRGB, red: 26/255, green: 119/255, blue: 242/255)
        case .github:
            return .white
        case .google:
            return .red
        case .instagram:
            return .white
        case .jetbrains:
            return .white
        case .netflix:
            return .black
        case .paypal:
            return .white
        case .reddit:
            return Color(.sRGB, red: 242/255, green: 66/255, blue: 1/255)
        case .twitter:
            return Color(.sRGB, red: 30/255, green: 161/255, blue: 241/255)
        }
    }
}

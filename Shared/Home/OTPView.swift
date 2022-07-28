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
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image("google")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .frame(width: 40, height: 40)
                        .background(.red)
                        .cornerRadius(OTPView.cornerRadius)
                        .shadow(color: .red.opacity(0.4), radius: 3, y: 2)

                    VStack(alignment: .leading) {
                        Text(totpViewModel.issuer ?? "No issuer")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(totpViewModel.label ?? "No label")
                            .font(.caption2)
                    }

                    Spacer()

                    LoadingSpinner()
                        .frame(width: 35, height: 35)
                }.frame(height: 40)

                HStack {
                    ForEach(0..<6) { index in
                        Text(totpViewModel.code[index])
                            .fontWeight(.bold)
                            .font(.title)
                            .frame(width: 30)
                            .glassBackground(.background)
                            .cornerRadius(8)
                            .onReceive(MFClock.shared.$time) { time in
                                totpViewModel.generateCode(for: time)
                            }
                        if index != 5 {
                            Spacer()
                        }
                    }
                }
            }
            .padding()
            .glassBackground(.element, intensity: .strong)
            .frame(maxWidth: 400)
            .cornerRadius(OTPView.cornerRadius)
            #if os(iOS)
            .foregroundColor(Color(uiColor: .label))
            #endif
        })
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

    @State private var loaded = 1.0 //TODO: color

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
                .onReceive(MFClock.shared.$time) { time in
                    let seconds = Double(Calendar.current.component(.second, from: time))
                    let toLoad = 30.0 - seconds.truncatingRemainder(dividingBy: 30)
                    loaded = toLoad / 30

                    withAnimation(.linear(duration: toLoad)) {
                        loaded = 0
                    }
                }
        }
    }
}

struct OTPView_Previews: PreviewProvider {
    static var previews: some View {
        OTPView(encryptedOTP: EncryptedOTP(entity: .init(), insertInto: .none))
    }
}

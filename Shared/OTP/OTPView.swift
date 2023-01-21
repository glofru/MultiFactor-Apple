//
//  AuthCodeView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 21/07/22.
//

import SwiftUI

struct OTPView: View {
    static private let cornerRadius = 12.0

    @Environment(\.scenePhase) private var scenePhase

    @EnvironmentObject private var homeViewModel: HomeViewModel
    @StateObject private var totpViewModel: TOTPViewModel

    @State private var presentedActionSheet: PresentedActionSheet?

    init(viewModel: TOTPViewModel) {
        _totpViewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Button(action: copyCode, label: {
            HStack {
                if let knownProvider = KnowProviders(rawValue: (totpViewModel.issuer ?? "").lowercased()) {
                    Image(knownProvider.rawValue)
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .frame(width: 40, height: 40)
                        .background(knownProvider.color)
                        .cornerRadius(OTPView.cornerRadius)
//                        .shadow(color: knownProvider.color.opacity(0.4), radius: 3, y: 2)
//                        .privacySensitive()
                } else {
                    Text(String(totpViewModel.issuer?.first ?? totpViewModel.label?.first ?? " "))
                        .frame(width: 30, height: 30, alignment: .center)
                        .frame(width: 40, height: 40)
                        .background(Color.systemBackground)
                        .cornerRadius(OTPView.cornerRadius)
//                        .shadow(color: .white.opacity(0.4), radius: 3, y: 2)
//                        .privacySensitive()
                }

                VStack(alignment: .leading) {
                    Text(totpViewModel.issuer ?? "No issuer")
                        .font(.title2)
                        .bold()
                    Text(totpViewModel.label ?? "No label")
                        .font(.caption2)
                }
//                .privacySensitive()

                Spacer()

                Text(totpViewModel.code)
                    .font(.custom("Poppins", size: 20).monospaced())
                    .onReceive(MFClock.shared.$time) { time in
                        // Avoid the sheet to reload if the code is updated
                        if presentedActionSheet == nil {
                            totpViewModel.generateCode(for: time)
                        }
                    }
                    .onAppear {
                        totpViewModel.generateCode(for: .now)
                    }
//                    .privacySensitive()

                LoadingSpinner(period: totpViewModel.period)
            }
            .padding(8)
            .glassBackground(.element, intensity: .weak)
            .frame(maxWidth: 400)
            .cornerRadius(OTPView.cornerRadius*1.5)
            #if os(iOS)
            .foregroundColor(Color(uiColor: .label))
            #endif
        })
        .frame(height: 40)
        .contextMenu {
            Button(action: copyCode, label: {
                Label("Copy", systemImage: "doc.on.doc")
            })

            Button(action: {
                presentedActionSheet = .edit
            }, label: {
                Label("Edit", systemImage: "pencil")
            })

            Button(action: {
                presentedActionSheet = .share
            }, label: {
                Label("Share", systemImage: "square.and.arrow.up")
            })

            Button(role: .destructive, action: {
                presentedActionSheet = .delete
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        }
        .sheet(item: $presentedActionSheet, onDismiss: {
            totpViewModel.generateCode(for: .now)
        }) { type in
            switch type {
            case .edit: EditOTPView(totpViewModel: totpViewModel)
            case .share: ShareOTPView(totpViewModel: totpViewModel)
            case .delete: DeleteOTPView(totpViewModel: totpViewModel)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                totpViewModel.generateCode(for: .now)
            }
        }
    }

    private func copyCode() {
        homeViewModel.copyCode(totpViewModel.code)
    }

    private enum PresentedActionSheet: Identifiable {
        case edit, share, delete

        var id: UUID {
            UUID()
        }
    }
}

private struct EditOTPView: View {

    @Environment(\.dismiss) private var dismiss

    @ObservedObject var totpViewModel: TOTPViewModel

    @State private var hideSecret = true

    static private let placeholderSecret = "••••••••••"

    @State private var issuer: String
    @State private var label: String
    @State private var algorithm: DecryptedOTP.Algorithm
    @State private var digits: DecryptedOTP.Digits
    @State private var period: DecryptedOTP.Period

    init(totpViewModel: TOTPViewModel) {
        self.totpViewModel = totpViewModel

        self._issuer = State(initialValue: totpViewModel.issuer ?? "")
        self._label = State(initialValue: totpViewModel.label ?? "")
        self._algorithm = State(initialValue: totpViewModel.algorithm)
        self._digits = State(initialValue: totpViewModel.digits)
        self._period = State(initialValue: totpViewModel.period)
    }

    var body: some View {
        Group {
            Form {
                Section(header: Text("Secret"), footer: Text("Click to reveal")) {
                    Button(hideSecret ? EditOTPView.placeholderSecret : totpViewModel.secret) {
                        hideSecret.toggle()
                    }
                            .foregroundColor(.label)
                }

                Section("Issuer") {
                    TextField("Name", text: self.$issuer)
                }

                Section("Label") {
                    TextField("Name", text: self.$label)
                }

                Section("Algorithm") {
                    Picker("Algorithm", selection: self.$algorithm) {
                        ForEach(DecryptedOTP.Algorithm.allCases, id: \.self) { algorithm in
                            Text(algorithm.rawValue.uppercased())
                                    .tag(algorithm)
                        }
                    }
                            .pickerStyle(.segmented)
                }

                Section("Digits") {
                    Picker("Digits", selection: self.$digits) {
                        ForEach(DecryptedOTP.Digits.allCases, id: \.self) { digit in
                            Text("\(digit.rawValue)")
                                    .tag(digit)
                        }
                    }
                            .pickerStyle(.segmented)
                }

                Section("Period") {
                    Picker("Period", selection: self.$period) {
                        ForEach(DecryptedOTP.Period.allCases, id: \.self) { period in
                            Text("\(period.rawValue)")
                                    .tag(period)
                        }
                    }
                            .pickerStyle(.segmented)
                }
            }
                    .textFieldStyle(.plain)

            Button(action: {
                totpViewModel.issuer = issuer
                totpViewModel.label = label
                totpViewModel.algorithm = algorithm
                totpViewModel.digits = digits
                totpViewModel.period = period

                Task {
                    try? await totpViewModel.update()
                }

                dismiss()
            }, label: {
                Label("Save", systemImage: "pencil.line")
                        .gradientBackground(.login)
            })
                    .padding()
        }
    }
}

private struct ShareOTPView: View {

    @ObservedObject var totpViewModel: TOTPViewModel

    @State private var showQrCode = false
    @State private var resultQRCode: ImageSaver.Result?

    @State private var showDownload = false

    private var size: CGFloat {
        UIScreen.main.bounds.size.width - 32
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Button(action: {
                    showQrCode.toggle()
                }, label: {
                    Group {
                        if showQrCode {
                            if let qrCode = totpViewModel.encode()?.qrCode {
                                Image(uiImage: qrCode)
                                    .resizable()
                                    .padding()
                                    .background(.white)
                                    .id("qrCode")
                            } else {
                                Text("There was an error generating the QR code.")
                            }
                        } else {
                            Image(systemName: "lock.shield")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.label)
                                .id("lock")
                        }
                    }
                    .frame(width: size, height: size)
                    .background(Color.label.opacity(0.2))
                    .cornerRadius(30)
                    .animation(.default, value: showQrCode)
                })
                .padding(.bottom)

                Button(action: {
                    showQrCode.toggle()
                }, label: {
                    Label(showQrCode ? "Hide QR code" : "Show QR code", systemImage: showQrCode ? "eye.slash" : "eye")
                        .gradientBackground(.login)
                })
            }
            .padding()
            .navigationTitle(totpViewModel.issuer ?? "Share")
            .toolbar {
                Button(action: {
                    showDownload = true
                }, label: {
                    Image(systemName: "square.and.arrow.down")
                })
            }
        }
        .confirmationDialog("Save on gallery", isPresented: $showDownload, actions: {
            Button(role: .destructive, action: {
                totpViewModel.saveQRCodeInLibrary(onCompleted: { result in
                    self.resultQRCode = result
                })
            }, label: {
                Text("Save")
            })
        }, message: {
            Text("Are you sure do you want to save the QR code in your gallery? This is not a safe choice to protect your sensitive data.")
        })
        .alert(item: $resultQRCode) { result in
            let title: String
            let message: String
            switch result {
            case .success:
                title = "Info"
                message = "QR code successfully saved."
            case .qrGenerationFailed:
                title = "Error"
                message = "There was an error generating the QR code."
            case .savingFailed: fallthrough
            default:
                title = "Error"
                message = "There was an error saving the image. Be sure to give the permissions under Settings > MultiFactor."
            }
            return Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("Ok")))
        }
    }
}

struct DeleteOTPView: View {

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var homeViewModel: HomeViewModel

    @ObservedObject var totpViewModel: TOTPViewModel

    @State private var showConfirmation = false

    var body: some View {
        NavigationView {
            VStack {
                Text(totpViewModel.issuer?.isEmpty == false ? "Are you sure you want to delete \"\(totpViewModel.issuer!)\"?" : "Are you sure you want to delete this OTP?")
                        .font(.largeTitle)
                        .bold()

                Spacer()

                Text("This OTP will be deleted from all of your devices. Once deleted, it cannot be recovered in any way.")
                        .multilineTextAlignment(.center)

                Button(action: {
                    showConfirmation = true
                }, label: {
                    Label("Delete", systemImage: "trash")
                            .gradientBackground(.signUp)
                })

                Spacer()
            }
                    .padding()
                    .toolbar {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Cancel")
                        })
                    }
                    .confirmationDialog("Deleting this OTP is an IRREVERSIBLE action. Are you sure you want to proceed?", isPresented: $showConfirmation, titleVisibility: .visible) {
                        Button("Yes", role: .destructive) {
                            Task(priority: .userInitiated) {
                                await homeViewModel.deleteOTP(totpViewModel.id)
                            }
                            dismiss()
                        }

                        Button("Cancel", role: .cancel) {
                            dismiss()
                        }
                    }
        }
    }
}

private struct LoadingSpinner: View {

    private let period: Double

    static private let lineWidth = 3

    @AppStorage(MFKeys.loadingSpinner) private var showTime = true

    @ObservedObject private var clock = MFClock.shared

    init(period: DecryptedOTP.Period) {
        self.period = Double(period.rawValue)
    }

    private var loadingColor: Color {
        if showTime {
            return clock.loaded > 0.16 ? .green : .red
        } else {
            return clock.loaded > 0.3 ? .green : clock.loaded > 0.1 ? .yellow : .red
        }
    }

    var body: some View {
        ZStack {
            if showTime {
                Text("0:\(String(format: "%02d", Int(period * clock.loaded)))")
                    .font(.custom("Poppins", size: 16).monospaced())
                    .padding(4)
                    .background(loadingColor)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            } else {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .foregroundColor(Color.gray.opacity(0.1))
                    .frame(width: 25)
                Circle()
                    .trim(from: 0, to: clock.loaded)
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotation(.degrees(-90))
                    .foregroundColor(loadingColor)
                    .frame(width: 25)
            }
        }
        .animation(.linear(duration: 1), value: clock.loaded)
        .animation(.default, value: showTime)
        .highPriorityGesture(
            TapGesture()
                .onEnded {
                    showTime.toggle()
                }
        )
    }
}

struct OTPView_Previews: PreviewProvider {
    static var previews: some View {
//        return OTPView(viewModel: TOTPViewModel.getInstance(otp: .init(entity: .init(), insertInto: .none)))
//            .padding()
        return ShareOTPView(totpViewModel: .getInstance(otp: .init(entity: .init(), insertInto: .none)))
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

//
//  ForgotPasswordView.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 19/08/22.
//

import SwiftUI

struct ForgotPasswordView: View {

    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel

    @State private var username = ""
    @State private var message: String?
    @State private var status = Status.userInput

    private func restorePassword() {
        status = .waiting
        Task {
            if let error = await authenticationViewModel.sendResetPasswordLink(to: username) {
                await MainActor.run {
                    message = error.localizedDescription
                    status = .userInput
                }
            } else {
                await MainActor.run {
                    status = .completed
                }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text("Forgot password")
                    .mfFont(size: 30)
                    .bold()
                    .padding(.vertical)
                Spacer()
            }

            Text("Please enter your registered email ID. We’ll send a code to reset your password.")

            TextField("Username", text: $username)
                .submitLabel(.next)
                .onSubmit(restorePassword)
                .disableAutocorrection(true)
                .padding(.vertical)
            #if os(iOS)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
            #endif

            if let message = message {
                Text(message)
                    .foregroundColor(.red)
            }

            if status != .completed {
                Button(action: restorePassword, label: {
                    if status == .waiting {
                        ProgressView()
                            .gradientBackground(.signUp)
                    } else {
                        Text("Send")
                            .gradientBackground(.signUp)
                    }
                })
            } else {
                HStack {
                    Spacer()
                    AnimatedCheckmark()
                    Spacer()
                }
            }

//            if #unavailable(iOS 16) {
//                Spacer()
//            }
        }
        .padding()
        .animation(.default, value: status)
        .disabled(status != .userInput)
    }

    private enum Status {
        case userInput, waiting, completed
    }
}

private struct AnimatedCheckmark: View {
    private let animationDuration: Double = 0.40

    @Environment(\.dismiss) private var dismiss

    @State private var trimCircle: CGFloat = 0
    @State private var trimCheckmark: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: trimCircle)
                .stroke(Color.green, lineWidth: 4)
                .rotationEffect(.degrees(-90))

            Checkmark()
                .trim(from: 0.0, to: trimCheckmark)
                .stroke(Color.green, lineWidth: 4)
                .frame(width: 20, height: 20)
        }
        .frame(width: 40, height: 40)
        .onAppear {
            withAnimation(.linear(duration: animationDuration)) {
                trimCircle = 1.0
            }
            withAnimation(
                .linear(duration: animationDuration)
                .delay(animationDuration)) {
                trimCheckmark = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration*2.2) {
                dismiss()
            }
        }
    }

    private struct Checkmark: Shape {
        func path(in rect: CGRect) -> Path {
            let width = rect.size.width
            let height = rect.size.height
     
            var path = Path()
            path.move(to: .init(x: 0 * width, y: 0.5 * height))
            path.addLine(to: .init(x: 0.4 * width, y: 1.0 * height))
            path.addLine(to: .init(x: 1.0 * width, y: 0 * height))
            return path
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}

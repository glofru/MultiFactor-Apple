//
//  CodesView.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 12/08/22.
//

import SwiftUI

struct CodesView: View {

    @EnvironmentObject private var homeViewModel: HomeViewModel

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\EncryptedOTP.label)
    ])
    private var encryptedOTPs: FetchedResults<EncryptedOTP>

    @State private var sheet: PresentedSheet?

    var body: some View {
        NavigationView {
            ScrollView {
                Button(action: {
                    sheet = .addQr
                }, label: {
                    Label("Add", systemImage: "plus")
                })

                if encryptedOTPs.isEmpty {
                    Text("No otps")
                } else {
                    LazyVStack {
                        ForEach(encryptedOTPs, id: \.id) { otp in
                            if otp.isValid {
                                OTPView(encryptedOTP: otp)
                                    .padding(.vertical, 10)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle("MultiFactor")
        }
        .sheet(item: $sheet) { type in
            switch type {
            case .addQr:
                AddOTPView(onFillManually: {
                    sheet = .addManual
                })
            case .addManual:
                AddOTPManuallyView()
            }
        }
    }

    private enum PresentedSheet: Identifiable {
        case addQr, addManual

        var id: UUID {
            UUID()
        }
    }
}

struct CodesView_Previews: PreviewProvider {
    static var previews: some View {
        CodesView()
    }
}

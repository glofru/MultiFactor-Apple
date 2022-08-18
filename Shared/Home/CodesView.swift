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

    @State private var showAddSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                Button(action: {
                    showAddSheet = true
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
        .sheet(isPresented: $showAddSheet) {
            AddOTPView()
        }
    }
}

struct CodesView_Previews: PreviewProvider {
    static var previews: some View {
        CodesView()
    }
}

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
        SortDescriptor(\EncryptedOTP.order),
        SortDescriptor(\EncryptedOTP.label)
    ])
    private var encryptedOTPs: FetchedResults<EncryptedOTP>

    @State private var sheet: PresentedSheet?

    var body: some View {
        NavigationView {
            Group {
                if encryptedOTPs.isEmpty {
                    Text("No otps")
                } else {
                    List {
                        ForEach(encryptedOTPs, id: \.id) { otp in
                            Group {
                                if otp.isValid {
                                    OTPView(encryptedOTP: otp)
                                        .padding(.vertical, 10)
                                } else {
                                    EmptyView()
                                }
                            }
                            .listRowSeparator(.hidden)
                        }
                        .onMove(perform: moveOTPs)
                        .onDelete(perform: deleteOTPs)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("MultiFactor")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        sheet = .addQr
                    }, label: {
                        Label("Add", systemImage: "plus")
                    })
                }
            }
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

    private func moveOTPs(from source: IndexSet, to destination: Int) {
        print(source)
    }

    private func deleteOTPs(at offset: IndexSet) {
        var ids = [OTPIdentifier]()
        offset.forEach { i in
            ids.append(encryptedOTPs[i].id!)
        }
        Task {
            await homeViewModel.deleteOTPs(ids)
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

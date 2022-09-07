//
//  CodesView.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 12/08/22.
//

import SwiftUI

struct CodesView: View {

    @EnvironmentObject var homeViewModel: HomeViewModel

    var body: some View {
        ZStack {
            #if os(iOS)
            NavigationView {
                CodesViewContent()
            }
            #elseif os(macOS)
            VStack(alignment: .center) {
                CodesViewContent()
            }
            #endif

            Text("Copied code \(Image(systemName: "checkmark.circle.fill"))")
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .opacity(homeViewModel.showCopy ? 1 : 0)
                .animation(.easeInOut, value: homeViewModel.showCopy)
        }
    }
}
    
private struct CodesViewContent: View {

    @EnvironmentObject private var homeViewModel: HomeViewModel

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\EncryptedOTP.order),
        SortDescriptor(\EncryptedOTP.label)
    ])
    private var encryptedOTPs: FetchedResults<EncryptedOTP>

    @State private var sheet: PresentedSheet?

    var body: some View {
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
                        #if os(iOS)
                        .listRowSeparator(.hidden)
                        #endif
                    }
                    .onMove(perform: moveOTPs)
                    .onDelete(perform: deleteOTPs)
                }
                .listStyle(.plain)
            }
        }
        #if os(iOS)
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
        #endif
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
        guard let first = source.first, first != destination else {
            return
        }
        var copiedList = encryptedOTPs.map({ $0 })
        copiedList.move(fromOffsets: source, toOffset: destination)
        for i in 0..<copiedList.count {
            copiedList[i].order = Int16(i)
        }
        Task(priority: .userInitiated) {
            await homeViewModel.moveOTPs(copiedList)
        }
    }

    private func deleteOTPs(at offset: IndexSet) {
        var ids = [OTPIdentifier]()
        offset.forEach { i in
            ids.append(encryptedOTPs[i].id!)
        }
        Task(priority: .userInitiated) {
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

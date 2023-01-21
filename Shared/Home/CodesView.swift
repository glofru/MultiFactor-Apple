//
//  CodesView.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 12/08/22.
//

import SwiftUI

struct CodesView: View {

    @EnvironmentObject private var homeViewModel: HomeViewModel

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

    @State private var searched = ""

    #if os(iOS)
    @State private var editMode = EditMode.inactive
    #endif
    @State private var selected: Set<EncryptedOTP>?

    var body: some View {
        ZStack {
            if encryptedOTPs.isEmpty {
                Text("No otps")
            } else {
                List(selection: $selected) {
                    ForEach(encryptedOTPs, id: \.id) { otp in
                        Group {
                            if otp.isValid &&
                                (searched.isEmpty ||
                                 TOTPViewModel.getInstance(otp: otp).issuer?.lowercased().contains(searched.lowercased()) == true ||
                                 TOTPViewModel.getInstance(otp: otp).label?.lowercased().contains(searched.lowercased()) == true) {
                                OTPView(viewModel: TOTPViewModel.getInstance(otp: otp))
                                    .padding(.vertical, 5)
                            } else {
                                EmptyView()
                            }
                        }
                        #if os(iOS)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 5, leading: 16, bottom: 5, trailing: 16))
                        #endif
                    }
                    .onMove(perform: moveOTPs)
                    .onDelete(perform: deleteOTPs)

                    #if os(iOS)
                    Spacer(minLength: 100)
                        .listRowSeparator(.hidden)
                    #else
                    Spacer(minLength: 5)
                    #endif
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searched)
        #if os(iOS)
        .environment(\.editMode, $editMode)
        .navigationTitle("MultiFactor")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if editMode == .active {
                        editMode = .inactive
                    } else {
                        editMode = .active
                    }
                }, label: {
                    Text(editMode == .active ? "Done" : "Edit")
                })
            }
        }
        #endif
        .animation(.default, value: encryptedOTPs.isEmpty)
        #if os(iOS)
        .animation(.default, value: editMode)
        #endif
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
}

struct CodesView_Previews: PreviewProvider {
    static var previews: some View {
        CodesView()
    }
}

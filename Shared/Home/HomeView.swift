//
//  HomeView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 21/07/22.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel

    @Namespace private var namespace

    @StateObject private var homeViewModel = HomeViewModel()

    @State private var selectedTab = MFTabBar.Tab.codes

    var body: some View {
        Group {
            #if os(iOS)
            ZStack(alignment: .bottom) {
                switch selectedTab {
                case .codes:
                    CodesView()
                        .transition(.scale(scale: 2).combined(with: .opacity))
                case .account:
                    AccountView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }

                MFTabBar(selectedTab: $selectedTab)
            }
            .animation(.easeIn, value: selectedTab)
            #elseif os(macOS)
            CodesView()
//            AccountView()
            #endif
        }
        .confirmationDialog("Do you want to sign out?", isPresented: $authenticationViewModel.showSignOut, titleVisibility: .visible) {
            Button("Sign out", role: .destructive) {
                authenticationViewModel.signOut()
            }

            Button("Cancel", role: .cancel) {
                authenticationViewModel.showSignOut = false
            }
        }
//        .alert(homeViewModel.error ?? "", isPresented: Binding(get: { homeViewModel.error != nil }, set: { _, _ in homeViewModel.error = nil })) { }
        .environmentObject(homeViewModel)
    }
}

private struct MFTabBar: View {

    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject private var homeViewModel: HomeViewModel

    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            Button(action: {
                selectedTab = .codes
            }, label: {
                Image(systemName: "lock")
                    .resizable()
                    .scaledToFit()
            })
            .background(selectedLight(.codes))

            Spacer()

            Button(action: {
                homeViewModel.sheet = .addQr
            }, label: {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .scaledToFit()
                    .foregroundColor(.white)
            })
            .frame(width: 50, height: 50)
            .background(.blue)
            .clipShape(Circle())
            .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 0)
            .contextMenu {
                Button(action: {
                    homeViewModel.sheet = .addQr
                }, label: {
                    Label("Camera", systemImage: "camera")
                })

                Button(action: {
                    homeViewModel.sheet = .addManual
                }, label: {
                    Label("Manual", systemImage: "rectangle.and.pencil.and.ellipsis")
                })
            }

            Spacer()

            Button(action: {
                selectedTab = .account
            }, label: {
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
            })
            .background(selectedLight(.account))
            .contextMenu {
                Button(role: .destructive, action: {
                    authenticationViewModel.showSignOut = true
                }, label: {
                    Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                })
            }
        }
        .foregroundColor(.label)
        .frame(height: 24)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 0)
        .padding(.horizontal, 70)
        .padding(.vertical)
        .sheet(isPresented: Binding(get: { homeViewModel.sheet != nil }, set: { _, _ in homeViewModel.sheet = nil })) {
            AddOTPView()
        }
    }

    private func selectedLight(_ tab: Tab) -> some View {
        VStack {
            if selectedTab == tab {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 20, height: 5)
                    .foregroundColor(.blue)
                    .offset(x: 0, y: -10)

                Spacer()
            } else {
                EmptyView()
            }
        }
    }

    enum Tab {
        case codes
        case account
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationViewModel())
            .preferredColorScheme(.dark)
//        HomeView()
//            .environmentObject(AuthenticationViewModel())
//            .preferredColorScheme(.light)
    }
}

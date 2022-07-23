//
//  HomeView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 21/07/22.
//

import SwiftUI

struct HomeView<ViewModel>: View where ViewModel: AuthenticationViewModel {

//    @State private var searched = ""
    @ObservedObject var authenticationViewModel: ViewModel

    var body: some View {
        ScrollView {
            HStack {
                Button(action: {
                    authenticationViewModel.signOut()
                }, label: {
                    Text("Sign out")
                })
            }
            LazyVStack {
                AuthCodeView()
                AuthCodeView()
                AuthCodeView()
                Spacer()
            }
        }
        .padding()
//        .searchable(text: $searched)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(authenticationViewModel: FirebaseAuthenticationViewModel())
    }
}

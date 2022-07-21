//
//  HomeView.swift
//  MultiFactor
//
//  Created by g.lofrumento on 21/07/22.
//

import SwiftUI

struct HomeView: View {
    
    @State private var searched = ""
    
    var body: some View {
        VStack {
            AuthCodeView()
            AuthCodeView()
            AuthCodeView()
            Spacer()
        }
        .padding()
        .searchable(text: $searched)
        .background(Color.background)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

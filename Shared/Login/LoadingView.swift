//
//  LoadingView.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 08/09/22.
//

import SwiftUI
import RiveRuntime

struct LoadingView: View {

    @State private var animation = RiveViewModel(fileName: "lock", animationName: "Animation 1", fit: .contain, alignment: .center, autoPlay: false)
    private var lockSize: Double {
        size*0.3672
    }

    @State private var blur = 0.0

    var body: some View {
        VStack {
            ZStack {
                Image("lockShadow")
                    .resizable()
                    .frame(width: 0.702*size, height: 0.786*size)
                    .opacity(0.8)
                    .blur(radius: blur)

                Image("lockShield")
                    .resizable()
                    .frame(width: 0.702*size, height: 0.786*size)

                Image("lockLight")
                    .resizable()
                    .frame(width: 0.7568*size, height: 0.833*size)

                animation
                        .view()
                        .frame(width: lockSize)
                        .offset(x: 0, y: -size*0.05)
            }
        }
        .task {
            animation.play(loop: .pingPong)
            withAnimation(.easeOut(duration: 0.8).delay(0.2).repeatForever()) {
                blur = 30
            }
        }
    }

    private var size: Double {
        switch UIDevice.current.orientation {
        case .landscapeLeft: fallthrough
        case .landscapeRight: return UIScreen.main.bounds.size.height * 0.6
        case .faceUp: fallthrough
        case .faceDown: fallthrough
        case .portrait: fallthrough
        case .portraitUpsideDown: fallthrough
        case .unknown: fallthrough
        @unknown default: return UIScreen.main.bounds.size.width * 0.4
        }
    }
}


struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}

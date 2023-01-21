//
//  LoadingView.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 08/09/22.
//

import SwiftUI
#if os(iOS)
import RiveRuntime
#endif

struct LoadingView: View {

    #if os(iOS)
    @State private var animation = RiveViewModel(fileName: "lock", animationName: "Animation 1", fit: .contain, alignment: .center, autoPlay: false)
    @State private var blur = 0.0
    #endif

    var body: some View {
        VStack {
            #if os(iOS)
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
                        .frame(width: 0.3672*size)
                        .offset(x: 0, y: -0.05*size)
            }
            #elseif os(macOS)
            Image("noBackgroundIcon")
                .resizable()
                .scaledToFit()
                .frame(width: size)
            #endif
        }
        #if os(iOS)
        .task {
            animation.play(loop: .pingPong)
            withAnimation(.easeOut(duration: 0.8).delay(0.2).repeatForever()) {
                blur = 30
            }
        }
        #endif
    }

    private var size: Double {
        #if os(iOS)
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
        #elseif os(macOS)
        100
        #endif
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}

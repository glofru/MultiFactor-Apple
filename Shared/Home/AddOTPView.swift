//
//  AddOTPView.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 12/08/22.
//

import SwiftUI
import AVKit

struct AddOTPView: View {

    @EnvironmentObject private var homeViewModel: HomeViewModel

    @State private var showCamera = true

    private func addOTP() {
        Task {
            await homeViewModel.addOTP()
        }
    }

    var body: some View {
        VStack {
            if showCamera {
                #if os(iOS)
                QrScanView(onQrCodeDeted: { qr in
                    print("QR: \(qr.value)")
                }, onFailCamera: {
                    showCamera = false
                })
                #elseif os(macOS)
                Text("QR")
                #endif
            } else {
                Spacer()
                Text("No camera")
                Spacer()
            }

            Button(action: {
                
            }, label: {
                Label("Fill manually", systemImage: "rectangle.and.pencil.and.ellipsis")
                    .gradientBackground(.login)
            })
            .padding()
            .background(.background)
        }
    }
}

#if os(iOS)
private struct QrScanView: View, QrScanViewControllerDelegate {

    let onQrCodeDeted: (QrCode) -> Void
    let onFailCamera: () -> Void

    @State private var detectedQr: DetectedQrCode?
    @State private var animationSwitch = false

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    private let pathRadius = 10.0
    private let pathColor = Color.yellow
    private let pathLineWidth = 4.0
    private let sideLength = 13.0
    private let animationSlide = 4.0

    var body: some View {
        QrScanViewControllerRepresentable(delegate: self)
//            .maskedBlur(qrCode: $detectedQr)
            .overlay {
                if let detectedQr = detectedQr {
                    let angle = Double(atan2(detectedQr.corners[3].y - detectedQr.corners[0].y, detectedQr.corners[3].x - detectedQr.corners[0].x))
                    let animationValue = animationSlide * sin(Double.pi/4 * (animationSwitch ? 1 : -1))
                    let cos2Angle = cos(angle*2)
                    let cos2AngleAnimationValue = cos2Angle*animationValue
                    Group {
                        Path() { path in
                            let center = detectedQr.corners[0]
                            let startAngle = Double.pi+angle
                            let endAngle = Double.pi*1.5+angle

                            path.addArc(center: center, radius: pathRadius, startAngle: .radians(startAngle), endAngle: .radians(endAngle), clockwise: false)

                            let newPointA = CGPoint(x: center.x + pathRadius * cos(endAngle), y: center.y + pathRadius * sin(endAngle))
                            path.move(to: newPointA)
                            path.addLine(to: CGPoint(x: newPointA.x + sideLength * cos(angle), y: newPointA.y + sideLength * sin(angle)))

                            let newPointB = CGPoint(x: center.x + pathRadius * cos(startAngle), y: center.y + pathRadius * sin(startAngle))
                            path.move(to: newPointB)
                            path.addLine(to: CGPoint(x: newPointB.x - sideLength * sin(angle), y: newPointB.y + sideLength * cos(angle)))
                        }
                        .stroke(pathColor, lineWidth: pathLineWidth)
                        .offset(x: -abs(cos2Angle)*animationValue, y: -cos2AngleAnimationValue)

                        Path() { path in
                            let center = detectedQr.corners[1]
                            let startAngle = Double.pi/2+angle
                            let endAngle = Double.pi+angle

                            path.addArc(center: center, radius: pathRadius, startAngle: .radians(startAngle), endAngle: .radians(endAngle), clockwise: false)

                            let newPointA = CGPoint(x: center.x + pathRadius * cos(endAngle), y: center.y + pathRadius * sin(endAngle))
                            path.move(to: newPointA)
                            path.addLine(to: CGPoint(x: newPointA.x + sideLength * sin(angle), y: newPointA.y - sideLength * cos(angle)))

                            let newPointB = CGPoint(x: center.x + pathRadius * cos(startAngle), y: center.y + pathRadius * sin(startAngle))
                            path.move(to: newPointB)
                            path.addLine(to: CGPoint(x: newPointB.x + sideLength * cos(angle), y: newPointB.y + sideLength * sin(angle)))
                        }
                        .stroke(pathColor, lineWidth: pathLineWidth)
                        .offset(x: -cos2AngleAnimationValue, y: animationValue)

                        Path() { path in
                            let center = detectedQr.corners[2]
                            let startAngle = angle
                            let endAngle = Double.pi/2+angle

                            path.addArc(center: center, radius: pathRadius, startAngle: .radians(startAngle), endAngle: .radians(endAngle), clockwise: false)

                            let newPointA = CGPoint(x: center.x + pathRadius * cos(endAngle), y: center.y + pathRadius * sin(endAngle))
                            path.move(to: newPointA)
                            path.addLine(to: CGPoint(x: newPointA.x - sideLength * cos(angle), y: newPointA.y - sideLength * sin(angle)))

                            let newPointB = CGPoint(x: center.x + pathRadius * cos(startAngle), y: center.y + pathRadius * sin(startAngle))
                            path.move(to: newPointB)
                            path.addLine(to: CGPoint(x: newPointB.x + sideLength * sin(angle), y: newPointB.y - sideLength * cos(angle)))
                        }
                        .stroke(pathColor, lineWidth: pathLineWidth)
                        .offset(x: animationValue, y: cos2AngleAnimationValue)

                        Path() { path in
                            let center = detectedQr.corners[3]
                            let startAngle = angle
                            let endAngle = Double.pi*1.5+angle

                            path.addArc(center: center, radius: pathRadius, startAngle: .radians(startAngle), endAngle: .radians(endAngle), clockwise: true)

                            let newPointA = CGPoint(x: center.x + pathRadius * cos(endAngle), y: center.y + pathRadius * sin(endAngle))
                            path.move(to: newPointA)
                            path.addLine(to: CGPoint(x: newPointA.x - sideLength * cos(angle), y: newPointA.y - sideLength * sin(angle)))

                            let newPointB = CGPoint(x: center.x + pathRadius * cos(startAngle), y: center.y + pathRadius * sin(startAngle))
                            path.move(to: newPointB)
                            path.addLine(to: CGPoint(x: newPointB.x - sideLength * sin(angle), y: newPointB.y + sideLength * cos(angle)))
                        }
                        .stroke(pathColor, lineWidth: pathLineWidth)
                        .offset(x: cos2AngleAnimationValue, y: -animationValue)
                    }
                    .animation(.linear(duration: 0.3), value: animationSwitch)
                    .onReceive(timer) { _ in
                        animationSwitch.toggle()
                    }
                } else {
                    EmptyView()
                }
            }
            .onAppear {
                if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
                    Task {
                        if await AVCaptureDevice.requestAccess(for: .video) == false {
                            onFailCamera()
                        }
                    }
                }
            }
    }

    func didQrCodeDetect(_ code: DetectedQrCode?) {
        if let code = code {
            if detectedQr?.value != code.value {
                onQrCodeDeted(QrCode(value: code.value))
                withAnimation(.easeIn(duration: 1)) {
                    detectedQr = code
                }
            } else {
                detectedQr = code
            }
        } else {
            if detectedQr != nil {
                withAnimation {
                    detectedQr = nil
                }
            }
        }
    }
}

private struct QrScanViewControllerRepresentable: UIViewControllerRepresentable {

    let delegate: QrScanViewControllerDelegate

    func makeUIViewController(context: Context) -> QrScanViewController {
        let vc = QrScanViewController()
        vc.delegate = delegate
        return vc
    }

    func updateUIViewController(_ uiViewController: QrScanViewController, context: Context) { }
}

private class QrScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var qrCodeFrameView: UIView?

    var delegate: QrScanViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        guard let captureDevice = discoverySession.devices.last else {
            print("Failed to get the camera")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print("Error: \(error)")
            return
        }

        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer!.videoGravity = .resizeAspectFill
        videoPreviewLayer!.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)

        captureSession.startRunning()

        qrCodeFrameView = UIView()
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if  let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            metadataObject.type == .qr,
            let value = metadataObject.stringValue,
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject {

            delegate.didQrCodeDetect(DetectedQrCode(value: value, corners: barCodeObject.corners))
        } else {
            qrCodeFrameView?.frame = .zero
            delegate.didQrCodeDetect(nil)
        }
    }
}

private protocol QrScanViewControllerDelegate {
    func didQrCodeDetect(_ code: DetectedQrCode?)
}

private struct DetectedQrCode {
    let value: String
    let corners: [CGPoint]
}

private struct QrCode {
    let value: String
}

private struct MaskedBlur: ViewModifier {

    @Binding fileprivate var qrCode: DetectedQrCode?

    func body(content: Content) -> some View {
        ZStack {
            content

            if let qrCode = qrCode {
                Color.black
                    .opacity(0.4)
                    .mask(
                        Path() { path in
                            path.addRect(UIScreen.main.bounds)
                            path.move(to: qrCode.corners[0])
                            path.addLines([qrCode.corners[1], qrCode.corners[2], qrCode.corners[3], qrCode.corners[0]])
                        }
                            .fill(style: FillStyle(eoFill: true))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
            }
        }
    }
}

extension View {
    fileprivate func maskedBlur(qrCode: Binding<DetectedQrCode?>) -> some View {
        self.modifier(MaskedBlur(qrCode: qrCode))
    }
}
#endif

struct AddOTPView_Previews: PreviewProvider {
    static var previews: some View {
        AddOTPView()
    }
}

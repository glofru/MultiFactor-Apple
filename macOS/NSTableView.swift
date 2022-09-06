//
//  NSTableView.swift
//  MultiFactor
//
//  Created by Gianluca Lofrumento on 06/09/22.
//

import SwiftUI

extension NSTableView {
  open override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

    backgroundColor = NSColor.clear
    enclosingScrollView!.drawsBackground = false
  }
}

//
//  ShareSheet.swift
//  AppIconMaker
//
//  Created by Josafat Vicente Pérez on 17/10/24.
//



import SwiftUI

#if os(iOS) || os(tvOS)
import UIKit
typealias PlatformColor = UIColor
typealias PlatformFont = UIFont
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformColor = NSColor
typealias PlatformFont = NSFont
typealias PlatformImage = NSImage
#endif

#if os(iOS) || os(tvOS)
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#elseif os(macOS)
struct ShareSheet: NSViewRepresentable {
    var activityItems: [Any]

    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        DispatchQueue.main.async {
            let picker = NSSharingServicePicker(items: activityItems)
            picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif

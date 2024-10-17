//
//  ContentView.swift
//  AppIconMaker
//
//  Created by Josafat Vicente Pérez on 17/10/24.
//
import SwiftUI

struct ContentView: View {
    @State private var options = EmojiImageOptions()
    @State private var showShareSheet = false
    @State private var generatedImage: Image?
    @State private var uiImage: UIImage?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Emoji")) {
                    TextField("Emoji", text: $options.emoji)
                        .font(.largeTitle)
                }

                Section(header: Text("Tamaño del Emoji")) {
                    Slider(value: $options.emojiSize, in: 100...1024, step: 1)
                    Text("Tamaño: \(Int(options.emojiSize)) px")
                }

                Section(header: Text("Tipo de Fondo")) {
                    Picker("Tipo de Fondo", selection: $options.backgroundType)
                    {
                        ForEach(BackgroundType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                if options.backgroundType == .solidColor {
                    Section(header: Text("Color de Fondo")) {
                        ColorPicker(
                            "Selecciona un color",
                            selection: $options.solidColor)
                    }
                } else {
                    Section(header: Text("Colores del Gradiente")) {
                        Stepper(
                            "Número de Colores: \(options.gradientColorCount)",
                            value: $options.gradientColorCount, in: 2...5)
                        ForEach(0..<options.gradientColorCount, id: \.self) {
                            index in
                            ColorPicker(
                                "Color \(index + 1)",
                                selection: Binding(
                                    get: {
                                        if index < options.gradientColors.count
                                        {
                                            return options.gradientColors[index]
                                        } else {
                                            return .white
                                        }
                                    },
                                    set: { newValue in
                                        if index < options.gradientColors.count
                                        {
                                            options.gradientColors[index] =
                                                newValue
                                        } else {
                                            options.gradientColors.append(
                                                newValue)
                                        }
                                    }
                                ))
                        }
                    }
                }

                Section {
                    Button("Generar Imagen") {
                        generateImage()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                if generatedImage != nil {
                    Section(header: Text("Imagen Generada")) {
                        generatedImage?
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                        Button("Compartir") {
                            showShareSheet = true
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Generador de Emojis")
            .sheet(
                isPresented: $showShareSheet,
                content: {
                    if let uiImage = uiImage {
                        ShareSheet(activityItems: [uiImage])
                    }
                })
        }
    }

    func generateImage() {
        let size = CGSize(width: 1024, height: 1024)
        #if os(iOS) || os(tvOS)
            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { context in
                drawContent(in: context.cgContext, size: size)
            }
            uiImage = image
            generatedImage = Image(uiImage: image)
        #elseif os(macOS)
            let image = NSImage(size: size)
            image.lockFocus()
            if let context = NSGraphicsContext.current?.cgContext {
                drawContent(in: context, size: size)
            }
            image.unlockFocus()
            uiImage = image
            generatedImage = Image(nsImage: image)
        #endif
    }

    func drawContent(in context: CGContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)

        // Dibuja el fondo
        if options.backgroundType == .solidColor {
            context.setFillColor(PlatformColor(options.solidColor).cgColor)
            context.fill(rect)
        } else {
            let colors =
                options.gradientColors.map { PlatformColor($0).cgColor }
                as CFArray
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors,
                locations: nil)!
            context.drawLinearGradient(
                gradient, start: CGPoint.zero,
                end: CGPoint(x: size.width, y: size.height), options: [])
        }

        // Dibuja el emoji
        let fontSize = options.emojiSize
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: PlatformFont.systemFont(ofSize: fontSize),
            .paragraphStyle: paragraphStyle,
        ]

        let attributedString = NSAttributedString(
            string: options.emoji, attributes: attributes)
        let textSize = attributedString.size()
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )

        attributedString.draw(in: textRect)
    }
}
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

import AppKit

// Draws the Usherette app icon and writes every size the asset catalog needs.
//
//   swift scripts/make-icon.swift App/Assets.xcassets/AppIcon.appiconset
//
// The picture: an usherette's torch lighting three icons in a row and leaving two in the dark.
// Everything is drawn on a 1024 canvas with the origin at the top left.

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ".", isDirectory: true)
let canvas: CGFloat = 1024
let rgb = CGColorSpaceCreateDeviceRGB()

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(
        colorSpace: rgb,
        components: [CGFloat((hex >> 16) & 0xFF) / 255, CGFloat((hex >> 8) & 0xFF) / 255, CGFloat(hex & 0xFF) / 255, alpha]
    )!
}

func gradient(_ stops: [(CGFloat, CGColor)]) -> CGGradient {
    CGGradient(colorsSpace: rgb, colors: stops.map(\.1) as CFArray, locations: stops.map(\.0))!
}

func rounded(_ rect: CGRect, _ radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

/// Fills `path` with a gradient running from `start` to `end`.
func fill(_ path: CGPath, with gradient: CGGradient, from start: CGPoint, to end: CGPoint, in context: CGContext) {
    context.saveGState()
    context.addPath(path)
    context.clip()
    context.drawLinearGradient(gradient, start: start, end: end, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    context.restoreGState()
}

/// Shadows ignore the context's scale, so their size has to follow the size being drawn.
/// `drop` is how far down the shadow falls and `blur` how soft it is, both on the 1024 canvas.
func shadow(_ context: CGContext, drop: CGFloat = 0, blur: CGFloat, _ color: CGColor, scale: CGFloat) {
    context.setShadow(offset: CGSize(width: 0, height: -drop * scale), blur: blur * scale, color: color)
}

func drawIcon(in context: CGContext, scale: CGFloat) {
    // Apple's macOS icon grid: an 824 pt rounded square centred on the canvas.
    let plate = rounded(CGRect(x: 100, y: 100, width: 824, height: 824), 185)

    // The plate, with the soft shadow macOS icons sit on.
    context.saveGState()
    shadow(context, drop: 12, blur: 28, color(0x000000, 0.32), scale: scale)
    context.addPath(plate)
    context.setFillColor(color(0x5A1626))
    context.fillPath()
    context.restoreGState()
    fill(plate, with: gradient([(0, color(0x93263B)), (1, color(0x461020))]), from: CGPoint(x: 0, y: 100), to: CGPoint(x: 0, y: 924), in: context)

    context.saveGState()
    context.addPath(plate)
    context.clip()

    // The row of icons: five slots, the three in the middle caught by the light.
    let slot: CGFloat = 104
    let gap: CGFloat = 36
    let rowTop: CGFloat = 262
    let rowLeft = (canvas - (slot * 5 + gap * 4)) / 2
    let slots = (0..<5).map { CGRect(x: rowLeft + CGFloat($0) * (slot + gap), y: rowTop, width: slot, height: slot) }

    // The beam, widening from the lens up past the row.
    let lensY: CGFloat = 632
    let beam = CGMutablePath()
    beam.move(to: CGPoint(x: 452, y: lensY))
    beam.addLine(to: CGPoint(x: 296, y: 212))
    beam.addLine(to: CGPoint(x: 728, y: 212))
    beam.addLine(to: CGPoint(x: 572, y: lensY))
    beam.closeSubpath()
    fill(
        beam,
        with: gradient([(0, color(0xFFE49A, 0.62)), (0.5, color(0xFFDC86, 0.28)), (0.82, color(0xFFDC86, 0.12)), (1, color(0xFFDC86, 0))]),
        from: CGPoint(x: 0, y: lensY), to: CGPoint(x: 0, y: 212), in: context
    )

    for (index, rect) in slots.enumerated() {
        let path = rounded(rect, 28)
        if (1...3).contains(index) {
            context.saveGState()
            shadow(context, blur: 46, color(0xFFD873, 0.75), scale: scale)
            context.addPath(path)
            context.setFillColor(color(0xFFE9AE))
            context.fillPath()
            context.restoreGState()
            fill(path, with: gradient([(0, color(0xFFF6D6)), (1, color(0xFFD98C))]), from: CGPoint(x: 0, y: rect.minY), to: CGPoint(x: 0, y: rect.maxY), in: context)
        } else {
            context.addPath(path)
            context.setFillColor(color(0xFFFFFF, 0.15))
            context.fillPath()
        }
    }

    // The torch: a flared head and a round body, shaded like a cylinder lit from the front.
    let metal = gradient([(0, color(0xC7B48F)), (0.38, color(0xFBF4E4)), (0.62, color(0xF3E8D0)), (1, color(0xBBA680))])
    context.saveGState()
    shadow(context, drop: 10, blur: 30, color(0x1E0509, 0.45), scale: scale)
    let head = CGMutablePath()
    head.move(to: CGPoint(x: 424, y: lensY))
    head.addLine(to: CGPoint(x: 600, y: lensY))
    head.addQuadCurve(to: CGPoint(x: 560, y: 728), control: CGPoint(x: 596, y: 704))
    head.addLine(to: CGPoint(x: 464, y: 728))
    head.addQuadCurve(to: CGPoint(x: 424, y: lensY), control: CGPoint(x: 428, y: 704))
    head.closeSubpath()
    let body = rounded(CGRect(x: 464, y: 708, width: 96, height: 172), 30)
    context.addPath(body)
    context.addPath(head)
    context.setFillColor(color(0xE9DCC0))
    context.fillPath()
    context.restoreGState()
    fill(body, with: metal, from: CGPoint(x: 464, y: 0), to: CGPoint(x: 560, y: 0), in: context)
    fill(head, with: metal, from: CGPoint(x: 424, y: 0), to: CGPoint(x: 600, y: 0), in: context)

    // Where the head meets the body, the switch, and the lens.
    context.setFillColor(color(0x8E7B58, 0.55))
    context.fill(CGRect(x: 464, y: 726, width: 96, height: 6))
    context.addPath(rounded(CGRect(x: 498, y: 762, width: 28, height: 58), 14))
    context.setFillColor(color(0x6E1A2A))
    context.fillPath()
    context.saveGState()
    shadow(context, blur: 36, color(0xFFE08A, 0.9), scale: scale)
    context.setFillColor(color(0xFFF8E1))
    context.fillEllipse(in: CGRect(x: 424, y: lensY - 17, width: 176, height: 34))
    context.restoreGState()

    // A hairline of light along the top edge of the plate.
    context.restoreGState()
    context.saveGState()
    context.addPath(plate)
    context.clip()
    context.addPath(rounded(CGRect(x: 101.5, y: 101.5, width: 821, height: 821), 183.5))
    context.setStrokeColor(color(0xFFFFFF, 0.14))
    context.setLineWidth(3)
    context.strokePath()
    context.restoreGState()
}

func render(pixels: Int) -> CGImage {
    let context = CGContext(
        data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: 0,
        space: rgb, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    context.interpolationQuality = .high
    // Flip to a top-left origin and scale the 1024 design to the size being drawn.
    let scale = CGFloat(pixels) / canvas
    context.translateBy(x: 0, y: CGFloat(pixels))
    context.scaleBy(x: scale, y: -scale)
    drawIcon(in: context, scale: scale)
    return context.makeImage()!
}

for pixels in [16, 32, 64, 128, 256, 512, 1024] {
    let image = NSBitmapImageRep(cgImage: render(pixels: pixels))
    let url = outputDirectory.appendingPathComponent("icon_\(pixels).png")
    try image.representation(using: .png, properties: [:])!.write(to: url)
    print("wrote \(url.path)")
}

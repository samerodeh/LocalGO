import SwiftUI

/// Full-screen, pinch-to-zoom viewer for a menu item's photo.
/// Presented when the user taps an item's picture.
struct FullScreenImageView: View {
    let item: MenuItem
    let restaurant: Restaurant

    @EnvironmentObject private var cartVM: CartViewModel
    @Environment(\.dismiss) private var dismiss

    // Zoom / pan state
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private let minScale: CGFloat = 1
    private let maxScale: CGFloat = 4

    var body: some View {
        ZStack {
            // Tap the backdrop to dismiss (only when not zoomed in).
            Color.black.ignoresSafeArea()
                .onTapGesture { if scale <= 1.01 { dismiss() } }

            photo

            overlay
        }
        .statusBarHidden(true)
    }

    // MARK: - Photo with gestures
    private var photo: some View {
        CachedAsyncImage(url: item.largeImageURL, maxPixel: 1200) { image in
            image.resizable().aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView().tint(.white).scaleEffect(1.3)
        }
        .scaleEffect(scale)
        .offset(offset)
        .gesture(magnification)
        .simultaneousGesture(panWhenZoomed)
        .onTapGesture(count: 2) { toggleZoom() }
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: scale)
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: offset)
    }

    // MARK: - Chrome (close button + caption)
    private var overlay: some View {
        VStack {
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                        .environment(\.colorScheme, .dark)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()

            captionBar
        }
    }

    private var captionBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                    if !item.description.isEmpty {
                        Text(item.description)
                            .font(.system(size: 14)).foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                    }
                }
                Spacer()
                Text(String(format: "$%.2f", item.price))
                    .font(.system(size: 20, weight: .black)).foregroundColor(AppTheme.primary)
            }

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    cartVM.addItem(item, restaurant: restaurant)
                }
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add to Cart").font(.system(size: 16, weight: .bold))
                }
                .primaryButtonStyle()
            }
        }
        .padding(20)
        .background(
            LinearGradient(colors: [.black.opacity(0), .black.opacity(0.85)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    // MARK: - Gestures
    private var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = min(max(lastScale * value, minScale), maxScale)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1 { resetZoom() }
            }
    }

    private var panWhenZoomed: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1 else { return }
                offset = CGSize(width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height)
            }
            .onEnded { _ in lastOffset = offset }
    }

    private func toggleZoom() {
        if scale > 1 {
            resetZoom()
        } else {
            scale = 2.5
            lastScale = 2.5
        }
    }

    private func resetZoom() {
        scale = 1; lastScale = 1
        offset = .zero; lastOffset = .zero
    }
}

import SwiftUI
import UIKit
import ImageIO

/// High-performance image pipeline for menu photos.
///
/// Layers, fastest → slowest:
///   1. In-memory `NSCache` of *already-decoded, downsampled* `UIImage`s — instant.
///   2. On-disk cache of the original bytes — survives app launches.
///   3. Network fetch with a hard 3-second timeout.
///
/// Key memory optimizations:
///   • **Downsampling** — images are decoded straight to thumbnail size via
///     ImageIO, so a 400px tile costs ~0.5 MB instead of the full-res decode.
///   • **Cost-limited NSCache** — bounded to ~60 MB; the OS evicts under pressure.
///   • **In-flight de-duplication** — concurrent requests for the same URL share
///     one download instead of stampeding the network.
final class ImageCache {
    static let shared = ImageCache()

    private let memory = NSCache<NSURL, UIImage>()
    private let diskDir: URL
    private let session: URLSession

    /// Coordinates in-flight loads so the same URL is only fetched once at a time.
    private actor InFlight {
        private var tasks: [URL: Task<UIImage?, Never>] = [:]
        func existing(_ url: URL) -> Task<UIImage?, Never>? { tasks[url] }
        func store(_ url: URL, _ task: Task<UIImage?, Never>) { tasks[url] = task }
        func clear(_ url: URL) { tasks[url] = nil }
    }
    private let inFlight = InFlight()

    private init() {
        memory.totalCostLimit = 60 * 1024 * 1024   // ~60 MB of decoded pixels
        memory.countLimit = 250

        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskDir = caches.appendingPathComponent("FoodImageCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: diskDir, withIntermediateDirectories: true)

        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 3          // never block a tile longer than 3s
        cfg.timeoutIntervalForResource = 3
        cfg.requestCachePolicy = .returnCacheDataElseLoad
        cfg.urlCache = URLCache(memoryCapacity: 16 * 1024 * 1024,
                                diskCapacity: 128 * 1024 * 1024)
        session = URLSession(configuration: cfg)
    }

    // MARK: - Synchronous peek (instant first frame)

    /// Returns a decoded image immediately if it's already in memory — lets a view
    /// render the photo on its very first frame with no flash or async hop.
    func cachedImage(for url: URL) -> UIImage? {
        memory.object(forKey: url as NSURL)
    }

    // MARK: - Async load

    func image(for url: URL, maxPixel: CGFloat = 600) async -> UIImage? {
        if let cached = memory.object(forKey: url as NSURL) { return cached }

        if let running = await inFlight.existing(url) { return await running.value }

        let task = Task<UIImage?, Never> { [weak self] in
            await self?.loadFromDiskOrNetwork(url, maxPixel: maxPixel)
        }
        await inFlight.store(url, task)
        let image = await task.value
        await inFlight.clear(url)
        return image
    }

    /// Warm the cache ahead of time (call on launch) so tiles appear instantly.
    func prefetch(_ urls: [URL], maxPixel: CGFloat = 600) {
        for url in urls where memory.object(forKey: url as NSURL) == nil {
            Task.detached(priority: .utility) { [weak self] in
                _ = await self?.image(for: url, maxPixel: maxPixel)
            }
        }
    }

    // MARK: - Internals

    private func loadFromDiskOrNetwork(_ url: URL, maxPixel: CGFloat) async -> UIImage? {
        let file = diskDir.appendingPathComponent(diskKey(url))

        // 2. Disk
        if let data = try? Data(contentsOf: file),
           let image = Self.downsample(data, maxPixel: maxPixel) {
            store(image, for: url)
            return image
        }

        // 3. Network (bounded to 3s by the session config)
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 3
            let (data, response) = try await session.data(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode >= 400 { return nil }
            try? data.write(to: file, options: .atomic)
            guard let image = Self.downsample(data, maxPixel: maxPixel) else { return nil }
            store(image, for: url)
            return image
        } catch {
            return nil   // timeout / offline → caller shows the branded fallback
        }
    }

    private func store(_ image: UIImage, for url: URL) {
        let cost = (image.cgImage?.bytesPerRow ?? 0) * (image.cgImage?.height ?? 0)
        memory.setObject(image, forKey: url as NSURL, cost: max(cost, 1))
    }

    /// Decode directly to a thumbnail of `maxPixel` — the core memory saver.
    private static func downsample(_ data: Data, maxPixel: CGFloat) -> UIImage? {
        let srcOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, srcOptions) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ]
        guard let cg = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return UIImage(cgImage: cg)
    }

    private func diskKey(_ url: URL) -> String {
        var hash: UInt64 = 5381
        for byte in url.absoluteString.utf8 { hash = (hash &* 33) &+ UInt64(byte) }
        return String(hash, radix: 16) + ".img"
    }
}

/// Drop-in cached image view: renders instantly from memory when warm, otherwise
/// shows `placeholder` while loading and fades the photo in.
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        // Instant first-frame render if the photo is already decoded in memory.
        if let url, let cached = ImageCache.shared.cachedImage(for: url) {
            _uiImage = State(initialValue: cached)
        }
    }

    var body: some View {
        Group {
            if let uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            guard uiImage == nil, let url else { return }
            if let loaded = await ImageCache.shared.image(for: url) {
                withAnimation(.easeInOut(duration: 0.2)) { uiImage = loaded }
            }
        }
    }
}

import SwiftUI
import MapKit

/// Interactive map address picker. The user moves the map under a fixed center
/// pin; the centered coordinate is reverse-geocoded into a street address.
///
/// Uses Apple MapKit — native, no API key, works immediately. To use the Google
/// Maps SDK instead, add the `GoogleMaps` Swift package + your API key and swap
/// the `Map` here for a `GMSMapView` wrapper; the surrounding flow is unchanged.
struct LocationPickerView: View {
    /// Returns the chosen address string when the user confirms.
    var onConfirm: (String) -> Void

    @EnvironmentObject private var location: LocationManager
    @Environment(\.dismiss) private var dismiss

    // Default to downtown Montreal until we get a fix.
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.4972, longitude: -73.5790),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @State private var address = "Move the map to set your address"
    @State private var isGeocoding = false
    @State private var pinDrop = false
    @State private var geocodeWork: DispatchWorkItem?

    private let geocoder = CLGeocoder()

    var body: some View {
        ZStack(alignment: .bottom) {
            map
            centerPin
            topBar
            addressCard
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.15)) { pinDrop = true }
            location.requestCurrentLocation()
            reverseGeocode()   // for the initial center
        }
        .onChange(of: location.lastLocation?.latitude) { _ in
            if let coord = location.lastLocation {
                withAnimation(.easeInOut(duration: 0.6)) {
                    region = MKCoordinateRegion(center: coord,
                                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                }
                scheduleGeocode()
            }
        }
        .onChange(of: regionKey) { _ in scheduleGeocode() }
    }

    // MARK: - Map
    private var map: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .ignoresSafeArea()
    }

    /// A stable key that changes as the map center moves (debounces geocoding).
    private var regionKey: String {
        String(format: "%.5f,%.5f", region.center.latitude, region.center.longitude)
    }

    // MARK: - Center pin
    private var centerPin: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(AppTheme.primary)
                .offset(y: pinDrop ? -14 : -40)        // drop-in animation
                .shadow(color: .black.opacity(0.25), radius: 3, y: 3)
            Circle()
                .fill(.black.opacity(0.18))
                .frame(width: 10, height: 5)
                .blur(radius: 1)
        }
        .offset(y: -7)   // lift so the tip points at the exact center
        .allowsHitTesting(false)
    }

    // MARK: - Top bar
    private var topBar: some View {
        VStack {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                        .frame(width: 40, height: 40).background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
                Button { location.requestCurrentLocation() } label: {
                    Group {
                        if location.isRequesting {
                            ProgressView().tint(AppTheme.primary)
                        } else {
                            Image(systemName: "location.fill")
                                .font(.system(size: 16, weight: .bold)).foregroundColor(AppTheme.primary)
                        }
                    }
                    .frame(width: 40, height: 40).background(.ultraThinMaterial, in: Circle())
                }
            }
            .padding(.horizontal, 20).padding(.top, 60)
            Spacer()
        }
    }

    // MARK: - Address card
    private var addressCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(AppTheme.primary.opacity(0.12)).frame(width: 42, height: 42)
                    Image(systemName: "mappin.and.ellipse").foregroundColor(AppTheme.primary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Deliver to").font(.system(size: 12, weight: .medium)).foregroundColor(AppTheme.textSecondary)
                    if isGeocoding {
                        Text("Finding address…").font(.system(size: 15, weight: .semibold)).foregroundColor(AppTheme.textSecondary)
                    } else {
                        Text(address).font(.system(size: 15, weight: .semibold)).foregroundColor(AppTheme.textPrimary).lineLimit(2)
                    }
                }
                Spacer()
            }

            Button {
                onConfirm(address)
                dismiss()
            } label: {
                Text("Confirm Address").font(.system(size: 16, weight: .bold)).primaryButtonStyle()
            }
            .disabled(isGeocoding || address.isEmpty)
        }
        .padding(18)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 16, y: -2)
        .padding(.horizontal, 14)
        .padding(.bottom, 34)
    }

    // MARK: - Geocoding (debounced)
    private func scheduleGeocode() {
        geocodeWork?.cancel()
        isGeocoding = true
        let work = DispatchWorkItem { reverseGeocode() }
        geocodeWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
    }

    private func reverseGeocode() {
        let center = region.center
        let loc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        geocoder.reverseGeocodeLocation(loc) { placemarks, _ in
            isGeocoding = false
            guard let p = placemarks?.first else { return }
            let parts = [
                [p.subThoroughfare, p.thoroughfare].compactMap { $0 }.joined(separator: " "),
                p.locality, p.administrativeArea, p.postalCode
            ].compactMap { $0 }.filter { !$0.isEmpty }
            if !parts.isEmpty { address = parts.joined(separator: ", ") }
        }
    }
}

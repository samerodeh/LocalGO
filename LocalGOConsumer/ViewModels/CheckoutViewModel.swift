import Foundation
import StripePaymentSheet

@MainActor
class CheckoutViewModel: ObservableObject {
    @Published var deliveryAddress = ""
    @Published var deliveryInstructions = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var paymentSheet: PaymentSheet? = nil

    func preparePayment(amountCents: Int) async {
        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: "\(Config.backendURL)/create-payment-intent") else {
            errorMessage = "Backend URL is not configured."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["amount": amountCents, "currency": "cad"])

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            guard
                let clientSecret  = json?["clientSecret"] as? String,
                let ephemeralKey  = json?["ephemeralKey"] as? String,
                let customerId    = json?["customer"] as? String
            else {
                errorMessage = "Invalid response from payment backend."
                return
            }

            var config = PaymentSheet.Configuration()
            config.merchantDisplayName = "LocalGO"
            config.customer = .init(id: customerId, ephemeralKeySecret: ephemeralKey)
            config.allowsDelayedPaymentMethods = false
            config.returnURL = "localgo://stripe-redirect"

            paymentSheet = PaymentSheet(
                paymentIntentClientSecret: clientSecret,
                configuration: config
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

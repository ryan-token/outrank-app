//
//  SubscriptionPolicyLinksContent.swift
//  Outrank
//

import SwiftUI

/// The two policy links and the word between them, for `SubscriptionPolicyLinks` to lay
/// out in a row or a column.
struct SubscriptionPolicyLinksContent: View {
    var body: some View {
        Link("Terms of Service", destination: AppLinks.termsOfUse)
            .foregroundStyle(.tint)

        Text("and")
            .foregroundStyle(.secondary)

        Link("Privacy Policy", destination: AppLinks.privacyPolicy)
            .foregroundStyle(.tint)
    }
}

#Preview {
    HStack {
        SubscriptionPolicyLinksContent()
    }
}

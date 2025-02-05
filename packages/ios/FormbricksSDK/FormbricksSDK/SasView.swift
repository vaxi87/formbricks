//
//  SasView.swift
//  FormbricksSDK
//
//  Created by Peter Pesti-Varga on 2025. 02. 03..
//

import SwiftUI

public struct SasView: View {
    public init() {
    }
    public var body: some View {
        Button("Metfe") {
            if let window = UIApplication.safeShared?.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first {
                    print("Talált ablak: \(window)")
                    let alert = UIAlertController(title: "Metfe", message: "Metfe", preferredStyle: .alert)
                    window.rootViewController?.present(alert, animated: true, completion: nil)
                }
        }
    }
}

#Preview {
    SasView()
}

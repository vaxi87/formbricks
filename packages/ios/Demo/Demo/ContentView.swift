import SwiftUI
import FormbricksSDK

struct ContentView: View {
    @State var text = ""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            
        }
    }
}

#Preview {
    ContentView()
}

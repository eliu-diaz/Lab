import SwiftUI


struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                NavigationLink(destination: LocalEncryptionSampleView()) {
                    Text("Local Encryption Sample")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 200)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                
                Spacer()
                
                NavigationLink(destination: EmptyView()) {
                    Text("Coming soon...")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 200)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                
                Spacer()
            }
            .navigationTitle("Encryptionnnn")
        }
    }
}


#Preview {
    ContentView()
}

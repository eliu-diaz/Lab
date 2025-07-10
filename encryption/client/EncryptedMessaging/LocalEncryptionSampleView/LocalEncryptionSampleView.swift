//
//  LocalEncryptionSampleView.swift
//  EncryptedMessaging
//
//  Created by Eliu Diaz on 25/06/25.
//

import SwiftUI
import CryptoKit

struct LocalEncryptionSampleView: View {
    @State private var currentMessage = ""
    @State private var encryptedMessage = ""
    @State private var decryptedMessage = ""
    @State private var encryptionFailed = false
    @State private var decryptionFailed = false
    @State private var symmetricKey: Data?
    
    let encryptionService = EncryptionService()
    
    var body: some View {
        VStack {
            TextField("Enter some text to encrypt", text: $currentMessage)
            
            Text("Encrypted Result:")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextEditor(text: $encryptedMessage)
                .frame(minHeight: 100)
                .border(Color.gray.opacity(0.3))
                .disabled(true) // Make it read-only
            
            Button("Encrypt") {
                encryptMessage()
            }
            
            if !encryptedMessage.isEmpty {
                TextEditor(text: $decryptedMessage)
                    .frame(minHeight: 100)
                    .border(Color.gray.opacity(0.3))
                    .disabled(true) // Make it read-only
                
                Button("Decrypt") {
                    decryptMessage()
                }
            }
        }
        .padding()
        .alert("Encryption faield!", isPresented: $encryptionFailed) { }
        .alert("Decryption faield!", isPresented: $decryptionFailed) { }
    }
    
    private func encryptMessage() {
        guard !currentMessage.isEmpty else { return }
        
        if let (ciphertext, symmetricKey) = encryptionService.encrypt(message: currentMessage) {
            self.symmetricKey = symmetricKey
            encryptedMessage = ciphertext.base64EncodedString()
        } else {
            encryptionFailed = true
        }
    }
    
    private func decryptMessage() {
        if let symmetricKey,
           let decryptedData = encryptionService.decrypt(encryptedMessage, using: symmetricKey),
           let message = String(data: decryptedData, encoding: .utf8) {
            decryptedMessage = message
        } else {
            decryptionFailed = true
        }
    }
}

#Preview {
    LocalEncryptionSampleView()
}

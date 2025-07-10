import Foundation
import CryptoKit

// MARK: - Encryption Service
final class EncryptionService {
    let recipientPrivateKey = P256.KeyAgreement.PrivateKey()
    lazy var recipientPublicKey: P256.KeyAgreement.PublicKey = recipientPrivateKey.publicKey
    
    /// Encrypts a message from the client
    /// - Parameters:
    ///   - message: The plaintext message to encrypt.
    /// - Returns: The encrypted message (ciphertext).
    func encrypt(message: String) -> (ciphertext: Data, encapsulatedKey: Data)? {
        let protocolInfo = "Super secret protocol info!".data(using: .utf8)!
        let messageData = message.data(using: .utf8)!
        
        do {
            var hpkeSender = try HPKE.Sender(
                recipientKey: recipientPublicKey,
                ciphersuite: HPKE.Ciphersuite.P256_SHA256_AES_GCM_256,
                info: protocolInfo
            )
            
            return (try hpkeSender.seal(messageData), hpkeSender.encapsulatedKey)
        } catch {
            print("Failed to encrypt message with error: \(error)")
            return nil
        }
    }
    
    /// Decrypts a message from the client
    /// - Parameters:
    ///   - message: The plaintext message to decrypt.
    ///   - encapsulatedKey: The symmetricKey used to encrypt the message.
    /// - Returns: The decrypted message data.
    func decrypt(_ message: String, using encapsulatedKey: Data) -> Data? {
        guard let messageData = Data(base64Encoded: message) else { return nil }
        
        let ciphersuite = HPKE.Ciphersuite.P256_SHA256_AES_GCM_256
        let protocolInfo = "Super secret protocol info!".data(using: .utf8)!
        
        do {
            var hpkeRecipient = try HPKE.Recipient(
                privateKey: recipientPrivateKey,
                ciphersuite: ciphersuite,
                info: protocolInfo,
                encapsulatedKey: encapsulatedKey
            )
            
            return try hpkeRecipient.open(messageData)
        } catch {
            print("Failed to decrypt message with error: \(error)")
            return nil
        }
    }
}

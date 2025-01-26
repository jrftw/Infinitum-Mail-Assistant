/*****************************************************************************
 MARK: UnsubscribeEmail.swift
*****************************************************************************/

import SwiftUI
import os.log

struct UnsubscribeEmail: Identifiable, Hashable, Codable {
    let id: UUID
    let messageId: String
    let from: String
    let unsubscribeLink: String
    
    enum CodingKeys: String, CodingKey {
        case messageId
        case from
        case unsubscribeLink
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.messageId = try container.decode(String.self, forKey: .messageId)
        self.from = try container.decode(String.self, forKey: .from)
        self.unsubscribeLink = try container.decode(String.self, forKey: .unsubscribeLink)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageId, forKey: .messageId)
        try container.encode(from, forKey: .from)
        try container.encode(unsubscribeLink, forKey: .unsubscribeLink)
    }
}

struct UnsubscribeView: View {
    let userEmail: String
    @Environment(\.presentationMode) var presentationMode
    @State private var unsubItems: [UnsubscribeEmail] = []
    @State private var selectedItems: Set<UnsubscribeEmail> = []
    @State private var statusMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Mass Unsubscribe")
                .font(.title2)
            List(unsubItems, selection: $selectedItems) { item in
                VStack(alignment: .leading) {
                    Text(item.from)
                        .font(.headline)
                    Text(item.unsubscribeLink)
                        .font(.footnote)
                }
            }
            .environment(\.editMode, .constant(.active))
            Text(statusMessage)
                .font(.footnote)
                .foregroundColor(.gray)
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Button("Unsubscribe Selected") {
                    unsubscribeSelected()
                }
            }
            .padding()
        }
        .onAppear {
            fetchUnsubscribeEmails()
        }
    }
    
    private func fetchUnsubscribeEmails() {
        statusMessage = "Loading unsubscribable emails..."
        guard var urlComponents = URLComponents(string:
            "https://script.google.com/macros/s/AKfycbyP1wB2Es-8C-e0EeMcRn1wVKAOgJrgCiIirKdU53V38-zmHslREqDh-UbbrZzRetSz/exec")
        else { return }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "action", value: "getUnsubEmails"),
            URLQueryItem(name: "email", value: userEmail)
        ]
        guard let finalUrl = urlComponents.url else { return }
        
        os_log("Fetching unsubscribable emails for %@", log: OSLog.default, type: .info, userEmail)
        URLSession.shared.dataTask(with: finalUrl) { data, response, error in
            if let err = error {
                DispatchQueue.main.async {
                    statusMessage = "Error: \(err.localizedDescription)"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    statusMessage = "No data returned."
                }
                return
            }
            do {
                let result = try JSONDecoder().decode([UnsubscribeEmail].self, from: data)
                DispatchQueue.main.async {
                    unsubItems = result
                    statusMessage = "Unsubscribe list loaded."
                }
            } catch {
                DispatchQueue.main.async {
                    statusMessage = "JSON parse error."
                }
            }
        }.resume()
    }
    
    private func unsubscribeSelected() {
        statusMessage = "Unsubscribing selected..."
        guard var urlComponents = URLComponents(string:
            "https://script.google.com/macros/s/AKfycbyP1wB2Es-8C-e0EeMcRn1wVKAOgJrgCiIirKdU53V38-zmHslREqDh-UbbrZzRetSz/exec")
        else { return }
        
        let ids = selectedItems.map { $0.messageId }.joined(separator: ",")
        urlComponents.queryItems = [
            URLQueryItem(name: "action", value: "unsubscribeSelected"),
            URLQueryItem(name: "email", value: userEmail),
            URLQueryItem(name: "ids", value: ids)
        ]
        guard let finalUrl = urlComponents.url else { return }
        
        os_log("Mass unsubscribing for %@", log: OSLog.default, type: .info, userEmail)
        URLSession.shared.dataTask(with: finalUrl) { data, response, error in
            if let err = error {
                DispatchQueue.main.async {
                    statusMessage = "Unsubscribe error: \(err.localizedDescription)"
                }
                return
            }
            guard let data = data, let respStr = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    statusMessage = "No data or decoding error."
                }
                return
            }
            DispatchQueue.main.async {
                statusMessage = "Unsubscribe complete: \(respStr)"
            }
        }.resume()
    }
}

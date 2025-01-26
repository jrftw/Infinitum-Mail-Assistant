/*****************************************************************************
 MARK: DuplicateEmail.swift
 Description:
   Data model for duplicate emails, and view to display and remove them.
*****************************************************************************/

import SwiftUI
import os.log

struct DuplicateEmail: Identifiable, Hashable, Codable {
    let id: UUID
    let messageId: String
    let from: String
    let subject: String
    let preview: String
    
    enum CodingKeys: String, CodingKey {
        case messageId
        case from
        case subject
        case preview
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.messageId = try container.decode(String.self, forKey: .messageId)
        self.from = try container.decode(String.self, forKey: .from)
        self.subject = try container.decode(String.self, forKey: .subject)
        self.preview = try container.decode(String.self, forKey: .preview)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageId, forKey: .messageId)
        try container.encode(from, forKey: .from)
        try container.encode(subject, forKey: .subject)
        try container.encode(preview, forKey: .preview)
    }
}

struct DuplicateListView: View {
    let userEmail: String
    @Environment(\.presentationMode) var presentationMode
    @State private var duplicates: [DuplicateEmail] = []
    @State private var selectedItems: Set<DuplicateEmail> = []
    @State private var statusMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Confirm or Deny Deletion")
                .font(.title2)
            List(duplicates, selection: $selectedItems) { item in
                VStack(alignment: .leading) {
                    Text(item.from)
                        .font(.headline)
                    Text(item.subject)
                        .font(.subheadline)
                    Text(item.preview)
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
                Button("Delete Selected") {
                    removeSelected()
                }
            }
            .padding()
        }
        .onAppear {
            fetchDuplicates()
        }
    }
    
    private func fetchDuplicates() {
        statusMessage = "Loading duplicates..."
        guard var urlComponents = URLComponents(string:
            "https://script.google.com/macros/s/AKfycbyP1wB2Es-8C-e0EeMcRn1wVKAOgJrgCiIirKdU53V38-zmHslREqDh-UbbrZzRetSz/exec")
        else { return }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "action", value: "getDuplicates"),
            URLQueryItem(name: "email", value: userEmail)
        ]
        guard let finalUrl = urlComponents.url else { return }
        
        os_log("Fetching duplicates for %@", log: OSLog.default, type: .info, userEmail)
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
                let result = try JSONDecoder().decode([DuplicateEmail].self, from: data)
                DispatchQueue.main.async {
                    duplicates = result
                    statusMessage = "Duplicates loaded."
                }
            } catch {
                DispatchQueue.main.async {
                    statusMessage = "JSON parse error."
                }
            }
        }.resume()
    }
    
    private func removeSelected() {
        statusMessage = "Removing selected..."
        guard var urlComponents = URLComponents(string:
            "https://script.google.com/macros/s/AKfycbyP1wB2Es-8C-e0EeMcRn1wVKAOgJrgCiIirKdU53V38-zmHslREqDh-UbbrZzRetSz/exec")
        else { return }
        
        let ids = selectedItems.map { $0.messageId }.joined(separator: ",")
        urlComponents.queryItems = [
            URLQueryItem(name: "action", value: "removeSelected"),
            URLQueryItem(name: "email", value: userEmail),
            URLQueryItem(name: "ids", value: ids)
        ]
        guard let finalUrl = urlComponents.url else { return }
        
        os_log("Deleting selected messages for %@", log: OSLog.default, type: .info, userEmail)
        URLSession.shared.dataTask(with: finalUrl) { data, response, error in
            if let err = error {
                DispatchQueue.main.async {
                    statusMessage = "Removal error: \(err.localizedDescription)"
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
                statusMessage = "Removal complete: \(respStr)"
            }
        }.resume()
    }
}

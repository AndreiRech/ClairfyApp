//
//  ChatBody.swift
//  ClairfyApp
//
//  Created by Andrei Rech on 08/10/25.
//

struct ChatBody: Encodable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
}

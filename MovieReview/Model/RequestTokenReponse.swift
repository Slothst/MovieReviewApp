//
//  RequestTokenReponse.swift
//  MovieReview
//
//  Created by 최낙주 on 11/9/24.
//

import Foundation

struct RequestTokenReponse: Codable {
    let success: Bool
    let expires_at: String
    let request_token: String
}

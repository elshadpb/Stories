//
//  Snap.swift
//  PASHABankSME
//
//  Created by Javid Museyibli on 07.08.21.
//

import Foundation

public struct Snap: Codable {
    let id: Int?
    let mediaType: MediaType?
    let mediaId: String?
    let snapLanguage: SnapTitle?

    func mediaUrl(baseURL: String) -> String {
        switch mediaType {
        case .photo:
            return "\(baseURL)/v1/stories/image/\(mediaId ?? "")"
        case .video:
            return "\(baseURL)/v1/stories/video/\(mediaId ?? "")"
        case .none:
            return ""
        }
    }
}

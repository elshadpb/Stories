//
//  Story.swift
//  PASHABankSME
//
//  Created by Javid Museyibli on 07.08.21.
//

import Foundation

public struct Story: Codable, Equatable {
    let id: Int?
    let titleLanguage: StoryTitle?
    let createdAt: String?
    let coverImageId: String?
    let snaps: [Snap]

    var lastPlayedSnapIndex = 0
    var isCompletelyVisible = false
    var isCancelledAbruptly = false

    func coverImageUrl(baseURL: String) -> String {
        return "\(baseURL)/v1/stories/image/\(coverImageId ?? "")"
    }

    public static func == (lhs: Story, rhs: Story) -> Bool {
        return lhs.id == rhs.id
    }

    private enum CodingKeys: String, CodingKey {
        case id, titleLanguage, createdAt, coverImageId, snaps
    }
}


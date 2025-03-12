//
//  Story.swift
//  PASHABankSME
//
//  Created by Javid Museyibli on 07.08.21.
//

import Foundation

public struct StoryStateModel: Equatable {
    public let id: Int?
    public let titleLanguage: StoryTitle?
    public let createdAt: String?
    public let coverImageId: String?
    public let snaps: [SnapState]

    var lastPlayedSnapIndex = 0
    var isCompletelyVisible = false
    var isCancelledAbruptly = false
    
    public init(
        id: Int?,
        titleLanguage: StoryTitle?,
        createdAt: String?,
        coverImageId: String?,
        snaps: [SnapState],
        lastPlayedSnapIndex: Int = 0,
        isCompletelyVisible: Bool = false,
        isCancelledAbruptly: Bool = false
    ) {
        self.id = id
        self.titleLanguage = titleLanguage
        self.createdAt = createdAt
        self.coverImageId = coverImageId
        self.snaps = snaps
        self.lastPlayedSnapIndex = lastPlayedSnapIndex
        self.isCompletelyVisible = isCompletelyVisible
        self.isCancelledAbruptly = isCancelledAbruptly
    }
    
    public static func == (lhs: StoryStateModel, rhs: StoryStateModel) -> Bool {
        return lhs.id == rhs.id
    }
}

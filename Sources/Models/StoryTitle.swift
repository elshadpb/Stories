//
//  StoryTitle.swift
//  PASHABankSME
//
//  Created by Javid Museyibli on 07.08.21.
//

import Foundation

public struct StoryTitle: Codable {
    public let azerbaijani: StoryTitleValue?
    public let english: StoryTitleValue?
    public let russian: StoryTitleValue?

    private enum CodingKeys: String, CodingKey {
        case azerbaijani = "az"
        case english = "en"
        case russian = "ru"
    }
}

public struct StoryTitleValue: Codable {
    public var title: String?
}

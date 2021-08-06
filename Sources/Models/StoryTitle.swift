//
//  StoryTitle.swift
//  PASHABankSME
//
//  Created by Javid Museyibli on 07.08.21.
//

import Foundation

struct StoryTitle: Codable {
    let azerbaijani: StoryTitleValue?
    let english: StoryTitleValue?
    let russian: StoryTitleValue?

    private enum CodingKeys: String, CodingKey {
        case azerbaijani = "az"
        case english = "en"
        case russian = "ru"
    }
}

struct StoryTitleValue: Codable {
    var title: String?
}

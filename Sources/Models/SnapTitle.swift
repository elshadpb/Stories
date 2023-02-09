//
//  SnapTitle.swift
//  PASHABankSME
//
//  Created by Javid Museyibli on 07.08.21.
//

import Foundation

public struct SnapTitle: Codable {
    public let azerbaijani: SnapDetails?
    public let english: SnapDetails?
    public let russian: SnapDetails?

    private enum CodingKeys: String, CodingKey {
        case azerbaijani = "az"
        case english = "en"
        case russian = "ru"
    }
    
    public init(
        azerbaijani: SnapDetails?,
        english: SnapDetails?,
        russian: SnapDetails?
    ) {
        self.azerbaijani = azerbaijani
        self.english = english
        self.russian = russian
    }
}

public struct SnapDetails: Codable {
    public let title: String?
    public let description: String?
    public let buttonText: String?
    public let buttonLink: String?
    
    public init(
        title: String?,
        description: String?,
        buttonText: String?,
        buttonLink: String?
    ) {
        self.title = title
        self.description = description
        self.buttonText = buttonText
        self.buttonLink = buttonLink
    }
}

//
//  SnapTitle.swift
//  PASHABankSME
//
//  Created by Javid Museyibli on 07.08.21.
//

import Foundation

struct SnapTitle: Codable {
    let azerbaijani: SnapDetails?
    let english: SnapDetails?
    let russian: SnapDetails?

    private enum CodingKeys: String, CodingKey {
        case azerbaijani = "az"
        case english = "en"
        case russian = "ru"
    }
}

struct SnapDetails: Codable {
    let title: String?
    let description: String?
    let buttonText: String?
    let buttonLink: String?
}

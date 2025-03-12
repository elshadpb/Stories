//
//  Snap.swift
//  PASHABankSME
//
//  Created by Javid Museyibli on 07.08.21.
//

import Foundation

public struct SnapState {
    public final class Callbacks {
        public enum LocalURLState: Hashable {
            case preparing
            case ready(URL)
            case fail
        }
        
        public var localURLState: ((LocalURLState) -> Void)?
        public var startLocalURLFetch: (() -> Void)?
        
        public init() {}
    }
    
    public let id: Int?
    public let mediaType: MediaType?
    public let mediaId: String?
    public let snapLanguage: SnapTitle?
    
    public let callbacks: Callbacks
    
    public init(
        id: Int?,
        mediaType: MediaType?,
        mediaId: String?,
        snapLanguage: SnapTitle?,
        callbacks: Callbacks
    ) {
        self.id = id
        self.mediaType = mediaType
        self.mediaId = mediaId
        self.snapLanguage = snapLanguage
        self.callbacks = callbacks
    }
}

//
//  ImageView+Extensions.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 02/04/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {

    public func setStoryImage(urlString: String, withHeaders headers: [String: String], placeHolderImage: UIImage? = nil, completion: @escaping (Result<RetrieveImageResult, KingfisherError>) -> Void) {

        let url = URL(string: urlString)
        let modifier = AnyModifier { request in
            var urlRequest = request
            headers.forEach { (key, value) in
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            return urlRequest
        }

        self.kf.setImage(with: url, options: [.transition(.fade(0.25)), .requestModifier(modifier)]) { response in
            switch response {
            case .success(let value):
                self.image = value.image
                return completion(.success(value))

            case .failure(let error):
                return completion(.failure(error))
            }

        }
    }
}

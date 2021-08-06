//
//  VideoCacheManager.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 26/07/19.
//  Copyright © 2019 DrawRect. All rights reserved.
//

import Foundation

public class VideoCacheManager {
    
    enum VideoError: Error, CustomStringConvertible {
        case downloadError
        case fileRetrieveError
        var description: String {
            switch self {
            case .downloadError:
                return "Can't download video"
            case .fileRetrieveError:
                return "File not found"
            }
        }
    }
    
    static let shared = VideoCacheManager()
    private init(){}
    typealias Response = Result<URL, Error>
    
    private let fileManager = FileManager.default
    private lazy var mainDirectoryUrl: URL? = {
        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        return documentsUrl
    }()
    
    func getFile(forURL url: String, with headers: [String: String]? = nil, completionHandler: @escaping (Response) -> Void) {
        guard let file = getLocalVideoPath(forRemoteURL: url) else {
            completionHandler(Result.failure(VideoError.fileRetrieveError))
            return
        }
        
        //return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: file.path) else {
            completionHandler(Result.success(file))
            return
        }
        var request = URLRequest(url: URL(string: url)!)
        headers?.forEach({ (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        })
        DispatchQueue.global().async {

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let videoData = data as NSData? {
                    videoData.write(to: file, atomically: true)

                    DispatchQueue.main.async {
                        completionHandler(Result.success(file))
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler(Result.failure(VideoError.downloadError))
                    }
                }
            }.resume()

        }
    }
    func clearCache(for urlString: String? = nil) {
        guard let cacheURL =  mainDirectoryUrl else { return }
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: nil, options: [])
            if let string = urlString, let url = URL(string: string) {
                do {
                    try fileManager.removeItem(at: url)
                }
                catch let error as NSError {
                    debugPrint("Unable to remove the item: \(error)")
                }
            }else {
                for file in directoryContents {
                    do {
                        try fileManager.removeItem(at: file)
                    }
                    catch let error as NSError {
                        debugPrint("Unable to remove the item: \(error)")
                    }
                }
            }
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
    }
    private func getLocalVideoPath(forRemoteURL url: String) -> URL? {
        guard let fileName = URL(string: url)?.lastPathComponent, let directoryPath = self.mainDirectoryUrl else { return nil }
        var filePath = directoryPath.appendingPathComponent(fileName)
        filePath.appendPathExtension(".mp4")
        return filePath
    }

    func removeCachedFile(for urlString: String) {
        getFile(forURL: urlString) { (result) in
            switch result {
            case .success(let url):
                self.clearCache(for: url.absoluteString)
            case .failure(let error):
                debugPrint("File read error: \(error)")
            }
        }
    }
    func removeAllVideoFilesFromCache() {
        clearCache()
    }
}


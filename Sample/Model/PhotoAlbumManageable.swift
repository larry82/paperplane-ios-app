import Foundation
import Photos
import UIKit

protocol PhotoAlbumManageable {}

extension PhotoAlbumManageable {
    func getPhotoAlbum(isSortByCreationDate: Bool = false, isOnlyPhoto: Bool = false) -> PHFetchResult<PHAsset> {
        guard let album: PHAssetCollection = getSelectPhotoAlbum() else {
            return PHAsset.fetchAssets(with: PHFetchOptions())
        }
        
        let options = PHFetchOptions()
        if isSortByCreationDate {
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            options.sortDescriptors = [sortDescriptor]
        }
        
        let allPhoto: PHFetchResult<PHAsset>
        if isOnlyPhoto {
            allPhoto = PHAsset.fetchAssets(with: .image, options: options)
        } else {
            allPhoto = PHAsset.fetchAssets(in: album, options: options)
        }
        
        return allPhoto
    }
    
    func getSelectPhotoAlbum(albumName: String = "") -> PHAssetCollection? {
        var assetAlbum: PHAssetCollection?
        
        let list: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                                             subtype: .any,
                                                                                             options: nil)
        list.enumerateObjects { (album, _, stop) in
            let assectCollection: PHAssetCollection = album
            if albumName == assectCollection.localizedTitle {
                assetAlbum = assectCollection
                stop.initialize(to: true)
            }
        }
        
        if albumName.isEmpty {
            let list = PHAssetCollection.fetchAssetCollections(
                with: .smartAlbum,
                subtype: .smartAlbumUserLibrary,
                options: nil)
            assetAlbum = list[0]
        }
        
        return assetAlbum
    }
    
    func getAndCreatePhotoAlbum(albumName: String = "") -> PHAssetCollection? {
        var assetAlbum: PHAssetCollection?
        
        //Default album
        if albumName.isEmpty {
            let list = PHAssetCollection.fetchAssetCollections(
                with: .smartAlbum,
                subtype: .smartAlbumUserLibrary,
                options: nil)
            assetAlbum = list[0]
            return assetAlbum
        }
        
        assetAlbum = getSelectPhotoAlbum(albumName: albumName)
        
        if assetAlbum != nil {
            return assetAlbum
        } else {
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            }
            assetAlbum = self.getSelectPhotoAlbum(albumName: albumName)
        }
        
        return assetAlbum
    }
    
    func saveDataToAlbum(albumName: String = "",
                         image: UIImage? = nil,
                         type: PHAssetResourceType? = nil,
                         fileData: Data? = nil,
                         filePath: String? = nil,
                         downHandle: ((Bool, Error?) -> Void)? = nil) {
        if image == nil && type == nil && fileData == nil && filePath == nil {
            print("noData to save")
            downHandle?(false, nil)
            return
        }
        
        guard let album: PHAssetCollection = getAndCreatePhotoAlbum(albumName: albumName) else {
            print("getAndCreatePhotoAlbum fail")
            downHandle?(false, nil)
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            var result: PHAssetChangeRequest!
            if let image = image {
                result = PHAssetChangeRequest.creationRequestForAsset(from: image)
            } else if let data = fileData, let dataType = type {
                let request = PHAssetCreationRequest.forAsset()
                result = request
                request.addResource(with: dataType, data: data, options: nil)
            } else if let filePath = filePath, let dataType = type {
                let request = PHAssetCreationRequest.forAsset()
                result = request
                request.addResource(with: dataType, fileURL: URL(fileURLWithPath: filePath), options: nil)
            } else {
                downHandle?(false, nil)
                return
            }
            
            if !albumName.isEmpty {
                if result != nil {
                    let assetPlaceholder: PHObjectPlaceholder? = result.placeholderForCreatedAsset
                    let albumChangeRequset: PHAssetCollectionChangeRequest? = PHAssetCollectionChangeRequest(for: album)
                    guard let placeholder = assetPlaceholder else {
                        downHandle?(false, nil)
                        return
                    }
                    
                    guard let albumChange: PHAssetCollectionChangeRequest = albumChangeRequset else {
                        downHandle?(false, nil)
                        return
                    }
                    albumChange.addAssets([placeholder] as NSArray)
                }
            }
        }, completionHandler: downHandle)
    }
    
    func getImageFromAlbum(
        isThumbnail: Bool = false,
        thumbnailSize: CGSize = CGSize(width: 512, height: 512),
        photo: PHAsset,
        _ downHandle: ((_ isDone: Bool, _ image: UIImage?) -> Void)?
    ) -> PHImageRequestID {
        var targetSize: CGSize!
        
        if isThumbnail {
            targetSize = thumbnailSize
        } else {
            targetSize = PHImageManagerMaximumSize
        }
        
        return PHImageManager.default().requestImage(
            for: photo,
            targetSize: targetSize,
            contentMode: .aspectFit,
            options: nil) { (image, _: [AnyHashable: Any]?) in
                downHandle?(true, image)
        }
    }
    
    func getImageDataFromAlbum(photo: PHAsset, _ downHandle: ((_ data: Data?) -> Void)?) -> PHImageRequestID {
        return PHImageManager.default().requestImageDataAndOrientation(for: photo, options: nil) { data, _, _, _ in
            downHandle?(data)
        }
    }
    
    func getVideoDataFromAlbum(video: PHAsset, _ downHandle: ((_ data: Data?) -> Void)? ) -> PHImageRequestID {
        return PHImageManager.default().requestAVAsset(forVideo: video, options: nil) { (video, _, info) in
            print("Info: ", info as Any)
            if let videoUrl = video as? AVURLAsset {
                do {
                    let videoData = try Data(contentsOf: videoUrl.url)
                    downHandle?(videoData)
                    return
                } catch {
                    downHandle?(nil)
                    print("exception catch at block - while uploading video")
                }
            } else {
                downHandle?(nil)
                return
            }
        }
    }
    
    func thumbnailFromLocalVideo(url: URL) -> UIImage? {
        let avAsset = AVURLAsset(url: url)
        return thumbnailFromVideo(avAsset: avAsset)
    }

    func thumbnailFromNetworkVideo(player: AVPlayer) -> UIImage? {
        guard let avAsset = player.currentItem?.asset else {
            return nil
        }
        return thumbnailFromVideo(avAsset: avAsset)
    }

    func thumbnailFromVideo(avAsset: AVAsset) -> UIImage? {
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        var actualTime: CMTime = CMTimeMake(value: 0, timescale: 0)
        guard let imageRef: CGImage = try? generator.copyCGImage(at: time, actualTime: &actualTime) else {
            print("thumbnailFromLocalVideo error")
            return nil
        }
        return UIImage(cgImage: imageRef)
    }

    func photoLibraryPermissions(_ handler: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .notDetermined:
                handler(true)
            case .authorized:
                handler(true)
            case .denied, .restricted:
                handler(false)
            case .limited:
                handler(true)
            @unknown default:
                print("Unknown Error")
                handler(false)
            }
        }
    }
}

//
//  FirebaseService.swift
//  ANO
//
//  Created by Mychal Culpepper on 11/19/16.
//  Copyright © 2016 Blue Shift Group. All rights reserved.
//

import UIKit
import Firebase

class FirebaseService {
    static let sharedInstance = FirebaseService()
    
    func getAllLocations(completion: @escaping ([Location]?) -> Void) {
        let ref = FIRDatabase.database().reference().child("Locations")
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            var aryLocations = [Location]()
            for child in snapshot.children {
                let childSnapshot = child as! FIRDataSnapshot
                if let dicLocation = childSnapshot.value as? [String: Any] {
                    aryLocations.append(Location(json: dicLocation))
                }
            }
            
            completion(aryLocations)
        })
    }
    
    func updateUserInfo(id: String, user: [String: Any], completion: @escaping(String?) -> Void) {
        var userInfo = user
        
        let usersRef = FIRDatabase.database().reference().child("Users").child(id)
        usersRef.updateChildValues(user, withCompletionBlock: { (error, ref) in
            if error != nil {
                completion(error?.localizedDescription)
            } else {
                userInfo["id"] = id
                User.currentUser = User(json: userInfo)
                completion(nil)
            }
        })
    }
    
    func uploadImage(ref: FIRStorageReference, image: UIImage, completion: @escaping (String?, String?) -> Void) {
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.5) {
            ref.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                
                if error == nil {
                    if let imageUrl = metadata?.downloadURL()?.absoluteString {
                        completion(imageUrl, nil)
                    } else {
                        completion(nil, error?.localizedDescription)
                    }
                } else {
                    completion(nil, error?.localizedDescription)
                }
            })
        } else {
            completion(nil, "Invaid Photo")
        }
    }
    
    func uploadVideo(ref: FIRStorageReference, file: URL, completion: @escaping (String?, String?) -> Void) {
        let metadata = FIRStorageMetadata()
        metadata.contentType = "video/quicktime"
        
        ref.putFile(file, metadata: metadata, completion: { (metadata, error) in
            if error == nil {
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl, nil)
                } else {
                    completion(nil, error?.localizedDescription)
                }
            } else {
                completion(nil, error?.localizedDescription)
            }
        })
    }
    
    func addMediaToFeed(eventID: String, videoUrl: String, imageUrl: String, mediaType: Constants.MediaType, completion: @escaping (String?) -> Void) {
        let ref = FIRDatabase.database().reference().child("Feeds").childByAutoId()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd h:mm a"
        
        let feed = [
                    "eventID": eventID,
                    "videoUrl": videoUrl,
                    "imageUrl": imageUrl,
                    "mediaType": mediaType == Constants.MediaType.Photo ? 0 : 1,
                    "userID": User.currentUser?.userID ?? "",
                    "createdAt": formatter.string(from: Date())] as [String : Any]
        ref.updateChildValues(feed) { (error, ref) in            
            completion(error?.localizedDescription)
        }
    }
    
    func createEvent(event: [String: Any], completion: @escaping (String?, String?) -> Void) {
        let eventRef = FIRDatabase.database().reference().child("Events").childByAutoId()
        eventRef.updateChildValues(event, withCompletionBlock: { (error, eventRef) in
            if error != nil {
                completion(nil, error?.localizedDescription)
            } else {
                completion(eventRef.key, nil)
            }
        })
    }
    
    func updateUserEventID(eventID: String, completion: @escaping (String?) -> Void) {
        let ref = FIRDatabase.database().reference().child("Users").child((User.currentUser?.userID)!)
        
        ref.updateChildValues(["eventID": eventID], withCompletionBlock: {(error, ref) in
            if error != nil {
                completion(error?.localizedDescription)
            } else {
                completion(nil)
            }
        })
    }
    
    func getAllEventUsers(eventID: String, completion: @escaping ([User]?) -> Void) {
        let ref = FIRDatabase.database().reference().child("Users")
        ref.observe(.value, with: {(snapshot) in
            var aryUsers = [User]()
            for child in snapshot.children {
                let childSnapshot = child as! FIRDataSnapshot
                if let dicUser = childSnapshot.value as? [String: Any] {
                    let user = User(json: dicUser)
                    if user.userEventID == eventID {
                        aryUsers.append(user)
                    }
                }
            }
            
            completion(aryUsers)
        })
    }
    
    func getAllEventFeeds(eventID: String, completion: @escaping ([Feed]?) -> Void) {
        let ref = FIRDatabase.database().reference().child("Feeds")
        ref.observe(.value, with: {(snapshot) in
            var aryFeeds = [Feed]()
            for child in snapshot.children {
                let childSnapshot = child as! FIRDataSnapshot
                if let dicFeed = childSnapshot.value as? [String: Any] {
                    let feed = Feed(key: childSnapshot.key, json: dicFeed)
                    if feed.feedEventID == eventID {
                        aryFeeds.append(feed)
                    }
                }
            }
            
            completion(aryFeeds)
        })
    }
    
    func reportMedia(eventID: String, feedID: String, completion: @escaping (String?) -> Void) {
        let reportRef = FIRDatabase.database().reference().child("Reports").childByAutoId()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd h:mm a"
        let report = [
            "userID": User.currentUser?.userID ?? "",
            "eventID": eventID,
            "feedID": feedID,
            "createdAt": formatter.string(from: Date())] as [String : Any]
        
        reportRef.updateChildValues(report, withCompletionBlock: { (error, eventRef) in
            if error != nil {
                completion(error?.localizedDescription)
            } else {
                completion(nil)
            }
        })
    }
}

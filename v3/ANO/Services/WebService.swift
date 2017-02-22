//
//  WebService.swift
//  ANO
//
//  Created by Jacob May on 12/30/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

class WebService {
    static var _webService: WebService? = nil;
    var header: [String: String]?
    
    static func sharedInstance() -> WebService {
        if(_webService == nil) {
            _webService = WebService()
        }
        
        return _webService!;
    }
    
    init() {
        let defaults = UserDefaults.standard;
        if let strToken = defaults.string(forKey: Constants.UserDefaults.USER_ACCESS_TOKEN) {
            self.header = ["AccessToken": strToken]
        }
    }
    
    private func saveAccessToken(_ AccessToken: String) {
        self.header = ["AccessToken": AccessToken]
        
        let defaults = UserDefaults.standard;
        defaults.set(AccessToken, forKey: Constants.UserDefaults.USER_ACCESS_TOKEN)
        defaults.synchronize()
    }
    
    private func getErrorString(ErrorData: Data) -> String {
        do {
            let dicError = try JSONSerialization.jsonObject(with: ErrorData, options: []) as! [String: Any]
            return dicError[Constants.Server.RESPONSE_MESSAGE] as! String
        } catch let error {
            return error.localizedDescription
        }
    }
    
    func login(UserName: String, UserPass: String, completion: @escaping (UserObj?, String?) -> Void) {
        let dicParams = [
            "user_name"         : UserName,
            "user_pass"         : UserPass,
            "user_device_type"  : "iOS",
            "user_device_token" : GlobalService.sharedInstance().g_userDeviceToken!
            ] as [String: Any]
        
        Alamofire.request("\(Constants.Server.URL)/users/login",
            parameters: dicParams)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let value as [String: Any]):
                    self.saveAccessToken(value["my_access_token"] as! String)
                    let objUser = Mapper<UserObj>().map(JSON: value["my_user"] as! [String : Any])
                    completion(objUser, nil)
                case .failure(_):
                    completion(nil, self.getErrorString(ErrorData: response.data!))
                default:
                    completion(nil, "Unkown Error")
                }
                
        }
    }
    
    func signup(UserName: String, UserPass: String, UserPhone: String, completion: @escaping (UserObj?, String?) -> Void) {
        let dicParams = [
            "user_name"         : UserName,
            "user_pass"         : UserPass,
            "user_phone"        : UserPhone,
            "user_device_type"  : "iOS",
            "user_device_token" : GlobalService.sharedInstance().g_userDeviceToken!
            ] as [String: Any]
        
        Alamofire.request("\(Constants.Server.URL)/users",
            method: .post,
            parameters: dicParams)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let value as [String: Any]):
                    self.saveAccessToken(value["my_access_token"] as! String)
                    let objUser = Mapper<UserObj>().map(JSON: value["my_user"] as! [String : Any])
                    completion(objUser, nil)
                case .failure(_):
                    completion(nil, self.getErrorString(ErrorData: response.data!))
                default:
                    completion(nil, "Unkown Error")
                }
                
        }
    }
    
    func sendVerificationCode(PhoneNumber: String, VerificationCode: String, IsSignUp: Bool, completion: @escaping (String?, String?) -> Void) {
        let dicParams = [
            "phone_number"      : PhoneNumber,
            "verification_code" : VerificationCode,
            "is_sign_up"        : IsSignUp
            ] as [String : Any]
        
        Alamofire.request("\(Constants.Server.URL)/send/code",
            method: .post,
            parameters: dicParams)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let value as [String: String]):
                    completion(value[Constants.Server.RESPONSE_MESSAGE], nil)
                case .failure(_):
                    completion(nil, self.getErrorString(ErrorData: response.data!))
                default:
                    completion(nil, "Unkown Error")
                }
        }
    }
    
    func resetPassword(PhoneNumber: String, NewPass: String, completion: @escaping (String?, String?) -> Void) {
        let dicParams = [
            "user_phone"    : PhoneNumber,
            "user_pass"     : NewPass
            ] as [String : Any]
        
        Alamofire.request("\(Constants.Server.URL)/users/reset/password",
            method: .patch,
            parameters: dicParams)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let value as [String: String]):
                    completion(value[Constants.Server.RESPONSE_MESSAGE], nil)
                case .failure(_):
                    completion(nil, self.getErrorString(ErrorData: response.data!))
                default:
                    completion(nil, "Unkown Error")
                }
        }
    }
    
    func getActiveEvents(completion: @escaping ([EventObj]?, String?) -> Void) {
        Alamofire.request("\(Constants.Server.URL)/events/active",
            headers: header)
            .validate()
            .responseArray { (response: DataResponse<[EventObj]>) in
                switch response.result {
                case .success(let value):
                    completion(value, nil)
                case .failure(_):
                    completion(nil, self.getErrorString(ErrorData: response.data!))
                }
        }
    }
    
    func voteVibe(VibeId: Int, IsLike: Bool, completion: @escaping (String?, String?) -> Void) {
        let dicParams = [
            "vibe_vote_type"    : IsLike
            ] as [String : Any]
        
        Alamofire.request("\(Constants.Server.URL)/vibes/\(VibeId)",
            method: .post,
            parameters: dicParams,
            headers: header)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let value as [String: String]):
                    completion(value[Constants.Server.RESPONSE_MESSAGE], nil)
                case .failure(_):
                    completion(nil, self.getErrorString(ErrorData: response.data!))
                default:
                    completion(nil, "Unkown Error")
                }
        }
    }
    
    func addVibe(EventId: Int, Text: String, completion: @escaping (VibeObj?, String?) -> Void) {
        let dicParams = [
            "vibe_text" : Text
            ] as [String: Any]
        
        Alamofire.request("\(Constants.Server.URL)/events/\(EventId)/vibes",
            method: .post,
            parameters: dicParams,
            headers: header)
            .validate()
            .responseObject { (response: DataResponse<VibeObj>) in
                switch response.result {
                case .success(let value):
                    completion(value, nil)
                case .failure(_):
                    completion(nil, self.getErrorString(ErrorData: response.data!))
                }
        }
    }
    
    func markMediaAsRead(MediaId: Int, completion: @escaping (String?, String?) -> Void) {
        Alamofire.request("\(Constants.Server.URL)/medias/\(MediaId)/read",
            method: .post,
            headers: header)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let value as [String: String]):
                    completion(value[Constants.Server.RESPONSE_MESSAGE], nil)
                case .failure(_):
                    completion(nil, self.getErrorString(ErrorData: response.data!))
                default:
                    completion(nil, "Unkown Error")
                }
        }
    }
    
    func reportMedia(MediaId: Int, completion: @escaping (String?, String?) -> Void) {
        Alamofire.request("\(Constants.Server.URL)/medias/\(MediaId)/report",
            method: .post,
            headers: header)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let value as [String: String]):
                    completion(value[Constants.Server.RESPONSE_MESSAGE], nil)
                case .failure(_):
                    completion(nil, self.getErrorString(ErrorData: response.data!))
                default:
                    completion(nil, "Unkown Error")
                }
        }
    }
    
    func uploadPhoto(EventId: Int, Photo: UIImage, MediaType: String, onProgress: @escaping (Double?) -> Void, completion: @escaping (MediaObj?, String?) -> Void) {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImageJPEGRepresentation(Photo, 0.5)!,
                                     withName: "media_photo",
                                     fileName: "media_photo.jpg",
                                     mimeType: "image/jpeg")
            multipartFormData.append(MediaType.data(using: .utf8)!,
                                     withName: "media_type")
        },
                         to: "\(Constants.Server.URL)/events/\(EventId)/photos",
            headers: header)
        { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress() { (progress) in
                    onProgress(progress.fractionCompleted)
                }
                upload.responseObject() { (response: DataResponse<MediaObj>) in
                    switch response.result {
                    case .success(let value):
                        completion(value, nil)
                    case .failure(_):
                        completion(nil, self.getErrorString(ErrorData: response.data!))
                    }
                }
            case .failure(let error):
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    func uploadVideo(EventId: Int, Thumbnail: UIImage, VideoURL: URL, onProgress: @escaping (Double?) -> Void, completion: @escaping (MediaObj?, String?) -> Void) {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImageJPEGRepresentation(Thumbnail, 0.5)!,
                                     withName: "media_photo",
                                     fileName: "media_photo.jpg",
                                     mimeType: "image/jpeg")
            multipartFormData.append(VideoURL, withName: "media_video", fileName: "media_video.mov", mimeType: "video/quicktime")
        },
                         to: "\(Constants.Server.URL)/events/\(EventId)/videos",
            headers: header)
        { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress() { (progress) in
                    onProgress(progress.fractionCompleted)
                }
                upload.responseObject() { (response: DataResponse<MediaObj>) in
                    switch response.result {
                    case .success(let value):
                        completion(value, nil)
                    case .failure(_):
                        completion(nil, self.getErrorString(ErrorData: response.data!))
                    }
                }
            case .failure(let error):
                completion(nil, error.localizedDescription)
            }
        }
    }
}

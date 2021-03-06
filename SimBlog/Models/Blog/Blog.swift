//
//  Blog.swift
//  SimBlog
//
//  Created by 松下慶大 on 2016/04/27.
//  Copyright © 2016年 matsushita keita. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Bond

class Blog: NSObject {
    var materials: [AnyObject] = []
    var title: String! = ""
    var sentence: String! = ""
    var topImage: UIImage?
    var id: Int!
    var topImageURL: String?
    var user: User!
    var comments: [Comment] = []
    
    var likesCount = Observable<Int>(0)
    var commentsCount = Observable<Int>(0)
    
    var numberOfMaterials: Int {
        return materials.count
    }
    
    init(apiAttributes: JSON) {
        self.title = apiAttributes["title"].string
        self.sentence = apiAttributes["sentence"].string
        self.topImageURL = apiAttributes["image"]["url"].string
        self.id = apiAttributes["id"].int
        self.likesCount.value = apiAttributes["likes_count"].int!
        self.commentsCount.value = apiAttributes["comments_count"].int!
    }
    
    override init() {
        super.init()
        addTextAtPosition("")
    }
    
    func addTextAtPosition(text: String) {
        materials.insert(BlogText(text: text, order: numberOfMaterials), atIndex: numberOfMaterials)
    }
    
    func addImageAtPosition(image: UIImage) {
        materials.insert(BlogImage(image: image, order: numberOfMaterials), atIndex: numberOfMaterials)
    }
    
    func addMaterialAtPosition(material: AnyObject, index: Int) {
        
        materials.insert(material, atIndex: index)
    }
    
    func materialAtPosition(index: Int) -> AnyObject {
        return materials[index]
    }
    
    //API
    func saveInbackground(callback: () -> Void) {
        
        let blogTexts = divideToBlogText()
        let blogImages = divideToBlogImage()
        
        var params: [String: AnyObject] = [
            "title": self.title,
            "sentence": self.sentence,
            "user_id": CurrentUser.sharedInstance.id
        ]
        
        for blogText in blogTexts {
            params["\(blogText.order)-text"] = blogText.text
        }
        
        let pass = String.rootPath() + "/api/blogs/"
        let httpMethod = Alamofire.Method.POST.rawValue

        let urlRequest = NSData.urlRequestWithComponents(httpMethod, urlString: pass, parameters: params, images: blogImages)
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .responseJSON { response in
                guard let object = response.result.value else {
                    StatusBarNotification.showErrorMessage()
                    return
                }
                StatusBarNotification.hideMessage()
                let json = JSON(object)
                self.id = json["blog"]["id"].int
                self.user = User(apiAttributes: json["user"])
                callback()
        }
    }
    
    //MARK blog show
    func findMaterialsInBackground(callback: () -> Void) {
        Alamofire.request(.GET, String.rootPath() + "/api/blogs/\(self.id)", parameters: nil)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                let json = JSON(object)
                self.materials = []
                for material in json["materials"].array! {
                    let type = material["material_type"].string!
                    if type == "Text" {
                        let sentence = material["material"]["sentence"].string!
                        let order = material["material"]["order"].int!
                        let blogText = BlogText(text: sentence, order: order)
                        self.addMaterialAtPosition(blogText, index: 0)
                    } else {
                        let order = material["material"]["order"].int!
                        let blogImage = BlogImage(image: nil, order: order)
                        blogImage.imageURL = material["material"]["image"]["url"].string!
                        self.addMaterialAtPosition(blogImage, index: 0)
                    }
                }
                self.materials = self.sortMaterials()
                callback()
        }
    }
    
    func deleteBlogInBackground(callback: () -> Void) {
        Alamofire.request(.DELETE, String.rootPath() + "/api/blogs/\(self.id)", parameters: nil)
            .responseJSON { response in
                guard let _ = response.result.value else {
                    callback()
                    return
            }
            callback()
        }
    }
    
    //MARK: Comment API
    func getCommentsInBackground(completion: () -> Void) {
        let params: [String: AnyObject] = [
            "blog_id": self.id
        ]
        Alamofire.request(.GET, String.rootPath() + "/api/comments", parameters: params)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                self.comments = []
                let json = JSON(object)
                for cmt in json["comments"].array! {
                    let comment = Comment(json: cmt)
                    self.comments.append(comment)
                    completion()
                }
                completion()
        }
    }
    
    private func divideToBlogText() -> [BlogText]{
        var blogTexts: [BlogText] = []
        for material in self.materials {
            if let blogText = material as? BlogText {
                blogTexts.append(blogText)
            }
        }
        return blogTexts
    }
    
    private func divideToBlogImage() -> [BlogImage]{
        var blogImages: [BlogImage] = []
        for material in self.materials {
            if let blogText = material as? BlogImage {
                blogImages.append(blogText)
            }
        }
        return blogImages
    }
    
    private func sortMaterials() -> [AnyObject] {
        let mterialsCount = self.materials.count
        var tmpArray: [AnyObject] = Array(count: mterialsCount, repeatedValue: "aaa")
        for material in materials {
            if let blogText = material as? BlogText {
                tmpArray.insert(blogText, atIndex: blogText.order)
                tmpArray.removeAtIndex(blogText.order + 1)
                
            } else {
                let blogImage = material as! BlogImage                
                tmpArray.insert(blogImage, atIndex: blogImage.order)
                tmpArray.removeAtIndex(blogImage.order + 1)
            }
        }
        return tmpArray
    }
    
    
}

//
//  CZManufacturerModel.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 24/08/21.
//

import Foundation


struct Model:Codable, Hashable {
    var id:String
    var name:String
    var manufacturerName:String?
}

struct CZCarManufacturer:Codable {
    var page:Int
    var pageSize:Int
    var totalPageCount:Int
    var objectList:[Model]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pageSize
        case totalPageCount
        case objectList = "wkda"
    }

    public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.page = try container.decode(Int.self, forKey: CodingKeys.page.self)
            self.pageSize = try container.decode(Int.self, forKey: CodingKeys.pageSize.self)
            self.totalPageCount = try container.decode(Int.self, forKey: CodingKeys.totalPageCount.self)
            let manuafactureContainer = try container.decode([String:String].self, forKey: CodingKeys.objectList.self)
            
            print(manuafactureContainer)
            self.objectList = [Model]()
            for (key,value) in manuafactureContainer {
                self.objectList.append(Model(id: key, name: value))
            }
    }
        
}

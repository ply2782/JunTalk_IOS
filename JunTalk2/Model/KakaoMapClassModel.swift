//
//  KakaoMapClassModel.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/09/04.
//

import Foundation


public class ResultSearchKeyword : Codable {
    var meta : PlaceMeta ;
    var documents : [Place];
    
    
    init() throws{
        self.meta = try PlaceMeta.init();
        self.documents = [];
    }
    
}

public class PlaceMeta : Codable {
    var total_count :Int;
    var pageable_count : Int;
    var is_end : Bool;
    var same_name : RegionInfo ;
    
    init() throws {
        
        self.total_count = 0;
        self.pageable_count = 0;
        self.is_end = false;
        self.same_name = try RegionInfo.init();
    }
}

public class RegionInfo : Codable {
    var region : [String];
    var keyword : String
    var selected_region : String;
    
    init() throws{
        
        self.region = []
        self.keyword = "";
        self.selected_region = "";
    }
}

public class Place : Codable {
    var id :String;
    var place_name : String ;
    var category_name : String ;
    var category_group_code : String ;
    var category_group_name : String ;
    var phone:  String ;
    var address_name : String ;
    var road_address_name : String ;
    var x : String ;
    var y : String ;
    var place_url : String ;
    var distance : String ;
    
    init () throws{
        self.id = "";
        self.place_name = "";
        self.category_name = "";
        self.category_group_code = "";
        self.category_group_name = "";
        self.phone = "";
        self.address_name = "";
        self.road_address_name = "";
        self.x = "";
        self.y = "" ;
        self.place_url = "";
        self.distance = "";
        
    }
    
    func serialize() -> Dictionary<String, Any> {
        return [
            "id" : id,
            "place_name" : place_name,
            "category_name" : category_name,
            "category_group_code" : category_group_code,
            "category_group_name" : category_group_name,
            "phone" : phone,
            "address_name" : address_name,
            "road_address_name": road_address_name,
            "x": x,
            "y": y,
            "place_url": place_url,
            "distance" : distance
       ]
    }
}

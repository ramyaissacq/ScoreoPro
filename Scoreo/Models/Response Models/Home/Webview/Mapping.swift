//
//  Mapping.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on November 15, 2022
//
import Foundation
import SwiftyJSON

struct Mapping {

	let keyword: String?
	let redirectUrl: String?
	let openType: String?

	init(_ json: JSON) {
		keyword = json["keyword"].stringValue
		redirectUrl = json["redirect_url"].stringValue
		openType = json["open_type"].stringValue
	}

}
//
//  CollisionCategory.swift
//  TowerDefense
//
//  Created by Gabriel Motelevicz Okura on 29/07/23.
//

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let bullet  = CollisionCategory(rawValue: 1 << 0) // 00...01
    static let tower = CollisionCategory(rawValue: 1 << 3)
    static let alien = CollisionCategory(rawValue: 1 << 5)
}

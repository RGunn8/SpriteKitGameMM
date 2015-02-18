//
//  WorldGenerator.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/12/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation
import SpriteKit

class WorldGenerator: SKNode {

    var moveGroundAction: SKAction!
    var groundPieces = [SKSpriteNode]()
    var moveGroundForeverAction: SKAction!

    var groundSpeed: CGFloat = 1.0
    let groundResetXCoord: CGFloat = -500
    var timeIncrement:Double = 0.001


    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


//    func moveBackground() {
//
//        var moveGroundAction = SKAction.repeatActionForever(SKAction.sequence([SKAction.moveByX(-groundSpeed, y: 0, duration: 0.02)]))
//
//        for sprite in groundPieces {
//            sprite.runAction(moveGroundForeverAction)
//        }
//        
//    }

    func setupScenery() {
        /* Setup your scene here */

        //Add background sprites
        let bgImages:[String] = ["bg_spaceship_1", "bg_spaceship_2", "bg_spaceship_3"]
        var bg = SKSpriteNode(imageNamed: bgImages[0])

        bg.position = CGPointMake(bg.size.width / 2, bg.size.height / 2)

        addChild(bg)

        for var x = 0; x < bgImages.count; x++ {
            var sprite = SKSpriteNode(imageNamed: bgImages[x])

            groundPieces.append(sprite)

            var wSpacing = sprite.size.width / 2
            var hSpacing = sprite.size.height / 2

            if x == 0 {
                sprite.position = CGPointMake(wSpacing, hSpacing)
            } else {
                sprite.position = CGPointMake((wSpacing * 2) + groundPieces[x - 1].position.x,groundPieces[x - 1].position.y)
            }
            
            addChild(sprite)

        }
    }


    func groundMovement() {
        for var x = 0; x < groundPieces.count; x++ {
            if groundPieces[x].position.x <= groundResetXCoord {
                if x != 0 {
                    groundPieces[x].position = CGPointMake(groundPieces[x - 1].position.x + groundPieces[x].size.width,groundPieces[x].position.y)
                } else {
                    groundPieces[x].position = CGPointMake(groundPieces[x + 1].position.x + groundPieces[x].size.width,groundPieces[x].position.y)
                }
            }
        }
    }



}
//
//  PowerUp.swift
//  SpriteKitGameMM
//
//  Created by Nick Dobrez on 2/13/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Spritekit

class PowerUp: SKSpriteNode {

    init(imageNamed: String) {

        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color: nil, size: imageTexture.size())
    }

    required init!(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

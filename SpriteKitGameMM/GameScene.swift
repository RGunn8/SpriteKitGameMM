//
//  GameScene.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/11/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate {

   // var increment = 0
    var soldierNode:Soldier?
    var girlSoldierNode:GirlSoldier? // testing for adding another player for selection
    var obstruction:Obstruction!
    var max:Obstruction! // playing around
    var moveObject = SKAction()
    var platform:Platform?
    var powerup: PowerUp?
    var bomb:Bomb!
    var labelScore:SKLabelNode!
    var score: Int!
    var scoreNode:Scorenode!

    //allows us to differentiate sprites
    struct PhysicsCategory {
        static let None                : UInt32 = 0
        static let SoldierCategory     : UInt32 = 0b1      // 1
        static let ObstructionCategory : UInt32 = 0b10     // 2
        static let Edge                : UInt32 = 0b100    // 3
        static let PlatformCategory    : UInt32 = 0b1000   // 4
        static let PowerupCategory     : UInt32 = 0b10000  // 5
        static let ScoreNodeCategory   : UInt32 = 0b100000 // 6
    }

    // Buttons
    let buttonJump    = SKSpriteNode(imageNamed: "directionUpRed")
    let buttonDuck    = SKSpriteNode(imageNamed: "directionDownRed")
    let buttonFire    = SKSpriteNode(imageNamed: "fireButtonRed")

    // Status Holders
    let healthStatus  = SKSpriteNode(imageNamed: "healthStatus")
    let scoreKeeperBG = SKSpriteNode(imageNamed: "scoreKeepYellow")

    let totalGroundPieces = 5
    var groundPieces = [SKSpriteNode]()

    let groundSpeed: CGFloat = 3.5
    var moveGroundAction: SKAction!
    var moveGroundForeverAction: SKAction!
    let groundResetXCoord: CGFloat = -500


    override func didMoveToView(view: SKView) {

        //added for collision detection
        //        view.showsPhysics = true
        initSetup()
        setupScenery()
        startGame()
         self.physicsWorld.gravity    = CGVectorMake(0, -4.5)
         physicsWorld.contactDelegate = self
//        var groundInfo:[String: String] = ["ImageName": "groundOutside",
//                                            "BodyType": "square",
//                                            "Location": "{0, 120}",
//                                   "PlaceMultiplesOnX": "10"
//                                                        ]
//
//        let groundPlatform = Object(groundDict: groundInfo)
//        addChild(groundPlatform)
        score = 0
        addScoreLabel()

        //adds soldier, moved to function to clean up
        addSoldier()
        addGirlSoldier()
        addScoreNode()
        //add an edge to keep soldier from falling forever. This currently has the edge just off the screen, needs to be fixed.
        addEdge()

        // PUT THIS STUFF INTO A SEPERATE GAME BUTTON CONTROLLERS CLASS
        addButtons()

//        addBombs() // testing out bombs

        let distance = CGFloat(self.frame.size.width * 2.0)
        let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.02 * distance))
        moveObject = SKAction.sequence([moveObstruction])

        let spawn = SKAction.runBlock({() in self.addBadGuys()})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.9))
        let spawnThenDelay = SKAction.sequence([spawn,delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)

        self.runAction(spawnThenDelayForever)

    }
//TODO: Change font size based on phone that is being used
//TODO: Do we want score in the middle?
    func addScoreLabel(){
        labelScore = SKLabelNode(text: "Score: \(score)")
        labelScore.fontName = "MarkerFelt-Wide"
        labelScore.fontSize = 24
        labelScore.zPosition = 4
        //labelScore.position = CGPointMake(500, 625)
        labelScore.position = CGPointMake(30 + labelScore.frame.size.width/2, self.size.height - (107 + labelScore.frame.size.height/2))
        addChild(labelScore)
    }


    //when Soldier collides with Obsturction, do this function (currently does nothing)
    func soldierDidCollideWithObstacle(Soldier:SKSpriteNode, Obstruction:SKSpriteNode) {
            //let changeColorAction = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 1.0, duration: 0.5)
            //soldierNode!.runAction(changeColorAction)

    }

    func soldierDidCollideWithPowerup(Soldier:SKSpriteNode, PowerUp:SKSpriteNode){
        //let changeColorAction = SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.5)
       // soldierNode!.runAction(changeColorAction)
    }

    func obstructionDidCollideWithScoreNode(Obstruction:SKSpriteNode, Scorenode:SKSpriteNode){
        score = score + 1
        labelScore.text = "Score: \(score)"
        println("Hit")
    }

    //when contact begins
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody : SKPhysicsBody
        var secondBody: SKPhysicsBody

        //die()

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody  = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody  = contact.bodyB
            secondBody = contact.bodyA
        }

        if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.ObstructionCategory != 0)) {
                soldierDidCollideWithObstacle(firstBody.node as SKSpriteNode, Obstruction: secondBody.node as SKSpriteNode)
                //die()
        } else if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.PowerupCategory != 0)){
                soldierDidCollideWithPowerup(firstBody.node as SKSpriteNode, PowerUp: secondBody.node as SKSpriteNode)
        } else if ((firstBody.categoryBitMask & PhysicsCategory.ObstructionCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.ScoreNodeCategory != 0)){
                obstructionDidCollideWithScoreNode(firstBody.node as SKSpriteNode, Scorenode: secondBody.node as SKSpriteNode)
        }
    }

    func didEndContact(contact: SKPhysicsContact) {
        // will get called automatically when two objects end contact with each other
    }

    func initSetup()
    {
        moveGroundAction = SKAction.moveByX(-groundSpeed, y: 0, duration: 0.02)
        moveGroundForeverAction = SKAction.repeatActionForever(SKAction.sequence([moveGroundAction]))
    }

    func startGame()
    {
        for sprite in groundPieces
        {
            sprite.runAction(moveGroundForeverAction)
        }
    }
//TODO: Background isnt sized correctly on ipad screen
    func setupScenery()
    {
        /* Setup your scene here */

        //Add background sprites

        let bgImages:[String] = ["bg_spaceship_1", "bg_spaceship_2", "bg_spaceship_3"]
        var bg = SKSpriteNode(imageNamed: bgImages[0])

        bg.position = CGPointMake(bg.size.width / 2, bg.size.height / 2)

        self.addChild(bg)

        for var x = 0; x < bgImages.count; x++
        {
            var sprite = SKSpriteNode(imageNamed: bgImages[x])

             groundPieces.append(sprite)

            var wSpacing = sprite.size.width / 2
            var hSpacing = sprite.size.height / 2

            if x == 0
            {
                sprite.position = CGPointMake(wSpacing, hSpacing)
            }
            else
            {
                sprite.position = CGPointMake((wSpacing * 2) + groundPieces[x - 1].position.x,groundPieces[x - 1].position.y)
            }

            self.addChild(sprite)
        }
    }

    func groundMovement()
    {
        for var x = 0; x < groundPieces.count; x++
        {
            if groundPieces[x].position.x <= groundResetXCoord
            {
                if x != 0
                {
                    groundPieces[x].position = CGPointMake(groundPieces[x - 1].position.x + groundPieces[x].size.width,groundPieces[x].position.y)
                }
                else
                {
                    groundPieces[x].position = CGPointMake(groundPieces[x + 1].position.x + groundPieces[x].size.width,groundPieces[x].position.y)
//                    groundPieces[x].position = CGPointMake(groundPieces[groundPieces.count - 1].position.x +       groundPieces[x].size.width,groundPieces[x].position.y)
             }
            }
        }
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//         Called when a touch begins 
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            soldierNode?.setCurrentState(Soldier.SoldierStates.Walk)
            soldierNode?.stepState()

            girlSoldierNode?.setCurrentState(GirlSoldier.SoldierStates.Walk)
            girlSoldierNode?.stepState()

            if CGRectContainsPoint(buttonJump.frame, location ) {
                jump()

            } else if CGRectContainsPoint(buttonDuck.frame, location) {
                duck()
                //can delete, just reference in case we want to change colors :)
                //let changeColorAction = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 1.0, duration: 0.5)
               //soldierNode!.runAction(changeColorAction)

            } else if CGRectContainsPoint(buttonFire.frame, location) {
                walkShoot()

            } else {
                run()

            }
        }
    }

    
    func jump() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Jump)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.Jump)
    }

    func duck() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Crouch)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.Crouch)
    }

    func run() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Run)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.Run)
    }

    func runShoot() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.RunShoot)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.RunShoot)
    }

    func walkShoot() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.WalkShoot)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.WalkShoot)
    }

    func walk() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Walk)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.Walk)
    }


    func die() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Dead)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.Dead)
    }

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        soldierNode?.update()
        groundMovement()

    }

    func girlFollowDelay(state: GirlSoldier.SoldierStates) {
        let delay = 0.07 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

        dispatch_after(time, dispatch_get_main_queue()) {
            self.girlSoldierNode?.setCurrentState(state)
            self.girlSoldierNode?.stepState()
        }
    }

    //add a soldier, called in did move to view
    func addSoldier(){
        soldierNode = Soldier(imageNamed: "Walk__000")
        //was 300, 300
        soldierNode?.position = CGPointMake(450, 450)
        soldierNode?.setScale(0.45)
        soldierNode?.physicsBody = SKPhysicsBody(rectangleOfSize: soldierNode!.size)
        soldierNode?.physicsBody?.categoryBitMask = PhysicsCategory.SoldierCategory
        soldierNode?.physicsBody?.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.PlatformCategory
        soldierNode?.physicsBody?.contactTestBitMask = PhysicsCategory.ObstructionCategory
        soldierNode?.physicsBody?.allowsRotation = false
        soldierNode?.physicsBody?.usesPreciseCollisionDetection = true

        addChild(soldierNode!)

        soldierNode?.setCurrentState(Soldier.SoldierStates.Walk)
        soldierNode?.stepState()
    }

    func addGirlSoldier() {
        girlSoldierNode = GirlSoldier(imageNamed: "G-Walk__000")
        girlSoldierNode?.position = CGPointMake(300, 450)
        girlSoldierNode?.setScale(0.45)
        girlSoldierNode?.physicsBody = SKPhysicsBody(rectangleOfSize: girlSoldierNode!.size)
        girlSoldierNode?.physicsBody?.allowsRotation = false
        girlSoldierNode?.physicsBody?.categoryBitMask = PhysicsCategory.SoldierCategory
        girlSoldierNode?.physicsBody?.collisionBitMask = PhysicsCategory.Edge //| PhysicsCategory.ObstructionCategory
        girlSoldierNode?.physicsBody?.contactTestBitMask = PhysicsCategory.ObstructionCategory
        girlSoldierNode?.physicsBody?.usesPreciseCollisionDetection = true

        addChild(girlSoldierNode!)

        girlSoldierNode?.setCurrentState(GirlSoldier.SoldierStates.Walk)
        girlSoldierNode?.stepState()

    }

    func addDon(){
        //Spaceship placeholder, don't delete. Can comment out
        obstruction = Obstruction(imageNamed: "don-bora")
        obstruction.setScale(0.45)
        obstruction.physicsBody = SKPhysicsBody(circleOfRadius: obstruction!.size.width/2)
       // obstruction.position = CGPointMake(740.0, 220.0)
//        let height = UInt32(self.frame.size.height / 4)
//        let y = arc4random() % height + height
        obstruction?.position = CGPointMake(1100.0, 175)

        obstruction.physicsBody?.dynamic = false
        obstruction.physicsBody?.categoryBitMask    = PhysicsCategory.ObstructionCategory
        //obstruction.physicsBody?.collisionBitMask   = PhysicsCategory.SoldierCategory
        obstruction.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory | PhysicsCategory.ScoreNodeCategory
        obstruction.physicsBody?.usesPreciseCollisionDetection = true
        obstruction.runAction(moveObject)

        addChild(obstruction!)
    }

    // Having fun, can remove in real thang if we want
    func addMax(){

        max = Obstruction(imageNamed: "max-howell")
        max.setScale(0.45)

        max.physicsBody = SKPhysicsBody(circleOfRadius: max!.size.width/2)
        let height = UInt32(self.frame.size.height / 4)
        let y = arc4random() % height + height
        max?.position = CGPointMake(1200.0, CGFloat(y + height))
        max.physicsBody?.dynamic = false
        max.physicsBody?.categoryBitMask = PhysicsCategory.ObstructionCategory
        max.physicsBody?.collisionBitMask = PhysicsCategory.ScoreNodeCategory
        max.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory | PhysicsCategory.ScoreNodeCategory
        max.physicsBody?.usesPreciseCollisionDetection = true
        max.runAction(moveObject)

        addChild(max!)

    }

    func addScoreNode(){
        scoreNode = Scorenode(imageNamed: "Spaceship")//(color: SKColor.blueColor(), size: CGSizeMake(100,100))
        scoreNode.position = CGPointMake(650, 380)
        scoreNode.setScale(1.1)
        scoreNode!.physicsBody = SKPhysicsBody(circleOfRadius: scoreNode!.size.width/2)
        scoreNode!.physicsBody?.dynamic = false
        scoreNode!.physicsBody?.categoryBitMask = PhysicsCategory.ScoreNodeCategory
        scoreNode!.physicsBody?.contactTestBitMask = PhysicsCategory.ObstructionCategory
        scoreNode!.physicsBody?.collisionBitMask = PhysicsCategory.ObstructionCategory
        scoreNode!.physicsBody?.usesPreciseCollisionDetection = true

        addChild(scoreNode!)
    }

    func addPlatform() {
        platform = Platform(imageNamed: "platform")
        // max.setScale(0.45)
        platform?.setScale(1.1)
        platform?.physicsBody = SKPhysicsBody(circleOfRadius: platform!.size.width/2)
        platform?.position = CGPointMake(1200.0, 350)
        platform?.physicsBody?.dynamic = false
        platform?.physicsBody?.categoryBitMask = PhysicsCategory.PlatformCategory
        platform?.physicsBody?.collisionBitMask = PhysicsCategory.SoldierCategory
        platform?.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        platform?.physicsBody?.usesPreciseCollisionDetection = true
        platform?.runAction(moveObject)
        
        addChild(platform!)
    }



    func addPowerup() {
        powerup = PowerUp(imageNamed: "powerup")
        // max.setScale(0.45)
        powerup?.setScale(0.75)
        powerup?.physicsBody = SKPhysicsBody(circleOfRadius: powerup!.size.width/2)
        powerup?.position = CGPointMake(1200.0, 420)
        powerup?.physicsBody?.dynamic = false
        powerup?.physicsBody?.categoryBitMask = PhysicsCategory.PowerupCategory
        powerup?.physicsBody?.collisionBitMask = PhysicsCategory.None
        powerup?.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        powerup?.physicsBody?.usesPreciseCollisionDetection = true
        powerup?.runAction(moveObject)

        addChild(powerup!)
    }

    func addBadGuys() {
        let distance = CGFloat(self.frame.size.width * 2.0)
        let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.003 * distance))
        moveObject = SKAction.sequence([moveObstruction])
        //can comment out, need for reference for collisions

        let y = arc4random() % 3
        if y == 0 {
            addDon()
        } else if y == 1 {
            addMax ()
        } else {
            addPlatform()
            addPowerup()
        }
    }

    //add an edge to keep soldier from falling forever. This currently has the edge just off the screen, needs to be fixed.
        func addEdge() {
        let edge = SKNode()
        //might not need the minus 200...will see!
        edge.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0,y: 160,width: self.frame.size.width,height: self.frame.size.height-200))
        edge.physicsBody!.usesPreciseCollisionDetection = true
        edge.physicsBody!.categoryBitMask = PhysicsCategory.Edge
        edge.physicsBody!.dynamic = false
        addChild(edge)
    }

    func addButtons(){
        // PUT THIS STUFF INTO A SEPERATE GAME BUTTON CONTROLLERS CLASS
        buttonJump.position = CGPointMake(75, 400)
        buttonJump.setScale(1.6)
        addChild(buttonJump)

        buttonDuck.position = CGPointMake(75, 200)
        buttonDuck.setScale(1.6)
        addChild(buttonDuck)

        buttonFire.position = CGPointMake(75, 300)
        buttonFire.setScale(1.4)
        addChild(buttonFire)

        healthStatus.position = CGPointMake(100, 630)
        healthStatus.setScale(1.1)
        addChild(healthStatus)

        scoreKeeperBG.position = CGPointMake(950, 610)
        scoreKeeperBG.setScale(1.3)
        addChild(scoreKeeperBG)
    }

//    func addBombs() {
//        bomb.position = CGPointMake(400, 450)
//        addChild(bomb)
//
//        bomb.bombAnimate()
//
//    }


//        if max?.position.x < soldierNode?.position.x || obstruction?.position.x < soldierNode?.position.x {
//            score = score + 1
//            labelScore.text = "Score: \(score)"
//        } else {
//            println("Didnt get it")
//        }

}


//
//  MyScene.m
//  chingam
//
//  Created by Rijul Gupta on 5/11/14.
//  Copyright (c) 2014 Rijul Gupta. All rights reserved.
//

#import "MyScene.h"
#define   IsIphone5     ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface MyScene () <SKPhysicsContactDelegate>

@property (nonatomic) SKSpriteNode * playerSprite;
@property (nonatomic) SKSpriteNode * buttSprite;

@property (nonatomic) int playerSizeChanger;
@property (nonatomic) int xTouchInput;

@property (nonatomic) int touchYPos;
@property (nonatomic) int untouchYPos;

@property (nonatomic) CGSize untouchSize;
@property (nonatomic) CGSize touchSize;


@property (nonatomic) BOOL playerIsHit;

@property (nonatomic) NSTimeInterval timesSinceLastCharge;
@property (nonatomic) NSTimeInterval timesSinceLastUpgrader;
@property (nonatomic) NSTimeInterval timeSinceLastCrap;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@property (nonatomic) int score;
@property (nonatomic) int health;
@property (nonatomic) int maxScore;
@property (nonatomic) int maxHealth;
@property (nonatomic) int level;


@property (nonatomic) SKSpriteNode * scoreImageBack;
@property (nonatomic) SKSpriteNode * scoreImage;
@property (nonatomic) SKSpriteNode * healthImageBack;
@property (nonatomic) SKSpriteNode * healthImage;
@property (nonatomic) SKSpriteNode *timeBack;
@property (nonatomic) SKLabelNode *timeLabel;

@property double sizeChanger;

@property (nonatomic) SKEmitterNode *endGameEmitter;
@property (strong, nonatomic) AVAudioPlayer *backgroundMusicPlayer;


@end


@implementation MyScene


NSMutableArray * playerUntouchedFrames;
NSMutableArray * playerTouchedFrames;
NSMutableArray * playerTouchedRepeatFrames;
NSMutableArray * playerHitFrames;
NSMutableArray * playerShootFrames;
NSMutableArray * moveButtLeftFrames;
NSMutableArray * moveButtRightFrames;
NSMutableArray * crapFrames;
NSMutableArray * crapHitFrames;


SKTextureAtlas *playerUntouchedAnimatedAtlas;
SKTextureAtlas *playerTouchedAnimatedAtlas;
SKTextureAtlas *playerTouchedRepeatAnimatedAtlas;
SKTextureAtlas *playerHitAnimatedAtlas;
SKTextureAtlas *playerShootAnimatedAtlas;
SKTextureAtlas *moveButtLeftAnimatedAtlas;
SKTextureAtlas *moveButtRightAnimatedAtlas;
SKTextureAtlas *crapAnimatedAtlas;
SKTextureAtlas *crapHitAnimatedAtlas;



-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
    
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
   
       // [self addChild:myLabel];
        int iPhone5Changer = 0;
        
        if(IsIphone5){
            iPhone5Changer = 568 - 480;
        }
        _sizeChanger = self.size.width/320;
        _playerIsHit = false;
        
        _playerSizeChanger = 25*_sizeChanger;
        _untouchYPos = 96*_sizeChanger + (iPhone5Changer/4)*_sizeChanger;
        _touchYPos = _untouchYPos + 35*_sizeChanger;
        _untouchSize = CGSizeMake(56*_sizeChanger, 72*_sizeChanger);
        _touchSize = CGSizeMake(280*_sizeChanger, 180*_sizeChanger);
        _isCharging = NO;
        _score = 0;
        _health = 1000;
        _maxScore = 1000;
        _maxHealth = 1000;
        _level = 1;
        _gameOver = false;
        _gameBegan = false;
        
        _playerSprite = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(56*_sizeChanger, 72*_sizeChanger)];
        [_playerSprite setTexture:[SKTexture textureWithImageNamed:@"stillBut.png"]];
       // _playerSprite.size = CGSizeMake(1 * _playerSizeChanger, 1 * _playerSizeChanger);
        _playerSprite.position = CGPointMake(_playerSprite.size.width/2 + 50*_sizeChanger, self.frame.size.height/2 - 100*_sizeChanger);
        [self addChild:_playerSprite];
        
        playerUntouchedFrames = [NSMutableArray array];
        //  SKTextureAtlas *playerWithEggAtlas = [SKTextureAtlas atlasNamed:@"PlayerWithEggImages"];
        playerUntouchedAnimatedAtlas = [SKTextureAtlas atlasNamed:@"playerUntouched"];
        
        
        //add images to the player with egg frames
        int playerUntouchNumImages = playerUntouchedAnimatedAtlas.textureNames.count;
        for (int i=1; i <= playerUntouchNumImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"%d", i];
            SKTexture *temp = [playerUntouchedAnimatedAtlas textureNamed:textureName];
            temp.filteringMode = SKTextureFilteringNearest;
            [playerUntouchedFrames addObject:temp];
        }
     //  playerUntouchedFrames = playerUntouchedFrames;
    
        [self animatePlayerUnTouch];


        
        
        
        
        playerTouchedFrames = [NSMutableArray array];
        //  SKTextureAtlas *playerWithEggAtlas = [SKTextureAtlas atlasNamed:@"PlayerWithEggImages"];
        playerTouchedAnimatedAtlas = [SKTextureAtlas atlasNamed:@"playerTouched"];
        
        
        //add images to the player with egg frames
        int playerTouchedNumImages = playerTouchedAnimatedAtlas.textureNames.count - 2;
        for (int i=-1; i <= playerTouchedNumImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"%d", i];
            SKTexture *temp = [playerTouchedAnimatedAtlas textureNamed:textureName];
            temp.filteringMode = SKTextureFilteringNearest;
            [playerTouchedFrames addObject:temp];
        }
        
        
        playerTouchedRepeatFrames = [NSMutableArray array];
        //  SKTextureAtlas *playerWithEggAtlas = [SKTextureAtlas atlasNamed:@"PlayerWithEggImages"];
        playerTouchedRepeatAnimatedAtlas = [SKTextureAtlas atlasNamed:@"playerTouchedRepeat"];
        
        
        //add images to the player with egg frames
        int playerTouchedRepeatNumImages = playerTouchedRepeatAnimatedAtlas.textureNames.count;
        for (int i=1; i <= playerTouchedRepeatNumImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"%d", i];
            SKTexture *temp = [playerTouchedRepeatAnimatedAtlas textureNamed:textureName];
            temp.filteringMode = SKTextureFilteringNearest;
            [playerTouchedRepeatFrames addObject:temp];
        }
        
        
        
        playerHitFrames = [NSMutableArray array];
        playerHitAnimatedAtlas = [SKTextureAtlas atlasNamed:@"playerHit"];
        int playerHitNumImages = playerHitAnimatedAtlas.textureNames.count - 1;
        for (int i=0; i <= playerHitNumImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"%d", i];
            SKTexture *temp = [playerHitAnimatedAtlas textureNamed:textureName];
            temp.filteringMode = SKTextureFilteringNearest;
            [playerHitFrames addObject:temp];
        }
        
        playerShootFrames = [NSMutableArray array];
        playerShootAnimatedAtlas = [SKTextureAtlas atlasNamed:@"playerShoot"];
        int playerShootNumImages = playerShootAnimatedAtlas.textureNames.count - 1;
        for (int i=0; i <= playerShootNumImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"%d", i];
            SKTexture *temp = [playerShootAnimatedAtlas textureNamed:textureName];
            temp.filteringMode = SKTextureFilteringNearest;
            [playerShootFrames addObject:temp];
        }
      //  [self animateBird];
        
        /*
        _playerSprite.zPosition = 7;
        _playerSprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_playerSprite.size]; // 1
        _playerSprite.physicsBody.dynamic = NO; // 2
  //      _playerSprite.physicsBody.categoryBitMask = birdCategory; // 3
  //      _playerSprite.physicsBody.contactTestBitMask = eggShadowCategory|eggCategory; // 4
        _playerSprite.physicsBody.collisionBitMask = 0;
        //Finished animating the crappy bird
        
        */
        
        
     //   _playerSizeChanger = 25;
        
        
        _buttSprite = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(50*_sizeChanger, 50*_sizeChanger)];
        
        _buttSprite.size = CGSizeMake(112*_sizeChanger, 50*_sizeChanger);
        _buttSprite.position = CGPointMake(_buttSprite.size.width/2 + 20*_sizeChanger, self.frame.size.height - 81*_sizeChanger - (iPhone5Changer*3/4)*_sizeChanger);
        [self addChild:_buttSprite];
        [_buttSprite setTexture:[SKTexture textureWithImageNamed:@"stillBut.png"]];

        
        
        NSString * string = [NSString stringWithFormat:@"stillButt.png"];
        SKTexture *texture = [SKTexture textureWithImageNamed:string];
        texture.filteringMode = SKTextureFilteringNearest;
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:texture];
        SKAction *stillAction = [SKAction animateWithTextures:array timePerFrame:0.05];
        [_buttSprite runAction:stillAction];
        
        moveButtLeftFrames = [NSMutableArray array];
        //  SKTextureAtlas *playerWithEggAtlas = [SKTextureAtlas atlasNamed:@"PlayerWithEggImages"];
        moveButtLeftAnimatedAtlas = [SKTextureAtlas atlasNamed:@"moveButtLeft"];
        
        
        //add images to the player with egg frames
        int moveButtLeftNumImages = moveButtLeftAnimatedAtlas.textureNames.count - 1;
        for (int i=0; i <= moveButtLeftNumImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"%d", i];
            SKTexture *temp = [moveButtLeftAnimatedAtlas textureNamed:textureName];
            temp.filteringMode = SKTextureFilteringNearest;
            [moveButtLeftFrames addObject:temp];
        }
        
        moveButtRightFrames = [NSMutableArray array];
        moveButtRightAnimatedAtlas = [SKTextureAtlas atlasNamed:@"moveButtLeft"];
        
        
        //add images to the player with egg frames
        int moveButtRightNumImages = moveButtRightAnimatedAtlas.textureNames.count - 1;
        for (int i=0; i <= moveButtRightNumImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"%d", i];
            SKTexture *temp = [moveButtRightAnimatedAtlas textureNamed:textureName];
            temp.filteringMode = SKTextureFilteringNearest;
            [moveButtRightFrames addObject:temp];
        }
        
        
        crapFrames = [NSMutableArray array];
        crapAnimatedAtlas = [SKTextureAtlas atlasNamed:@"crap"];
        
        
        //add images to the player with egg frames
        int crapNumImages = crapAnimatedAtlas.textureNames.count + 2;
        for (int i=3; i <= crapNumImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"%d", i];
            SKTexture *temp = [crapAnimatedAtlas textureNamed:textureName];
            temp.filteringMode = SKTextureFilteringNearest;
            [crapFrames addObject:temp];
        }
        
        
        
        
        crapHitFrames = [NSMutableArray array];
        crapHitAnimatedAtlas = [SKTextureAtlas atlasNamed:@"crapHit"];
        int crapHitNumImages = crapAnimatedAtlas.textureNames.count;
        for (int i=1; i <= crapHitNumImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"%d", i];
            SKTexture *temp = [crapHitAnimatedAtlas textureNamed:textureName];
            temp.filteringMode = SKTextureFilteringNearest;
            [crapHitFrames addObject:temp];
        }
        
        
        
        
        
        SKSpriteNode *underLay;
       // underLay = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(280, 440)];
        underLay = [SKSpriteNode spriteNodeWithImageNamed:@"crappyBackground.png"];
        underLay.name = @"underlayNode";
        underLay.size = CGSizeMake(280*_sizeChanger, 360*_sizeChanger);
        underLay.position = CGPointMake((self.size.width)/2, (self.size.height)/2 - (iPhone5Changer/4)*_sizeChanger);
        underLay.zPosition = -100;
        [self addChild:underLay];
        
        
        if(self.size.width >= 768){
            underLay.size = CGSizeMake(280*_sizeChanger, 310*_sizeChanger);
            underLay.position = CGPointMake((self.size.width)/2, (self.size.height)/2 - (iPhone5Changer/4)*_sizeChanger);
            
        }
        SKNode *labelHolder = [SKNode node];
        labelHolder.name = @"labelHolderNode";

        SKSpriteNode *blueBack;
        // underLay = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(280, 440)];
        blueBack = [SKSpriteNode spriteNodeWithImageNamed:@"blueBackground.png"];
        blueBack.size = CGSizeMake(self.size.width, self.size.height);
        blueBack.position = CGPointMake((self.size.width)/2, (self.size.height)/2);
        blueBack.zPosition = -200;
        [self addChild:blueBack];
        
        
        _timeBack = [SKSpriteNode spriteNodeWithImageNamed:@"timeSprite.png"];
        _timeBack.size = CGSizeMake(50*_sizeChanger, 50*_sizeChanger);
        _timeBack.position = CGPointMake(20*_sizeChanger + _timeBack.size.width/2, 5*_sizeChanger + _timeBack.size.height/2 + ((iPhone5Changer)/8)*_sizeChanger);
        _timeBack.zPosition = 1;
        [labelHolder addChild:_timeBack];
        
        
        _timeLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
        _timeLabel.text = @"99";
        _timeLabel.name = @"timeLabelNode";
        _timeLabel.fontSize = 34;
        _timeLabel.position = CGPointMake(_timeBack.position.x, _timeBack.position.y - 18*_sizeChanger);
        _timeLabel.zPosition = 1;
        [labelHolder addChild:_timeLabel];
        
        
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
        scoreLabel.text = @"score:";
        scoreLabel.fontSize = 18*_sizeChanger;
        scoreLabel.position = CGPointMake(110*_sizeChanger, 36*_sizeChanger + ((iPhone5Changer)/8)*_sizeChanger);
        scoreLabel.zPosition = 2;
        [labelHolder addChild:scoreLabel];
        
        SKSpriteNode *scoreImageBack = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(163*_sizeChanger, 17*_sizeChanger)];
        scoreImageBack.position = CGPointMake(140*_sizeChanger + scoreImageBack.size.width/2, 42*_sizeChanger + ((iPhone5Changer)/8)*_sizeChanger);
        scoreImageBack.name = @"scoreImageBackNode";
        _scoreImageBack = scoreImageBack;
        [labelHolder addChild:_scoreImageBack];
        
        SKSpriteNode *scoreImage = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(scoreImageBack.size.width - 2*_sizeChanger, scoreImageBack.size.height - 2*_sizeChanger)];
        scoreImage.position = CGPointMake(scoreImageBack.position.x, scoreImageBack.position.y);
        scoreImage.name = @"scoreImageNode";
        _scoreImage = scoreImage;
        [labelHolder addChild:_scoreImage];
        
        
        SKSpriteNode *healthImageBack = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(163*_sizeChanger, 17*_sizeChanger)];
        healthImageBack.position = CGPointMake(140*_sizeChanger + scoreImageBack.size.width/2, 17*_sizeChanger + ((iPhone5Changer)/8)*_sizeChanger);
        healthImageBack.name = @"healthImageBackNode";
        _healthImageBack = healthImageBack;
        [labelHolder addChild:_healthImageBack];
        
        SKSpriteNode *healthImage = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(healthImageBack.size.width - 2*_sizeChanger, healthImageBack.size.height - 2*_sizeChanger)];
        healthImage.position = CGPointMake(healthImageBack.position.x, healthImageBack.position.y);
        healthImage.name = @"healthImageNode";
        _healthImage = healthImage;
        [labelHolder addChild:_healthImage];
        
        
        SKLabelNode *healthLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
        healthLabel.text = @"health:";
        healthLabel.fontSize = 18*_sizeChanger;
        healthLabel.position = CGPointMake(110*_sizeChanger - 2*_sizeChanger, 10*_sizeChanger + ((iPhone5Changer)/8)*_sizeChanger);
        [labelHolder addChild:healthLabel];
        
        [self addChild:labelHolder];
        
        [self updateScore:0.0];
        [self updateHealth:0.0];
        [self setUpAds];
        
        SKSpriteNode *instructions = [SKSpriteNode spriteNodeWithImageNamed:@"instructions.png"];
        instructions.size = self.size;
        instructions.position = CGPointMake(self.size.width/2, self.size.height/2);
        instructions.name = @"instructionsNode";
        [self addChild:instructions];
        
       // [self startGame];
        
        /*
        
        adMobinterstitial_ = [[GADInterstitial alloc] init];
        
        adMobinterstitial_.adUnitID = @"ca-app-pub-4658531991803126/8773643690";
        [adMobinterstitial_ setDelegate:self];
        */
        NSError *error;
        
        NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"theme" withExtension:@"mp3"];
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        self.backgroundMusicPlayer.numberOfLoops = -1;
        [self.backgroundMusicPlayer prepareToPlay];
        self.backgroundMusicPlayer.volume = 0.1;
        [self.backgroundMusicPlayer play];

        
    }
    return self;
}

-(void)startGame{
    
    self.backgroundMusicPlayer.volume = 0.4;

    SKSpriteNode *instructions = (SKSpriteNode *)[self childNodeWithName:@"instructionsNode"];
    
    [instructions runAction:[SKAction fadeAlphaTo:0 duration:0.25] completion:^{
        [instructions removeFromParent];
    }];
    
    [self updateTime];

    
    _gameBegan = true;
    _gameOver = false;
    [self moveCrappyBird];
    
    
    
}

-(void)setUpAds{
    
    int iPhone5 = 0;
    if (IsIphone5) {
        iPhone5 = self.size.height - 480;
    }
    
    if(IsIphone5){
    NSMutableArray *adFrames = [NSMutableArray array];
    SKTextureAtlas *adAtlas = [SKTextureAtlas atlasNamed:@"cbAdLarge"];
    int adAtlasNumImages = adAtlas.textureNames.count;
    for (int i=1; i <= adAtlasNumImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"cbAd%d", i];
        SKTexture *temp = [adAtlas textureNamed:textureName];
        temp.filteringMode = SKTextureFilteringNearest;
        [adFrames addObject:temp];
    }
    


    
    SKSpriteNode *cbAd = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(self.size.width, 44*_sizeChanger + iPhone5/2)];
    
    cbAd.position = CGPointMake(cbAd.size.width/2,  self.size.height - cbAd.size.height/2  - 16*_sizeChanger);
        cbAd.name = @"cbAdNode";

    [self addChild:cbAd];
    SKAction *runAdAction = [SKAction animateWithTextures:adFrames timePerFrame:0.1];
    [cbAd runAction:[SKAction repeatAction:runAdAction count:-1]];
    }
    else{
        
        NSMutableArray *adFrames = [NSMutableArray array];
        SKTextureAtlas *adAtlas = [SKTextureAtlas atlasNamed:@"cbAdSmall"];
        int adAtlasNumImages = adAtlas.textureNames.count;
        for (int i=1; i <= adAtlasNumImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"cbAdSmall%d", i];
            SKTexture *temp = [adAtlas textureNamed:textureName];
            temp.filteringMode = SKTextureFilteringNearest;
            [adFrames addObject:temp];
        }
        
        
        
        SKSpriteNode *cbAd = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(self.size.width, 44*_sizeChanger + iPhone5/2)];
        
        cbAd.position = CGPointMake(cbAd.size.width/2,  self.size.height - cbAd.size.height/2  - 16*_sizeChanger);
        
        cbAd.name = @"cbAdNode";
        [self addChild:cbAd];
        SKAction *runAdAction = [SKAction animateWithTextures:adFrames timePerFrame:0.1];
        [cbAd runAction:[SKAction repeatAction:runAdAction count:-1]];
        
        
    }
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
       
        
        _xTouchInput = (location.x - 160)*1 + 160;
        
        if(_playerIsHit == false)
        {
        [self movePlayer];
        [self animatePlayerTouch];
        }
        _isCharging = YES;
        _timesSinceLastCharge = 0.0;

        
        SKNode *node = [self nodeAtPoint:location];

        SKAction *wiggle1 = [SKAction rotateByAngle:-5 duration:0.05];
        SKAction *wiggle2 = [SKAction rotateByAngle:10 duration:0.05];
        SKAction *wiggle3 = [SKAction rotateByAngle:-10 duration:0.05];
        SKAction *wiggle4 = [SKAction rotateByAngle:5 duration:0.05];
        
        SKAction *wiggle = [SKAction sequence:@[wiggle1, wiggle2, wiggle3, wiggle4]];

        if([node.name isEqualToString:@"fbNode"] == true){
            [node runAction:wiggle];
        }
        else{
        }
        if([node.name isEqualToString:@"twNode"]){
            [node runAction:wiggle];
        }
        else{
        }
        if([node.name isEqualToString:@"rpNode"]){
            [node runAction:wiggle];
            
        }
        else{

        }
        if([node.name isEqualToString:@"cbAdNode"]){
            [self cbAdClicked];
        }
        else{
            
        }
        if(_gameOver == TRUE){
            
            SKNode *holder = [self childNodeWithName:@"gameOverHolderNode"];
            SKLabelNode *labelNode = (SKLabelNode *)[holder childNodeWithName:@"playAgainLabelNodeBack"];
            SKLabelNode *labelNode2 = (SKLabelNode *)[labelNode childNodeWithName:@"playAgainLabelNode"];
            if(location.x > self.size.width/2 - 100 && location.x < self.size.width/2 + 100 && location.y > self.size.height/2 + (30 - 50) && location.y < self.size.height/2 + (30 + 50)){
                [labelNode2 setFontColor:[UIColor whiteColor]];

            }
            else{
                [labelNode2 setFontColor:[UIColor redColor]];

           }
            
        }
        
        
        
        if(_gameBegan == false){
            //_gameBegan = true;
            [self startGame];
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
            _xTouchInput = (location.x - 160)*1 + 160;
        
        if(_playerIsHit == false){
            [self movePlayer];
        }
        
        
        SKNode *node = [self nodeAtPoint:location];
        
        SKAction *wiggle1 = [SKAction rotateByAngle:-5 duration:0.05];
        SKAction *wiggle2 = [SKAction rotateByAngle:10 duration:0.05];
        SKAction *wiggle3 = [SKAction rotateByAngle:-10 duration:0.05];
        SKAction *wiggle4 = [SKAction rotateByAngle:5 duration:0.05];
        
        SKAction *wiggle = [SKAction sequence:@[wiggle1, wiggle2, wiggle3, wiggle4]];
        
        if([node.name isEqualToString:@"fbNode"] == true){
            [node runAction:wiggle];
        }
        else{
        }
        if([node.name isEqualToString:@"twNode"]){
            [node runAction:wiggle];
        }
        else{
        }
        if([node.name isEqualToString:@"rpNode"]){
            [node runAction:wiggle];
        }
        else{
            
        }
        
        
        
        
        
        if(_gameOver == TRUE){
            
            SKNode *holder = [self childNodeWithName:@"gameOverHolderNode"];
            SKLabelNode *labelNode = (SKLabelNode *)[holder childNodeWithName:@"playAgainLabelNodeBack"];
            SKLabelNode *labelNode2 = (SKLabelNode *)[labelNode childNodeWithName:@"playAgainLabelNode"];
            if(location.x > self.size.width/2 - 100 && location.x < self.size.width/2 + 100 && location.y > self.size.height/2 + (30 - 50) && location.y < self.size.height/2 + (30 + 50)){
                [labelNode2 setFontColor:[UIColor whiteColor]];
                
            }
            else{
                [labelNode2 setFontColor:[UIColor redColor]];
                
            }
            
        }
        
        
        
        
        
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        
        if(_playerIsHit == false){
            [self shootFinger];
      //  [self animatePlayerUnTouch];
    //    [self crap];
        }
        _isCharging = NO;
        
        
        SKNode *node = [self nodeAtPoint:location];
        
        SKAction *wiggle1 = [SKAction rotateByAngle:-5 duration:0.05];
        SKAction *wiggle2 = [SKAction rotateByAngle:10 duration:0.05];
        SKAction *wiggle3 = [SKAction rotateByAngle:-10 duration:0.05];
        SKAction *wiggle4 = [SKAction rotateByAngle:5 duration:0.05];
        
        SKAction *wiggle = [SKAction sequence:@[wiggle1, wiggle2, wiggle3, wiggle4]];
        
        if([node.name isEqualToString:@"fbNode"] == true){
            //[node runAction:wiggle];
            [self facebook];
        }
        else{
        }
        if([node.name isEqualToString:@"twNode"]){
            //[node runAction:wiggle];
            [self twitter];
        }
        else{
        }
        if([node.name isEqualToString:@"rpNode"]){
           // [node runAction:wiggle];
            [self rowdyPandaLogoClicked];
        }
        else{
            
        }
        
        
        
        
        
        if(_gameOver == TRUE){
            
            SKNode *holder = [self childNodeWithName:@"gameOverHolderNode"];
            SKLabelNode *labelNode = (SKLabelNode *)[holder childNodeWithName:@"playAgainLabelNodeBack"];
            SKLabelNode *labelNode2 = (SKLabelNode *)[labelNode childNodeWithName:@"playAgainLabelNode"];
            if(location.x > self.size.width/2 - 100 && location.x < self.size.width/2 + 100 && location.y > self.size.height/2 + (30 - 50) && location.y < self.size.height/2 + (30 + 50)){
                [labelNode2 setFontColor:[UIColor redColor]];
                [self restartGame];
                
            }
            else{
                [labelNode2 setFontColor:[UIColor redColor]];
                
            }
            
        }
        
        
        
        
    }
}

-(void)movePlayer{
     if(_playerIsHit == false && _gameBegan == true && _gameOver == false){
    
    if(_xTouchInput < 50*_sizeChanger){
        _xTouchInput = 50*_sizeChanger;
    }
    if(_xTouchInput > 270*_sizeChanger){
        _xTouchInput = 270*_sizeChanger;
    }
    // [_player removeAllActions];
    double playerMovesHowFast = 0.25;
    
    
    SKAction * actionMove = [SKAction moveTo:CGPointMake(_xTouchInput, _playerSprite.position.y) duration:playerMovesHowFast];
    
    [_playerSprite runAction:actionMove];
       }
}

-(void)shootFinger{
    
    
    if(_gameBegan == true && _gameOver == false){

    int yPos = _playerSprite.position.y + 10*_sizeChanger;
    int distanceToGo = _buttSprite.position.y;// - yPos;
    int finalDistance = self.frame.size.height + 20*_sizeChanger;
    
    double time = sqrt(_timesSinceLastCharge);
    double duration = 1.0/time;
    
    double durationToCheck = duration*0.6;//(distanceToGo/finalDistance);
    double maxDuration = 3;
    double minDuration = 0.25;
    if(duration < minDuration) duration = minDuration;
    if(duration > maxDuration) duration = maxDuration;
    
    double yellowRange = 1.0;
    double redRange = 2.0;
    double superRange = 3.0;
    SKSpriteNode *fingerSprite;

    _timesSinceLastCharge = _timesSinceLastCharge + _level*0.2;
    if(_timesSinceLastCharge < superRange){
        
        
        
        if(_timesSinceLastCharge > redRange){
            fingerSprite = [SKSpriteNode spriteNodeWithImageNamed:@"redFinger.png"];
        }
        else if (_timesSinceLastCharge > yellowRange){
            fingerSprite = [SKSpriteNode spriteNodeWithImageNamed:@"yellowFinger.png"];
        }
        else{
            fingerSprite = [SKSpriteNode spriteNodeWithImageNamed:@"blueFinger.png"];
        }
        
        fingerSprite.size = CGSizeMake(10*_sizeChanger, 22*_sizeChanger);
        fingerSprite.position = CGPointMake(_playerSprite.position.x, _playerSprite.position.y + 10*_sizeChanger);
        [self addChild:fingerSprite];
        
        
        SKAction *moveFingerUp = [SKAction moveToY:finalDistance duration:duration];
        
        [fingerSprite runAction:moveFingerUp completion:^{
            [fingerSprite removeFromParent];
            [fingerSprite removeFromParent];
        }];
        
        
        /*
         NSString * string = [NSString stringWithFormat:@"stillButt.png"];
         SKTexture *texture = [SKTexture textureWithImageNamed:string];
         texture.filteringMode = SKTextureFilteringNearest;
         NSMutableArray *array = [NSMutableArray array];
         [array addObject:texture];
         SKAction *stillAction = [SKAction animateWithTextures:array timePerFrame:0.05  resize:NO restore:NO];
         [_buttSprite runAction:stillAction];
         
         */
        double duration2 = 0.05;
        
        
        //   [_playerSprite runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:playerTouchedFrames timePerFrame:duration]]];
        [_playerSprite setSize:_untouchSize];
        [_playerSprite setPosition:CGPointMake(_playerSprite.position.x, _untouchYPos)];
        //[_playerSprite removeActionForKey:@"playerUntouchKey"];
        [_playerSprite removeAllActions];
        SKAction * action = [SKAction animateWithTextures:playerShootFrames timePerFrame:duration2];
        
        
        [_playerSprite runAction:action completion:^{
            
            [self animatePlayerUnTouch];
        }];
        
    }
    else{
        
        double duration2 = 0.05;
        double durationMove = 0.1;
        [_playerSprite setPosition:CGPointMake(_playerSprite.position.x, _untouchYPos)];
        durationToCheck = durationMove;
        //[_playerSprite removeActionForKey:@"playerUntouchKey"];
        [_playerSprite removeAllActions];
     //   SKAction * action = [SKAction animateWithTextures:playerShootFrames timePerFrame:duration2];
        SKAction *movePlayerUp = [SKAction moveByX:0 y:320*_sizeChanger duration:durationMove];
        SKAction *movePlayerDown =[SKAction moveByX:0 y:-320*_sizeChanger duration:durationMove];
        
        /*
        [_playerSprite runAction:action completion:^{
            
            [self animatePlayerUnTouch];
        }];
         */
        
        [_playerSprite runAction:movePlayerUp completion:^{
           
            SKSpriteNode *testNode = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(1, 1)];
            testNode.position = _playerSprite.position;
            
            [self checkButtHitforSprite:testNode andCharge:_timesSinceLastCharge];
            [_playerSprite runAction:movePlayerDown completion:^{
                
                [_playerSprite setSize:_untouchSize];
                [self animatePlayerUnTouch];
            }];
        }];
        
    }
    
    
    
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (durationToCheck) * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        
        [self checkButtHitforSprite:fingerSprite andCharge:_timesSinceLastCharge];
    });
    
    }
    
    
    
}
-(void)checkButtHitforSprite:(SKSpriteNode *) node andCharge:(double)charge{
   
    int xPos = node.position.x;
    int missRange = 50*_sizeChanger;
    int hitRange = 20*_sizeChanger;
    int perfectRange = 4*_sizeChanger;
    
    int buttPos = _buttSprite.position.x;
    int checkRange = abs(buttPos - xPos);
    
    
    double duration = 1.0;
    SKAction *bounceFingerLeft = [SKAction moveByX:-100*_sizeChanger y:-500*_sizeChanger duration:duration];
    SKAction *bounceFingerRight = [SKAction moveByX:100*_sizeChanger y:-500*_sizeChanger duration:duration];
    SKAction *spinFingerLeft = [SKAction rotateByAngle:-1080 duration:duration];
    SKAction *spinFingerRight = [SKAction rotateByAngle:1080 duration:duration];

    if(checkRange > missRange){//do nothing
        
        NSLog(@"Hit was not made");
    }
    else if(checkRange > hitRange){//no hit, bounce off sprite
        NSLog(@"Hit was not made - bounced off");
        if(buttPos - xPos > 0)
        {
            [node removeAllActions];
            [node runAction:bounceFingerLeft];
            [node runAction:spinFingerLeft];
        }
        else{
            [node removeAllActions];
            [node runAction:bounceFingerRight];
            [node runAction:spinFingerRight];
        }
        [self runAction:[SKAction playSoundFileNamed:@"fingerMiss.wav" waitForCompletion:NO]];

    }
    else if(checkRange > perfectRange){//hit not perfect
        NSLog(@"Hit was made");
        [node removeFromParent];
        [self runAction:[SKAction playSoundFileNamed:@"fingerHit.wav" waitForCompletion:NO]];

        if(_buttIsHit == false)[self animateButtHitwithValue:charge];

    }
    else{//perfect hit
        NSLog(@"Hit was made - perfect");
        [node removeFromParent];
        [self runAction:[SKAction playSoundFileNamed:@"fingerHit.wav" waitForCompletion:NO]];
        if(_buttIsHit == false)[self animateButtHitPerfectwithValue:charge];

    }
    
}



-(void)moveCrappyBird{
    

    if(_gameOver == false && _gameBegan == true){
        
    
        int birdMovesToX = ((arc4random()%16)*10 + 65)*_sizeChanger;
    
    //birdMovesToX = 65 to 255 ; range = 150
    
        int speed = 40;
        double duration = 1.0;
    double waitToRepeat = 2.2;
 
        SKAction * actionMove = [SKAction moveToX:birdMovesToX duration:duration];

    _buttSprite.size = CGSizeMake(112*_sizeChanger, 50*_sizeChanger);
        [_buttSprite runAction:actionMove completion:^{
            
 

            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (waitToRepeat) * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                
                if(_gameOver == false && _gameBegan == true){
                [self moveCrappyBird];
                }
            });
            
        }];
    
    
    
    int count = round(abs(birdMovesToX - _buttSprite.position.x)/20) + 1;
    double duration2 = duration/(moveButtLeftAnimatedAtlas.textureNames.count*count);
    SKAction *action;
    
    
    if(birdMovesToX - _buttSprite.position.x > 0)
    {
               action = [SKAction animateWithTextures:moveButtRightFrames timePerFrame:duration2];
    }
    else{
               action = [SKAction animateWithTextures:moveButtLeftFrames timePerFrame:duration2];
    }
    
   // [_buttSprite runAction:action];
    
    [_buttSprite runAction:[SKAction repeatAction:action count:count] completion:^{
        
            NSString * string = [NSString stringWithFormat:@"stillButt.png"];
        SKTexture *texture = [SKTexture textureWithImageNamed:string];
        texture.filteringMode = SKTextureFilteringNearest;
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:texture];
        SKAction *stillAction = [SKAction animateWithTextures:array timePerFrame:0.05];
        [_buttSprite runAction:stillAction];
        
    }];
    }
    
}

-(void)animatePlayerUnTouch{
    
    double duration = 0.3;
    
    [_playerSprite setSize:_untouchSize];
    [_playerSprite setPosition:CGPointMake(_playerSprite.position.x, _untouchYPos)];

  //  [_playerSprite removeActionForKey:@"playerTouchRepeatKey"];
    [_playerSprite removeAllActions];

    
    [_playerSprite runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:playerUntouchedFrames timePerFrame:duration]] withKey:@"playerUntouchKey"];
    
}

-(void)animatePlayerTouch{
    
  
    if(_gameOver == false && _gameBegan == true){
    //  playerUntouchedFrames = playerUntouchedFrames;
    double duration = 0.05;
    
 //   [_playerSprite runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:playerTouchedFrames timePerFrame:duration]]];
    [_playerSprite setSize:_touchSize];
    [_playerSprite setPosition:CGPointMake(_playerSprite.position.x, _touchYPos)];
    //[_playerSprite removeActionForKey:@"playerUntouchKey"];
    [_playerSprite removeAllActions];
    SKAction * action = [SKAction animateWithTextures:playerTouchedFrames timePerFrame:duration];
    
    
    [_playerSprite runAction:action completion:^{
        
        [self animatePlayerTouchRepeat];
    }];
    
    //[_playerSprite runAction:<#(SKAction *)#>]

    }
}

-(void)animatePlayerTouchRepeat{
    
    double duration = 0.05;
    [_playerSprite setSize:_touchSize];
    [_playerSprite removeAllActions];

        [_playerSprite runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:playerTouchedRepeatFrames timePerFrame:duration]] withKey:@"playerTouchRepeatKey"];
}

-(void)animatePlayerHit{
    
    _playerIsHit = true;
    [self runAction:[SKAction playSoundFileNamed:@"playerHit.wav" waitForCompletion:NO]];

    
    double duration = 0.05;
    [_playerSprite setSize:_untouchSize];
    [_playerSprite setPosition:CGPointMake(_playerSprite.position.x, _untouchYPos)];
    [_playerSprite removeAllActions];
    
    SKAction *action = [SKAction animateWithTextures:playerHitFrames timePerFrame:duration];
    
    [_playerSprite runAction:[SKAction repeatAction:action count:10] completion:^{
        
        [self animatePlayerUnTouch];
        _playerIsHit = false;

    }];


}

-(void)animateButtHitwithValue:(double)num{
    
    [self updateScore:num*1];
    _buttIsHit = true;
    CGSize changeSize = CGSizeMake(round(_buttSprite.size.width*65/71), _buttSprite.size.height);
    double duration = 0.05;
   // [_buttSprite setPosition:CGPointMake(_buttSprite.position.x, _untouchYPos)];
    [_buttSprite removeAllActions];
    
    NSMutableArray *buttHitFrames = [NSMutableArray array];
    SKTextureAtlas *buttHitAtlas = [SKTextureAtlas atlasNamed:@"buttHit"];
    int buttHitNumImages = buttHitAtlas.textureNames.count - 1;
    for (int i=0; i <= buttHitNumImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        SKTexture *temp = [buttHitAtlas textureNamed:textureName];
        temp.filteringMode = SKTextureFilteringNearest;
        [buttHitFrames addObject:temp];
    }
    
    SKAction *action = [SKAction animateWithTextures:buttHitFrames timePerFrame:duration];
    
    [_buttSprite setSize:changeSize];
    [_buttSprite runAction:[SKAction repeatAction:action count:1] completion:^{
        
      //  [self animatePlayerUnTouch];
       // _playerIsHit = false;
        _buttIsHit = false;
        [self moveCrappyBird];
        
    }];
    
}


-(void)animateButtHitPerfectwithValue:(double)num{
    
    
    [self updateScore:num*3];
    _buttIsHit = true;
    CGSize changeSize = CGSizeMake(round(_buttSprite.size.width*86/71), round(_buttSprite.size.height*23/31));
    double duration = 0.05;
    // [_buttSprite setPosition:CGPointMake(_buttSprite.position.x, _untouchYPos)];
    [_buttSprite removeAllActions];
    
    NSMutableArray *buttHitPerfectFrames = [NSMutableArray array];
    SKTextureAtlas *buttHitPerfectAtlas = [SKTextureAtlas atlasNamed:@"buttHitPerfect"];
    int buttHitPerfectNumImages = buttHitPerfectAtlas.textureNames.count - 1;
    for (int i=0; i <= buttHitPerfectNumImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        SKTexture *temp = [buttHitPerfectAtlas textureNamed:textureName];
        temp.filteringMode = SKTextureFilteringNearest;
        [buttHitPerfectFrames addObject:temp];
    }
    
    SKAction *action = [SKAction animateWithTextures:buttHitPerfectFrames timePerFrame:duration];
    
    [_buttSprite setSize:changeSize];
    [_buttSprite runAction:[SKAction repeatAction:action count:1] completion:^{
        
        //  [self animatePlayerUnTouch];
        // _playerIsHit = false;
        _buttIsHit = false;
        [self moveCrappyBird];
        
    }];
    
}



-(void)crap{
    
    if(_buttIsHit == false && _gameOver == false && _gameBegan == true){
       // [self revmob];
        [self runAction:[SKAction playSoundFileNamed:@"addCrap.wav" waitForCompletion:NO]];

        
        
    double duration = 0.05;
        /*
    SKSpriteNode *crapSprite = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(100*_sizeChanger, 400*_sizeChanger)];
    
    crapSprite.zPosition = _buttSprite.zPosition - 1;
    crapSprite.position = CGPointMake(_buttSprite.position.x, _buttSprite.position.y - 180*_sizeChanger);
    [self addChild:crapSprite];
    
    SKAction *animateCrap = [SKAction animateWithTextures:crapFrames timePerFrame:duration];

    [crapSprite runAction:animateCrap completion:^{
        
        [self checkCrapHit:crapSprite.position.x forSprite:crapSprite];
    }];
         */
        
        SKEmitterNode *poopEmitter = [self addPoopEmitter];
        

        poopEmitter.zPosition  = _buttSprite.zPosition - 1;
        poopEmitter.position = CGPointMake(_buttSprite.position.x, _buttSprite.position.y - 0*_sizeChanger);
        
        [self addChild:poopEmitter];
        SKAction *moveCrap = [SKAction moveToY:150*_sizeChanger duration:1.2];
        


        [poopEmitter runAction:moveCrap completion:^{
            [self checkCrapHit:poopEmitter.position.x forSprite:poopEmitter];

        }];
        
        
    NSMutableArray *buttCrapFrames = [NSMutableArray array];
    SKTextureAtlas *buttCrapAtlas = [SKTextureAtlas atlasNamed:@"buttPooping"];
    int buttCrapNumImages = buttCrapAtlas.textureNames.count - 1;
    for (int i=0; i <= buttCrapNumImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        SKTexture *temp = [buttCrapAtlas textureNamed:textureName];
        temp.filteringMode = SKTextureFilteringNearest;
        [buttCrapFrames addObject:temp];
                }
    
    
        
        
    [_buttSprite removeAllActions];
    SKAction *animateBut = [SKAction animateWithTextures:buttCrapFrames timePerFrame:duration];
    
    [_buttSprite runAction:animateBut completion:^{
        
        [self moveCrappyBird];

    }];
    }
    
}

-(void)checkCrapHit:(int) location forSprite:(SKEmitterNode*)node{
    
    double duration = 0.5;
    
    int range = abs(_playerSprite.position.x - node.position.x);
    
    if(range < 50*_sizeChanger)
    {
    //    double duration2 = 0.05;
        /*
        SKAction *animateCrap = [SKAction animateWithTextures:crapHitFrames timePerFrame:duration2];
        [node setPosition:CGPointMake(_playerSprite.position.x, node.position.y - 90*_sizeChanger)];
        node.zPosition = _playerSprite.zPosition + 1;
        [node runAction:animateCrap];
         */
        node.particleSpeedRange = 1000;
        

        node.yAcceleration = -500;
        node.particleLifetime = 10.00;
        node.particleAlphaSpeed = 1;
        node.emissionAngleRange = 360;

        
        SKAction *fadeCrap = [SKAction fadeAlphaTo:0.0 duration:1.0];
        [node runAction:fadeCrap completion:^{
                          [node removeFromParent];
        }];

        [self animatePlayerHit];
        [self updateHealth:(100 + 10*arc4random()%5)];
    }
    else{
        
        SKAction *moveDown = [SKAction moveByX:0 y:-200*_sizeChanger duration:duration];
        
        [node runAction:moveDown completion:^{
            
            [node removeFromParent];
        }];
        
    }

    
    
    
    
    
}











-(void)addUpgrader{
    
    if(_gameOver == false && _gameBegan == true){
    NSLog(@"Added Upgrader");
        [self runAction:[SKAction playSoundFileNamed:@"addUpgrader.wav" waitForCompletion:NO]];

    
    SKSpriteNode *upgraderSprite = [SKSpriteNode node];
    double frameDuration = 0.08;
    double moveDuration = 2.0;
    double checkDuration = moveDuration*0.65;

    int xPos = (arc4random()%280 + 20)*_sizeChanger;
    
    NSMutableArray *upgradeFrames = [NSMutableArray array];
    SKTextureAtlas *upgradeAtlas = [SKTextureAtlas atlasNamed:@"upgradeSprite"];
    int upgradeNumImages = upgradeAtlas.textureNames.count - 1;
    for (int i=0; i <= upgradeNumImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        SKTexture *temp = [upgradeAtlas textureNamed:textureName];
        temp.filteringMode = SKTextureFilteringNearest;
        [upgradeFrames addObject:temp];
    }
    
    upgraderSprite.size = CGSizeMake(round(53*0.75)*_sizeChanger, round(70*0.75)*_sizeChanger);
    upgraderSprite.position = CGPointMake(xPos, self.size.height + 50*_sizeChanger);
    
    [self addChild:upgraderSprite];
    SKAction *animateAction = [SKAction animateWithTextures:upgradeFrames timePerFrame:frameDuration];
    SKAction *moveAction = [SKAction moveToY:-100*_sizeChanger duration:moveDuration];
    
    [upgraderSprite runAction:[SKAction repeatAction:animateAction count:-1]];
    [upgraderSprite runAction:moveAction completion:^{
        
        [upgraderSprite removeFromParent];
    }];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (checkDuration) * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        
        [self checkUpgrader:upgraderSprite];
    });
    }
    
}

-(void)checkUpgrader:(SKSpriteNode *)node{
    
    int xPos = node.position.x;
    int hitRange = 50*_sizeChanger;
    
    int playerPos = _playerSprite.position.x;
    int checkRange = abs(playerPos - xPos);
    
    
    double duration = 1.0;
 
    if(checkRange < hitRange){//do nothing
        
        [node removeFromParent];
        _level = _level + 1;
        
    }
  
    
    
}




-(void)updateScore:(double)num{
    
    _score = _score + num*50;
    
    
    
    double test = (_score*1.0)/(_maxScore*1.0);
    if(test >= 1.0) test = 1.0;
    
    _scoreImageBack.size = CGSizeMake(163*(test)*_sizeChanger, _scoreImageBack.size.height);
    _scoreImageBack.position = CGPointMake(140*_sizeChanger + _scoreImageBack.size.width/2, _scoreImageBack.position.y);
    
    _scoreImage.size = CGSizeMake(_scoreImageBack.size.width-2*_sizeChanger, _scoreImageBack.size.height-2*_sizeChanger);
    _scoreImage.position = CGPointMake(_scoreImageBack.position.x, _scoreImageBack.position.y);
    
    
    if(_score >= _maxScore){
        
        [self winGame];
    }
    
    
}

-(void)updateHealth:(int)num{
    
    _health = _health - num;
  
    
    double test = (_health*1.0)/(_maxHealth*1.0);
    
    if(test >= 1.0) test = 1.0;
    if(test <= 0) test = 0;
    _healthImageBack.size = CGSizeMake(round(163*(test)*_sizeChanger), _healthImageBack.size.height);
    _healthImageBack.position = CGPointMake(140*_sizeChanger + _healthImageBack.size.width/2, _healthImageBack.position.y);
    
    _healthImage.size = CGSizeMake(_healthImageBack.size.width-2*_sizeChanger, _healthImageBack.size.height-2*_sizeChanger);
    _healthImage.position = CGPointMake(_healthImageBack.position.x, _healthImageBack.position.y);
    
    
    if(_health <= 0){
        
        [self loseGameforText:@"you died"];
    }
}

-(void)updateTime{
    
    if(_gameOver == false){
    SKNode *holder = [self childNodeWithName:@"labelHolderNode"];
    
   // SKLabelNode *timeLabel = (SKLabelNode *)[holder childNodeWithName:@"timeLabelNode"];
    
    int time = [_timeLabel.text intValue];
    
    time = time - 1;
   // [timeLabel removeFromParent];
    NSString *string = [NSString stringWithFormat:@"%d", time];
    _timeLabel.text = string;
    
    if(time > 0)
    {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (0.90) * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self updateTime];
    });
    }
    else{
        [self loseGameforText:@"time out"];
    }
    }
    
    
}



-(void)winGame{
    
    
    if(_gameOver == false){
        _gameOver = true;
    SKNode *holder = [SKNode node];
    holder.name = @"gameOverHolderNode";

    double duration = 0.5;
    SKAction *scaleUp = [SKAction scaleBy:2.8 duration:duration];
    
    SKSpriteNode *underlay = (SKSpriteNode *)[self childNodeWithName:@"underlayNode"];
    SKAction *fadeToWhite = [SKAction colorizeWithColor:[UIColor blueColor] colorBlendFactor:0.5 duration:duration];
    [underlay runAction:fadeToWhite];
    
    SKLabelNode *deathLabelBack = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    deathLabelBack.text = @"you win!";
    deathLabelBack.fontColor = [UIColor blackColor];
    deathLabelBack.fontSize = 18*_sizeChanger;
    deathLabelBack.position = CGPointMake(underlay.position.x, underlay.position.y + 100*_sizeChanger);
    
    SKLabelNode *deathLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    deathLabel.text = @"you win!";
    deathLabel.fontColor = [UIColor redColor];
    deathLabel.fontSize = 18*_sizeChanger;
    deathLabel.position = CGPointMake(0, 1*_sizeChanger);
    deathLabel.name = @"deathLabelNode";
    [deathLabelBack addChild:deathLabel];
    
    [holder addChild:deathLabelBack];
    [deathLabelBack runAction:scaleUp];
    
    
    
    
    SKLabelNode *playAgainLabelBack = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    playAgainLabelBack.text = @"PLAY AGAIN";
    playAgainLabelBack.fontColor = [UIColor blackColor];
    playAgainLabelBack.fontSize = 12*_sizeChanger;
        playAgainLabelBack.name = @"playAgainLabelNodeBack";
    playAgainLabelBack.position = CGPointMake(underlay.position.x, underlay.position.y + 30*_sizeChanger);
    
    SKLabelNode *playAgainLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    playAgainLabel.text = @"PLAY AGAIN";
    playAgainLabel.fontColor = [UIColor redColor];
    playAgainLabel.fontSize = 12*_sizeChanger;
    playAgainLabel.name = @"playAgainLabelNode";
    playAgainLabel.position = CGPointMake(0, 1*_sizeChanger);
    [playAgainLabelBack addChild:playAgainLabel];
    
    [holder addChild:playAgainLabelBack];
    
    [playAgainLabelBack runAction:scaleUp];
    
    
    
    
    SKSpriteNode *fb = [SKSpriteNode spriteNodeWithImageNamed:@"facebook_128"];
    fb.size = CGSizeMake(50*_sizeChanger, 50*_sizeChanger);
    fb.name = @"fbNode";
    fb.position = CGPointMake((underlay.size.width - 10*_sizeChanger)/3 - fb.size.width/2 + 5*_sizeChanger, underlay.position.y - 25*_sizeChanger);
    [holder addChild:fb];
    
    
    SKSpriteNode *tw = [SKSpriteNode spriteNodeWithImageNamed:@"twitter_128"];
    tw.size = CGSizeMake(50*_sizeChanger, 50*_sizeChanger);
    tw.name = @"twNode";
    tw.position = CGPointMake((underlay.size.width - 10*_sizeChanger)*2/3 - fb.size.width/2 + 5*_sizeChanger, underlay.position.y - 25*_sizeChanger);
    [holder addChild:tw];
    
    
    SKSpriteNode *rp = [SKSpriteNode spriteNodeWithImageNamed:@"squarePandaButton_small"];
    rp.size = CGSizeMake(50*_sizeChanger, 50*_sizeChanger);
    rp.name = @"rpNode";
    rp.position = CGPointMake((underlay.size.width - 10*_sizeChanger)*3/3 - fb.size.width/2 + 5*_sizeChanger, underlay.position.y - 25*_sizeChanger);
    [holder addChild:rp];
    //[underlay removeFromParent];
    
    
    
    [self addChild:holder];
    
    [self animatePlayerUnTouch];
    }
}

-(void)loseGameforText:(NSString *)string{
    
    if(_gameOver == false){
    _gameOver = true;
    SKNode *holder = [SKNode node];
    holder.name = @"gameOverHolderNode";
    
    double duration = 0.5;
    SKAction *scaleUp = [SKAction scaleBy:2.8 duration:duration];
    
    SKSpriteNode *underlay = (SKSpriteNode *)[self childNodeWithName:@"underlayNode"];
    SKAction *fadeToBlack = [SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:0.5 duration:duration];
    [underlay runAction:fadeToBlack];
    
    
    SKLabelNode *deathLabelBack = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    deathLabelBack.text = string;
    deathLabelBack.fontColor = [UIColor blackColor];
    deathLabelBack.fontSize = 18*_sizeChanger;
    deathLabelBack.position = CGPointMake(underlay.position.x, underlay.position.y + 100*_sizeChanger);
    
    SKLabelNode *deathLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    deathLabel.text = string;
    deathLabel.fontColor = [UIColor redColor];
    deathLabel.fontSize = 18*_sizeChanger;
    deathLabel.position = CGPointMake(0, 1*_sizeChanger);
    deathLabel.name = @"deathLabelNode";
    [deathLabelBack addChild:deathLabel];
    
    [holder addChild:deathLabelBack];
    [deathLabelBack runAction:scaleUp];

    
    
        
        SKLabelNode *playAgainLabelBack = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
        playAgainLabelBack.text = @"PLAY AGAIN";
        playAgainLabelBack.fontColor = [UIColor blackColor];
        playAgainLabelBack.fontSize = 12*_sizeChanger;
        playAgainLabelBack.name = @"playAgainLabelNodeBack";
        playAgainLabelBack.position = CGPointMake(underlay.position.x, underlay.position.y + 30*_sizeChanger);
        
        SKLabelNode *playAgainLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
        playAgainLabel.text = @"PLAY AGAIN";
        playAgainLabel.fontColor = [UIColor redColor];
        playAgainLabel.fontSize = 12*_sizeChanger;
        playAgainLabel.name = @"playAgainLabelNode";
        playAgainLabel.position = CGPointMake(0, 1*_sizeChanger);
        [playAgainLabelBack addChild:playAgainLabel];
        
        [holder addChild:playAgainLabelBack];
        
        [playAgainLabelBack runAction:scaleUp];
        
        
        
        
        SKSpriteNode *fb = [SKSpriteNode spriteNodeWithImageNamed:@"facebook_128"];
        fb.size = CGSizeMake(50*_sizeChanger, 50*_sizeChanger);
        fb.name = @"fbNode";
        fb.position = CGPointMake((underlay.size.width - 10*_sizeChanger)/3 - fb.size.width/2 + 5*_sizeChanger, underlay.position.y - 25*_sizeChanger);
        [holder addChild:fb];
        
        
        SKSpriteNode *tw = [SKSpriteNode spriteNodeWithImageNamed:@"twitter_128"];
        tw.size = CGSizeMake(50*_sizeChanger, 50*_sizeChanger);
        tw.name = @"twNode";
        tw.position = CGPointMake((underlay.size.width - 10*_sizeChanger)*2/3 - fb.size.width/2 + 5*_sizeChanger, underlay.position.y - 25*_sizeChanger);
        [holder addChild:tw];
        
        
        SKSpriteNode *rp = [SKSpriteNode spriteNodeWithImageNamed:@"squarePandaButton_small"];
        rp.size = CGSizeMake(50*_sizeChanger, 50*_sizeChanger);
        rp.name = @"rpNode";
        rp.position = CGPointMake((underlay.size.width - 10*_sizeChanger)*3/3 - fb.size.width/2 + 5*_sizeChanger, underlay.position.y - 25*_sizeChanger);
        [holder addChild:rp];
    
    
    [self addChild:holder];
    
   // [self restartGame];
   // [holder runAction:scaleUp];
    [self animatePlayerUnTouch];
    

    }
}
-(void)restartGame{
    
    [_backgroundMusicPlayer stop];
    _backgroundMusicPlayer = nil;
    
    /*
    double duration = 0.1;
    SKNode *holder = [self childNodeWithName:@"gameOverHolderNode"];
    
    [holder removeFromParent];
    
    
    
    SKSpriteNode *underlay = (SKSpriteNode *)[self childNodeWithName:@"underlayNode"];
    [underlay removeFromParent];
    
    SKSpriteNode *underLay;
    // underLay = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(280, 440)];
    underLay = [SKSpriteNode spriteNodeWithImageNamed:@"crappyBackground.png"];
    underLay.name = @"underlayNode";
    underLay.size = CGSizeMake(280, 360);
    underLay.position = CGPointMake((self.size.width)/2, (self.size.height)/2);
    underLay.zPosition = -100;
    [self addChild:underLay];
    _gameOver = false;
    _gameBegan = true;
   // [underlay runAction:fadeToClear];
     */
    
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene transition:[SKTransition doorsOpenVerticalWithDuration:0.1]];
    
    [self revmob];
}


-(void)rowdyPandaLogoClicked{
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://bit.ly/1pfIrb4"]];
    
}
-(void)cbAdClicked{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bit.ly/1pfIrb4"]];
}




-(void)revmob{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        //    [_gameOverOverlay removeFromParent];
        //    [self setupGame];
        
    } else {
        NSLog(@"There IS internet connection");
        
        
        RevMobFullscreen *ad = [[RevMobAds session] fullscreen]; // you must retain this object
        [ad loadWithSuccessHandler:^(RevMobFullscreen *fs) {
            [fs showAd];
            NSLog(@"Ad loaded");
            //   [self doVolumeFadeOut:_themePlayer];
            
        } andLoadFailHandler:^(RevMobFullscreen *fs, NSError *error) {
            NSLog(@"Ad error: %@",error);
            //[adMobinterstitial_ loadRequest:request];
            
        } onClickHandler:^{
            NSLog(@"Ad clicked");
        } onCloseHandler:^{
            NSLog(@"Ad closed");
            //   [_gameOverOverlay removeFromParent];
            //   [self setupGame];
        }];
        
        
        //    [[RevMobAds session] showFullscreen];
        
        
    }
    
}


//Google admob


- (void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    
    
    
    [adMobinterstitial_ presentFromRootViewController:self.view.window.rootViewController];
    
    
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    
    //  [_gameOverOverlay removeFromParent];
    //  [self setupGame];
    
    
    
}


-(void)interstitialWillPresentScreen:(GADInterstitial *)ad{
    
    
}
-(void)interstitialWillDismissScreen:(GADInterstitial *)ad{
    
}

-(void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error{
    
    //  [self interstitialDidDismissScreen:ad];
}







-(void)facebook{
    
    
    
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.picture = [NSURL URLWithString:@"http://imgur.com/kJULreB.png"];
    params.link = [NSURL URLWithString:@"https://itunes.apple.com/us/app/chimgam/id887049468?ls=1&mt=8"];
    params.caption = @"Rowdy Panda Presents";
    NSString *descriptString = @"Chimgam - The weirdest game you've ever played";//[NSString stringWithFormat:@"I scored %d in 2040Ye. Think you can beat it?", [_scoreView.score.text intValue]];
    params.linkDescription = descriptString;
    params.name = @"Chimgam";
    
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
        
    } else {
        
        // Present the feed dialog
        
        // Put together the dialog parameters
        NSString *descriptString = @"Chimgam - The weirdest game you've ever played";//[NSString stringWithFormat:@"I scored %d in 2040Ye. Think you can beat it?", [_scoreView.score.text intValue]];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Chimgam", @"name",
                                       @"Rowdy Panda Presents", @"caption",
                                       descriptString, @"description",
                                       @"https://itunes.apple.com/us/app/chimgam/id887049468?ls=1&mt=8", @"link",
                                       @"http://imgur.com/kJULreB.png", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
        
        
    }
    
    

    
}




// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}





-(void)twitter{
    
    
    //  Create an instance of the Tweet Sheet
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:
                                           SLServiceTypeTwitter];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any required UI
    // updates occur on the main queue
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
        }
    };
    
    //  Set the initial body of the Tweet
    int score = 50;//[_scoreView.score.text intValue];
    NSString *initialTextString = [NSString stringWithFormat:@"Wow. This game...wow. \n@TheRowdyPanda"];
    [tweetSheet setInitialText:initialTextString];
    
    //  Add an URL to the Tweet.  You can add multiple URLs.
    if (![tweetSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/chimgam/id887049468?ls=1&mt=8"]]){
        NSLog(@"Unable to add the URL!");
    }
    
    //  Adds an image to the Tweet.  For demo purposes, assume we have an
    //  image named 'larry.png' that we wish to attach
    if (![tweetSheet addImage:[UIImage imageNamed:@"icon_120.png"]]) {
        NSLog(@"Unable to add the image!");
    }
    
    
    UIViewController *vc = self.view.window.rootViewController;

    //  Presents the Tweet Sheet to the user
    [vc presentViewController:tweetSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
    
}













- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    
    
    
    
    
    if(_isCharging == YES)
    {
        _timesSinceLastCharge += timeSinceLast;
        NSLog(@"Time charging = %f", _timesSinceLastCharge);
        
    }
    
    _timesSinceLastUpgrader += timeSinceLast;
    _timeSinceLastCrap += timeSinceLast;
    
    if(_timesSinceLastUpgrader > 10 + arc4random()%4 - 2){
        
        _timesSinceLastUpgrader = 0;
        [self addUpgrader];
    }
    
    double checkDouble = (12 + arc4random()%4 - 2 - floor(_score*10/_maxScore))/5.0;
    
    if(checkDouble <= 0.12){
        
    checkDouble = 0.15;
}
    if(_timeSinceLastCrap > (checkDouble)){
        
        _timeSinceLastCrap = 0;
        [self crap];
    }
    
    
}
- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}




-(SKEmitterNode *)addPoopEmitter{
    
    
    _endGameEmitter = [[SKEmitterNode alloc] init];
    
	_endGameEmitter.name = @"coin_cell";
    _endGameEmitter.particleTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"flower.png"]];
    _endGameEmitter.particleScale = 0.2*_sizeChanger;

	_endGameEmitter.particleColorRedRange = 0.00;
	_endGameEmitter.particleColorGreenRange = 0.00;
	_endGameEmitter.particleColorBlueRange = 0.00;
	_endGameEmitter.particleColorAlphaRange = 0.00;
    
	_endGameEmitter.particleColorRedSpeed = 0.00;
	_endGameEmitter.particleColorBlueSpeed = 0.00;
	_endGameEmitter.particleColorGreenSpeed = 0.00;
	_endGameEmitter.particleColorAlphaSpeed = 0.00;
    
	_endGameEmitter.particleLifetime = 0.20;
	_endGameEmitter.particleLifetimeRange = 0.00;
	_endGameEmitter.particleBirthRate = 50;
	_endGameEmitter.particleSpeed = 0.00;
	_endGameEmitter.particleSpeedRange = 100.00;
	_endGameEmitter.xAcceleration = 0.00;
	_endGameEmitter.yAcceleration = 0.00;
	//emitterSprite.zAcceleration = 0.00;
    
	// these values are in radians, in the UI they are in degrees
	_endGameEmitter.particleRotation = 0.00;
	_endGameEmitter.particleRotationRange = 0.000;
	//emitterSprite.emissionLatitude = 0.000;
	//emitterSprite.emissionLongitude = 0.000;
	_endGameEmitter.emissionAngle = 0.000;
    _endGameEmitter.emissionAngleRange = 360.0;
    
   /*
    
    double duration = 1.5;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (duration) * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissNode:_endGameEmitter];
        
    });
    
    _endGameEmitter.zPosition = 200;
    */
    return _endGameEmitter;
    
    
}



@end

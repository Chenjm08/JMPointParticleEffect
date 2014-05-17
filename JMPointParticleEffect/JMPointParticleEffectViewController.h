//
//  JMPointParticleEffectViewController.h
//  JMPointParticleEffect
//
//  Created by jieminChen on 14-5-17.
//
//

#import <GLKit/GLKit.h>
#import "AGLKContext.h"
#import "AGLKPointParticleEffect.h"

typedef void (^EmitterBlock)();

@interface JMPointParticleEffectViewController : GLKViewController

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKPointParticleEffect *particleEffect;
@property (nonatomic, assign) NSTimeInterval autoSpawnDelta;
@property (nonatomic, assign) NSTimeInterval lastSpawnTime;
@property (nonatomic, assign) NSInteger currentEmitterIndex;
@property (nonatomic, strong) NSArray *emitterBlocks;
@property (nonatomic, strong) GLKTextureInfo *ballParticleTexture;//球形纹理
@property (nonatomic, strong) GLKTextureInfo *burstParticleTexture;//爆炸纹理
@property (nonatomic, strong) GLKTextureInfo *smokeParticleTexture;//烟雾纹理

@end

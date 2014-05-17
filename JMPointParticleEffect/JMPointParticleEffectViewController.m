//
//  JMPointParticleEffectViewController.m
//  JMPointParticleEffect
//
//  Created by jieminChen on 14-5-17.
//
//

#import "JMPointParticleEffectViewController.h"

@implementation JMPointParticleEffectViewController
@synthesize baseEffect = _baseEffect;
@synthesize particleEffect = _particleEffect;
@synthesize autoSpawnDelta = _autoSpawnDelta;
@synthesize lastSpawnTime = _lastSpawnTime;
@synthesize currentEmitterIndex = _currentEmitterIndex;
@synthesize emitterBlocks = _emitterBlocks;
@synthesize ballParticleTexture = _ballParticleTexture;//球形纹理
@synthesize burstParticleTexture = _burstParticleTexture;//爆炸纹理
@synthesize smokeParticleTexture = _smokeParticleTexture;//烟雾纹理

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"not a GLView");

    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;//高深度缓存
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    
    //基本特效
    self.baseEffect = ({
        GLKBaseEffect *baseEffect = [[GLKBaseEffect alloc] init];
        baseEffect.light0.enabled = GL_TRUE;
        baseEffect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);//漫反射颜色
        baseEffect.light0.ambientColor = GLKVector4Make(0.9f, 0.9f, 0.9f, 1.0f);//环境颜色
        baseEffect;
    });
    
    //球形纹理
    self.ballParticleTexture = ({
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"ball" ofType:@"png"];
        NSAssert(path != nil, @"ball Texture image not found");
        
        NSError *error = nil;
        GLKTextureInfo *texture = [GLKTextureLoader textureWithContentsOfFile:path options:nil error:&error];
        texture;
    });
    
    // 爆炸纹理
    self.burstParticleTexture = ({
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"burst" ofType:@"png"];
        NSAssert(path != nil, @"burst Texture image not found");
        
        NSError *error = nil;
        GLKTextureInfo *texture = [GLKTextureLoader textureWithContentsOfFile:path options:nil error:&error];
        texture;
    });
    
    //烟雾纹理
    self.smokeParticleTexture = ({
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"smoke" ofType:@"png"];
        NSAssert(path != nil, @"smoke Texture image not found");
        
        NSError *error = nil;
        GLKTextureInfo *texture = [GLKTextureLoader textureWithContentsOfFile:path options:nil error:&error];
        texture;
    });
    
    //粒子特效 (默认是球形纹理)
    self.particleEffect = ({
        AGLKPointParticleEffect *effect = [[AGLKPointParticleEffect alloc] init];
        effect.texture2d0.name = self.ballParticleTexture.name;
        effect.texture2d0.target = self.ballParticleTexture.target;
        effect;
    });
    
    //设置context
    [(AGLKContext *)view.context setClearColor:GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f)];
    [(AGLKContext *)view.context enable:GL_DEPTH_TEST]; //深度缓存
    [(AGLKContext *)view.context enable:GL_BLEND];      //混合模式
    [(AGLKContext *)view.context setBlendSourceFunction:GL_SRC_ALPHA            // alpha
                                    destinationFunction:GL_ONE_MINUS_SRC_ALPHA];// 1 - alpha
    
    
    self.autoSpawnDelta = 0.0f;// 一秒钟产生的粒子数量
    self.currentEmitterIndex = 0;
    
    // 轰炮
    EmitterBlock cannonBall = ^{
        self.autoSpawnDelta = 0.5f;                         // 生成速度
        self.particleEffect.gravity = AGLKDefaultGravity;   // 重力
        float randomXVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX; // -0.5 ~ 0.5
        [self.particleEffect addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.9f)
                                          velocity:GLKVector3Make(randomXVelocity, 1.0f, -1.0f)
                                             force:GLKVector3Make(0.0f, 9.0f, 0.0f)
                                              size:4.0f
                                   lifeSpanSeconds:3.2f
                               fadeDurationSeconds:0.5f];
    };
    
    // 巨浪
    EmitterBlock billow = ^{
        self.autoSpawnDelta = 0.05f;
        self.particleEffect.gravity = GLKVector3Make(0.0f, 0.5f, 0.0f);
        for (int i = 0; i < 20; i++) {
            float randomXVelocity = -0.1f + 0.2f * (float)random() / (float)RAND_MAX;   // -0.1 ~ 0.1
            float randomZvelocity = 0.1f + 0.2f * (float)random() / (float)RAND_MAX;    // 0.1 ~ 0.3
            [self.particleEffect addParticleAtPosition:GLKVector3Make(0.0f, -0.5f, 0.0f)
                                              velocity:GLKVector3Make(randomXVelocity, 0.0f, randomZvelocity)
                                                 force:GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                  size:64.0f
                                       lifeSpanSeconds:2.2f
                                   fadeDurationSeconds:3.0f];
        }
    };
    
    // 脉冲
    EmitterBlock pulse = ^{
        self.autoSpawnDelta = 0.5f;
        self.particleEffect.gravity = GLKVector3Make(0.0f, 0.0f, 0.0f);
        for (int i = 0; i < 100; i++) {
            float randomXVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX; // -0.5 ~ 0.5;
            float randomYVelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            float randomZvelocity = -0.5f + 1.0f * (float)random() / (float)RAND_MAX;
            [self.particleEffect addParticleAtPosition:GLKVector3Make(0.0f, 0.0f, 0.0f)
                                              velocity:GLKVector3Make(randomXVelocity, randomYVelocity, randomZvelocity)
                                                 force:GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                  size:4.0f
                                       lifeSpanSeconds:3.2f
                                   fadeDurationSeconds:0.5];
            
        }

    };
    
    self.emitterBlocks = [NSArray arrayWithObjects: [cannonBall copy], [billow copy], [pulse copy], nil];
}

//配置投影矩阵和视图矩阵
- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio
{
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0f),
                                                                           aspectRatio,
                                                                           0.1f,    //近面距离
                                                                           20.0f);  //远面距离
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(0.0, 0.0, 1.0, // 眼睛位置
                                                                     0.0, 0.0, 0.0, // 目标位置
                                                                     0.0, 1.0, 0.0); // 向上看
}

- (void)update
{
    NSTimeInterval timeElapsed = self.timeSinceFirstResume;
    self.particleEffect.elapsedSeconds = timeElapsed;
    
    if (self.autoSpawnDelta < (timeElapsed - self.lastSpawnTime)) {
        self.lastSpawnTime = timeElapsed;
        EmitterBlock emitter = [self.emitterBlocks objectAtIndex:self.currentEmitterIndex];
        emitter();
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT];
    [self preparePointOfViewWithAspectRatio:aspectRatio];
    self.baseEffect.light0.position = GLKVector4Make(0.4f, 0.4f, -0.2f, 0.0f);
    self.particleEffect.transform.projectionMatrix = self.baseEffect.transform.projectionMatrix;
    self.particleEffect.transform.modelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    [self.particleEffect prepareToDraw];
    [self.particleEffect draw];
    
    [self.baseEffect prepareToDraw];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark UISegmentedControl Event

//选择发射器
- (void)selectedEmitter:(UISegmentedControl *)sender
{
    
}

//选择纹理
- (void)selectedTexture:(UISegmentedControl *)sender
{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    GLKView *view = (GLKView *)self.view;
    UIImage *image = [view snapshot];
}

@end

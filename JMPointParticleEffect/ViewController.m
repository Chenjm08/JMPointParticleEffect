//
//  ViewController.m
//  JMPointParticleEffect
//
//  Created by jieminChen on 14-5-17.
//
//

#import "ViewController.h"
#import "JMPointParticleEffectViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    JMPointParticleEffectViewController *pointParticleEffectViewController = [[JMPointParticleEffectViewController alloc] init];
    [self.view addSubview:pointParticleEffectViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

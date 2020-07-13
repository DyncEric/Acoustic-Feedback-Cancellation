//
//  ViewController.m
//  Feedback
//
//  Created by Kashyap Patel on 3/4/20.
//  Copyright © 2020 Kashyap Patel. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

Configuration* Configuration::_instance = NULL;
Configuration* Config = Configuration::getInstance();

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    iosAudio = [[IosAudioController alloc] init];
    [iosAudio start];
    
}


@end

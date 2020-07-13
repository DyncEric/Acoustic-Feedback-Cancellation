//
//  IosAudioController.h
//  Aruts
//
//  Created by Simon Epskamp on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#include "AudioFormat.h"
#import <QuartzCore/QuartzCore.h>   // For time.
#include <MacTypes.h>
#import "Transforms.h"
#include "dsp.hpp"
#ifndef max
#define max( a, b ) ( ((a) > (b)) ? (a) : (b) )
#endif

#ifndef min
#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )
#endif


@interface IosAudioController : NSObject {
	AudioComponentInstance audioUnit;
	// this will hold the latest data from the microphone
}

@property (readonly) AudioComponentInstance audioUnit;
@property (readonly) AudioBuffer tempBuffer;

- (void) start;
- (void) stop;


@end

// setup a global iosAudio variable, accessible everywhere
extern IosAudioController* iosAudio;

//
//  AudioBuffer.h
//  Kash_Stereo
//
//  Created by SSPRL on 8/29/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#ifndef AudioFormat_h
#define AudioFormat_h
#include <MacTypes.h>



#define FRAME_SIZE 64// Please put in order of 2.
#define SAMPLING_FREQUENCY 48000
#define kOutputBus 0
#define kInputBus 1
#define kNumberOfChannel 1
#define NFFT FRAME_SIZE*2




#include <stdio.h>

typedef struct AudioData{
    int                  frameSize;
    float*                left;
    float*                right;
}audioData;








#endif /* AudioBuffer_h */

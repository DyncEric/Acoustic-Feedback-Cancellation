//
//  AFC.hpp
//  Feedback
//
//  Created by SSPRL UTD on 3/11/20.
//  Copyright © 2020 Kashyap Patel. All rights reserved.
//

#ifndef AFC_hpp
#define AFC_hpp

#include <stdio.h>
#include <stdlib.h>
#include "AudioFormat.h"
#include "CircularBuffer.hpp"
#include "Filter.hpp"

bool NIMode = false;
int NICounter = 0;
int NInumFrames = 20;
static const int filterLen = 1000;
float weights[filterLen] = {0};
CircularBuffer* RecordingBuffer = new CircularBuffer();
Filter* F = new Filter(weights, filterLen);
float previous[FRAME_SIZE] = {0};


void applyAFC(audioData* data, int numFrames);
void cancellationMode(float* data, float* prev, int numFrames);
void init();
bool howlingDetection(float* data, int numFrames);
void computeFilter(float* mic, float* spk, int filterLen);

#endif /* AFC_hpp */

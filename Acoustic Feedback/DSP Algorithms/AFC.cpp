//
//  AFC.cpp
//  Feedback
//
//  Created by SSPRL UTD on 3/11/20.
//  Copyright © 2020 Kashyap Patel. All rights reserved.
//

#include "AFC.hpp"

void applyAFC(float* data, int numFrames){
    
    if (NIMode){
        RecordingBuffer->write(data, numFrames);
        for(int i=0; i<numFrames; i++){
            //data[i] = noise[NICounter*FRAME_SIZE + i] ; Put noise;
        }
        NICounter ++;
        if (NICounter == NInumFrames){
            //get the mic and spk data. Put here. Get filter.
            //computeFilter(<#float *mic#>, <#float *spk#>, <#int filterLen#>)
            NIMode = false;
        }
        NICounter = NICounter % NInumFrames;
        
    }else{
        cancellationMode(data, previous,  numFrames);
        NIMode = howlingDetection(data, numFrames);
        
        for (int i=0; i< FRAME_SIZE; i++){
            previous[i] = data[i];
        }
    }
}

void cancellationMode(float* data, float* prev, int numFrames){
    float toCancel[FRAME_SIZE] = {0};
    F->filter(prev, toCancel, numFrames);
    for(int i=0; i<numFrames; i++){
        data[i] = data[i] - toCancel[i];
    }    
}

bool howlingDetection(float* data, int numFrames){
    bool NIMode_ = false;
    
    return NIMode_;
}

void computeFilter(float* mic, float* spk, int filterLen);

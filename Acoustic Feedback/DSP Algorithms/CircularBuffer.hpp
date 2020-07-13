//
//  CircularBuffer.hpp
//  DSP
//
//  Created by Kashyap Patel on 2/26/20.
//  Copyright © 2020 Kashyap Patel. All rights reserved.
//

#ifndef CircularBuffer_hpp
#define CircularBuffer_hpp

#include <stdio.h>
#include "AudioFormat.h"

static const int capacity = FRAME_SIZE*100;
class CircularBuffer{

   
    
public:
    CircularBuffer();
    int getSize();
    int read(float* data, int numFrames);
    int write(float* data, int numFrames);
    float buffer[capacity] = {};
       int readPos;
       int writePos;
       int size;
    
    
};



#endif /* CircularBuffer_hpp */

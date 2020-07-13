//
//  RingBuffer.h
//  Kash_Stereo
//
//  Created by SSPRL on 9/10/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#ifndef RingBuffer_h
#define RingBuffer_h
#include <MacTypes.h>
#include <stdio.h>
#include <cstdlib>

static const int32_t CAPACITY = 48000;

class RingBuffer {
    
public:
    virtual ~RingBuffer();
    virtual int32_t read(Float32 *data, int32_t numFrames);
    virtual int32_t write(Float32 *data, int32_t numFrames);
    int32_t getSize();
    
protected:
    int32_t head_ = 0;
    int32_t n_ = 0;
    Float32* data_ = (Float32*)calloc(CAPACITY, sizeof(Float32));
    int32_t getWritePos();
};


#endif /* RingBuffer_h */

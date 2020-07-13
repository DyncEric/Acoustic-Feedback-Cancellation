//
//  IOBuffer.h
//  Kash_Stereo2
//
//  Created by SSPRL on 9/11/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#ifndef IOBuffer_h
#define IOBuffer_h

#include <stdio.h>
#include <MacTypes.h>
#include "RingBuffer.h"
#include <thread>

class IOBuffer: public RingBuffer {
    
public:
    virtual ~IOBuffer();
    IOBuffer(int32_t bufferSize);
    virtual int32_t read(Float32 *data, int32_t numFrames) override;
    virtual int32_t write(Float32 *data, int32_t numFrames) override;
    int32_t drain();
    
private:
    bool firstRead_ = true;
    bool ready_ = false;
    int32_t bufferSize_ = 0;
    void writeEmpty(Float32 *data, int32_t numFrames);
    std::mutex lock_;
};

#endif /* IOBuffer_h */

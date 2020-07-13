//
//  AsyncBuffer.h
//  Kash_Stereo2
//
//  Created by SSPRL on 9/11/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#ifndef AsyncBuffer_h
#define AsyncBuffer_h

#include <stdio.h>
#include <MacTypes.h>
#include "RingBuffer.h"
#include <thread>

class AsyncBuffer: public RingBuffer {
    
public:
    virtual ~AsyncBuffer();
    virtual int32_t read(Float32 *data, int32_t numFrames) override;
    virtual int32_t write(Float32 *data, int32_t numFrames) override;
    
private:
    std::mutex lock_;
};

#endif /* AsyncBuffer_h */

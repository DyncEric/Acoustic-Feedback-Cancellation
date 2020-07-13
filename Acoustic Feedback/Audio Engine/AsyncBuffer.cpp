//
//  AsyncBuffer.c
//  Kash_Stereo2
//
//  Created by SSPRL on 9/11/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#include "AsyncBuffer.h"

AsyncBuffer::~AsyncBuffer() {
    
}

int32_t AsyncBuffer::read(Float32 *data, int32_t numFrames) {
    lock_.lock();
    int32_t framesRead = RingBuffer::read(data, numFrames);
    lock_.unlock();
    return framesRead;
}
int32_t AsyncBuffer::write(Float32 *data, int32_t numFrames) {
    lock_.lock();
    int32_t framesWritten = RingBuffer::write(data, numFrames);
    lock_.unlock();
    return framesWritten;
}

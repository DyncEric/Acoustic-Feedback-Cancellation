//
//  IOBuffer.c
//  Kash_Stereo2
//
//  Created by SSPRL on 9/11/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#include "IOBuffer.h"

IOBuffer::~IOBuffer() {
    
}

IOBuffer::IOBuffer(int32_t bufferSize) {
    bufferSize_ = bufferSize;
}

int32_t IOBuffer::read(Float32 *data, int32_t numFrames) {
    lock_.lock();
    int32_t framesRead = 0;
    if (firstRead_) {
        firstRead_ = false;
        drain();
    }
    if (ready_) {
       // printf("buffer size %d \n", n_);
        framesRead = RingBuffer::read(data, numFrames);
    } else {
       writeEmpty(data, numFrames);
    }
    lock_.unlock();
    return framesRead;
}

int32_t IOBuffer::write(Float32 *data, int32_t numFrames) {
    lock_.lock();
    int32_t framesWritten = RingBuffer::write(data, numFrames);
    if (n_ >= bufferSize_) {
        ready_ = true;
    }
    lock_.unlock();
    return framesWritten;
}

void IOBuffer::writeEmpty(Float32 *data, int32_t numFrames) {
    for (int i = 0; i < numFrames; i++) {
        data[i] = 0;
    }
}

int32_t IOBuffer::drain() {
    int32_t framesDrained = n_;
    n_ = 0;
    ready_ = false;
    return framesDrained;
}


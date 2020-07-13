//
//  RingBuffer.c
//  Kash_Stereo
//
//  Created by SSPRL on 9/10/19.
//  Copyright © 2019 SSPRL. All rights reserved.
//

#include "RingBuffer.h"

RingBuffer::~RingBuffer() {
    
}

int32_t RingBuffer::getWritePos() {
    return (head_ + n_) % CAPACITY;
}

int32_t RingBuffer::read(Float32 *data, int32_t numFrames) {
    int32_t framesRead = numFrames < n_ ? numFrames : n_;
    
    for (int i = 0; i < framesRead; i++) {
        data[i] = data_[(head_ + i) % CAPACITY];
    }
    
    head_ = (head_ + framesRead) % CAPACITY;
    n_ -= framesRead;
    
    return framesRead;
}

int32_t RingBuffer::write(Float32 *data, int32_t numFrames) {
    int32_t framesWritten = (n_ + numFrames) > CAPACITY ? CAPACITY - n_ : numFrames;
    int32_t tail = getWritePos();
    
    for (int i = 0; i < framesWritten; i++) {
        data_[(tail + i) % CAPACITY] = data[i];
    }
    
    n_ += framesWritten;
    
    return framesWritten;
}

int32_t RingBuffer::getSize() {
    return n_;
}







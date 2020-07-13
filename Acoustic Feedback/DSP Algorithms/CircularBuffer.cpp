//
//  CircularBuffer.cpp
//  DSP
//
//  Created by Kashyap Patel on 2/26/20.
//  Copyright © 2020 Kashyap Patel. All rights reserved.
//

#include "CircularBuffer.hpp"

CircularBuffer::CircularBuffer(){
    readPos = 0;
    writePos = 0;
    size = 0;
}

int CircularBuffer::getSize(){
    return size;
}

int CircularBuffer::read(float *data, int numFrames){
    int framesRead = numFrames > size ? size : numFrames;
    for(int i = 0; i< framesRead; i++){
        int pos = (readPos + i) % capacity;
        data[i] = buffer[pos];
    }
    readPos = (readPos + framesRead) % capacity;
    size -= framesRead;
    return framesRead;
}

int CircularBuffer::write(float *data, int numFrames){
    int framesWritten = numFrames > capacity - size ? capacity - size : numFrames;
    for (int i = 0; i < framesWritten; i++){
        int pos = (writePos + i) % capacity;
        buffer[pos] = data[i];
    }
    
    writePos = (writePos + framesWritten) % capacity;
    size += framesWritten;
    return framesWritten;
}


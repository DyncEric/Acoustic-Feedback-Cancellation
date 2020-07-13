//
//  Filter.cpp
//  DSPFIlter
//
//  Created by SSPRL UTD on 3/4/20.
//  Copyright © 2020 SSPRL UTD. All rights reserved.
//

#include "Filter.hpp"
Filter::~Filter(){
    delete [] weight_;
    delete [] buffer_;
}

Filter::Filter(float* weights, int filterLen){
    filterLen_ = filterLen;
    weight_ = new float[filterLen_];
    buffer_ = new float[filterLen_];
    for (int i = 0; i< filterLen; i++){
        weight_[i] = weights[i];
        buffer_[i] = 0;
    }
}

void Filter::filter(float *input, float* output, int numFrames){
    for(int i = 0; i< numFrames; i++){
        insert(input[i]);
        for(int j = 0; j< filterLen_; j++){
            int pos = (head_ + j) % filterLen_;
            output[i] += weight_[j]*buffer_[pos];
        }
    }
    return ;
}

void Filter::updateFilter(float *weights,int filterLen){
    for(int i = 0; i< filterLen_; i++){
        weight_[i] = weights[i];
    }
}

void Filter::resetFilter(){
    for(int i = 0; i< filterLen_; i++){
        buffer_[i] = 0;
    }
}

void Filter::insert(float x){
    int pos = getPos() ;
    buffer_[pos] = x;
    head_ = pos;
    return;
}

int Filter::getPos(){
    int pos = head_ - 1;
    if (pos < 0){
        pos = filterLen_ - 1;
    }
    return pos;
}


//
//  Filter.hpp
//  DSPFIlter
//
//  Created by SSPRL UTD on 3/4/20.
//  Copyright © 2020 SSPRL UTD. All rights reserved.
//

#ifndef Filter_hpp
#define Filter_hpp

#include <stdio.h>
#include <stdlib.h>
class Filter{
public:
    int filterLen_;
    float* weight_;
    Filter(float* weights, int filterLen);
    ~Filter();
    
    void filter(float* input, float* output, int numFrames);
    void updateFilter(float* weights, int filterLen);
    void resetFilter();
    
private:
    float* buffer_;
    int head_ = 0;
    void insert(float x);
    int getPos();
};
#endif /* Filter_hpp */

//
//  GLD.hpp
//  DSPFIlter
//
//  Created by SSPRL UTD on 3/4/20.
//  Copyright © 2020 SSPRL UTD. All rights reserved.
//

#ifndef GLD_hpp
#define GLD_hpp

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Transforms.h"
float* GLD(float *final_x_frame, float *final_noise, int lenx, int maxlag, int delay, int M_behind);

#endif /* GLD_hpp */

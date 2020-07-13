//
//  GLD.cpp
//  DSPFIlter
//
//  Created by SSPRL UTD on 3/4/20.
//  Copyright © 2020 SSPRL UTD. All rights reserved.
//

#include "GLD.hpp"


float* GLD(float *final_x_frame, float *final_noise, int lenx, int maxlag, int delay, int M_behind){
    
    float* E;
    float* K;
    float* a;
    float* b;
    float* pre_a;
    float* pre_b;
    float* R;
    float* R_reverse;
    int i, j, M;
    int p = maxlag + 1;
    float E0;
    float temp1;
    float temp2;
    E = (float*)calloc(maxlag + 1, sizeof(float));
    K = (float*)calloc(maxlag + 1, sizeof(float));
    a = (float*)calloc(maxlag + 1, sizeof(float));
    b = (float*)calloc(maxlag + 1, sizeof(float));
    pre_a = (float*)calloc(maxlag + 1, sizeof(float));
    pre_b = (float*)calloc(maxlag + 1, sizeof(float));
    //rxx = (float*)calloc(maxlag + 3, sizeof(float));
    R = (float*)calloc(maxlag + 1, sizeof(float));
    R_reverse = (float*)calloc(maxlag + 1, sizeof(float));


    Transform *X,*Y,*Z,*W;
    float *A,*B,*C,*D,*F,*G;
    int npt = 4096;

    A = (float*)calloc(npt,sizeof(float));
    B = (float*)calloc(npt,sizeof(float));
    C = (float*)calloc(npt,sizeof(float));
    F = (float*)calloc(npt,sizeof(float));
    G = (float*)calloc(npt,sizeof(float));
    D = (float*)calloc(npt,sizeof(float));

    X = newTransform(npt);
    Y = newTransform(npt);
    Z = newTransform(npt);
    W = newTransform(npt);

    memcpy(A, final_x_frame, sizeof(float)*lenx);
    memcpy(B, final_noise, sizeof(float)*lenx);
    //memcpy(F, &(*(final_x_frame + delay-M_behind + 1)),sizeof(float)*(lenx-delay+M_behind-1) );

    X->doTransform(X, A);
    Y->doTransform(Y, B);

    for (int ij = 0; ij <npt; ij++) {
        C[ij] = X->real[ij]*Y->real[ij] + X->imaginary[ij] * Y->imaginary[ij];
        D[ij] =  -X->real[ij] * Y->imaginary[ij] + X->imaginary[ij] * Y->real[ij];
    }

    Z->invTransform(Z, C, D);

    for (int ik = 0; ik <npt; ik++) {
        C[ik] = Y->real[ik]*Y->real[ik] + Y->imaginary[ik] * Y->imaginary[ik];

    }

    W->invTransform(W, C, G);

    for (j = 0; j < p; j++) {
        R[j] = W->real[j + 1];
        R_reverse[p - j - 1] = R[j];
    }
    
    E0 = W->real[0];

    for (M = 0; M < p; M++)
    {
        if (M == 0){
            K[M] = -R[M] / E0;
            a[M] = K[M];
            b[M] = Z->real[M] / E0;
            E[M] = (1 - (K[M] * K[M]))*E0;
        }else{
            temp1 = 0;
            for (i = 0; i < M; i++){            {
                temp1 = temp1 + (pre_a[i])* (R_reverse[p - M + i]);
            }
            K[M] = -(temp1 + R[M]) / E[M - 1];
            a[M] = K[M];
            temp2 = 0;
            for (i = 0; i < M; i++){
                temp2 = temp2 + pre_b[i] * R_reverse[p - M + i];
            }
            b[M] = (Z->real[M] - temp2) / E[M - 1];
            for (i = 0; i < M; i++) {
                a[i] = pre_a[i] + K[M] * pre_a[M - 1 - i];
                b[i] = pre_b[i] + b[M] * pre_a[M - 1 - i];
            }
            E[M] = (1 - (K[M] * K[M]))*E[M - 1];
        }
        for (i = 0; i < p; i++){
            pre_a[i] = a[i];
            pre_b[i] = b[i];
        }
        }}

    return b;

    }


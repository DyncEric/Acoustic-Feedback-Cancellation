#ifndef TRANSFORMS_H
#define TRANSFORMS_H
#define _USE_MATH_DEFINES

#include "AudioFormat.h"
#include <stdlib.h>
#include <math.h>

typedef struct Transform {
	int points;
	Float32* sine;
	Float32* cosine;
	Float32* real;
	Float32* imaginary;
	void(*doTransform)(struct Transform* transform, Float32* input);
	void(*invTransform)(struct Transform* transform, Float32* inputreal, Float32* inputimaginary);
} Transform;


void FFT(Transform* fft, Float32* input);
Transform* newTransform(int points);
void transformMagnitude(Transform* transform, Float32* output);
void invtranMagnitude(Transform* transform, Float32* output);
void destroyTransform(Transform* transform);


#endif
#pragma once

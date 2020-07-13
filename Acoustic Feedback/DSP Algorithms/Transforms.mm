#include "Transforms.h"
//#include "stdafx.h"
void FFT(Transform* fft, Float32* input);
void IFFT(Transform* fft, Float32* inputreal, Float32* inputimaginary);

Transform*
newTransform(int points)
{
	Transform* newTransform = (Transform*)malloc(sizeof(Transform));

	newTransform->points = points;
	newTransform->real = (Float32*)malloc(points * sizeof(Float32));
	newTransform->imaginary = (Float32*)malloc(points * sizeof(Float32));
	newTransform->sine = NULL;
	newTransform->cosine = NULL;
	newTransform->doTransform = *FFT;
	newTransform->invTransform = *IFFT;
	newTransform->sine = (Float32*)malloc((points / 2) * sizeof(Float32));
	newTransform->cosine = (Float32*)malloc((points / 2) * sizeof(Float32));
	//precompute twiddle factors
	Float32 arg;
	int i;
	for (i = 0; i<points / 2; i++)
	{
		arg = -2 * M_PI*i / points;
		newTransform->cosine[i] = cos(arg);
		newTransform->sine[i] = sin(arg);
	}
	return newTransform;
}

void
FFT(Transform* fft, Float32* input)
{
	int i, j, k, L, m, n, o, p, q;
	Float32 tempReal, tempImaginary, cos, sin, xt, yt;
	k = fft->points;
	for (i = 0; i<k; i++)
	{
		fft->real[i] = input[i];
		fft->imaginary[i] = 0;
	}

	j = 0;
	m = k / 2;
	//bit reversal
	for (i = 1; i<(k - 1); i++)
	{
		L = m;
		//L = pow(2,ceil(log2(m)));
		while (j >= L)
		{
			j = j - L;
			L = L / 2;
		}
		j = j + L;
		if (i<j)
		{
			tempReal = fft->real[i];
			tempImaginary = fft->imaginary[i];
			fft->real[i] = fft->real[j];
			fft->imaginary[i] = fft->imaginary[j];
			fft->real[j] = tempReal;
			fft->imaginary[j] = tempImaginary;
		}
	}
	L = 0;
	m = 1;
	n = k / 2;
	//computation
	for (i = k; i>1; i = (i >> 1))
	{
		L = m;
		m = 2 * m;
		o = 0;
		for (j = 0; j<L; j++)
		{
			cos = fft->cosine[o];
			sin = fft->sine[o];
			o = o + n;
			for (p = j; p<k; p = p + m)
			{
				q = p + L;
				xt = cos*fft->real[q] - sin*fft->imaginary[q];
				yt = sin*fft->real[q] + cos*fft->imaginary[q];
				fft->real[q] = (fft->real[p] - xt);
				fft->imaginary[q] = (fft->imaginary[p] - yt);
				fft->real[p] = (fft->real[p] + xt);
				fft->imaginary[p] = (fft->imaginary[p] + yt);
			}
		}
		n = n >> 1;
	}
}
void
IFFT(Transform* fft, Float32* inputreal, Float32* inputimaginary)
{
    int i, j, k, L, m, n, o, p, q;
	Float32 tempReal, tempImaginary, cos, sin, xt, yt;
	k = fft->points;
	for (i = 0; i<k; i++)
	{
		fft->real[i] = inputreal[i];
		fft->imaginary[i] = (-1)*inputimaginary[i];
	}

	j = 0;
	m = k / 2;
	//bit reversal
	for (i = 1; i<(k - 1); i++)
	{
		L = m;
		while (j >= L)
		{
			j = j - L;
			L = L / 2;
		}
		j = j + L;
		if (i<j)
		{
			tempReal = fft->real[i];
			tempImaginary = fft->imaginary[i];
			fft->real[i] = fft->real[j];
			fft->imaginary[i] = fft->imaginary[j];
			fft->real[j] = tempReal;
			fft->imaginary[j] = tempImaginary;
		}
	}
	L = 0;
	m = 1;
	n = k / 2;
	//computation
	for (i = k; i>1; i = (i >> 1))
	{
		L = m;
		m = 2 * m;
		o = 0;
		for (j = 0; j<L; j++)
		{
			cos = fft->cosine[o];
			sin = fft->sine[o];
			o = o + n;
			for (p = j; p<k; p = p + m)
			{
				q = p + L;
				xt = cos*fft->real[q] - sin*fft->imaginary[q];
				yt = sin*fft->real[q] + cos*fft->imaginary[q];
				fft->real[q] = (fft->real[p] - xt);
				fft->imaginary[q] = (fft->imaginary[p] - yt);
				fft->real[p] = (fft->real[p] + xt);
				fft->imaginary[p] = (fft->imaginary[p] + yt);
			}
		}
		n = n >> 1;
	}
	for (i = 0; i<k; i++)
	{
		fft->real[i] = fft->real[i] / k;
		fft->imaginary[i] = fft->imaginary[i] / k;
	}
}
void
transformMagnitude(Transform* transform, Float32* output)
{
	int n;
	for (n = 0; n<transform->points; n++)
	{
		output[n] = sqrt(transform->real[n] * transform->real[n] + transform->imaginary[n] * transform->imaginary[n]);
	}
}

void
invtranMagnitude(Transform* transform, Float32* outputinv)
{
	int n;
	Float32 a;
	a = 1.0 / transform->points;
	for (n = 0; n < transform->points; n++)
	{
		outputinv[n] = a * sqrt(transform->real[n] * transform->real[n] + transform->imaginary[n] * transform->imaginary[n]);
	}
}

void
destroyTransform(Transform* transform)
{
	if (transform != NULL) {
		if ((transform)->cosine != NULL) {
			free((transform)->cosine);
			(transform)->cosine = NULL;
		}
		if ((transform)->sine != NULL) {
			free((transform)->sine);
			(transform)->sine = NULL;
		}
		if ((transform)->real != NULL) {
			free((transform)->real);
			(transform)->real = NULL;
		}
		if ((transform)->imaginary != NULL) {
			free((transform)->imaginary);
			(transform)->imaginary = NULL;
		}
		free(transform);
		transform = NULL;
	}
}

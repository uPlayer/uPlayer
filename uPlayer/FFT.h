#include <math.h>

#ifndef INCLUDE_FFT
#define INCLUDE_FFT

class FFT
{
private:
	float* xre;
	float* xim;
	float* mag;
	float* fftSin;
	float* fftCos;

	int* fftBr;
	int m_samplesize;
	int m_samplesize2;
	int nu;
	int nu1;
public:
	FFT(int sampleSize)
	{
		m_samplesize = sampleSize;
		m_samplesize2 = sampleSize >> 1;

		xre = new float[sampleSize];
		xim = new float[sampleSize];
		mag = new float[m_samplesize2];

		nu = (int)(log((float)sampleSize) / log((float)2));
		nu1 = nu - 1;

		prepareFFTTables();
	}

	~FFT()
	{
		if(xre != NULL) delete[] xre;
		if(xim != NULL) delete[] xim;
		if(mag != NULL) delete[] mag;
		if(fftSin != NULL) delete[] fftSin;
		if(fftCos != NULL) delete[] fftCos;
		if(fftBr != NULL) delete[] fftBr;
	}

	float* calculate(float* pSample, int nSampleSize) {
		int n2 = m_samplesize2;
		int nu1 = nu - 1;
		int wAps = nSampleSize / m_samplesize;
		int a = 0;

		for (int b = 0; a < nSampleSize; b++) {
			xre[b] = pSample[a];
			xim[b] = 0.0F;
			a += wAps;
		}

		int x = 0;
		for (int l = 1; l <= nu; l++) {
			for (int k = 0; k < m_samplesize; k += n2) {
				for (int i = 1; i <= n2; i++) {
					float c = fftCos[x];
					float s = fftSin[x];
					int kn2 = k + n2;
					float tr = xre[kn2] * c + xim[kn2] * s;
					float ti = xim[kn2] * c - xre[kn2] * s;
					xre[kn2] = xre[k] - tr;
					xim[kn2] = xim[k] - ti;
					xre[k] += tr;
					xim[k] += ti;
					k++;
					x++;
				}

			}

			nu1--;
			n2 >>= 1;
		}

		for (int k = 0; k < m_samplesize; k++) {
			int r = fftBr[k];
			if (r > k) {
				float tr = xre[k];
				float ti = xim[k];
				xre[k] = xre[r];
				xim[k] = xim[r];
				xre[r] = tr;
				xim[r] = ti;
			}
		}

		mag[0] = (float) sqrt(xre[0] * xre[0] + xim[0] * xim[0])
			/ (float) m_samplesize;
		for (int i = 1; i < m_samplesize2; i++)
			mag[i] = (2.0F * (float) sqrt(xre[i] * xre[i] + xim[i]
		* xim[i]))
			/ (float) m_samplesize;

		return mag;
	}

private:
	void prepareFFTTables()
	{
		int n2 = m_samplesize2;
		int nu1 = nu - 1;

		fftSin = new float[nu * n2];
		fftCos = new float[nu * n2];

		int k = 0;
		int x = 0;
		for (int l = 1; l <= nu; l++) {
			while (k < m_samplesize) {
				for (int i = 1; i <= n2; i++) {
					float p = (float)bitrev(k >> nu1, nu);
					float arg = (6.283185 * p) / (float) m_samplesize;
					fftSin[x] = (float) sin(arg);
					fftCos[x] = (float) cos(arg);
					k++;
					x++;
				}

				k += n2;
			}

			k = 0;
			nu1--;
			n2 >>= 1;
		}

		fftBr = new int[m_samplesize];
		for (k = 0; k < m_samplesize; k++)
			fftBr[k] = bitrev(k, nu);
	}

	int bitrev(int j, int nu) {
		int j1 = j;
		int k = 0;
		for (int i = 1; i <= nu; i++) {
			int j2 = j1 >> 1;
			k = ((k << 1) + j1) - (j2 << 1);
			j1 = j2;
		}

		return k;
	}
};
#endif

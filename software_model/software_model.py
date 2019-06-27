import numpy as np
from scipy.fftpack import fft

def soft_model(data):
	result_np = fft(data)
	return [[x.real,x.imag] for x in result_np.tolist()]

if __name__ == '__main__':
	data = np.random.randn(8)
	result = soft_model(data)
	# print(type(result[0]))
	print(result)
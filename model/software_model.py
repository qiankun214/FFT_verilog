import numpy as np
from scipy.fftpack import fft

def software_fft(data):
	result_np = fft(data)
	return np.array([[x.real,x.imag] for x in result_np.tolist()])

if __name__ == '__main__':
	data = np.random.randn(8)
	result = software_fft(data)
	# print(type(result[0]))
	print(result)
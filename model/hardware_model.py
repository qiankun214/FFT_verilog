import math
import random
# from software_model import soft_fft
import software_model as sm
import numpy as np

class plural(object):
	"""docstring for plural"""
	def __init__(self,real=0,imag=0):
		super(plural, self).__init__()
		self.real = real
		self.imag = imag

	def __add__(self,x):
		tmp = plural()
		tmp.real = self.real + x.real
		tmp.imag = self.imag + x.imag
		return tmp

	def __sub__(self,x):
		tmp = plural()
		tmp.real = self.real - x.real
		tmp.imag = self.imag - x.imag
		return tmp

	def __mul__(self,x):
		tmp = plural()
		tmp.real = self.real * x.real - self.imag * x.imag
		tmp.imag = self.real * x.imag + self.imag * x.real
		return tmp

	def __str__(self):
		if self.imag > 0:
			return "%s+%s*j" % (self.real,self.imag)
		elif self.imag < 0:
			return "%s-%s*j" % (self.real,abs(self.imag))
		else:
			return "%s" % self.real
		
	def to_list(self):
		return [self.real,self.imag]

	def from_list(self,x):
		assert(len(x) == 2)
		self.real,self.imag = x

def plural_test():
	a,b = plural(1,1),plural(3,-2)
	print(a+b)
	print(a-b)
	print(a*b)

def weight_generator(N,k):
	weight = plural()
	weight.real = math.cos((2 * math.pi * k) / N)
	weight.imag = - math.sin((2 * math.pi * k) / N)
	return weight

def data_generator_from_real(data):
	return [plural(x,0) for x in data]

def result_generator_from_plural(data):
	return np.array([[x.real,x.imag] for x in data])

def butterfly(x1,x2,w):
	y1 = x1 + w * x2
	y2 = x1 - w * x2
	return y1,y2

def parallel_fft_8(din,len_log=3):
	# check
	assert(len(din) == 2 ** len_log)

	# pre-handle
	tmp = [[None for _ in range(2 ** len_log)] for _ in range(len_log+1)]
	for i in range(2 ** (len_log - 1)):
		tmp[0][2*i] = din[i]
		tmp[0][2*i+1] = din[i+2**(len_log-1)]
	# tmp[0] = din[::4] + din[1::4] + din[2::4] + din[3::4]
	# print([str(x) for x in tmp[0]])
	group_num = 2 ** (len_log - 1)
	group_len = 1
	bias = 1

	# 2 point fft
	for step in range(len_log):
		# print(step)
		assert(group_num * group_len * 2 == 2 ** len_log)
		for group in range(group_num):
			for num in range(group_len):
				op1_index = group * group_len * 2 + num
				op2_index = op1_index + bias
				tmp[step+1][op1_index],tmp[step+1][op2_index] = butterfly(
					tmp[step][op1_index],tmp[step][op2_index],weight_generator(group_len*2,num))
				print("handle step:",step,"op1:",op1_index,"op2:",op2_index,"weight N,k:",group_len*2,num)
		group_num = group_num // 2
		group_len = group_len * 2
		bias = bias * 2

	return tmp[len_log]

if __name__ == '__main__':
	# print(weight_generator(8,3),weight_generator(8,8+3))
	len_log = 3
	data = np.random.randn(2**len_log)
	# data = np.arange(2**len_log)
	print("input:",data)
	result = sm.software_fft(data)
	# print(type(result[0]))
	print("software:\n",result)

	data_hd = data_generator_from_real(data)
	result_hd = parallel_fft_8(data_hd,len_log)
	result_hd = result_generator_from_plural(result_hd)
	print("hardware:\n",result_hd)
	# plural_test()
	print("compare:\n",np.abs(result - result_hd))
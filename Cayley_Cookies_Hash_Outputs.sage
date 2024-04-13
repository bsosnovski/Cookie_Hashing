############################################################
### This function  prints hash values   ###################
### from Cayley Cookies Hash Function   ###################
############################################################
#
#
############################################################
### Parameters
############################################################
#
# Number and length of parameters
p=1  #number of prime_modulos
#print("Number of prime_modulos = "+str(p));
n=500000  #number of random bit strings generated (number of samples observed)
print("Number of bit strings generated = "+str(n));
l=1000;  #lengths of the input (we want a total of 1000 bits with padding)
#print("Input_length = "+str(l+3));

# Prime Modulo
Mod_nbits="512";
nbits = 512;
#
############################################################
### Preamble
############################################################
from random import *

## Function that generates a random bit string of length m
def randBinList(m):
	"""
	This function outputs is an array with m bits 0 and 1.
	"""
	x=[randint(0,1) for t in range(1,m+1)];
	return x

## Function that converts integer to binary with fixed length
def binary(n, length=5):
	"""
	Return a binary string of specified length for this integer
	The binary string is padded with initial zeros if needed.
	The default length of 5 can be overriden.
	The units bits is on the right of the string.
	"""
	x=""
	if n!=0:
			if length < n.nbits():
					raise ValueError('Writing {} in binary requires more than {} bits'.format(n,length))
			else:
					x = '0' * (length-n.nbits()) + n.binary()
	else:
			x = '0' * (length-1) + n.binary()
	return x

	## Function that reverses a string
def reverse(x):
	"""
	This function has the go to reverse a bit string.
	This is to be used with the function binary(n) above to
	reverse a bit string so that the lowest power digits of the string is on
	the left.
	"""
	return x[::-1]

############################################################
### Settings/Ring Modulo
############################################################
#
o2 = open("/Users/beebee/Desktop/Cayley_Cookies/prime_modulos_2^"+Mod_nbits+".txt", "w") # record of the primes used
for i in range(1,p+1):
		prime = random_prime(2^nbits-1, True, 2^(nbits-1)); #change proof to False to speed up (pseudo prime)
		prime_hex = hex(prime);
		print(" Prime i = "+str(i));
		#print("prime_dec = "+str(prime));
		#print("prime_hex = "+str(prime_hex));
		o2.write("prime i = "+str(i)); o2.write('\n');
		o2.write("prime_dec = "+str(prime)); o2.write('\n');
		o2.write("prime_hex = "+str(prime_hex)); o2.write('\n\n');

		R=Integers(prime);    #ring of integers mod 'prime'
		Mod_len = len(prime.binary());


		# Generating matrices
		#   A        B            C
		# [1 2]    [1 0]        [2 1]
		# [0 1]    [2 1]        [1 1]

		A=matrix(R,[[1, 2], [0, 1]]);
		B=matrix(R,[[1, 0], [2, 1]]);
		C=matrix(R,[[2, 1], [1, 1]]);

############################################################
### Main function
############################################################

		# Hash files
		# A file is created with hashes values for each prime
		w=l+3; # total number of bits in an input to the hash
		o1 = open("/Users/beebee/Desktop/Cayley_Cookies/"+str(i)+"_Hashes_inputLength_"+str(w)+"_mod_2^"+Mod_nbits+".txt",'w');

		# temp matrix that starts with value of B and changes according to cookies
		Temp=B;

		# temp bit that starts with value of 1 and changes according to a series of 3 bits in a roll
		zero_bit=0;
		one_bit=1;
		cookie=one_bit;

		# Bit strings
		o3 = open("/Users/beebee/Desktop/Cayley_Cookies/inputs_length_"+str(w)+"_mod_2^"+Mod_nbits+".txt", "w") # record of the primes used
		for j in range(n):
				print("Input_j="+str(j+1));
				input=randBinList(l)+[0, 0, 0]; # generate a random binary of length l with padding of 3 zeros
				o3.write(str(input));o3.write('\n')
				prod=matrix(R,[[1, 0], [0, 1]]); #initial value is the identity matrix

				for k in range(l+3):
						#print("Multiplication_k="+str(k));
						#print("bit = "+str(input[k]));
						if input[k]==0:
								prod=prod*A;
						if input[k]==1:
								prod=prod*Temp;
						if (k>=2 and cookie==input[k] and cookie==input[k-1] and cookie==input[k-2]):
								#print("--**Found cookie!**--");
								Temp = C; C = B; B = Temp;
								cookie=zero_bit; zero_bit=one_bit; one_bit=cookie;
						#else:
								#print("No cookie")
						#if (k==w and cookie==input[k] and cookie==input[k-1] and cookie==input[k-2]):
								#print("Reset Matrices!\n");

				prod=prod.list(); #transform the result from matrix form to a vector
				#print(prod)
				prod=[ZZ(prod[0]),ZZ(prod[1]), ZZ(prod[2]), ZZ(prod[3])]; # convert entries to integers
				#print(prod)
				prod_string=str(reverse(binary(prod[0],Mod_len)))+str(reverse(binary(prod[1],Mod_len)))+str(reverse(binary(prod[2],Mod_len)))+str(reverse(binary(prod[3],Mod_len)));
				#print(prod_string)
				o1.write(str(prod_string));
				if ((j+1)%500)==0:
					  o1.write('\n');

        #
		#print("----------Next Prime----------\n");
		o1.close();
		o3.close();
o2.close();

print("THE END!!!")

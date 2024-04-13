############################################################
### This function evaluates hash values   ###################
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
n=100  #number of random bit strings generated (number of samples observed)
print("Number of bit strings generated = "+str(n));
l=1000000;  #lengths of the input (we want a total of 1000 bits with padding)
#print("Input_length = "+str(l+3));

# Prime Modulo
Mod_nbits="256";
nbits = 256;
#
############################################################
### Preamble
############################################################
from random import *
from hashlib import sha256
from hashlib import sha512
import time


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
w=l+3; # total number of bits in an input to the hash
o2 = open("/Users/beebee/Desktop/Cayley_Cookies/comp_time_len_"+str(w)+"_mod_2^"+Mod_nbits+".txt", "w") # record of the primes used
for i in range(1,p+1):
		#prime = random_prime(2^nbits-1, True, 2^(nbits-1)); #change proof to False to speed up (pseudo prime)
		#prime = 5  # for testing the code
		# prime with 256 bits
	  prime= 78517880940288269288270644415929494872480996439579746524177134503470327948351
		# prime with 512 bits
		#prime = 11934462843244563576740747427938757314891023812661679477731466282260419118525308765385414560351663827862988533170591047124539416616027809368030638816000499;

		#prime_hex = hex(prime);
		#print(" Prime i = "+str(i));
		#print("prime_dec = "+str(prime));
		#print("prime_hex = "+str(prime_hex));
		#o2.write("prime i = "+str(i)); o2.write('\n');
		o2.write("prime_dec = "+str(prime)); o2.write('\n\n');
		#o2.write("prime_hex = "+str(prime_hex)); o2.write('\n\n');

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
		#o1 = open("/Users/beebee/Desktop/Cayley_Cookies/CompTime_Hashes_inputLength_"+str(w)+"_mod_2^"+Mod_nbits+".txt",'w');

		# temp matrix that starts with value of B and changes according to cookies
		Temp=B;

		# temp bit that starts with value of 1 and changes according to a series of 3 bits in a roll
		zero_bit=0;
		one_bit=1;
		cookie=one_bit;

		# Average of time for calculating the hashes
		meanTime=0;
		meanTime_sha=0;

		# Bit strings
		o3 = open("/Users/beebee/Desktop/Cayley_Cookies/bitstrings_length_"+str(w)+"_mod_2^"+Mod_nbits+".txt", "w") # record of the bitstrings generated
		for j in range(n):
				print("Input_j="+str(j+1));
				input=randBinList(l)+[0, 0, 0]; # generate a random binary of length l with padding of 3 zeros
				#print(input)
				o3.write(str(input));o3.write('\n')
				prod=matrix(R,[[1, 0], [0, 1]]); #initial value is the identity matrix

				## SHA hashing
				sha_input = '';
				for r in range(l+3):
					  sha_input = sha_input+str(input[r]);
				time_sha=0;
				t0_sha = time.time(); #time performing the SHA Hashing
				sha256(sha_input.encode('utf-8'));
				t1_sha = time.time();
				time_sha = t1_sha-t0_sha;
				meanTime_sha=meanTime_sha+time_sha;
				o2.write("SHA_Time = "+str(time_sha)+" sec");
				o2.write('\n');

				time_=0;
				t0 = time.time(); #time performing the Cookie Hashing
				for k in range(l+3):
						#print("Multiplication_k="+str(k));
						#print("bit = "+str(input[k]));
						if input[k]==0:
								#prod=prod*A;
								prod[0,1]=prod[0,0]+prod[0,0]+prod[0,1];
								prod[1,1]=prod[1,0]+prod[1,0]+prod[1,1];
						if input[k]==1:
							 if Temp==B:
							 	  #prod=prod*Temp;
									prod[0,0]=prod[0,0]+prod[0,1]+prod[0,1];
									prod[1,0]=prod[1,0]+prod[1,1]+prod[1,1];
							 else:
							 		prod1=matrix(R,[[1, 0], [0, 1]]);
									# To avoid prod1 and prod to refer to the same object and cause error in the product matrix
							 		prod1=prod1*prod;
							 		prod[0,0]=prod1[0,0]+prod1[0,0]+prod1[0,1]; #OK
							 		prod[0,1]=prod1[0,0]+prod1[0,1];
							 		prod[1,0]=prod1[1,0]+prod1[1,0]+prod1[1,1];
							 		prod[1,1]=prod1[1,0]+prod1[1,1];
						if (k>=2 and cookie==input[k] and cookie==input[k-1] and cookie==input[k-2]):
								#print("--**Found cookie!**--");
								Temp = C; C = B; B = Temp;
								cookie=zero_bit; zero_bit=one_bit; one_bit=cookie;

				t1 = time.time()
				time_=t1-t0;
				o2.write("Cookie_Time = "+str(time_)+" sec");
				o2.write('\n');
				meanTime=meanTime+time_;
				prod=prod.list(); #transform the result from matrix form to a vector
				#print(prod)
				prod=[ZZ(prod[0]),ZZ(prod[1]), ZZ(prod[2]), ZZ(prod[3])]; # convert entries to integers
				#print(prod)
				prod_string=str(reverse(binary(prod[0],Mod_len)))+str(reverse(binary(prod[1],Mod_len)))+str(reverse(binary(prod[2],Mod_len)))+str(reverse(binary(prod[3],Mod_len)));
				#print(prod_string)
				#o1.write(str(prod_string));
		#
		# Average SHA time for n random strings of length l
		meanTime_sha=meanTime_sha/n;#
		o2.write('\n');
		o2.write("Average time for SHA Hashing = ");o2.write(str(meanTime_sha)+" sec");o2.write('\n');
		#
    # Average Cookie time for n random strings of length l
		meanTime=meanTime/n;#
		o2.write('\n');
		o2.write("Average time for Cookie Hashing = ");o2.write(str(meanTime)+" sec");o2.write('\n');
		#print("----------Next Prime----------\n");
		#o1.close();
		o3.close();
o2.close();

print("THE END!!!")

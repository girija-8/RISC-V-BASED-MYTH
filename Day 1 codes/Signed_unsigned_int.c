//Unsigned Highest Integer 
#include <stdio.h>
#include <math.h>

int main() {
	unsigned long long int max = (unsigned long long int) (pow(2,64)-1);
	printf("Highest number represented by unsigned long long int is %llu\n",max);
	return 0;
}


//Signed Highest Integer 
#include <stdio.h>
#include <math.h>

int main() {
	long long int max1 = (long long int) (pow(2,63)-1);
	long long int min = (long long int) (pow(2,63)*-1);
	printf("Highest number represented by signed long long int is %lld\n",max1);
	printf("Lowest number represented by signed long long int is %lld\n" ,min);
	return 0;
}

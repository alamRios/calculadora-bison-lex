#include <stdio.h>
#include <stdlib.h>

struct Str{
	int a;
	int b;
} str;

int main(){
	str.a = 3; 
	str.b = 4;
	printf("%d",str.a + str.b);
}

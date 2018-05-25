#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{

	printf("START\n");

	int i,j;
	for (i=0; i<10; i++) {
		printf("i=%d\n", i);

		printf("\t--> ");
		for (j=0; j<5; j++) {
			if (j==2) {
				printf("[[[Skip j eq 2]]]");
				continue;
			}
			printf("j=%d - ", j);
		}
		printf("\n");
	}

	int x = 2;
	if (x == 2) printf("Ahoy there\n");


	for (i=0; i<5; i++) {
		printf("loop i = %d\n", i);

		if (i > 1) i -= 1;

		printf("loop i = %d\n", i);

		i++;
	}


	char cAlbury = 'N';
	char cPenrith = 'N';
	int iNumInPack;

	/*
	 * Or iNumInPack = 10 or 20
	 */
	iNumInPack = 8; 

	if ( ( ((iNumInPack + 19) / 20) & 2 ) == 2 )
		cAlbury = 'Y';

	if ( ( ((iNumInPack + 19) / 20) & 1) == 1 )
		cPenrith = 'Y';

	printf("Hopper 1 (Penrith): %c\n", cPenrith);
	printf("Hopper 1 (Albury): %c\n", cAlbury);

	return 0;
}

#include <stdio.h>
#include <stdlib.h>

int main(void) {
    FILE *fp;
    int c;
    char filename[] = "mytext.txt";

    fp = fopen(filename, "r");


    while ((c = fgetc(fp)) != EOF) {
        putchar(c); 
    }

    fclose(fp);
    return EXIT_SUCCESS;
}

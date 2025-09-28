#include <stdio.h>
#include <stdlib.h>

//extern const char text[];       /* In text.s */

int main (void)
{
    char text[10] = "hello!";
    printf ("%s\n", text);
    return EXIT_SUCCESS;
}



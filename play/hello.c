#include <stdio.h>
#include <stdlib.h>

extern const char text[];       /* In text.s */

int main (void)
{
    int x = 0;
    if (x == 0) {
      x = 1;
    } else {
      x = 2;
    }
    return EXIT_SUCCESS;
}



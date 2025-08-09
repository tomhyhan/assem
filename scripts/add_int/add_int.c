#include <stdio.h>
#include <stdlib.h>

int main(void) {
  // FILE *file;
  long int a = 0;
  long int x = 5; 
  // char line[5] = {};

  // file = fopen("input.txt", "r");

  // while (fgets(line, 5, file) != NULL) {
  //   x += atol(line);
  // }

  if (x > a) {
    a = x;
  } else {
    a = 1;
  }

  // fclose(file);

  return 0;
}

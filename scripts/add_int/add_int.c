#include <stdio.h>
#include <stdlib.h>

int main(void) {
  FILE *file;
  int x = 0; 
  char line[5] = {};

  file = fopen("input.txt", "r");

  while (fgets(line, 5, file) != NULL) {
    x += atoi(line);
  }

  printf("%d\n", x);

  fclose(file);

  return 0;
}

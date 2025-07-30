#include <stdio.h>

#define FILE_LENGTH 5

int main(void) {
  FILE *file;
  char line[FILE_LENGTH] = "abc";

  file = fopen("test.txt", "r");

  while (fgets(line, sizeof(line), file) != NULL) {
    printf("%s", line);
  }

  fclose(file);
  
  return 0;
}

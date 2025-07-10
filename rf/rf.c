#include <stdio.h>
#include <stdlib.h> // For exit()

int main() {
  FILE *filePointer;
  int ch;

  filePointer = fopen("ttt.txt", "r");

  while ((ch = fgetc(filePointer)) != EOF) {
      printf("%c", ch);
  }

  fclose(filePointer);
  return EXIT_SUCCESS;
}

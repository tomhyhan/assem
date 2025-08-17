#include <stdio.h>

int main() {
  long int x[3];
  int i;
  for (i=1; i < 3; i++) {
    x[0] += x[i];
  }
  return 1;
}
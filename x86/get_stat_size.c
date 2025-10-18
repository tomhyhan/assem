#include <stdio.h>
#include <sys/stat.h>

int main () {
  size_t size = sizeof(struct stat);

  printf("size: %zu\n", size);
  return 0;
}

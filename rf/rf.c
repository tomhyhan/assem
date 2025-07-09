#include <stdio.h>
#include <stdlib.h> // For exit()

int main() {
    FILE *filePointer;
    char buffer[64]; // Buffer to store each line

    filePointer = fopen("text.txt", "r");

    if (filePointer == NULL) {
        perror("Error opening file");
        return 1;
    }

    printf("Reading file line by line:\n");
    while (fgets(buffer, sizeof(buffer), filePointer) != NULL) {
        printf("%s", buffer);
    }

    fclose(filePointer);
    return 0;
}

#include <stdio.h>
#include <stdlib.h>

int main(void) {
    FILE *fp;
    int c;
    /*
     * The filename MUST be in uppercase in the C code.
     * The actual file on your host computer can be lowercase.
     * The '0:' prefix specifies the drive number, which is optional
     * but can sometimes help. VICE will intercept this call.
     */
    char filename[] = "mytext.txt";

    // Open the file for reading ("r")
    fp = fopen(filename, "r");

    // Check if the file was opened successfully
    if (fp == NULL) {
        printf("Error: Could not open file.\n");
        // In a real-world C64 program, you might check for specific
        // KERNAL error codes here.
        exit(EXIT_FAILURE);
    }

    printf("Successfully opened %s\n\n", filename);

    // Read and print the file character by character
    while ((c = fgetc(fp)) != EOF) {
        putchar(c); // Using putchar is slightly more efficient
    }

    // Close the file
    fclose(fp);

    printf("\n\n--- End of file ---\n");

    return EXIT_SUCCESS;
}
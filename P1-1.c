/*
This program loads 2500 8-bit pixels (as 625 words of 4 pixels each)into a
linear array of words, overlaid with an alternate representation of bytes,
either of which can be used for the solution.

Add code to find the length of the contour around the white (0xFF) pixels,
as well as the pixel index (0-2499) of the upper-left and lower-right 
bounding box of the white region. All calculations are relative to the
outermost WHITE pixel of the region, NOT the first black pixel outside the
region. In addition, each white boundary pixel must be changed to color 0xAA.
*/

#include <stdio.h>
#include <stdlib.h>

#define DEBUG 0

#define PixelArraySize (50 * 50)
#define WordArraySize (PixelArraySize / 4) 

int Load_Mem(char *InputFileName, int wPixels[]);
int Load_N_Values(FILE *FP, int N, int PixelArray[]);
void Display_Pixels(unsigned char* pp);

int main(int argc, char *argv[]) {
  int	WordArray[WordArraySize];
  /* The next line declares a pointer that points to the array, but
     treats it as a pixel array. You can thus refer to pixel(i,j) as
     PixelArray[50*i + j] */
  unsigned char* PixelArray= (unsigned char*)WordArray;
  int	Length, UpperLeft, LowerRight;

  if (argc != 2) {
    printf("usage: %s valuefile\n", argv[0]);
    exit(1);
  }
  Length = Load_Mem(argv[1], WordArray);
  if (Length != WordArraySize) {
     printf("valuefile does not contain valid data.\n");
     exit(1);
  }
  if (DEBUG){
     printf("Sample debugging print statement.\n");
  }

  /* my thought process for this code
  
  simple -> go through every element of the array and check if they are boundary pixels, change and store left most pixel
  
  more optimal -> start in top left, find boundary, then start at bottom right and find boundary, then only search throughout box

  i'm going to start with more simple implementation and then update to more optimal
  
  */
  
  Length = 0;
  int i, j;
  int upper = 50;
  int lower = 0;
  int left = 50;
  int right = 0;
  for (j = 0; j < 50; j++) { // iterate through columns 
    for (i = 0; i < 50; i++) { // iterate through rows
        unsigned char pixel = PixelArray[50*i + j];
        int address = 50*i + j;
        if (pixel == 0xFF) { // check if pixel is white
          // calculate the address of all orthogonal pixels
          int pixel_above = ((i-1)*50 + j);
          int pixel_down = ((i+1)*50 + j);
          int pixel_left = (50*i + (j-1));
          int pixel_right = (50*i + (j+1));
          if (i == 0 || j == 49 || i == 49 || j == 0 ||
            PixelArray[pixel_above] == 0 || PixelArray[pixel_down] == 0 || 
            PixelArray[pixel_left] == 0 || PixelArray[pixel_right] == 0) { // check if boundary pixel
            Length++;
            PixelArray[address] = 0xAA;
            // check if larger/least than stored largest/least i, j
            if (i < upper) {
              upper = i;
            }
            if (i > lower) {
              lower = i;
            }
            if (j < left) {
              left = j;
            }
            if (j > right) {
              right = j;
            }
          }
        }
    }
  }

  UpperLeft = 50 * upper + left; // calc upper left
  LowerRight = 50 * lower + right; // calc upper right
  
  
  if (DEBUG){
    Display_Pixels(PixelArray);  // Prints pixels as asterisks
  }
  

  printf("The contour values are %d:%d:%d (length:upperleft:lowerright)\n", Length, UpperLeft, LowerRight);
  exit(0);
}

/* This routine loads in pairs of integers of the form "Addr: Value"
from a named file in the local directory. Each pair is delimited by a
newline. Addr is discarded. Value is a 4-pixel value. The first 625 
Values are placed in the passed integer array wPixels. The file may 
contain some additional irrelevant values which are discarded. 
The number of input integers is returned, and should be 625. */

int Load_Mem(char *InputFileName, int wordPixels[]) {
  int	Nc;
   FILE	*FP;

   FP = fopen(InputFileName, "r");
   if (FP == NULL) {
      printf("%s could not be opened; check the filename\n", InputFileName);
      return 0;
   } else {
     Nc = Load_N_Values(FP, WordArraySize, wordPixels);
     fclose(FP);
     return Nc;
   }
}

int Load_N_Values(FILE *FP, int N, int Array[]){
  int i, NumVals, Addr, Value;
  for (i = 0; i < N; i++){
    NumVals = fscanf(FP, "%d: %d", &Addr, &Value);
    if (NumVals == 2)
      Array[i] = Value;
    else 
      return(i);
  }
  return(N);
}

/* This routine prints the pixel array as 50 rows of 50 asterisks.
Black pixels will be gray, white pixels will be white, and any
pixels set to 0xAA by your program (contour pixels) will be blue. 
Only one input is needed -- a pointer to the base of your pixel
array.  */

void Display_Pixels(unsigned char* pp) {
  for (int i=0; i<50; i++) {
    for (int j=0; j<50; j++) {
      switch (pp[i * 50 + j]){
        case 0: 
          printf("\e[1;30m");
          break;
        case 0xAA: 
          printf("\e[1;34m");
          break;
        case 0xFF: 
          printf("\e[1;37m");
          break;
      }
      printf("*\e[1;37m");
    }
    printf("\e[1;37m\n");
  }
  return;
}

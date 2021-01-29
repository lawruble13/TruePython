#ifndef COLOR_PRINTF_H
#define COLOR_PRINTF_H
#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

typedef union {
  uint32_t true_color;
  uint8_t ext_color;
  uint8_t orig_color;
} ColorData;

typedef enum {
  TRUECOLOR,
  EXTCOLOR,
  ORIGCOLOR
} ColorMode;

typedef struct {
  ColorMode fgmode;
  ColorData fgdata;
  ColorMode bgmode;
  ColorData bgdata;
} Color;

int cprintf(Color color, const char* format, ...);
int cfprintf(Color color, FILE* stream, const char* format, ...);
int csprintf(Color color, char* str, const char* format, ...);

#endif // COLOR_PRINTF_H

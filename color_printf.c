#include "color_printf.h"

int compute_ansi_color(ColorMode mode, ColorData data, char* outbuf){
  switch(mode){
    case ORIGCOLOR:
      return sprintf(outbuf, "\x1b[%d;3%dm", data.orig_color>>3, data.orig_color%0x07);
    case EXTCOLOR:
      return sprintf(outbuf, "\x1b[38;5;%dm", data.ext_color);
    case TRUECOLOR:
      return sprintf(outbuf, "\x1b[38;2;%d;%d;%dm",
                  data.true_color>>16,
                  (data.true_color>>8)&0xff,
                  data.true_color&0xff);
  }
  return 0;
}

void calculate_cformat(Color color, const char* format, char** outptr){
  char* fg_buf = calloc(20, sizeof(char));
  size_t fg_len = 0;
  fg_len = compute_ansi_color(color.fgmode, color.fgdata, fg_buf);

  char* bg_buf = calloc(19, sizeof(char));
  size_t bg_len = 0;
  bg_len = compute_ansi_color(color.bgmode, color.bgdata, bg_buf);

  *outptr = calloc(fg_len+bg_len+strlen(format)+1, sizeof(char));
  sprintf(*outptr, "%s%s%s\x1b[39;49m",fg_buf,bg_buf, format);
  free(fg_buf);
  free(bg_buf);
}

int cprintf(Color color, const char* format, ...){
  va_list args;
  va_start(args, format);
  char* cformat;
  calculate_cformat(color, format, &cformat);

  int val = vprintf(cformat, args);
  free(cformat);
  va_end(args);
  return val;
}

int cfprintf(Color color, FILE* stream, const char* format, ...){
  va_list args;
  va_start(args, format);
  char* cformat;
  calculate_cformat(color, format, &cformat);

  int val = vfprintf(stream, cformat, args);
  free(cformat);
  va_end(args);
  return val;
}

int csprintf(Color color, char* str, const char* format, ...){
  va_list args;
  va_start(args, format);
  char* cformat;
  calculate_cformat(color, format, &cformat);

  int val = vsprintf(str, cformat, args);
  free(cformat);
  va_end(args);
  return val;
}

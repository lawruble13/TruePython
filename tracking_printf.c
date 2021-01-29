#include "tracking_printf.h"

char last_printed = '\n';

int remove_redundant_newlines(const char* format, va_list* args, char** buf){
  va_list args_copy;
  va_copy(args_copy, *args);

  size_t bufsz = vsnprintf(NULL, 0, format, *args);
  if (bufsz <= 0){
    return (int) bufsz;
  }
  *buf = calloc(bufsz+1, sizeof(char));

  vsnprintf(*buf, bufsz+1, format, args_copy);
  va_end(args_copy);
  size_t printed = 0;
  for (char* current = *buf; *current; current++){
    if (*current == '\r') continue;
    if(last_printed != '\n' || *current != '\n'){
      *((*buf)+printed++) = *current;
    }
    last_printed = *current;
  }
  *((*buf)+printed) = '\0';
  return (int) bufsz;
}

int tprintf(const char* format, ...){
  va_list args;
  va_start(args, format);
  char* buf;
  remove_redundant_newlines(format, &args, &buf);
  int val = printf("%s", buf);
  free(buf);
  va_end(args);
  return val;
}

int tfprintf(FILE* stream, const char* format, ...){
  va_list args;
  va_start(args, format);
  char* buf;
  remove_redundant_newlines(format, &args, &buf);
  int val = fprintf(stream, "%s", buf);
  free(buf);
  va_end(args);
  return val;
}

int tsprintf(char* str, const char* format, ...){
  va_list args;
  va_start(args, format);
  char* buf;
  remove_redundant_newlines(format, &args, &buf);
  int val = sprintf(str, "%s", buf);
  free(buf);
  va_end(args);
  return val;
}

int tsnprintf(char* str, size_t n, char* format, ...){
  va_list args;
  va_start(args, format);
  char* buf;
  remove_redundant_newlines(format, &args, &buf);
  int val = snprintf(str, n, "%s", buf);
  free(buf);
  va_end(args);
  return val;
}

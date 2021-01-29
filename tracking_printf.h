#ifndef TRACKING_PRINTF_H
#define TRACKING_PRINTF_H
#include <stdio.h>
#include <stdbool.h>
#include <stdarg.h>
#include <stdlib.h>

int tprintf(const char* format, ...);
int tfprintf(FILE* stream, const char* format, ...);
int tsprintf(char* str, const char* format, ...);
int tsnprintf(char* str, size_t n, char* format, ...);

bool printed_this_line();

#endif // TRACKING_PRINTF_H

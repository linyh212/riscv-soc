#ifndef _KPRINTF_H_
#define _KPRINTF_H_

#include <stdarg.h>

int put_char(char c);
int put_str(const char *str);
void put_hex(unsigned int h);
void kprintf(const char* s, ...);

#endif
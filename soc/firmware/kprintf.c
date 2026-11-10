#include "kprintf.h"
#include "util.h"
#include "soc_reg.h"

int put_char(char c)
{
    DEV_WRITE(CTRL_BASE + CTRL_OUT, (unsigned char)c);
    return c;
}

int put_str(const char *str)
{
    while (*str)
        put_char(*str++);
    return 0;
}

void put_hex(unsigned int h)
{
    int cur_digit;
    for (int i = 0; i < 8; i++)
    {
        cur_digit = (h >> 28) & 0xF;
        if (cur_digit < 10)
            put_char('0' + cur_digit);
        else
            put_char('A' - 10 + cur_digit);
        h <<= 4;
    }
}

static void _kprintf(const char *s, va_list vl)
{
    int format = 0;
    int longarg = 0;
    unsigned char out;
    for (; *s; s++)
    {
        if (format)
        {
            switch (*s)
            {
            case 'l':
            {
                longarg = 1;
                break;
            }
            case 'p':
            {
                longarg = 1;
                put_str("0x");
            }
            case 'x':
            {
                long num = longarg ? va_arg(vl, long) : va_arg(vl, int);
                int hexdigits = 2 * (longarg ? sizeof(long) : sizeof(int)) - 1;
                for (int i = hexdigits; i >= 0; i--)
                {
                    int d = (num >> (4 * i)) & 0xF;
                    out = (d < 10 ? '0' + d : 'a' + d - 10);
                    put_char(out);
                }
                longarg = 0;
                format = 0;
                break;
            }
            case 'd':
            {
                long num = longarg ? va_arg(vl, long) : va_arg(vl, int);
                static const unsigned long decimal_power[10] = {1000000000UL, 100000000UL, 10000000UL, 1000000UL, 100000UL, 10000UL, 1000UL, 100UL, 10UL, 1UL};
                unsigned long magnitude = (unsigned long)num;
                if (num < 0)
                {
                    put_char('-');
                    magnitude = 0UL - magnitude;
                }
                long digits = 0;
                for (int i = 0; i < 10; i++)
                {
                    long p = (long)decimal_power[i];
                    int digit = 0;
                    while (magnitude >= (unsigned long)p)
                    {
                        magnitude -= (unsigned long)p;
                        digit++;
                    }
                    if (digit != 0 || digits != 0 || i == 9)
                    {
                        out = '0' + digit;
                        put_char(out);
                        digits = 1;
                    }
                }
                longarg = 0;
                format = 0;
                break;
            }
            case 's':
            {
                const char *s2 = va_arg(vl, const char *);
                while (*s2)
                {
                    put_char(*s2);
                    s2++;
                }
                longarg = 0;
                format = 0;
                break;
            }
            case 'c':
            {
                out = (char)va_arg(vl, int);
                put_char(out);
                longarg = 0;
                format = 0;
                break;
            }
            default:
                break;
            }
        }
        else if (*s == '%')
        {
            format = 1;
        }
        else
        {
            put_char(*s);
        }
    }
}

void kprintf(const char *s, ...)
{
    va_list vl;
    va_start(vl, s);
    _kprintf(s, vl);
    va_end(vl);
}

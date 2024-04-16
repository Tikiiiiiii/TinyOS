#ifndef __LIB_STRING_H
#define __LIB_STRING_H

#include "stdint.h"

/*将dst_起始的size个字节置为value*/
 void memset(void *dst_, uint8_t value, uint32_t size);

 /*将src_起始的size个字节复制到 dst_ */
 void memcpy(void *dst_, const void *src, uint32_t size);
 /*连续比较以地址a_和地址b_开头的size个字节.
    相等则返回 0, a>b return 1, a<b return -1;*/
int memcmp(const void *a_, const void *b_, uint32_t size);

/*src_ 复制到 dst_*/
char *strcpy(char *dst_, const char *src_);

/*返回字符串长度*/
uint32_t strlen(const char *str);
/*比较两个字符串，若a_中的字符大于b_中的字符调用1，相等返回0，否则返回-1*/
int8_t strcmp(const char *a, const char *b);

/*左到右找str中首次出现的 ch 的地址*/
char *strchr(const char *str, const uint8_t ch);

/*从后往前找字符串str中首次出现的ch的地址*/
char *strrchr(const char *str, const uint8_t ch);

/*将字符串 src 拼接到dst_后,返回拼接的字符串地址*/
char *strcat(char *dst_, const char *str_);

/*在字符串str中查找字符ch出现的次数*/
uint32_t strchrs(const char *str, uint8_t ch);

#endif /*__LIB_STRING_H*/

#include "string.h"
#include "global.h"
#include "debug.h"
#include <stddef.h>
/*将dst_起始的size个字节置为value*/
 void memset(void *dst_, uint8_t value, uint32_t size)
 {
    ASSERT(dst_ != NULL);
    uint8_t *dst = (uint8_t*)dst_;
    while(size-- > 0){
        *dst++ = value;
    }
    return;
 }

 /*将src_起始的size个字节复制到 dst_ */
 void memcpy(void *dst_, const void *src_, uint32_t size){
    ASSERT(dst_ != NULL && src_ != NULL);
    uint8_t *dst = dst_;
    const uint8_t *src = src_;
    while(size-- > 0){
        *dst++ = *src++;
    }
 }
 /*连续比较以地址a_和地址b_开头的size个字节.
    相等则返回 0, a>b return 1, a<b return -1;*/
int memcmp(const void *a_, const void *b_, uint32_t size)
{
    const char *a = a_;
    const char *b = b_;
    ASSERT(a != NULL || b != NULL);
    while(size-- > 0){
        if(*a != *b){
            return (*a > *b) ? 1: -1;
        }
        ++a;
        ++b;
    }
    return 0;
}

/*src_ 复制到 dst_*/
char *strcpy(char *dst_, const char *src_)
{
    ASSERT(dst_ != NULL && src_ != NULL);
    char *r = dst_;
    while((*dst_ ++ = *src_ ++));
    return r;
}

/*返回字符串长度*/
uint32_t strlen(const char *str){
    ASSERT(str != NULL);
    const char *p = str;
    while(*p++);
    return (p - str - 1);
}
/*比较两个字符串，若a_中的字符大于b_中的字符调用1，相等返回0，否则返回-1*/
int8_t strcmp(const char *a, const char *b)
{
    ASSERT(a != NULL && b != NULL);
    while(*a != 0 && *a == *b){
        ++a;
        ++b;
    }
    //if(*a < *b) return -1;
    //if(*a > *b) return 1; else return 0;
    return (*a < *b) ? -1 : (*a > *b);
}

/*左到右找str中首次出现的 ch 的地址*/
char *strchr(const char *str, const uint8_t ch)
{
    ASSERT(str != NULL);
    while(*str != 0){
        if(*str == ch){
            return (char *)str;//需要强制转化为返回值类型。
        }
        ++str;
    }
    return NULL;
}

/*从后往前找字符串str中首次出现的ch的地址*/
char *strrchr(const char *str, const uint8_t ch)
{
    ASSERT(str != NULL);
    const char *last_char = NULL;
    while(*str != 0){
        if(*str == ch){
            last_char = str;
        }
        ++str;

    }
    return (char *)last_char;
}

/*将字符串 src 拼接到dst_后,返回拼接的字符串地址*/
char *strcat(char *dst_, const char *src_)
{
    ASSERT(dst_ != NULL && src_ != NULL);
    char *str = dst_;
    while(*str++);
    --str;
    while((*str++ = *src_++));
    return dst_;
}

/*在字符串str中查找字符ch出现的次数*/
uint32_t strchrs(const char *str, uint8_t ch){
    ASSERT(str != NULL);
    uint32_t ch_cnt = 0;
    const char *p = str;
    while(*p != 0){
        if(*p == ch){
            ++ch_cnt;
        }
        ++p;
    }
    return ch_cnt;
}

#include "bitmap.h"
#include "stdint.h"
#include "string.h"
#include "print.h"
#include "interrupt.h"
#include "debug.h"

/*初始化 btmp 位图*/
void bitmap_init(struct bitmap *btmp)
{
    memset(btmp->bits, 0, btmp->btmp_bytes_len);
}

bool bitmap_scan_test(struct bitmap *btmp, uint32_t bit_idx)
{
    uint32_t byte_idx = bit_idx / 8;//向下取整用于数组索引。
    uint32_t bit_odd = bit_idx % 8; //取余用索引数组内的位
    return (btmp->bits[byte_idx] & (BITMAP_MASK << bit_odd));
}

int bitmap_scan(struct bitmap *btmp, uint32_t cnt)
{
    uint32_t idx_byte = 0;
    /*先字节比较*/
    while((0xff == btmp->bits[idx_byte]) && (idx_byte < btmp->btmp_bytes_len)){
        //该字节无空位，去下一个字节
        ++idx_byte;
    }
    ASSERT(idx_byte < btmp->btmp_bytes_len);
    if(idx_byte == btmp->btmp_bytes_len){ //找不到可用空间
        return -1;
    }

    //某字节有空位，则依次查找
    int idx_bit = 0;
    while((uint8_t)(BITMAP_MASK << idx_bit & btmp->bits [idx_byte])){
        ++idx_bit;
    }

    int bit_idx_start = idx_byte * 8 + idx_bit;
    if(cnt == 1){
        return bit_idx_start;
    }
    uint32_t bit_left = (btmp->btmp_bytes_len * 8 - bit_idx_start);
    //记录还有多少位可以判断
    uint32_t next_bit = bit_idx_start + 1;
    uint32_t count = 1;

    bit_idx_start = -1;
    while (bit_left -- > 0){
        if(!(bitmap_scan_test(btmp, next_bit))){
            count++;
        }else{
            count = 0;
        }
        if(count == cnt){
            bit_idx_start = next_bit - cnt + 1;
            break;
        }
        next_bit++;
    }
    return bit_idx_start;
}
/*将位图bit_idx设置为value*/
void bitmap_set(struct bitmap *btmp, uint32_t bit_idx, int8_t value)
{
    ASSERT((value == 0) || (value == 1));
    uint32_t byte_idx = bit_idx / 8;
    uint32_t bit_odd = bit_idx % 8;

    if(value){
        btmp->bits[byte_idx] != (BITMAP_MASK << bit_odd);
    }else{
        btmp->bits[byte_idx] &= (BITMAP_MASK << bit_odd);
    }
}
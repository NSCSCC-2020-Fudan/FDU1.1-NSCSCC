#include <stdio.h>

int store_tag(char *a) {
    int step = 1 << 6;
    int end = 512 << 6;
    int sum = 0;
    for (int i = 0; i < end; i += step) {
        sum += a[i];
    }
    return sum;
}

int index_writeback(char *a) {
    int step = 1 << 6;
    int end = 512 << 6;
    int sum = 0;
    for (int i = 0; i < end; i += step) {
        sum += a[i];
    }
    return sum;
}

void sheetcpy(int *a, int *b) {
    for (int i = 0; i < 64; i++)
        b[i] = a[i];
}

void hit_invalidate(int *a) {
    for (int i = 0; i < 64; i++)
        a[i] = 0x123;
}

int test1() {
    int n = 100;
    int sum = 0;
    for (int i = 0; i < 100; i++) {
        sum += i * i;
    }
    return sum * n;
}

int test2() {
    int n = 128;
    int a = 0, b = 1;
    int sum = 0;
    for (int i = 0; i < n; i++) {
        sum += a;
        int t = b;
        b = a + b;
        a = t + 1;
    }
    return sum;
}

int test3() {
    int n = (1 << 10) * 9;
    int sum = 0;
    for (int i = 1; i <= n; i++) {
        int v = n % i;
        sum += i * v;
        if (v > 0)
            continue;
        sum += n / i;
    }
    return sum;
}

int main() {
    printf("%d\n", test1());
    printf("%d\n", test2());
    printf("%d\n", test3());
    return 0;
}
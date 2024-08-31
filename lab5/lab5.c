int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall write code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n){
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code){
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void _start(){
  int ret_code = main();
  exit(ret_code);
}

#define STDIN_FD  0
#define STDOUT_FD 1

// 0b11111, 0b1111111, 0b111111111, 0b1111, 0b1111111
int masks[5] = {31, 127, 511, 15, 127};

// Quantidade de bits a serem "shiftados".
int shifts[5] = {0, 5, 12, 21, 25};

int atoi(char *array){
    int val = 0;

    for (int i = 1; i <= 4; i++){
        val *= 10;
        val += (array[i] - '0');
    }

    if (array[0] == '-')
        return -val;
    return val;   
}

int getBit(int val, int i){
  return (val & masks[i]);
}

void pack(int input, int start_bit, int *val){
  input <<= shifts[start_bit];
  (*val) = (*val) | input; 
}

void hex_code(int val){
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;
    
    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(1, hex, 11);
}

int main(){

    int val = 0;
    char str[30];
    /* Read up to 30 bytes from the standard input into the str buffer */
    int n = read(STDIN_FD, str, 30);

    for (int i = 0; i <= 4; i++){
        char temp[5];
        for (int j = 0; j <= 4; j++)
            temp[j] = str[j + (i*6)];
        int maskval = getBit(atoi(temp), i);
        pack(maskval, i, &val);
    }
    hex_code(val);

    return 0;
}
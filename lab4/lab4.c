int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall write code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return valor to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
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

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}

#define STDIN_FD  0
#define STDOUT_FD 1

char in_buffer[20];
char out_buffer[35], out_buffer_bin[35], out_buffer_hex[35];

// Confere se é decimal(1) ou hexadecimal(0)
int checa_tipo(){
  if (in_buffer[1] == 'x')
    return 0;
  else
    return 1;
}

// Converte array para o seu valor em int.
unsigned int atoi_dec(){

  unsigned int num = 0;
  int i = 0;
  int eh_negativo = 0;

  // Verifica se o número é negativo
  if (in_buffer[0] == '-') {
      eh_negativo = 1;
      i = 1;
  }

  // Loop para converter os dígitos da string para um inteiro
  while (in_buffer[i] != '\0'){
      num = num * 10 + (in_buffer[i] - '0');
      i++;
  }

  // Se for negativo, converte para o valor absoluto
  if (eh_negativo)
      num = -num;

  return num;
}

// Converte array hex para o seu valor em int.
unsigned int atoi_hex(){

  unsigned int num = 0;
  int i = 0;

  // Loop para converter os dígitos da string para um inteiro
  while (in_buffer[i] != '\0')
    if (in_buffer[i] >= '0' && in_buffer <= '9')
      num = num * 16 + (in_buffer[i++] - '0');
    else
      num = num * 16 + (in_buffer[i++] - 'a' + 10);

  return num;
}

void complemento_de_dois(){
  for (int i = 0; i < 35 || out_buffer_bin[i] != '\n'; i++)
    if (out_buffer_bin[i] == '0')
      out_buffer_bin[i] = '1';
    else
      out_buffer[i] = '0';
}

void dec_to_bin(unsigned int valor) {
  char aux[33];
  int resto = 0, i = 0;

  out_buffer_bin[0] = '0';
  out_buffer_bin[1] = 'b';

  if (valor == 0 || valor == 1) {
    out_buffer_bin[3] = valor + '0';
    out_buffer_bin[4] = '\n';
  }

  while(valor != 0) {
    resto = valor % 2;
    aux[i++] = resto + '0';
    valor /= 2;
  }

  // Inverte array auxiliar
  for (int j = i; j >= 0; j--){
    out_buffer_bin[i - j + 2] = aux[j];
  }

  out_buffer_bin[i + 2] = '\n';
}

void bin_to_hex() {
  int j = 2;

  out_buffer_hex[0] = '0';
  out_buffer_hex[1] = 'x';

  for (int i = 2; i < 34; i += 4) {
    int x = 0;
    x += (out_buffer_bin[i]) * 8;
    x += (out_buffer_bin[i + 1]) * 4;
    x += (out_buffer_bin[i + 2]) * 2;
    x += (out_buffer_bin[i + 3]) * 1;

    if (x >= 10)
      out_buffer_hex[j++] = x + 'a' - 10;
    else
      out_buffer_hex[j++] = '0' + x;
  }
  out_buffer_hex[j] = '\n';
}

void bin_to_oct() {
  int j = 2;

  out_buffer[0] = '0';
  out_buffer[1] = 'o';

  for (int i = 2; i < 34; i += 4) {
    int x = 0;
    x += (out_buffer_bin[i]) * 4;
    x += (out_buffer_bin[i + 1]) * 2;
    x += (out_buffer_bin[i + 2]) * 1;
    out_buffer[j++] = '0' + x;
  }
  out_buffer[j] = '\n';
}

void troca_endianness() {
  int pos = 0, j = 2;
  char aux[35];

  aux[0] = '0';
  aux[1] = 'x';
  for (int i = 2; i < 10; i++) {
    aux[i] = '0';
  }
  aux[10] = '\n';

  for (int i = 2; out_buffer[i] != '\n'; i++)
    pos++;

  for (int i = 10 - pos; out_buffer[j] != '\n'; i++)
    aux[i] = out_buffer[j++];

  for (int i = 2; aux[i] != '\n'; i += 2) {
    out_buffer[10 - i] = aux[i];
    out_buffer[11 - i] = aux[i + 1];
  }

  out_buffer[10] = '\n';
  for (int i = 0; i < 20; i++){
    in_buffer[i] = out_buffer[i];
  }
  unsigned int valor = atoi_hex();
  
}

void decimais(){

  int valor = atoi_dec();

  if (in_buffer[0] == '-'){
    dec_to_bin(valor - 1);
    complemento_de_dois();
    write(STDOUT_FD, (void*) out_buffer_bin, 35);  // Bin
    write(STDOUT_FD, (void*) in_buffer, 20);  // Dec
    bin_to_hex();
    troca_endianness();
    write(STDOUT_FD, (void*) out_buffer, 35);  // Dec com endian swap
    write(STDOUT_FD, (void*) out_buffer_hex, 35);  // Hex
    bin_to_oct();
    write(STDOUT_FD, (void*) out_buffer, 35); // Oct
  }
  else{
    dec_to_bin(valor);
    write(STDOUT_FD, (void*) out_buffer_bin, 35); // Bin
    write(STDOUT_FD, (void*) in_buffer, 20);  // Dec
    bin_to_hex();
    troca_endianness();
    write(STDOUT_FD, (void*) out_buffer, 35);  // Dec com endian swap
    write(STDOUT_FD, (void*) out_buffer_hex, 35); // Hex
    bin_to_oct();
    write(STDOUT_FD, (void*) out_buffer, 35); // Oct
  }
}

void hexadecimais(){
  int valor = atoi_hex();

  if (in_buffer[0] == '-'){
    dec_to_bin(valor - 1);
    complemento_de_dois();
    write(STDOUT_FD, (void*) out_buffer_bin, 35);  // Bin
    write(STDOUT_FD, (void*) valor, 20);  // Dec
    bin_to_hex();
    troca_endianness();
    write(STDOUT_FD, (void*) out_buffer, 35);  // Dec com endian swap
    write(STDOUT_FD, (void*) in_buffer, 35);  // Hex
    bin_to_oct();
    write(STDOUT_FD, (void*) out_buffer, 35); // Oct
  }
  else{
    dec_to_bin(valor);
    write(STDOUT_FD, (void*) out_buffer_bin, 35); // Bin
    write(STDOUT_FD, (void*) valor, 20);  // Dec
    bin_to_hex();
    troca_endianness();
    write(STDOUT_FD, (void*) out_buffer, 35);  // Dec com endian swap
    write(STDOUT_FD, (void*) in_buffer, 35); // Hex
    bin_to_oct();
    write(STDOUT_FD, (void*) out_buffer, 35); // Oct
  }
}

int main()
{
  //char str[20];
  /* Read up to 20 bytes from the standard input into the str buffer */
  //int n = read(STDIN_FD, str, 20);
  if (checa_tipo)
    decimais();
  else
    hexadecimais();

  /* Write n bytes from the str buffer to the standard output */
  //write(STDOUT_FD, str, n);
  return 0;
}
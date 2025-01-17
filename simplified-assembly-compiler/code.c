/**
 * @autor: https://github.com/bruno-said
 */

/**
 * Bibliotecas
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

/**
 * @description: 
 *  Verifica se uma string é igual de outra.
 * @param:
 *  strA: Primeira string a ser avaliada.
 *  strB: Segunda string a ser avaliada.
 */
uint8_t isEqual ( char * strA, char * strB )
{
  uint8_t lenA = strlen( strA ), lenB = strlen( strB );

  if ( lenA != lenB ) return 0;
  
  uint8_t i;
  for ( i = 0; i < lenA; i++ )
    if ( strA[ i ] != strB[ i ] )
      return 0;

  return 1;
}

/**
 * @description: 
 *  Função para converter uma string em um byte
 * @parm:
 *  buffer: String para conversão
 *  byte: byte para receber o conversão
 */
void bufferToByte ( uint8_t * buffer, uint8_t * byte )
{
  uint8_t i, len = strlen( buffer );

  *byte = 0;

  for ( i = 0; i < len; i++ )
    if ( buffer[ i ] == '1' )
      ( *byte ) |= ( 1 << ( ( len - 1 ) - i ) );
}

/**
 * @description: 
 *  Realiza a leitura de um parâmetro numérico e grava no arquivo de saída.
 * @parm:
 *  buffer: String para conversão
 *  byte: byte para receber o conversão
 */
uint8_t readAndSaveParam (
  FILE * input,
  FILE * output,
  uint8_t * line, 
  uint8_t * index,
  uint8_t * buffer,
  uint8_t * readByte,
  uint8_t * writeByte,
  char * label )
{
  uint8_t i; // Variável para controle de loop

  for ( i = 0; i < 8; i++) // Lendo parâmetro de entrada para essa instrução
  {
    fread( readByte, sizeof( uint8_t ), 1, input );
    
    if ( '0' <= readByte[ 0 ] && readByte[ 0 ] <= '9' )
    {
      buffer[ ( *index )++ ] = readByte[ 0 ];
    }
    else
    {
      printf( "LINE: %d - ERROR: Instrução '%s' espera um número de 8 bits no formato binário. - CODE: 0b00000001\n", *line, label );
      return 0;
    }
  }

  // Leitura de mais um byte para verificação de erro
  fread( readByte, sizeof( uint8_t ), 1, input );

  if ( readByte[ 0 ] != '\n' )
  {
    printf( "LINE: %d - ERROR: Instrução '%s' espera um número de 8 bits no formato binário. - CODE: 0b00000001\n", *line, label );
    return 0;
  }
  else
  {
    buffer[ ( *index )++ ] = '\0';
  }

  ( *line )++; // Aumentando a contagem de linhas

  bufferToByte( buffer, writeByte ); // Converter a string binaria do buffer para um único byte
  fwrite( writeByte, sizeof( uint8_t ), 1, output ); // Escrevendo o byte no arquivo de saída

  *index = 0; // Limpando variável index para próxima leitura de Buffer
}

typedef struct 
{
  char * label;
  uint8_t binaryCode;
  uint8_t qtdParans;
} Instruction;

int main ( int argc, char ** argv )
{
  FILE * input = fopen( "input.asm", "r" ); // Ponteiro para manipulação do arquivo de entrada
  FILE * output = fopen( "output", "wb" );  // Ponteiro para manipulação do arquivo de saída

  uint8_t line = 1;       // Variável para controle da linha sendo processada atualmente
  uint8_t index = 0;      // Indíce para controle do buffer
  uint8_t buffer[ 100 ];    // Buffer que recebe as linha do arquivo de entrada
  uint8_t readByte[ 1 ];  // Byte para ler do arquivo de entrada
  uint8_t writeByte[ 1 ]; // Byte para escrever no arquivo de saída

  Instruction instructions[] = { 
    { .label = "ADD", .binaryCode = 0b00000000, .qtdParans = 2 }, 
    { .label = "SUB", .binaryCode = 0b00000001, .qtdParans = 2 },
    { .label = "MUL", .binaryCode = 0b00000010, .qtdParans = 2 },
    { .label = "DIV", .binaryCode = 0b00000011, .qtdParans = 2 },
    { .label = "MOD", .binaryCode = 0b00000100, .qtdParans = 2 },
    { .label = "AND", .binaryCode = 0b00000101, .qtdParans = 2 },
    { .label = "OR" , .binaryCode = 0b00000110, .qtdParans = 2 },
    { .label = "XOR", .binaryCode = 0b00000111, .qtdParans = 2 },
    { .label = "NOT", .binaryCode = 0b00001000, .qtdParans = 1 },
    { .label = "GRT", .binaryCode = 0b00001001, .qtdParans = 2 },
//  { .label = ">=" , .binaryCode = 0b00001010, .qtdParans = 2 },
    { .label = "LSS", .binaryCode = 0b00001011, .qtdParans = 2 },
//  { .label = "<=" , .binaryCode = 0b00001100, .qtdParans = 2 },
    { .label = "EQL", .binaryCode = 0b00001101, .qtdParans = 2 },
    { .label = "NEQ", .binaryCode = 0b00001110, .qtdParans = 2 },
    { .label = "MOV", .binaryCode = 0b00001111, .qtdParans = 2 },
    { .label = "SHR", .binaryCode = 0b00010000, .qtdParans = 2 },
    { .label = "SHL", .binaryCode = 0b00010001, .qtdParans = 2 },
    { .label = "LSB", .binaryCode = 0b00010010, .qtdParans = 2 },
    { .label = "MSB", .binaryCode = 0b00010011, .qtdParans = 2 },
    { .label = "IN" , .binaryCode = 0b00010100, .qtdParans = 2 },
    { .label = "OUT", .binaryCode = 0b00010101, .qtdParans = 2 },
    { .label ="HALT", .binaryCode = 0b00010110, .qtdParans = 2 },
  };

  // Enquanto ouver bytes para serem lidos
  while ( fread( readByte, sizeof( uint8_t ), 1, input ) )
  {
    // Se o byte lido for uma quebra de linha
    if ( readByte[ 0 ] == '\n' )
    {
      // Retirar comentários
      if ( index >= 1 && buffer[ 0 ] == '/' && buffer[ 1 ] == '/' )
      {
        index = 0;
        line++;
        continue;
      }

      buffer[ index ] = '\0'; // Adicionando o caractere de fim de string
      index = 0; // Limpando variável index para próxima leitura de Buffer
      
      uint8_t i, j;
      uint8_t isValid = 0;
      uint8_t lenIntructions = sizeof( instructions ) / sizeof( Instruction );
      
      for ( i = 0; i < lenIntructions; i++ )
      {
        if ( isEqual( instructions[ i ].label, buffer ) )
        {
          writeByte[ 0 ] = instructions[ i ].binaryCode; // Escrevermos na saída o byte correspondente a instrução
          fwrite( writeByte, sizeof( uint8_t ), 1, output ); // Escrevendo o byte no arquivo de saída

          for ( j = 0; j < instructions[ i ].qtdParans; j++ )
            if ( readAndSaveParam( input, output, &line, &index, buffer, readByte, writeByte, instructions[ i ].label ) == 0 ) return 0;
        
          isValid = 1;
          break;
        }
      }
      
      if ( isValid == 0 )
      {
        printf( "LINE: %d - ERROR: Comando desconhecido. - CODE: 0b00000000\n", line );
        return 0;
      }
    
      line++; // Chegando ao fim da linha vamos para a próxima
    }
    else // Caso não seja um caractere de quebra de linha
      buffer[ index++ ] = readByte[ 0 ]; // Armazenamos o caractere no buffer
  }

  // Caso no final do arquivo ainda sobre caracteres não processado no buffer
  if ( index > 0 )
  {
    bufferToByte( buffer, writeByte ); // Convertemos a string para byte
    fwrite( writeByte, sizeof( uint8_t ), 1, output ); // Escrevendo o byte no arquivo de saída
  }
  
  fclose( input );  // Liberando ponteiro do arquivo de entrada
  fclose( output ); // Liberando ponteiro do arquivo de saída

  return 0;
}
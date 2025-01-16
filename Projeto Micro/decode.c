#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

/**
 * @description: Função para converter um byte em string
 * @param:
 *  byte: Byte que dever ser convertido
 *  string: String para armazena o byte convertido
 */
void byteToString ( uint8_t * byte, uint8_t * string )
{
  uint8_t i;

  for ( i = 0; i < 8; i++ )
    if ( ( *byte ) & ( 1 << ( 7 - i ) ) )
      string[ i ] = '1';
    else
      string[ i ] = '0';
}

int main ( int argc, char ** argv )
{
  FILE * input = fopen( "output", "rb" ); // Ponteiro para receber o arquivo de entrada

  uint8_t string[ 8 ];   // String para armazenar a converser de byte para string 
  uint8_t readByte[ 1 ]; // Byte para ler dados do arquivo de entrada

  // Enquanto houver bytes para serem lidos
  while( fread( readByte, sizeof( uint8_t ), 1, input ) )
  {
    byteToString( readByte, string ); // Convertendo o byte para string
    printf( "readByte = %d = %s\n", *readByte, string ); // Exibindo informações para debug
  }

  fclose( input ); // Liberando o ponteiro do arquivo de entrada

  return 0;
}
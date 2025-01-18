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
 * Verifica se uma string é igual de outra.
 * @param:
 * strA: Primeira string a ser avaliada.
 * strB: Segunda string a ser avaliada.
 */
uint8_t isEqual(char *strA, char *strB) {
    uint8_t lenA = strlen(strA), lenB = strlen(strB);
    if (lenA != lenB) return 0;
    for (uint8_t i = 0; i < lenA; i++) {
        if (strA[i] != strB[i]) return 0;
    }
    return 1;
}

/**
 * @description:
 * Converte um byte para string binária.
 * @param:
 * byte: Byte a ser convertido.
 * buffer: String para armazenar o binário.
 */
void byteToBinaryString(uint8_t byte, char *buffer) {
    for (int i = 7; i >= 0; i--) {
        buffer[7 - i] = (byte & (1 << i)) ? '1' : '0';
    }
    buffer[8] = '\0';
}

/**
 * @description:
 * Função para converter uma string em um byte.
 * @param:
 * buffer: String para conversão.
 * byte: Byte para receber a conversão.
 */
void bufferToByte(uint8_t *buffer, uint8_t *byte) {
    uint8_t len = strlen(buffer);
    *byte = 0;
    for (uint8_t i = 0; i < len; i++) {
        if (buffer[i] == '1') {
            (*byte) |= (1 << ((len - 1) - i));
        }
    }
}

/**
 * @description:
 * Realiza a leitura de um parâmetro numérico e grava no arquivo de saída.
 * @param:
 * input: Arquivo de entrada.
 * output: Arquivo de saída.
 * line: Linha atual sendo processada.
 * index: Índice para controle do buffer.
 * buffer: Buffer para leitura de dados.
 * readByte: Byte de leitura.
 * writeByte: Byte para escrita.
 * label: Instrução atual.
 */
uint8_t readAndSaveParam (
    FILE *input,
    FILE *output,
    uint8_t *line, 
    uint8_t *index,
    uint8_t *buffer,
    uint8_t *readByte,
    uint8_t *writeByte,
    char *label
) {
    uint8_t i;
    uint8_t isRegister = 0;

    *index = 0;

    // Lê o parâmetro do arquivo
    for (i = 0; i < 2; i++) { // Verifica se o parâmetro é um registrador (2 caracteres, como AX)
        fread(readByte, sizeof(uint8_t), 1, input);
        if (readByte[0] != '\n' && *index < 100) {
            buffer[(*index)++] = readByte[0];
        } else {
            break;
        }
    }

    buffer[*index] = '\0'; // Termina a string

    // Verifica se o parâmetro é um registrador
    for (i = 0; i < lenRegisters; i++) {
        if (isEqual((char *)buffer, registers[i].name)) {
            *writeByte = registers[i].code;
            isRegister = 1;
            break;
        }
    }

    // Se não for registrador, verifica se é um número binário
    if (!isRegister) {
        if (strlen((char *)buffer) != 8 || strspn((char *)buffer, "01") != 8) {
            printf("LINE: %d - ERROR: Operando inválido para '%s'. Use um registrador ou número binário de 8 bits.\n", *line, label);
            return 0;
        }

        bufferToByte(buffer, writeByte); // Converte número binário em byte
    }

    fwrite(writeByte, sizeof(uint8_t), 1, output); // Escreve o operando no arquivo de saída
    return 1;
}

typedef struct {
    char *label;
    uint8_t binaryCode;
    uint8_t qtdParans;
} Instruction;

typedef struct {
    char *name;
    uint8_t code;
} Register;

Register registers[] = {
    { "AX", 0b00000001 },
    { "BX", 0b00000010 },
    { "CX", 0b00000011 },
    { "DX", 0b00000100 }
};

uint8_t lenRegisters = sizeof(registers) / sizeof(Register);


int main(int argc, char **argv) {
    FILE *input = fopen("input.asm", "r");
    FILE *output = fopen("output.txt", "w");

    uint8_t line = 1;
    uint8_t index = 0;
    uint8_t buffer[100];
    uint8_t readByte[1];
    uint8_t writeByte[1];

    Instruction instructions[] = {
        {"ADD", 0b00000000, 2},
        {"SUB", 0b00000001, 2},
        {"MUL", 0b00000010, 2},
        {"DIV", 0b00000011, 2},
        {"MOD", 0b00000100, 2},
        {"AND", 0b00000101, 2},
        {"OR",  0b00000110, 2},
        {"XOR", 0b00000111, 2},
        {"NOT", 0b00010100, 1},
        {"GRT", 0b00001000, 2},
        {"LSS", 0b00001001, 2},
        {"EQL", 0b00001010, 2},
        {"NEQ", 0b00001011, 2},
        {"MOV", 0b00001100, 2},
        {"SHR", 0b00001110, 2},
        {"SHL", 0b00010001, 2},
        {"LSB", 0b00001111, 2},
        {"MSB", 0b00010000, 2},
        {"IN",  0b00010001, 2},
        {"OUT", 0b00010010, 2},
        {"HALT",0b00010011, 0},
        {"JMP", 0b00010101, 1},
        {"RTN", 0b00010110, 0}
    };

    while (fread(readByte, sizeof(uint8_t), 1, input)) {
        if (readByte[0] == '\n') {
            if (index >= 1 && buffer[0] == '/' && buffer[1] == '/') {
                index = 0;
                line++;
                continue;
            }
            buffer[index] = '\0';
            index = 0;

            uint8_t isValid = 0;
            uint8_t lenInstructions = sizeof(instructions) / sizeof(Instruction);

            for (uint8_t i = 0; i < lenInstructions; i++) {
                if (isEqual(instructions[i].label, buffer)) {
                    char binaryString[9];
                    byteToBinaryString(instructions[i].binaryCode, binaryString);
                    fprintf(output, "%s\n", binaryString);

                    for (uint8_t j = 0; j < instructions[i].qtdParans; j++) {
                        if (readAndSaveParam(input, output, &line, &index, buffer, readByte, writeByte, instructions[i].label) == 0) {
                            fclose(input);
                            fclose(output);
                            return 1;
                        }
                    }
                    isValid = 1;
                    break;
                }
            }

            if (isValid == 0) {
                printf("LINE: %d - ERROR: Comando desconhecido.\n", line);
                fclose(input);
                fclose(output);
                return 1;
            }
            line++;
        } else {
            buffer[index++] = readByte[0];
        }
    }

    fclose(input);
    fclose(output);
    return 0;
}

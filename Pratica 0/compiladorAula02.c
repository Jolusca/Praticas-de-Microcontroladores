#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char const *argv[])
{
    FILE *arquivoBinario, *arquivoOriginal;
    char palavra[100], *linha;
    char *result;
    char temp[100];
    int contador = 1;
    FILE *TESTE;

    arquivoOriginal = fopen("as.txt", "rt");
    arquivoBinario = fopen("bin.txt", "wb");
    if (arquivoOriginal == NULL)
{
    printf("Problemas na CRIACAO do arquivo\n");
    return 0;
}

    while(!feof(arquivoOriginal)){
        result = fgets(palavra, 100, arquivoOriginal);
        if (result){  //     Se foi possível ler
	        printf("%s", palavra);
            if(strcmp(palavra, "add")){
                strcpy(temp, "11000");
            }
            else if(strcmp(palavra, "sub")){
                strcpy(temp, "10000");
            }
            else{
                strcpy(temp, palavra);
            }
            //printf("temp= %p\n", &temp);
            fwrite(temp, 100, sizeof(temp), arquivoBinario);
            contador++;
        }
    }
    fclose(arquivoOriginal);
    fclose(arquivoBinario);

    TESTE = fopen("bin.txt", "rb");
    while(!feof(TESTE)){
        result = fgets(palavra, 100, TESTE);
        if (result){  //     Se foi possível ler
	        printf("\n%s",palavra);
    }
    }
    fclose(TESTE);
    return 0;
}

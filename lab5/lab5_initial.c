#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>


void progEnd(bool task_status, const char* img) {
    printf("\nProgram completion\n");
    if (task_status == true) {
        printf("The image \"%s\" processsed correctly\n", img);
    } else {
        printf("Programm status: Failed\n");
    }

    return;
}

void img_averaging_asm(unsigned char* img_data, int width, int height);

// provides calculation stricktly for 3 channels
void img_averaging_c(unsigned char* img_data, int width, int height) {
    unsigned int pixel_num = width * height;
    size_t avg, red, blue, green;
    for (size_t i = 0; i < pixel_num; i++) {
        red = img_data[i * 3 + 0];
        green = img_data[i * 3 + 1];
        blue = img_data[i * 3 + 2];

        avg = (red + green + blue) / 3;

        img_data[i * 3 + 0] = avg;
        img_data[i * 3 + 1] = avg;
        img_data[i * 3 + 2] = avg;
    }
    return;
}


int main(int argc, char *argv[]) {
    bool task_status = false;
    char* img_in;
    char* img_out;

    if (argc < 3) {
        printf("Missing arguments\n");
        progEnd(task_status, img_in);
        return 0;
    }

    img_in = argv[1]; // first argument of command line is *.jpg to be processed
    img_out = argv[2]; // second argument of command line is *.jpg - recipient

    int width, heigth, channels; // 3 parametrs to define the file we have

    unsigned char* img_data = stbi_load(img_in, &width, &heigth, &channels, 0); // we got simple sequence of pixels (24 bit each)

    if (img_data == NULL) {
        printf("Image loading error: '%s'", stbi_failure_reason());
        progEnd(task_status, img_in);
        return 0;
    }

    printf("Image loaded successfully\n");
    printf("| Width: %d\t| Heigth: %d\t| Channels: %d\t|\n", width, heigth, channels);

    size_t colors_num = width * heigth * channels;
    unsigned char* img_data_copy = calloc(colors_num, 1);
    memcpy(img_data_copy, img_data, colors_num);

    clock_t start, end;
    double cpu_time_sec;

    start = clock();

    img_averaging_asm(img_data, width, heigth);

    end = clock();

    cpu_time_sec = ((double) (end - start)) / CLOCKS_PER_SEC;
    printf("ASM: Algorithm has spent %lf seconds\n", cpu_time_sec);
    
    img_averaging_c(img_data_copy, width, heigth);

    start = clock();
    cpu_time_sec = ((double) (start - end)) / CLOCKS_PER_SEC;
    printf("C: Algorithm has spent %lf seconds\n", cpu_time_sec);


    char* img_out_copy = calloc(strlen(img_out) + 6, 1);
    strcpy(img_out_copy, img_out);
    strcpy(img_out_copy + strlen(img_out), "_copy");	

    int result_asm = stbi_write_jpg(img_out, width, heigth, channels, img_data, 90);
    int result_c = stbi_write_jpg(img_out_copy, width, heigth, channels, img_data, 90);

    task_status = (result_asm != 0 && result_c != 0);

    progEnd(task_status, img_in);
    return 0;
}

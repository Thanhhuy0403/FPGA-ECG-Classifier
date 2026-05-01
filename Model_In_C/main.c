#include "CNN.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define INPUT_SIZE 320
#define OUTPUT_SIZE 5
#define WEIGHTS_SIZE 6457

static int read_weights(const char *path, float weights[WEIGHTS_SIZE]) {
    FILE *f = fopen(path, "r");
    if (!f) {
        return 0;
    }
    for (int i = 0; i < WEIGHTS_SIZE; i++) {
        if (fscanf(f, "%f", &weights[i]) != 1) {
            fclose(f);
            return 0;
        }
    }
    fclose(f);
    return 1;
}

int main(void) {
    clock_t start_time = clock();

    const char *signals_path = "signals.txt";
    const char *labels_path = "labels.txt";
    const char *weights_path = "Float_Weights.txt";

    float weights[WEIGHTS_SIZE];
    if (!read_weights(weights_path, weights)) {
        printf("Failed to read weights from %s\n", weights_path);
        clock_t end_time = clock();
        double elapsed_sec = (double)(end_time - start_time) / CLOCKS_PER_SEC;
        printf("Elapsed time: %.6f s\n", elapsed_sec);
        return 1;
    }

    FILE *fs = fopen(signals_path, "r");
    if (!fs) {
        printf("Failed to open %s\n", signals_path);
        clock_t end_time = clock();
        double elapsed_sec = (double)(end_time - start_time) / CLOCKS_PER_SEC;
        printf("Elapsed time: %.6f s\n", elapsed_sec);
        return 1;
    }

    FILE *fl = fopen(labels_path, "r");
    if (!fl) {
        printf("Failed to open %s\n", labels_path);
        fclose(fs);
        clock_t end_time = clock();
        double elapsed_sec = (double)(end_time - start_time) / CLOCKS_PER_SEC;
        printf("Elapsed time: %.6f s\n", elapsed_sec);
        return 1;
    }

    int total = 0;
    int correct = 0;

    while (1) {
        float input[INPUT_SIZE];
        for (int i = 0; i < INPUT_SIZE; i++) {
            if (fscanf(fs, "%f", &input[i]) != 1) {
                fclose(fs);
                fclose(fl);
                if (total == 0) {
                    printf("No samples read. Check input format.\n");
                } else {
                    float acc = (float)correct * 100.0f / (float)total;
                    printf("Accuracy: %.2f%% (%d/%d)\n", acc, correct, total);
                }
                clock_t end_time = clock();
                double elapsed_sec = (double)(end_time - start_time) / CLOCKS_PER_SEC;
                printf("Elapsed time: %.6f s\n", elapsed_sec);
                return 0;
            }
        }

        int label;
        if (fscanf(fl, "%d", &label) != 1) {
            fclose(fs);
            fclose(fl);
            printf("Labels ended early at sample %d\n", total);
            clock_t end_time = clock();
            double elapsed_sec = (double)(end_time - start_time) / CLOCKS_PER_SEC;
            printf("Elapsed time: %.6f s\n", elapsed_sec);
            return 1;
        }

        float output[OUTPUT_SIZE] = {0};
        CNN(input, output, weights);

        int pred = 0;
        float best = output[0];
        for (int i = 1; i < OUTPUT_SIZE; i++) {
            if (output[i] > best) {
                best = output[i];
                pred = i;
            }
        }

        if (pred == label) {
            correct++;
        }
        total++;
    }

    return 0;
}

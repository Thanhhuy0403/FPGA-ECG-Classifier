// gcc ECG_Embedded_Software.c -o main $(pkg-config --cflags --libs sdl2 SDL2_ttf) -O2 -lm
#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <time.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>

#include "CGRA.h"
#include "FPGA_Driver.c"

#define BILLION 1000000000

// Write channel
#define START_BASE                   (0x0000000)
#define LDM_INPUT_BASE_PHYS          (0x1000000 >> 2) //>> 2) // 4000
#define CRAM_INPUT_BASE_PHYS         (0x2000000 >> 2) //>> 2) // 8000
#define WRAM_INPUT_BASE_PHYS         (0x3000000 >> 2) //>> 2) // C000
#define BRAM_INPUT_BASE_PHYS         (0x4000000 >> 2) //>> 2) // 10000
#define SCALE_INPUT_BASE_PHYS        (0x5000000 >> 2) //>> 2) // 14000

// Read channel
#define DONE_BASE_PHYS               (0x0000000)
#define LDM_OUTPUT_BASE_PHYS         (0x1000000 >> 2) //>> 2) // 4000

#define d 1
#define SEG_LEN 320
#define NumberOfPicture 15009
#define DRAW_ECG 0

// Quantization parameters extracted from model_int8.tflite
#define INPUT_SCALE              0.021843135356903076f
#define INPUT_ZERO_POINT         5
#define FEATURE_SCALE            1.1296360492706299f
#define FEATURE_ZERO_POINT       -128
#define DENSE_W_SCALE            0.0075363884679973125f
#define DENSE_W_ZERO_POINT       0
#define DENSE_B_SCALE            0.0023991165217012167f

// ------- SDL layout -------
#define WIDTH   1000
#define HEIGHT  360
#define TOP_BAR 28
#define BOT_BAR 28
#define PLOT_H  (HEIGHT - TOP_BAR - BOT_BAR)

static inline double clampd(double v, double lo, double hi){
    return v < lo ? lo : (v > hi ? hi : v);
}

static inline int8_t quantize_int8(float x, float scale, int zp){
    int q = (int)lrintf(x / scale) + zp;
    if (q > 127) q = 127;
    if (q < -128) q = -128;
    return (int8_t)q;
}

// ---- Text helpers ----
static void draw_text(SDL_Renderer* ren, TTF_Font* font, const char* msg, int x, int y, SDL_Color col){
    SDL_Surface *surf = TTF_RenderUTF8_Blended(font, msg, col);
    if(!surf) return;
    SDL_Texture *tex = SDL_CreateTextureFromSurface(ren, surf);
    if(tex){
        SDL_Rect r = { x, y, surf->w, surf->h };
        SDL_RenderCopy(ren, tex, NULL, &r);
        SDL_DestroyTexture(tex);
    }
    SDL_FreeSurface(surf);
}

static void draw_text_center(SDL_Renderer* ren, TTF_Font* font, const char* msg, int y, SDL_Color col){
    int w=0, h=0;
    if (TTF_SizeUTF8(font, msg, &w, &h) != 0) return;
    int x = (WIDTH - w)/2;
    draw_text(ren, font, msg, x, y, col);
}
// ---- End text helpers ----

static const char* VN_LABELS[5] = {
    "Bình thường",
    "Ngoại tâm thu trên thất",
    "Ngoại tâm thu thất",
    "Nhịp hợp nhất",
    "Không xác định"
};

static inline double ring_get(const double *buf, int buf_head, int buf_n, int idx){
    return buf[(buf_head + idx) % buf_n];
}

static int8_t ClampInt8(int v){
	if (v > 127) return 127;
	if (v < -128) return -128;
	return (int8_t)v;
}

static int8_t QuantizeToInt8(float x){
	int q = (int)((x >= 0.0f) ? (x + 0.5f) : (x - 0.5f));
	return ClampInt8(q);
}

static int8_t QuantizeByScaleZp(float x, float scale, int zeroPoint){
	if (scale <= 0.0f) return QuantizeToInt8(x);
	float qf = x / scale + (float)zeroPoint;
	int q = (int)((qf >= 0.0f) ? (qf + 0.5f) : (qf - 0.5f));
	return ClampInt8(q);
}

float int8ToFloat(int8_t value, float scale, float zero_point) {
    return scale * ((float)value - zero_point);
}

int main(int argc, char** argv){

    const int PRED_SHOW_AT_SAMPLES = (SEG_LEN * 3) / 4; 

    // CLI paths (optional)
    const char *signals_path = (argc >= 2) ? argv[1] : "signals.txt";
    const char *labels_path  = (argc >= 3) ? argv[2] : "labels.txt";
    const char *font_path    = (argc >= 4) ? argv[3] : "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf";
    int num_pictures_to_process = NumberOfPicture;
    if (argc >= 5) {
        num_pictures_to_process = atoi(argv[4]);
        if (num_pictures_to_process <= 0) {
            num_pictures_to_process = NumberOfPicture;
        }
        if (num_pictures_to_process > NumberOfPicture) {
            printf("Warning: Requested %d pictures but only %d available. Using %d.\n", 
                   num_pictures_to_process, NumberOfPicture, NumberOfPicture);
            num_pictures_to_process = NumberOfPicture;
        }
    }
    
    unsigned char* membase;

    if (cgra_open() == 0) { exit(1); }

    cgra.dma_ctrl = CGRA_info.dma_mmap;
    membase = (unsigned char*)CGRA_info.ddr_mmap;

    FILE *CTX_file = fopen("context.txt", "r");
    if(CTX_file == NULL){ perror("Unable to open context.txt");  return 1;  }
    FILE *WEIGHT_file = fopen("Weight.txt", "r");
    if(WEIGHT_file == NULL) { perror("Unable to open Weight.txt"); return 1; }
    FILE *BIAS_file = fopen("Bias.txt", "r"); if(BIAS_file == NULL) { perror("Unable to open Bias.txt"); return 1; }
    FILE *SCALE_file = fopen("scale_hex_1.txt", "r");
    if(SCALE_file == NULL) { perror("Unable to open scale_hex_1.txt"); return 1; }
    FILE *WRAM_2_file = fopen("WRAM_2_File.txt", "r"); if (WRAM_2_file == NULL) { perror("Unable to open WRAM_2_File.txt"); return 1; }
    FILE *BRAM_2_file = fopen("BRAM_2_File.txt", "r"); if (BRAM_2_file == NULL) { perror("Unable to open BRAM_2_File.txt"); return 1; }

    int i = 0;
    U32 value;
    float value_f;
    float weight_final[160]; //dense
    float bias_final[5]; // dense
    U32 CONTEXT_MEM[42], WEIGHT_MEM[6256], BIAS_MEM[196], SCALE_MEM[196];

    struct timespec start_setup, end_setup;
    unsigned long long time_setup = 0;
    i = 0; while (fscanf(CTX_file, "%8x", &value) == 1) { CONTEXT_MEM[i++] = value; } fclose(CTX_file);
    i = 0; while (fscanf(WEIGHT_file, "%2x", &value) == 1) { WEIGHT_MEM[i++] = (U32)(value & 0xFF); } fclose(WEIGHT_file); 
    i = 0; while (fscanf(BIAS_file, "%4x", &value) == 1) { BIAS_MEM[i++] = (U32)(value & 0xFFFF); } fclose(BIAS_file);
    i = 0; while (fscanf(SCALE_file, "%8x", &value) == 1) { SCALE_MEM[i++] = (U32)(value); } fclose(SCALE_file);

    clock_gettime(CLOCK_REALTIME, &start_setup);
    for(int j=0; j<42; j++) { *(CGRA_info.reg_mmap + CRAM_INPUT_BASE_PHYS + j) = CONTEXT_MEM[j]; }
    for(int j=0; j<6256; j++) { *(CGRA_info.reg_mmap + WRAM_INPUT_BASE_PHYS + j) = WEIGHT_MEM[j]; }
    for(int j=0; j<196; j++) { *(CGRA_info.reg_mmap + BRAM_INPUT_BASE_PHYS + j) = BIAS_MEM[j]; }
    for(int j=0; j<196; j++) { *(CGRA_info.reg_mmap + SCALE_INPUT_BASE_PHYS + j) = SCALE_MEM[j]; }
    clock_gettime(CLOCK_REALTIME, &end_setup);
    time_setup = BILLION * (end_setup.tv_sec - start_setup.tv_sec) + (end_setup.tv_nsec - start_setup.tv_nsec);
    printf("Setup Time = %.6f (s)\n", (double)time_setup/BILLION);

    i = 0; while (fscanf(WRAM_2_file, "%f", &value_f) == 1) { weight_final[i++] = value_f; } fclose(WRAM_2_file);
    i = 0; while (fscanf(BRAM_2_file, "%f", &value_f) == 1) { bias_final[i++] = value_f; } fclose(BRAM_2_file);


    // Model
    // Allocate memory for input data
    float* InModel = (float*)malloc(num_pictures_to_process * d * SEG_LEN * sizeof(float));
    float xSignal;
    FILE* Input = fopen("signals.txt", "r");
    if (Input == NULL) { perror("Failed to open signals.txt"); return 1; }
    for (int i = 0; i < num_pictures_to_process * d * SEG_LEN; i++) {
        fscanf(Input, "%f", &xSignal);
        InModel[i] = xSignal;
    }
    fclose(Input);

    // Allocate memory for labels
    int xLabel;
    int* Label = (int*)malloc(num_pictures_to_process * sizeof(int));
    FILE* Output = fopen("labels.txt", "r");
    if (Output == NULL) {
        perror("Failed to open labels.txt");
        free(InModel);
        return 1;
    }
    for (int i = 0; i < num_pictures_to_process; i++) {
        fscanf(Output, "%d", &xLabel);
        Label[i] = xLabel;
    }
    fclose(Output);

    // Allocate memory for the output array
    int* OutArray = (int*)malloc(num_pictures_to_process * sizeof(int));
    float CNN_output[1280];
    float GlobalAveragePool1D[32];
    float out_Dense[5];
    float Image[320];
	U32 Pixel[340];
	U16 address[1280];
	struct timespec start_CNN, end_CNN;
	unsigned long long time_spent_CNN = 0;

    for (int j = 0; j < 1280; j++) {
		int a = j/20;
		address[j] = (j + a*12) & 0xFFFF; // Mask to 16-bit address
	}

#if DRAW_ECG == 1
    // ===== SDL init =====
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER)!=0){ fprintf(stderr,"SDL_Init: %s\n", SDL_GetError()); return 1; }
    if (TTF_Init()!=0){ fprintf(stderr,"TTF_Init: %s\n", TTF_GetError()); return 1; }

    SDL_Window *winw = SDL_CreateWindow("FPGA ECG Viewer",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WIDTH, HEIGHT, 0);
    if(!winw){ fprintf(stderr,"SDL_CreateWindow: %s\n", SDL_GetError()); return 1; }
    SDL_Renderer *ren = SDL_CreateRenderer(winw, -1, SDL_RENDERER_ACCELERATED);
    if(!ren){ fprintf(stderr,"SDL_CreateRenderer: %s\n", SDL_GetError()); return 1; }

    TTF_Font *font = TTF_OpenFont(font_path, 16);
    if(!font){ fprintf(stderr,"TTF_OpenFont: %s\n", TTF_GetError()); return 1; }

    // waveform ring buffer for visible window
    double fs = 360.0, view_seconds = 5.0;
    int win_len = (int)(fs*view_seconds); if(win_len<10) win_len=10;
    double *buf = (double*)calloc(win_len, sizeof(double));
    int buf_n=0, buf_head=0;
    long long total_samples=0;

    double slow_factor = 5.0;     
    int update_every = 10;       
    double ms_per_sample = 1000.0*slow_factor/fs, ms_accum=0.0;

    int running=1;
    int correct=0;
    SDL_Color black={0,0,0,255}, red={255,0,0,255};

    for (int i = 0; i < num_pictures_to_process && running; i++) {
#else    
    for (int i = 0; i < num_pictures_to_process; i++) {
#endif
        // Signal done
        int startIndex = i * d * SEG_LEN;
        for (int k = 0; k < d * SEG_LEN; k++) {
            Image[k] = InModel[startIndex + k];
        }

        for (int k = 0; k < 340; k++) {
			if(k < SEG_LEN){
                Pixel[k] = quantize_int8(Image[k], INPUT_SCALE, INPUT_ZERO_POINT);
            }
			else {
                Pixel[k] = quantize_int8(0.0f, INPUT_SCALE, INPUT_ZERO_POINT);
            }
        }

        // Run FPGA
        clock_gettime(CLOCK_REALTIME, &start_CNN);
		for (int k = 0; k < 340; k++) {
				*(CGRA_info.reg_mmap + LDM_INPUT_BASE_PHYS + address[k]) = Pixel[k];
        }
		*(CGRA_info.reg_mmap + START_BASE) = 1;
        
        // Wait for computation to complete
        while (1){
			if(*(CGRA_info.reg_mmap + DONE_BASE_PHYS) == 1) 
                break;
		}

        // Read CNN output done
        for (int j = 0; j < 1280; j++) {    
            CNN_output[j] = int8ToFloat(*(CGRA_info.reg_mmap + LDM_OUTPUT_BASE_PHYS + address[j]), FEATURE_SCALE, FEATURE_ZERO_POINT);
        }

        // Global Average Pooling
        for (int j = 0; j < 32; j++) {
            float avg = 0;
            for (int k = 0; k < 40; k++) {
                avg += CNN_output[40 * j + k];
            }
            GlobalAveragePool1D[j] = avg / 40.0f;
        }

        // Dense Layer Calculation
        for (int j = 0; j < 5; j++) {
            float s = 0;
            for (int k = 0; k < 32; k++) {
                s += GlobalAveragePool1D[k] * weight_final[k * 5 + j];
            }
            out_Dense[j] = s + bias_final[j];
        }

        // Find the index of the maximum value in out_Dense
        int maxindex = 0;
        float max = out_Dense[0];
        for (int j = 1; j < 5; j++) {
            if (out_Dense[j] > max) {
                max = out_Dense[j];
                maxindex = j;
            }
        }

        // Store the result in OutArray
        OutArray[i] = maxindex;
#if DRAW_ECG == 1
        int pred = maxindex;
#endif
		clock_gettime(CLOCK_REALTIME, &end_CNN);
		time_spent_CNN = BILLION * (end_CNN.tv_sec - start_CNN.tv_sec) + (end_CNN.tv_nsec - start_CNN.tv_nsec) + time_spent_CNN;
#if DRAW_ECG == 1
        int gt=(int)Label[i];
        if (gt==pred) correct++;
        double acc = 100.0 * (double)correct / (double)(i+1);

        long long box_start = total_samples;
        long long box_end   = total_samples + SEG_LEN;
		
		for (int s = 0; s < SEG_LEN && running; s++) {
			double v = Image[s];
			if (buf_n < win_len) { 
				buf[buf_n++] = v; 
			} else { 
				buf[buf_head] = v; 
				buf_head = (buf_head + 1) % win_len; 
			}
			total_samples++;

			if (s % update_every == 0 || s == SEG_LEN-1) {
				SDL_Event e; 
				while (SDL_PollEvent(&e)) if (e.type == SDL_QUIT) running = 0;
				if (!running) break;

				// ==== y-range ====
				double ymin = buf[0], ymax = buf[0];
				for (int ii = 1; ii < buf_n; ++ii) {
					double vv = buf[(buf_head + ii) % buf_n];
					if (vv < ymin) ymin = vv;
					if (vv > ymax) ymax = vv;
				}
				if (fabs(ymax - ymin) < 1e-9) { ymin -= 0.1; ymax += 0.1; }

				// ==== clear ====
				SDL_SetRenderDrawColor(ren, 255,255,255,255);
				SDL_RenderClear(ren);

				// TOP: centered Accuracy
				char acc_str[128];
				snprintf(acc_str, sizeof(acc_str),
						 "Accuracy: %.2f%%  (%d/%d)", acc, correct, i+1);
				draw_text_center(ren, font, acc_str, 4, black);

				// BOTTOM: GT (VN)
				char gt_str[128];
				const char* gt_name = (gt >= 0 && gt < 5)? VN_LABELS[gt] : "N/A";
				snprintf(gt_str, sizeof(gt_str), "GT: %d (%s)", gt, gt_name);
				draw_text(ren, font, gt_str, 8, HEIGHT - BOT_BAR + 4, black);

				// waveform
				SDL_Rect plot_rect = {0, TOP_BAR, WIDTH, PLOT_H};
				SDL_SetRenderDrawColor(ren, 0,0,0,255);
				for (int ii = 1; ii < buf_n; ++ii) {
					double x0 = (double)(ii-1)/(double)win_len;
					double x1 = (double)ii/(double)win_len;
					double v0 = buf[(buf_head + ii - 1) % buf_n];
					double v1 = buf[(buf_head + ii) % buf_n];
					int X0 = (int)(x0 * (WIDTH-1));
					int X1 = (int)(x1 * (WIDTH-1));
					int Y0 = plot_rect.y + (int)((1.0 - (v0 - ymin) / (ymax - ymin)) * (plot_rect.h - 1));
					int Y1 = plot_rect.y + (int)((1.0 - (v1 - ymin) / (ymax - ymin)) * (plot_rect.h - 1));
					SDL_RenderDrawLine(ren, X0, Y0, X1, Y1);
				}

				// red box for current beat
				long long vis_start = total_samples - buf_n;
				long long vis_end   = total_samples;
				long long is0 = (box_start > vis_start) ? box_start : vis_start;
				long long is1 = (box_end   < vis_end  ) ? box_end   : vis_end;
				if (is1 > is0) {
					int b0 = (int)(is0 - vis_start);
					int b1 = (int)(is1 - vis_start);
					int X0 = (int)clampd((double)b0 / (double)win_len * (WIDTH - 1), 0, WIDTH - 1);
					int X1 = (int)clampd((double)b1 / (double)win_len * (WIDTH - 1), 0, WIDTH - 1);
					if (X1 <= X0) X1 = X0 + 1;

					SDL_Rect r = (SDL_Rect){ X0, plot_rect.y, X1 - X0, plot_rect.h };
					SDL_SetRenderDrawColor(ren, 255, 0, 0, 255);
					SDL_RenderDrawRect(ren, &r);

					if (s >= PRED_SHOW_AT_SAMPLES) {
						const char* pred_name = (pred >= 0 && pred < 5) ? VN_LABELS[pred] : "N/A";
						char pred_str[160];
						snprintf(pred_str, sizeof(pred_str), "Pred: %d (%s)", pred, pred_name);

						int tw = 0, th = 0;
						TTF_SizeUTF8(font, pred_str, &tw, &th);
						int x_text = X0 + (X1 - X0)/2 - tw/2;
						if (x_text < 2) x_text = 2;
						if (x_text > WIDTH - tw - 2) x_text = WIDTH - tw - 2;
						draw_text(ren, font, pred_str, x_text, plot_rect.y + 4, red);
					}
				}
				SDL_RenderPresent(ren);

				// pacing
				ms_accum += ms_per_sample * (double)update_every;
				if (ms_accum >= 1.0) {
					Uint32 ms = (Uint32)ms_accum;
					SDL_Delay(ms);
					ms_accum -= ms;
				}
			} 
		}
#endif
    }

    // Calculate accuracy
    float countTrue = 0;
    for (int i = 0; i < num_pictures_to_process; i++) {
        int labelValue = (int)Label[i];
        int predictValue = (int)OutArray[i];
        if (labelValue == predictValue) {
            countTrue += 1;
        }	
    }
    float accuracy = (countTrue / num_pictures_to_process) * 100;
    printf("Accuracy of Model = %f\n", accuracy);
	printf("Execution time in second = %.6f (s)\n", (double)time_spent_CNN/ BILLION);

    // Free allocated memory
    free(InModel);
    free(Label);
    free(OutArray);

    printf("===> TEST DONE\n"); 

    return 0;
}

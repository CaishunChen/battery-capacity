/**
 * battery_capacity.c
 * Plots and analyzes the battery capacity dataset.
 *
 * @author Nathan Campos <nathanpc@dreamintech.net>
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include "gnuplot_i/gnuplot_i.h"

#define DATADIR "data"
#define INDEXFILE "index.csv"

struct battery {
	bool show;
	char *brand;
	char *model;
	double voltage;
	unsigned int exp_capacity;
	unsigned int current;
	char *type;
	float cutoff;
	char *file;
	char *comment;
};

size_t countlines(const char *filename);
char* battery_label(struct battery batt);
struct battery create_battery(char *col[10]);
size_t battery_index(struct battery **index, const char *type);

int main(int argc, const char *argv[]) {
	struct battery *batteries;
	size_t nitems = battery_index(&batteries, "9V");

	for (int i = 0; i < nitems; i++) {
		printf("%s\n", battery_label(batteries[i]));
		//printf("%s %s %.1fV\n", batteries[i].brand, batteries[i].model, batteries[i].voltage);
		printf("%s\n\n", batteries[i].file);
	}

	printf("%zu lines\n", countlines("data/9V/index.csv"));
}

/**
 * Counts the number of lines in a file.
 *
 * @param filename Path to the file to be used.
 * @return Number of lines.
 */
size_t countlines(const char *filename) {
	FILE *file = fopen(filename, "r");
	char ch;
	size_t lines = 0;
	while (!feof(file)) {
		ch = fgetc(file);

		if (ch == '\n') {
			lines++;
		}
	}

	return lines;
}

/**
 * Generates a pretty label to indicate all the parameters of the battery.
 *
 * @param batt A battery struct.
 * @return The battery label.
 */
char* battery_label(struct battery batt) {
	char *model = "";
	char *exp_capacity = "";
	size_t bsize = 0;

	if (batt.model != NULL) {
		bsize = snprintf(NULL, 0, " %s", batt.model) + 1;
		model = malloc(bsize);
		snprintf(model, bsize, " %s", batt.model);
	}

	if (batt.exp_capacity != 0) {
		bsize = snprintf(NULL, 0, " %dmAh", batt.exp_capacity) + 1;
		exp_capacity = malloc(bsize);
		snprintf(exp_capacity, bsize, " %dmAh", batt.exp_capacity);
	}

	bsize = snprintf(NULL, 0, "%s%s %.1fV%s @ %dmA", batt.brand, model, batt.voltage, exp_capacity, batt.current) + 1;
	char *label = malloc(bsize);
	snprintf(label, bsize, "%s%s %.1fV%s @ %dmA", batt.brand, model, batt.voltage, exp_capacity, batt.current);

	return label;
}

/**
 * Creates a battery struct with the contents from the array of columns.
 *
 * @param col Array of columns.
 * @return Battery struct.
 */
struct battery create_battery(char *col[10]) {
	struct battery batt;

	batt.show = atoi(col[0]);
	batt.brand = (char *)malloc(sizeof(char) * strlen(col[1]));
	strcpy(batt.brand, col[1]);
	batt.voltage = atof(col[3]);
	batt.current = atoi(col[5]);
	batt.type = (char *)malloc(sizeof(char) * strlen(col[6]));
	strcpy(batt.type, col[6]);
	batt.cutoff = atof(col[7]);
	batt.file = (char *)malloc(sizeof(char) * strlen(col[8]));
	strcpy(batt.file, col[8]);
	
	if (strcmp(col[2], "NA") != 0) {
		batt.model = (char *)malloc(sizeof(char) * strlen(col[2]));
		strcpy(batt.model, col[2]);
	} else {
		batt.model = NULL;
	}

	unsigned int exp_capacity = 0;
	if (strcmp(col[4], "NA") != 0) {
		exp_capacity = atoi(col[4]);
	}
	batt.exp_capacity = exp_capacity;

	if (strcmp(col[9], "NA") != 0) {
		batt.comment = (char *)malloc(sizeof(char) * strlen(col[9]));
		strcpy(batt.comment, col[9]);
	} else {
		batt.comment = NULL;
	}


	return batt;
}

/**
 * Parses the index of batteries.
 *
 * @param index Battery list.
 * @param type Battery type.
 * @return Size of the struct.
 */
size_t battery_index(struct battery **index, const char *type) {
	FILE *csvfile;
	char filename[20];
	char *line = NULL;
	size_t len = 0;
	size_t items = 0;
	struct battery *batteries;

	sprintf(filename, "%s/%s/%s", DATADIR, type, INDEXFILE);
	batteries = malloc((countlines(filename) - 1) * sizeof(struct battery));
	csvfile = fopen(filename, "r");
	if (csvfile == NULL) {
		printf("Couldn't open file: %s\n", filename);
		exit(EXIT_FAILURE);
	}

	bool past_header = false;
	while (getline(&line, &len, csvfile) != -1) {
		char *col[10];
		char *token = NULL;
		uint8_t cols = 0;

		if (!past_header) {
			past_header = true;
			continue;
		}

		strtok(line, "\n");  // Remove the trailling newline.
		token = strtok(line, ",");
		while (token != NULL) {
			col[cols] = (char *)malloc(sizeof(char) * strlen(token));
			strcpy(col[cols], token);

			token = strtok(NULL, ",");
			cols++;
		}		

		if (cols != 10) {
			printf("WARNING: Column number different than 10: %d\n", cols);
			for (int i = 0; i < cols; i++) {
				printf("Col %d: %s\n", i, col[i]);
			}

			exit(EXIT_FAILURE);
		}

		batteries[items] = create_battery(col);
		
		cols = 0;
		items++;
	}

	*index = batteries;
	return items;
}

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

#define DATADIR "data"
#define INDEXFILE "index.csv"

size_t countlines(const char *filename);
struct battery create_battery(char *col[10]);
size_t battery_index(struct battery **index, const char *type);

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

int main(int argc, const char *argv[]) {
	struct battery *batteries;
	size_t nitems = battery_index(&batteries, "9V");

	for (int i = 0; i < nitems; i++) {
		printf("%s %s %.1fV\n", batteries[i].brand, batteries[i].model, batteries[i].voltage);
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
	batt.model = (char *)malloc(sizeof(char) * strlen(col[2]));
	strcpy(batt.model, col[2]);  // TODO: If NA then NULL.
	batt.voltage = atof(col[3]);
	batt.current = atoi(col[5]);
	batt.type = (char *)malloc(sizeof(char) * strlen(col[6]));
	strcpy(batt.type, col[6]);
	batt.cutoff = atof(col[7]);
	batt.file = (char *)malloc(sizeof(char) * strlen(col[8]));
	strcpy(batt.file, col[8]);
	batt.comment = (char *)malloc(sizeof(char) * strlen(col[9]));
	strcpy(batt.comment, col[9]);

	unsigned int exp_capacity = 0;
	if (strcmp(col[4], "NA") != 0) {
		exp_capacity = atoi(col[4]);
	}
	batt.exp_capacity = exp_capacity;

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
		char *value;
		char *col[10];
		char *token = NULL;
		char c;
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

	//memcpy(index, batteries, sizeof(struct) * sizeof(batteries));
	*index = batteries;
	return items;
}

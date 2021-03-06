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
#include <unistd.h>
#include <math.h>
#include "gnuplot_i/gnuplot_i.h"

#define DATADIR "data"
#define INDEXFILE "index.csv"
#define NCOLS 11

struct battery {
	char *type;
	bool show;
	char *brand;
	char *model;
	double voltage;
	unsigned int exp_capacity;
	unsigned int current;
	char *chem;
	float cutoff;
	char *file;
	unsigned int interval;
	char *comment;
};

size_t countlines(const char *filename);
char* battery_label(const struct battery batt);
struct battery create_battery(char *col[10], const char *type);
size_t battery_index(struct battery **index, const char *type);
size_t battery_discharge(const struct battery batt, double **voltages);
void plot_battery(gnuplot_ctrl *gp, const struct battery batt, double **mah_minmax, double **volt_minmax); 

int main(int argc, const char *argv[]) {
	if (argc < 2) {
		printf("Usage: %s type\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	struct battery *batteries;
	size_t nitems = battery_index(&batteries, argv[1]);

	// Initialize GNUplot and configure it.
	gnuplot_ctrl *gp = gnuplot_init();
	gnuplot_cmd(gp, "load 'gnuplot.cfg'");
	gnuplot_cmd(gp, "set key on");
	gnuplot_set_xlabel(gp, "Capacity (mAh)");
	gnuplot_set_ylabel(gp, "Voltage (V)");

	// Plot batteries.
	double xtics = 0;
	double ytics = 0;
	for (int i = 0; i < nitems; i++) {
		double *mah_minmax = NULL;
		double *volt_minmax = NULL;

		if (batteries[i].show) {
			plot_battery(gp, batteries[i], &mah_minmax, &volt_minmax);
			printf("mAh %.3f - %.3f | V %.3f - %.3f\n", mah_minmax[0], mah_minmax[1], volt_minmax[0], volt_minmax[1]);

			if (mah_minmax[1] > xtics) {
				xtics = mah_minmax[1];
			}

			if ((volt_minmax[0] - volt_minmax[1]) > ytics) {
				ytics = volt_minmax[0] - volt_minmax[1];
			}
		}
	}

	xtics /= 18;
	ytics /= 17;
	printf("x = %.3f -> %d\n", xtics, (int)ceil(xtics));
	printf("y = %.3f -> %.1f\n", ytics, ytics);

	char set_tics[15];
	snprintf(set_tics, 15, "set xtics %d", (int)ceil(xtics));
	gnuplot_cmd(gp, set_tics);
	if (ytics > 0.1) {
		snprintf(set_tics, 15, "set ytics %.1f", ytics);
		gnuplot_cmd(gp, set_tics);
	}
	gnuplot_cmd(gp, "replot");

	printf("Press Enter to continue...");
	getchar();
	gnuplot_close(gp);

	return EXIT_SUCCESS;
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
char* battery_label(const struct battery batt) {
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
 * @param type Battery type.
 * @return Battery struct.
 */
struct battery create_battery(char *col[10], const char *type) {
	struct battery batt;

	batt.type = (char *)malloc(sizeof(char) * strlen(type) + 1);
	strcpy(batt.type, type);
	batt.show = atoi(col[0]);
	batt.brand = (char *)malloc(sizeof(char) * strlen(col[1]) + 1);
	strcpy(batt.brand, col[1]);
	batt.voltage = atof(col[3]);
	batt.current = atoi(col[5]);
	batt.chem = (char *)malloc(sizeof(char) * strlen(col[6]) + 1);
	strcpy(batt.chem, col[6]);
	batt.cutoff = atof(col[7]);
	batt.file = (char *)malloc(sizeof(char) * strlen(col[8]) + 1);
	strcpy(batt.file, col[8]);
	batt.interval = atoi(col[9]);
	
	if (strcmp(col[2], "NA") != 0) {
		batt.model = (char *)malloc(sizeof(char) * strlen(col[2]) + 1);
		strcpy(batt.model, col[2]);
	} else {
		batt.model = NULL;
	}

	unsigned int exp_capacity = 0;
	if (strcmp(col[4], "NA") != 0) {
		exp_capacity = atoi(col[4]);
	}
	batt.exp_capacity = exp_capacity;

	if (strcmp(col[10], "NA") != 0) {
		batt.comment = (char *)malloc(sizeof(char) * strlen(col[10]) + 1);
		strcpy(batt.comment, col[10]);
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
	char *filename;
	char *line = NULL;
	size_t len = 0;
	size_t items = 0;
	struct battery *batteries;

	size_t bsize = snprintf(NULL, 0, "%s/%s/%s", DATADIR, type, INDEXFILE) + 1;
	filename = malloc(bsize);
	snprintf(filename, bsize, "%s/%s/%s", DATADIR, type, INDEXFILE);
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
			col[cols] = (char *)malloc(sizeof(char) * strlen(token) + 1);
			strcpy(col[cols], token);

			token = strtok(NULL, ",");
			cols++;
		}		

		if (cols != NCOLS) {
			printf("ERROR: Column number different than %d: %d\n", NCOLS, cols);
			for (int i = 0; i < cols; i++) {
				printf("Col %d: %s\n", i, col[i]);
			}

			exit(EXIT_FAILURE);
		}

		batteries[items] = create_battery(col, type);
		
		cols = 0;
		items++;
	}

	*index = batteries;
	return items;
}

/**
 * Creates a array with the voltages during the discharge.
 *
 * @param batt Battery struct.
 * @param voltages The array of voltages.
 * @return Number of voltage readings in the array.
 */
size_t battery_discharge(const struct battery batt, double **voltages) {
	FILE *csvfile;
	char *filename;
	char *line = NULL;
	size_t len = 0;
	size_t items = 0;
	double *_voltages;

	size_t bsize = snprintf(NULL, 0, "%s/%s/%s", DATADIR, batt.type, batt.file) + 1;
	filename = malloc(bsize);
	snprintf(filename, bsize, "%s/%s/%s", DATADIR, batt.type, batt.file);
	_voltages = malloc(countlines(filename) * sizeof(double));

	csvfile = fopen(filename, "r");
	if (csvfile == NULL) {
		printf("Couldn't open file: %s\n", filename);
		exit(EXIT_FAILURE);
	}
	
	while (getline(&line, &len, csvfile) != -1) {
		char *token = NULL;
		uint8_t col = 0;
		bool finished = false;

		strtok(line, "\n");  // Remove the trailling newline.
		token = strtok(line, ",");
		while (token != NULL) {
			if (col == 2) {
				double reading = atof(token);

				if (reading < batt.cutoff) {
					finished = true;
				} else {
					_voltages[items] = reading;
				}

				break;
			}

			token = strtok(NULL, ",");
			col++;
		}

		if (finished) {
			_voltages = (double *)realloc(_voltages, items * sizeof(double));
			break;
		}

		col = 0;
		items++;
	}

	*voltages = _voltages;
	return items;

}

void plot_battery(gnuplot_ctrl *gp, const struct battery batt, double **mah_minmax, double **volt_minmax) {
	double *voltages;
	size_t nreads = battery_discharge(batt, &voltages);
	double *mah;
	mah = malloc(nreads * sizeof(double));

	double *_mah_minmax = malloc(2 * sizeof(double));
	double *_volt_minmax = malloc(2 * sizeof(double));


	for (size_t i = 0; i < nreads; i++) {
		mah[i] = batt.current * ((i * batt.interval) / 3600.0);
	}
	
	gnuplot_setstyle(gp, "lines");
	gnuplot_plot_xy(gp, mah, voltages, nreads, battery_label(batt));

	if (mah_minmax != NULL) {
		_mah_minmax[0] = mah[0];
		_mah_minmax[1] = mah[nreads - 1];
	}

	if (volt_minmax != NULL) {
		_volt_minmax[0] = voltages[0];
		_volt_minmax[1] = voltages[nreads - 1];
	}

	*mah_minmax = _mah_minmax;
	*volt_minmax = _volt_minmax;
}


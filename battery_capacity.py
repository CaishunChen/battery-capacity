#!/usr/bin/env python

import sys
import csv
import matplotlib.pyplot

# Constants
DATADIR = "data/"

# Build a name to be displayed in the legend.
def build_name(batt):
    name = batt["brand"]

    if batt["model"] != "":
        name += " " + batt["model"]
    
    name += " " + str(batt["voltage"]) + "V"

    if batt["exp_capacity"] > 0:
        name += " " + str(batt["exp_capacity"]) + "mAh"

    name += " @ " + str(batt["current"]) + "mA"
    return name

# Parse the battery index.
def parse_index(btype):
    index = []
    bdir = DATADIR + btype + "/"

    with open(bdir + "index.csv", "rb") as f:
        reader = csv.reader(f)
        try:
            for i, row in enumerate(reader):
                if i > 0:
                    expcap = 0
                    if row[4] != "":
                        expcap = int(row[4])

                    index.append({
                        "show": bool(int(row[0])),
                        "brand": row[1],
                        "model": row[2],
                        "voltage": float(row[3]),
                        "exp_capacity": expcap,
                        "current": int(row[5]),
                        "type": row[6],
                        "cutoff": float(row[7]),
                        "file": row[8],
                        "comment": row[9]
                    })
        except csv.Error as err:
            sys.exit("File %s, line %d: %s" % (filename, reader.line_num, err))

    return index

# Parse the battery log data.
def parse_battery(filename, current, cutoff = 0.8):
    mah = []
    volts = []

    with open(filename, "rb") as f:
        reader = csv.reader(f)
        try:
            for i, row in enumerate(reader):
                voltage = float(row[2])
                mah.append(current * (float(i) / 3600))
                volts.append(voltage)

                if (voltage < cutoff):
                    break
        except csv.Error as err:
            sys.exit("File %s, line %d: %s" % (filename, reader.line_num, err))

    return { "mah": mah, "volts": volts }

def get_batteries(btype):
    index = parse_index(btype)
    bdir = DATADIR + btype + "/"
    batteries = []

    for battery in index:
        if battery["show"]:
            batteries.append({ "name": build_name(battery),
                "data": parse_battery(bdir + battery["file"], battery["current"], battery["cutoff"]) })

    return batteries

# Plot the capacity of the battery.
def plot(btype):
    batteries = get_batteries(btype)

    # Prepare the plot.
    matplotlib.pyplot.style.use("ggplot")

    for batt in batteries:
        matplotlib.pyplot.plot(batt["data"]["mah"], batt["data"]["volts"], label = batt["name"])

    # Setup the plot.
    matplotlib.pyplot.title(btype + " Battery Discharge")
    matplotlib.pyplot.legend(loc = "upper right")
    matplotlib.pyplot.xlabel("Capacity (mAh)")
    matplotlib.pyplot.ylabel("Voltage (V)")
    matplotlib.pyplot.grid(True)
    matplotlib.pyplot.tight_layout()
    matplotlib.pyplot.show()

# Execute program.
if __name__ == "__main__":
    plot("9V")

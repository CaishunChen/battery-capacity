#!/usr/bin/env python

import sys
import csv
import matplotlib.pyplot

def parse_csv(filename, current, cutoff = 0.8):
    mah = []
    volts = []

    with open(filename, "rb") as f:
        reader = csv.reader(f)
        try:
            for row in reader:
                voltage = float(row[2])
                mah.append(current * (float(row[0]) / 3600))
                volts.append(voltage)

                if (voltage < cutoff):
                    break
        except csv.Error as err:
            sys.exit("File %s, line %d: %s" % (filename, reader.line_num, err))

    return { "mah": mah, "volts": volts }

if __name__ == "__main__":
    batteries = []

    # Populate the data.
    data_dir = "data/AA/"
    batteries.append({ "name": "MOX \"3600mAh\"",
        "data": parse_csv(data_dir + "MOX-AA-3600mAh-Discharge.log", 200) })
    batteries.append({ "name": "Panasonic Platinum Power",
        "data": parse_csv(data_dir + "Panasonic-PlatinumPower-AA-0124.log", 200) })
    #batteries.append({ "name": "Panasonic SuperHyper",
    #    "data": parse_csv(data_dir + "Panasonic-SuperHyper-AA-1116.log", 200) })
    batteries.append({ "name": "Rontek 1800mAh",
        "data": parse_csv(data_dir + "Rontek-1800mAh-AA.log", 202) })

    # Prepare the plot.
    matplotlib.pyplot.style.use("ggplot")

    for batt in batteries:
        matplotlib.pyplot.plot(batt["data"]["mah"], batt["data"]["volts"], label = batt["name"])

    # Setup the plot.
    matplotlib.pyplot.title("AA Battery Discharge at 200mA")
    matplotlib.pyplot.legend(loc = "upper right")
    matplotlib.pyplot.xlabel("Capacity (mAh)")
    matplotlib.pyplot.ylabel("Voltage (V)")
    matplotlib.pyplot.grid(True)
    matplotlib.pyplot.show()


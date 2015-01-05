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
            for i, row in enumerate(reader):
                voltage = float(row[2])
                mah.append(current * (float(i) / 3600))
                volts.append(voltage)

                if (voltage < cutoff):
                    break
        except csv.Error as err:
            sys.exit("File %s, line %d: %s" % (filename, reader.line_num, err))

    return { "mah": mah, "volts": volts }

if __name__ == "__main__":
    batteries = []
    batt_type = "9V"
    data_dir = "data/" + batt_type + "/"

    # Populate the data.
    if batt_type is "AA":
        batteries.append({ "name": "MOX \"3600mAh\"",
            "data": parse_csv(data_dir + "MOX-AA-3600mAh-Discharge.log", 200) })
        batteries.append({ "name": "Panasonic Platinum Power",
            "data": parse_csv(data_dir + "Panasonic-PlatinumPower-AA-0124.log", 200) })
        #batteries.append({ "name": "Panasonic SuperHyper",
        #    "data": parse_csv(data_dir + "Panasonic-SuperHyper-AA-1116.log", 200) })
        batteries.append({ "name": "Rontek 1800mAh",
            "data": parse_csv(data_dir + "Rontek-1800mAh-AA.log", 202) })
        #batteries.append({ "name": "Sony Cyber-shot (Old) 2100mAh",
        #    "data": parse_csv(data_dir + "Sony-CyberShot-Old-2100mAh.log", 201) })
    elif batt_type is "AAA":
        batteries.append({ "name": "AmazonBasics 800mAh",
            "data": parse_csv(data_dir + "AmazonBasics-AAA-800mAh-100mA.log", 100) })
    elif batt_type is "9V":
        batteries.append({ "name": "Rayovac 8.4V 200mAh",
            "data": parse_csv(data_dir + "Rayovac-RechargePlus-8.4V-200mAh.log", 30) })
        #batteries.append({ "name": "Rayovac 8.4V 200mAh (Not Charged)",
        #    "data": parse_csv(data_dir + "Rayovac-RechargePlus-8.4V-200mAh-NotCharged.log", 30) })
        batteries.append({ "name": "Hi-Watt General Purpose",
            "data": parse_csv(data_dir + "Hi-Watt-6F22.log", 20) })

    # Prepare the plot.
    matplotlib.pyplot.style.use("ggplot")

    for batt in batteries:
        matplotlib.pyplot.plot(batt["data"]["mah"], batt["data"]["volts"], label = batt["name"])

    # Setup the plot.
    matplotlib.pyplot.title(batt_type + " Battery Discharge")
    matplotlib.pyplot.legend(loc = "upper right")
    matplotlib.pyplot.xlabel("Capacity (mAh)")
    matplotlib.pyplot.ylabel("Voltage (V)")
    matplotlib.pyplot.grid(True)
    matplotlib.pyplot.show()


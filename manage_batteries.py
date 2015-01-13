#!/usr/bin/env python

import sys
import os
import csv
import cmd
from pprint import pprint
from termcolor import colored

DATA_DIR = "data/"

class Cmdline(cmd.Cmd):
    DEFAULT_PROMPT = "> "
    type_selected = ""
    prompt = DEFAULT_PROMPT

    def do_type(self, line):
        no_batt = True

        for batt_type in battery_types():
            if line == "list":
                print batt_type
                no_batt = False
            elif line == batt_type:
                print "Battery type selected: " + batt_type
                self.type_selected = batt_type
                self.prompt = self.type_selected + self.DEFAULT_PROMPT
                no_batt = False
                break

        if no_batt:
            print "Battery type '" + line + "' not recognized, use 'type list' to get a list of the batteries available"

    def do_list(self, line):
        if not self.type_selected:
            self.do_type("list")
        else:
            for i,battery in enumerate(parse_index(self.type_selected)):
                color = "red"
                if battery["show"]:
                    color = "blue"

                print colored("%d. %s %s %.1fV %s (%s)", color) % (i, battery["brand"], battery["model"], battery["voltage"], battery["type"], battery["file"])

    def do_exit(self, line):
        exit()

    def do_EOF(self, line):
        return True

def battery_types():
    types = []

    for filename in os.listdir(DATA_DIR):
        if os.path.isdir(DATA_DIR + filename):
            types.append(filename)

    types.sort()
    return types

def parse_index(battery_type):
    filename = DATA_DIR + battery_type + "/index.csv"
    batteries = []

    with open(filename) as f:
        reader = csv.reader(f)
        try:
            for i, row in enumerate(reader):
                if i != 0:
                    exp_capacity = 0
                    if row[4] != "":
                        exp_capacity = int(row[4])

                    show = False
                    if row[0] == "1":
                        show = True

                    batteries.append({
                        "show": show,
                        "brand": row[1],
                        "model": row[2],
                        "voltage": float(row[3]),
                        "exp_capacity": exp_capacity,
                        "current": int(row[5]),
                        "type": row[6],
                        "cutoff": float(row[7]),
                        "file": row[8],
                        "comment": row[9] })
        except csv.Error as err:
            sys.exit("File %s, line %d: %s" % (filename, reader.line_num, err))

    return batteries

if __name__ == "__main__":
    cmdline = Cmdline()
    cmdline.cmdloop()


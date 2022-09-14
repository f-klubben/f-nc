#!/usr/bin/env python3

import os
import subprocess
import re

DUMP = "card.dump"

# clean run
try:
    os.remove("output")
except FileNotFoundError:
    pass


def wait_for_tag():
    while True:
        # run nfc-poll with subprocess and wait for string "Waiting for card removing..." or eq in stdout
        p = subprocess.Popen(["stdbuf", "-oL", "nfc-poll"], stdout=subprocess.PIPE)

        for line in iter(p.stdout.readline, b''):
            line = line.decode("utf-8")
            if "Waiting for card removing" in line or "SAK (SEL_RES):" in line:
                # kill and return when card is registered
                p.kill()
                return


wait_for_tag()

# read from card, forcing to ignore UID mismatch of preset dump
read_res = subprocess.call(f"nfc-mfclassic r a u output {DUMP} f", shell=True,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
if read_res != 0:
    print("Dump failed - is an AAU card present?")
    exit(1)

# regex out cardnumber
try:
    with open("output", "rb") as f:
        # scrub leading 0 and trailing 0? from regex pattern
        res = re.compile(r"0\d{6}0\?").search(str(f.read()))
        if res:
            card_number = res.group(0)[1:7]
            print(card_number)
        else:
            print("No AAU cardnumber found in dump")
            exit(1)
except FileNotFoundError:
    print("Dump failed - is an AAU card present?")

exit(0)

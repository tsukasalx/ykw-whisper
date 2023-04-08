from copy import deepcopy
import sys
from typing import List

import pysubs2
from pysubs2.ssaevent import SSAEvent


def convert_lines(input: str, output: str):

    subs = pysubs2.load(input)

    events: List[SSAEvent] = []
    for line in subs:
        place_holder_line = deepcopy(line)
        place_holder_line.text = ''
        line.is_comment = True
        events.append(line)
        events.append(place_holder_line)
    subs.events = events

    subs.save(output)


if __name__ == "__main__":
    convert_lines(sys.argv[1], sys.argv[2])

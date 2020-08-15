import re
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('file', type=str)
args = parser.parse_args()

pattern = r'.+:\t([0-9a-f]{8})'

with open(args.file, 'r') as fp:
    source = fp.read()

hex_instr = re.findall(pattern, source)
for instr in hex_instr:
    print(bin((1 << 32) | int(instr, base=16))[3:])

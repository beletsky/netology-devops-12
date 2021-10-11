#!/usr/bin/env python3

import os
import sys

dir = sys.argv[1]

if not os.path.isdir(dir):
    print(f'{dir} doesn\'t exists')
    exit()
if not os.access(dir, os.X_OK):
    print(f'{dir} isn\'t accessible')
    exit()

os.chdir(dir)

if os.popen('git rev-parse --is-inside-work-tree 2>/dev/null').read().strip() != 'true':
    print(f'{dir} isn\'t a git repository')
    exit()

result_os = os.popen('git status --porcelain=v2').read()
for result in result_os.splitlines():
    # Proceed modified files only
    if result[0] == '1':
        print(os.path.abspath(result.split(' ', 8)[8]))

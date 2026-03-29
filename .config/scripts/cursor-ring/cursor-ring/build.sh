#!/bin/bash
gcc $(pkg-config --cflags --libs gtk4 gtk4-layer-shell-0) -lm -O2 -o cursor-ring src/main.c
echo "Done: ./cursor-ring"

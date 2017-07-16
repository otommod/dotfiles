import json
import subprocess
import sys
from subprocess import PIPE, Popen


def format_colors(json):
    colors = {'none': '%{B-}%{F-}'}
    for n, c in json.items():
        colors[n] = ''
        if c[0]: colors[n] += '%{F' + c[0] + '}'
        if c[1]: colors[n] += '%{B' + c[1] + '}'

    return colors


def format_wm(string):
    wm = []
    for item in string.split(':'):
        # print(repr(item), file=sys.stderr)
        name = item[1:]
        if item.startswith('M'):
            if MONITOR_COUNT > 1:
                wm.append(COLORS['active_monitor'] + name + COLORS['none'])
        if item.startswith('m'):
            if MONITOR_COUNT > 1:
                wm.append(COLORS['inactive_monitor'] + name + COLORS['none'])

        if item.startswith('O'):
            wm.append(COLORS['focused_occupied'] + name + COLORS['none'])
        if item.startswith('F'):
            wm.append(COLORS['focused_free'] + name + COLORS['none'])
        if item.startswith('U'):
            wm.append(COLORS['focused_urgent'] + name + COLORS['none'])

        if item.startswith('o'):
            wm.append(COLORS['occupied'] + name + COLORS['none'])
        if item.startswith('f'):
            wm.append(COLORS['free'] + name + COLORS['none'])
        if item.startswith('u'):
            wm.append(COLORS['urgent'] + name + COLORS['none'])

        if item.startswith('L'):
            wm.append(COLORS['layout'] + name + COLORS['none'])

    # print(''.join(wm), file=sys.stderr)
    return ' '.join(wm)


def process(line):
    # print(repr(line), file=sys.stderr)
    line = line[:-1]  # strip the newline
    clock = title = wm = ''

    if line.startswith('S'):
        clock = COLORS['status'] + line[1:] + COLORS['none']
    elif line.startswith('T'):
        title = COLORS['title'] + line[1:] + COLORS['none']
    elif line.startswith('W'):
        wm = format_wm(line[1:])

    return '%{l}' + wm + '%{c}' + title + '%{r}' + clock


def read_fifo(filename):
    while True:
        with open(filename) as fifo:
            print(fifo.read(), file=sys.stderr)
            yield fifo.read()


COLORS = format_colors(json.load(open('panel_colors.json')))
# MONITOR_COUNT = int(subprocess.call(['bspc', 'query', '-M']))
MONITOR_COUNT = 1


with Popen(['lemonbar'], universal_newlines=True, stdin=PIPE) as bar:
    while True:
        with open('/tmp/panel-fifo', 'r') as fifo:
            # for line in read_fifo('/tmp/panel-fifo'):
            # for line in fifo:
            # while True:
            line = fifo.readline()
            print(line)
            bar.communicate(process(line))

    while True:
        pass

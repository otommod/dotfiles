import sys
import json
import subprocess
import collections


def format_colors(json):
    colors = {'none': '%{%U-}%{B-}%{F-}'}
    for n, c in json.items():
        colors[n] = ''
        try:
            if c[0]: colors[n] += '%{F' + c[0] + '}'
            if c[1]: colors[n] += '%{B' + c[1] + '}'
            if c[2]: colors[n] += '%{U' + c[2] + '}'
        except IndexError:
            pass

    return colors


class Widget:
    def __init__(self, string):
        self.string = string

    def __str__(self):
        return self.string


class Colored(Widget):
    def __init__(self, string, color_name='', attrs='', **kwargs):
        super().__init__(string, **kwargs)
        self.color_name = color_name
        self.attrs = attrs

    def __str__(self):
        attrs_start = ''.join('%{+' + a + '}' for a in self.attrs)
        attrs_end = ''.join('%{-' + a + '}' for a in self.attrs)
        return ' '.join([
            COLORS[self.color_name] + attrs_start,
            super().__str__(),
            attrs_end + COLORS['none']])


class Clickable(Widget):
    def __init__(self, string, buttons='', **kwargs):
        super().__init__(string, **kwargs)
        self.buttons = self.format_buttons(buttons)

    @classmethod
    def format_buttons(cls, buttons):
        if isinstance(buttons, str):
            return ['%{A:' + buttons + ':}']
        return ['%{A' + (str(b) if b else '') + ':' + c + ':}'
                for b, c in buttons.items() if c]

    def __str__(self):
        return (''.join(self.buttons)
                + super().__str__()
                + '%{A}' * len(self.buttons))


class ListWidget(Clickable):
    def append(self, item):
        self.string += str(item)


class LayoutIndicator(Clickable, Colored):
    def __init__(self, layout_specifier, **kwargs):
        super().__init__(layout_specifier, color_name='layout',
                         buttons='bspc desktop -l next', **kwargs)


class DesktopIndicator(Clickable, Colored):
    def __init__(self, desktop_name, style, **kwargs):
        super().__init__(desktop_name,
                         color_name=style,
                         attrs='u' if style.startswith('focused') else '',
                         buttons='bspc desktop -f ' + desktop_name, **kwargs)


class MonitorList(ListWidget):
    def __init__(self, *monitors):
        super().__init__(''.join(str(d) for d in monitors))

    def __str__(self):
        return super().__str__() if MONITOR_COUNT > 1 else ''


class DesktopList(ListWidget):
    def __init__(self, *desktops):
        super().__init__(''.join(str(d) for d in desktops),
                         buttons={4: 'bspc desktop -f next',
                                  5: 'bspc desktop -f prev'})


def format_wm(string):
    monitors = MonitorList()
    desktops = DesktopList()

    wm = [monitors, desktops]
    for item in string.split(':'):
        name = item[1:]

        monitor_styles = {
            'M': 'active_monitor',
            'm': 'inactive_monitor',
        }
        if item.startswith(tuple(monitor_styles.keys())):
            monitors.append(Colored(name, monitor_styles[item[:1]]))

        desktop_styles = {
            'o': 'occupied',
            'f': 'free',
            'u': 'urgent',
            'O': 'focused_occupied',
            'F': 'focused_free',
            'U': 'focused_urgent',
        }
        if item.startswith(tuple(desktop_styles.keys())):
            desktops.append(DesktopIndicator(name, desktop_styles[item[:1]]))

        if item.startswith('L'):
            wm.append(LayoutIndicator(name))

    # print('wm', wm)
    return ''.join(str(i) for i in wm)

COLORS_FILE = '/home/otto/.config/bspwm/panel_colors.json'
COLORS = format_colors(json.load(open(COLORS_FILE)))
MONITOR_COUNT = int(subprocess.call(['bspc', 'query', '-M']))

clock = title = wm = ''
for line in sys.stdin:
    line = line[:-1]  # strip the newline

    if line.startswith('C'):
        clock = COLORS['status'] + line[1:] + COLORS['none']
    elif line.startswith('T'):
        title = COLORS['title'] + line[1:] + COLORS['none']
    elif line.startswith('W'):
        wm = format_wm(line[1:])

    print('%{l}' + wm + '%{c}' + title + '%{r}' + clock)
    sys.stdout.flush()

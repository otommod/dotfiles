#!/usr/bin/env python3

import sys
import os
import json
from datetime import datetime, timedelta

import gi
gi.require_versions({"GLib": "2.0",
                     "GWeather": "3.0"})
from gi.repository import GLib, GWeather


XDG_CACHE_DIR = os.getenv('XDG_CACHE_DIR', os.path.expanduser('~/.cache'))


def cache_path(loc):
    return os.path.join(XDG_CACHE_DIR, "conky-weather.py",
                        loc.get_name() + ".json")


def get_cache(loc):
    try:
        with open(cache_path(loc)) as fp:
            fd = fp.fileno()
            mtime = datetime.fromtimestamp(os.stat(fd).st_mtime)
            if datetime.now() - mtime >= timedelta(hours=2):
                return None
            return json.load(fp)
    except (IOError, json.JSONDecodeError):
        return None


def set_cache(loc, data):
    path = cache_path(loc)
    cache_dir = os.path.dirname(path)
    try:
        os.makedirs(cache_dir, exist_ok=True)
        with open(path, "w") as fp:
            json.dump(data, fp)
    except IOError:
        pass


def show_info(data, key):
    print(data["current"][key])


def on_updated(info, key, loop):
    GWeather.Info.store_cache()

    def extract_info(i):
        cond = i.get_conditions()
        if cond == "-":
            cond = i.get_sky()

        return {
            "temp": i.get_temp(),
            "apparent": i.get_apparent(),
            "temp_min": i.get_temp_min(),
            "temp_max": i.get_temp_max(),
            "temp_summary": i.get_temp_summary(),
            "cond": cond,
            "icon": i.get_icon_name(),
            "symbolic": i.get_symbolic_icon_name(),
        }

    data = {
        "units": "metric",
        "location": {
            "latitude": info.get_location().get_coords()[0],
            "longitude": info.get_location().get_coords()[1],
            "name": info.get_location_name(),
        },
        "current": extract_info(info),
        "forecast": [extract_info(i) for i in info.get_forecast_list()],
    }

    set_cache(info.get_location(), data)
    show_info(data, key)

    loop.quit()


def parse_args(args):
    doc = ("usage: weather.py -l LOC [-M] [-i INDEX] KEY\n"
           "\n"
           "options:\n"
           "  -l LOC      the location in lat,lon\n"
           "  -i INDEX    the forecast index\n"
           "  -M          use imperial units\n"
           "  -h, --help  show this message and exit\n")

    import docopt

    opts = docopt.docopt(doc)

    units = "imperial" if opts["-M"] else "metric"
    lat, lon = opts["-l"].split(",")
    return float(lat), float(lon), opts["KEY"] or "temp"


def main(args):
    lat, lon, key = parse_args(args)

    world = GWeather.Location.get_world()
    city = world.find_nearest_city(lat, lon)
    loc = GWeather.Location.new_detached(city.get_name(), None, lat, lon)

    cache = get_cache(loc)
    if cache:
        show_info(cache, key)
    else:
        loop = GLib.MainLoop()

        info = GWeather.Info.new(loc, 0)
        info = GWeather.Info(location=loc,
                             # these are the providers GNOME Weather uses
                             enabled_providers=(GWeather.Provider.METAR |
                                                GWeather.Provider.YR_NO |
                                                GWeather.Provider.OWM))
        info.connect("updated", lambda i: on_updated(i, key, loop))
        info.update()

        loop.run()

if __name__ == "__main__":
    main(sys.argv[1:])

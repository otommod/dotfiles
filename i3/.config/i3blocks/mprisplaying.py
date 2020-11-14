#!/usr/bin/env python3

import signal
import sys
from xml.sax.saxutils import escape as xmlescape


def die(msg):
    print("<span background=\"red\">", msg, "</span>", sep="", flush=True)
    sys.exit(1)


try:
    import gi
    from gi.repository import GLib, Gio

except ImportError:
    die("No python-gobject")


def on_properties_changed(proxy, changed, invalidated):
    new_metadata = changed.lookup_value("Metadata")
    if new_metadata:
        print_status(new_metadata.unpack())
    elif "Metadata" in invalidated:
        print_status(None)


def on_owner_changed(proxy, _):
    if proxy.props.g_name_owner is None:
        die("playerctld crashed")


def print_status(metadata):
    if metadata is None:
        print(flush=True)
        return

    artist = metadata.get("xesam:artist")
    if artist and artist[0]:
        print("<span foreground=\"red\">", xmlescape(artist[0]), "</span> ",
              sep="", end="")

    title = metadata.get("xesam:title")
    print(xmlescape(title), flush=True)


def on_exit_signal():
    sys.exit(0)


def main(argv):
    proxy = Gio.DBusProxy.new_for_bus_sync(
        Gio.BusType.SESSION,
        Gio.DBusProxyFlags.NONE,
        None,
        "org.mpris.MediaPlayer2.playerctld",
        "/org/mpris/MediaPlayer2",
        "org.mpris.MediaPlayer2.Player")

    proxy.connect("notify::g-name-owner", on_owner_changed)
    proxy.connect("g-properties-changed", on_properties_changed)

    if proxy.props.g_name_owner is None:
        die("playerctld not found")

    metadata = proxy.get_cached_property("Metadata")
    if metadata is not None:
        metadata = metadata.unpack()
    print_status(metadata)

    # GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGINT, on_exit_signal)
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)

    mainloop = GLib.MainLoop()
    mainloop.run()

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

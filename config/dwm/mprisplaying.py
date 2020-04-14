#!/usr/bin/env python3

import signal
import sys

try:
    import gi
    from gi.repository import GLib, Gio

except ImportError:
    print("music-artist", flush=True)
    print("music-title No python-gobject found", flush=True)
    sys.exit(1)


def on_properties_changed(proxy, changed, invalidated):
    # print("g-properties-changed", changed, invalidated)
    new_metadata = changed.lookup_value("Metadata")
    if new_metadata:
        print_status(new_metadata.unpack())
    elif "Metadata" in invalidated:
        print_status(None)


def on_owner_changed(proxy, _):
    if proxy.props.g_name_owner is None:
        print("music-artist", flush=True)
        print("music-title playerctld crashed", flush=True)
        sys.exit(1)


def print_status(metadata):
    if metadata is None:
        metadata = {}
    print("music-artist", metadata.get("xesam:artist", [""])[0], flush=True)
    print("music-title", metadata.get("xesam:title", ""), flush=True)


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
        print("music-artist", flush=True)
        print("music-title playerctld not found", flush=True)
        return 1

    metadata = proxy.get_cached_property("Metadata")
    if metadata is not None:
        metadata = metadata.unpack()
    print_status(metadata)

    GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGINT, on_exit_signal)

    mainloop = GLib.MainLoop()
    mainloop.run()

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

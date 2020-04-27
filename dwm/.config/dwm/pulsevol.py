#!/usr/bin/env python3

import signal
import sys
from ctypes import *

libpulse = CDLL("libpulse.so.0")


# Typedefs
pa_volume_t = c_uint32
pa_usec_t = c_uint64

# Enums
pa_context_state_t = c_int
pa_context_flags_t = c_int
pa_sink_flags_t = c_int
pa_sink_state_t = c_int
pa_sample_format_t = c_int
pa_channel_position_t = c_int
pa_encoding_t = c_int
pa_subscription_event_type_t = c_int
pa_subscription_mask_t = c_int

# Opaque pointers
# Not all are actually opaque; most we just don't care about
pa_context_p = c_void_p
pa_mainloop_p = c_void_p
pa_mainloop_api_p = c_void_p
pa_operation_p = c_void_p
pa_signal_event_p = c_void_p
pa_proplist_p = c_void_p
pa_spawn_api_p = c_void_p
pa_format_info_p = c_void_p
pa_sink_port_info_p = c_void_p

# Constants
PA_CHANNELS_MAX = 32
PA_VOLUME_NORM = 65536


# Structs
# We only care about `pa_sink_info'; the rest are needed for sizing
class pa_sample_spec(Structure):
    _fields_ = [
        ("format",      pa_sample_format_t),
        ("rate",        c_uint32),
        ("channels",    c_uint8),
    ]


class pa_channel_map(Structure):
    _fields_ = [
        ("channels",    c_uint8),
        ("map",         pa_channel_position_t * PA_CHANNELS_MAX),
    ]


class pa_cvolume(Structure):
    _fields_ = [
        ("channels",    c_uint8),
        ("values",      pa_volume_t * PA_CHANNELS_MAX),
    ]


class pa_sink_info(Structure):
    _fields_ = [
        ("name",                c_char_p),
        ("index",               c_uint32),
        ("description",         c_char_p),
        ("sample_spec",         pa_sample_spec),
        ("channel_map",         pa_channel_map),
        ("owner_module",        c_uint32),
        ("volume",              pa_cvolume),
        ("mute",                c_int),
        ("monitor_source",      c_uint32),
        ("monitor_source_name", c_char_p),
        ("latency",             pa_usec_t),
        ("driver",              c_char_p),
        ("flags",               pa_sink_flags_t),
        ("proplist",            pa_proplist_p),
        ("configured_latency",  pa_usec_t),
        ("base_volume",         pa_volume_t),
        ("state",               pa_sink_state_t),
        ("n_volume_steps",      c_uint32),
        ("card",                c_uint32),
        ("n_ports",             c_uint32),
        ("ports",               POINTER(pa_sink_port_info_p)),
        ("active_port",         pa_sink_port_info_p),
        ("n_formats",           c_uint8),
        ("formats",             pa_format_info_p),
    ]


# Callbacks
pa_context_notify_cb_t = CFUNCTYPE(None, pa_context_p, c_void_p)
pa_sink_info_cb_t = CFUNCTYPE(None, pa_context_p, POINTER(pa_sink_info), c_int, c_void_p)
pa_context_subscribe_cb_t = CFUNCTYPE(None, pa_context_p, pa_subscription_event_type_t, c_uint32, c_void_p)
pa_context_success_cb_t = CFUNCTYPE(None, pa_context_p, c_int, c_void_p)
pa_signal_cb_t = CFUNCTYPE(None, pa_mainloop_api_p, pa_signal_event_p, c_int, c_void_p)


def wrap(fn, restype, *argtypes):
    fn.restype = restype
    fn.argtypes = argtypes
    return fn


# Function decls
pa_context_set_subscribe_callback = (
    wrap(libpulse.pa_context_set_subscribe_callback, None,
         pa_context_p, pa_context_subscribe_cb_t, c_void_p))
pa_context_subscribe = (
    wrap(libpulse.pa_context_subscribe, pa_operation_p,
         pa_context_p, pa_subscription_mask_t, pa_context_success_cb_t,
         c_void_p))

pa_mainloop_new = wrap(libpulse.pa_mainloop_new, pa_mainloop_p)
pa_mainloop_free = wrap(libpulse.pa_mainloop_free, None, pa_mainloop_p)
pa_mainloop_get_api = wrap(libpulse.pa_mainloop_get_api, pa_mainloop_api_p, pa_mainloop_p)
pa_mainloop_run = wrap(libpulse.pa_mainloop_run, c_int, pa_mainloop_p, POINTER(c_int))

pa_context_new = wrap(libpulse.pa_context_new, pa_context_p,
                      pa_mainloop_api_p, c_char_p)
pa_context_set_state_callback = (
    wrap(libpulse.pa_context_set_state_callback, None,
         pa_context_p, pa_context_notify_cb_t, c_void_p))
pa_context_connect = (
    wrap(libpulse.pa_context_connect, None,
         pa_context_p, c_char_p, pa_context_flags_t, pa_spawn_api_p))
pa_context_get_state = wrap(libpulse.pa_context_get_state, pa_context_state_t,
                            pa_context_p)
pa_context_errno = wrap(libpulse.pa_context_errno, c_int, pa_context_p)

pa_context_get_sink_info_by_name = (
    wrap(libpulse.pa_context_get_sink_info_by_name, pa_operation_p,
         pa_context_p, c_char_p, pa_sink_info_cb_t, c_void_p))

pa_operation_unref = wrap(libpulse.pa_operation_unref, None, pa_operation_p)

pa_strerror = wrap(libpulse.pa_strerror, c_char_p, c_int)

pa_channel_position_to_string = wrap(libpulse.pa_channel_position_to_string,
                                     c_char_p, pa_channel_position_t)

pa_signal_init = wrap(libpulse.pa_signal_init, c_int, pa_mainloop_api_p)
pa_signal_new = wrap(libpulse.pa_signal_new, pa_signal_event_p,
                     c_int, pa_signal_cb_t, c_void_p)


@pa_context_notify_cb_t
def on_state_change(ctx, userdata):
    state = pa_context_get_state(ctx)
    if (state == 0              # PA_CONTEXT_UNCONNECTED
            or state == 1       # PA_CONTEXT_CONNECTING
            or state == 2       # PA_CONTEXT_AUTHORIZING
            or state == 3):     # PA_CONTEXT_SETTING_NAME
        pass

    if (state == 5              # PA_CONTEXT_FAILED
            or state == 6):     # PA_CONTEXT_TERMINATED
        # XXX:
        print("vol Crashed", flush=True)
        sys.exit(1)

    if state == 4:              # PA_CONTEXT_READY:
        # This captures two types of events
        #   - 0x0001: sink events; for volume changes or muting
        #   - 0x0080: server events; the DEFAULT_SINK may change
        mask = 0x0001 | 0x0080
        null_cb = cast(None, pa_context_success_cb_t)

        pa_context_set_subscribe_callback(ctx, subscription, None)
        op = pa_context_subscribe(ctx, mask, null_cb, None)
        pa_operation_unref(op)

        op = pa_context_get_sink_info_by_name(
            ctx, b"@DEFAULT_SINK@", on_get_sink_info, None)
        pa_operation_unref(op)


@pa_context_subscribe_cb_t
def subscription(ctx, event, index, userdata):
    # We could find the event type and "facility" but we don't really care
    op = pa_context_get_sink_info_by_name(ctx, b"@DEFAULT_SINK@",
                                          on_get_sink_info, None)
    pa_operation_unref(op)


@pa_sink_info_cb_t
def on_get_sink_info(ctx, sink_info, is_last, userdata):
    if is_last < 0:
        print(pa_strerror(pa_context_errno(ctx)))
        return

    if is_last or not sink_info:
        return

    # ".contents" is essentially "->" in C
    chans = sink_info.contents.channel_map.channels
    print_status(bool(sink_info.contents.mute),
                 sink_info.contents.channel_map.map[:chans],
                 sink_info.contents.volume.values[:chans])


def print_status(is_muted, channel_map, volumes):
    voltext = "{:.0%}".format(volumes[0] / PA_VOLUME_NORM)
    if any(v != volumes[0] for v in volumes):
        voltext = " ".join("{}:{:.0%}".format(
            pa_channel_position_to_string(ch).decode("utf-8"),
            v / PA_VOLUME_NORM) for ch, v in zip(channel_map, volumes))
    if is_muted:
        voltext = "mute({})".format(voltext)

    print("vol", voltext, flush=True)


@pa_signal_cb_t
def on_exit_signal(mainloop_api, sigevent, sig, userdata):
    sys.exit(0)


def main(argv):
    mainloop = pa_mainloop_new()
    mainloop_api = pa_mainloop_get_api(mainloop)

    ctx = pa_context_new(mainloop_api, b"pulsevol")
    pa_context_set_state_callback(ctx, on_state_change, None)
    pa_context_connect(ctx, None, 0, None)

    # Make CTRL-c work again
    pa_signal_init(mainloop_api)
    pa_signal_new(signal.SIGINT, on_exit_signal, None)

    ret = c_int()
    pa_mainloop_run(mainloop, byref(ret))

    return ret.value


if __name__ == "__main__":
    sys.exit(main(sys.argv))

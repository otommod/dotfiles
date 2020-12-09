#!/usr/bin/env python3

import enum
import json
import urllib.request
from urllib.parse import urlunsplit


# The logic is mostly taken from tr_formatter_speed_KBps, what transmission
# uses to display its speeds.
def humanize_Bps(bps):
    K = 1000
    kbps = bps / K

    if kbps <= 999.95:      # 0.0 kB to 999.9 kB
        return "%d kB/s" % int(kbps)
    elif kbps <= 99.995e3:  # 0.98 MB to 99.99 MB
        return "%.2f MB/s" % kbps / K
    elif kbps <= 999.95e3:  # 100.0 MB to 999.9 MB
        return "%.1f MB/s" % kbps / K
    else:
        return "%.1f GB/s" % kbps / K / K


class TransmissionTorrentStatus(enum.IntEnum):
    # Transmission uses an enum to represent a torrent's status and
    # (unfortunately) that is also what it sents to us.
    # Source: libtransmission/transmission.h

    STOPPED = 0         # Torrent is stopped
    CHECK_WAIT = 1      # Queued to check files
    CHECK = 2           # Checking files
    DOWNLOAD_WAIT = 3   # Queued to download
    DOWNLOAD = 4        # Downloading
    SEED_WAIT = 5       # Queued to seed
    SEED = 6            # Seeding


class TransmissionSessionHandler(urllib.request.BaseHandler):
    header = "x-transmission-session-id"

    def __init__(self):
        self.session_id = ""

    def http_request(self, req):
        req.add_header(self.header, self.session_id)
        return req

    def http_error_409(self, req, fp, code, msg, headers):
        # XXX: could infintely loop; need to check if we get 409s on retries

        if self.header in headers:
            self.session_id = headers[self.header]

        req.add_header(self.header, self.session_id)
        return self.parent.open(req, timeout=req.timeout)


class TransmissionRPCError(Exception):
    pass


class Transmission:
    def __init__(self, host, rpc_path="/transmission/rpc"):
        self.url = urlunsplit(("http", host, rpc_path, "", ""))

        # auth_handler = urllib.request.HTTPBasicAuthHandler()
        # auth_handler.add_password(realm="Transmission",
        #                           uri=self.url,
        #                           user="user",
        #                           passwd="passwd")

        self.opener = urllib.request.build_opener(
            # auth_handler,
            TransmissionSessionHandler())

    def call(self, method, **kwargs):
        rpc_call = {
            "method": method,
            "arguments": {k.replace("_", "-"): v for k, v in kwargs.items()},
        }

        req = urllib.request.Request(
            url=self.url, method="POST",
            headers={"content-type": "application/json"},
            data=json.dumps(rpc_call, ensure_ascii=True).encode("ascii"))

        with self.opener.open(req) as resp:
            result = json.load(resp)
            if result["result"] != "success":
                raise TransmissionRPCError(result["result"])
            return result["arguments"]


def get_torrent_activity(transmission):
    fields = ["status", "isStalled", "rateDownload", "rateUpload"]
    resp = transmission.call("torrent-get", format="table", fields=fields)
    torrents = resp["torrents"]

    # format="table" is only available in Transmission 3.0 or newer
    if torrents and isinstance(torrents[0], list):
        torrents = {k: t for k, *t in zip(*torrents)}
    else:
        torrents = {k: [t[k] for t in torrents] for k in fields}

    # XXX: does not match the web UI's active count
    active = (torrents["status"].count(4)    # downloading
              + torrents["status"].count(6)  # seeding
              - sum(torrents["isStalled"]))  # stalled

    return (
        active,
        sum(torrents["rateDownload"]) // 1e3,
        sum(torrents["rateUpload"]) // 1e3,
    )


def i3blocks_main():
    import os

    host = os.getenv("instance", "localhost:9091")
    transmission = Transmission(host)

    active, rateDownload, rateUpload = get_torrent_activity(transmission)
    print("%s %d down %d up %d" % (host, active, rateDownload, rateUpload))
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(i3blocks_main())

#!/usr/bin/env bash

# Store only text clipboard entries in cliphist.
# wl-paste can exit when the current clipboard has no text offer, so keep the
# watcher alive without enabling image history.
while true; do
    wl-paste --type text --watch cliphist store
    sleep 1
done

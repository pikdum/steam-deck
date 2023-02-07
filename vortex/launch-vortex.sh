#!/usr/bin/env bash
if [ -z "$1" ]; then
    exec /home/deck/stl/prefix/steamtinkerlaunch vortex start
fi

exec /home/deck/stl/prefix/steamtinkerlaunch vortex url "$1"

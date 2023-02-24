#!/usr/bin/env bash
if [ -z "$1" ]; then
    exec "$HOME/stl/prefix/steamtinkerlaunch" vortex start
fi

exec "$HOME/stl/prefix/steamtinkerlaunch" vortex url "$1"

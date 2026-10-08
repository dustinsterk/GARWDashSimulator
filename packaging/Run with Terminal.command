#!/bin/bash
# Double-click this to run the GARW Dash Simulator with its output (QML errors,
# hot-reload messages) shown live in this Terminal window. Closing the window
# quits the simulator. Extra options can be added after the command, e.g. --hot.
cd "$(dirname "$0")" || exit 1
APP="$(ls -d *.app 2>/dev/null | head -1)"
if [ -z "$APP" ]; then
  echo "Can't find the simulator .app next to this script."; read -r -p "Press Return to close."; exit 1
fi
"./$APP/Contents/MacOS/${APP%.app}" "$@"
CODE=$?
echo; echo "Simulator exited (code $CODE)."; read -r -p "Press Return to close this window."

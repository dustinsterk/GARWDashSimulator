GARW Dash Simulator
===================

Preview and build QML dashes for the GARW IC7 instrument cluster -- no Python
install needed.

WHAT'S IN THIS FOLDER
  GARW Dash Simulator(.app / .exe)  the simulator
  dashes/                           your dashes, one folder each -- edit freely
  screen_configs/                   settings the dashes save (like the car's
                                    /opt/.../screen_configs)

Keep these together. If the app can't find a writable dashes/ folder next to
it, it uses  Documents/GARW Dash Simulator/  instead (filled with the sample
dashes on first run). The "Open dashes folder" button (bottom-right) always
shows you which folder is in use.

FIRST LAUNCH
  macOS:   the app isn't signed by Apple, so macOS blocks it the first time.
           Easiest fix -- open Terminal, type   xattr -dr com.apple.quarantine
           (with a space at the end), drag this whole folder onto the Terminal
           window, press Return. Then double-click the app normally.
           (Or: try to open it, then System Settings > Privacy & Security >
           "Open Anyway".)  The macOS build is for Apple Silicon (M1 and later).
  Windows: SmartScreen may say "Windows protected your PC" -- click
           "More info" > "Run anyway".

BUILDING A DASH WITH HOT RELOAD
  1. Put your dash in dashes/<YourDash>/ (restart the simulator to see a new
     folder in the Dash list).
  2. Pick it, click "Hot reload".
  3. Edit and save any .qml / .js file in that folder -- the dash reloads in
     about half a second, keeping the simulated RPM/speed/inputs.
  F5 reloads once at any time. If a save has a QML error, the status bar shows
  the file, line and message; fix it and save again.

ERRORS / LOGS
  Everything the simulator would print to a terminal is written to
  simulator_log.txt next to dashes/ (fresh each launch).

TWO VERSIONS
  "GARW Dash Simulator"      Qt 6 -- use this normally.
  "GARW Dash Simulator Qt5"  Qt 5 -- only needed for dashes that use Qt 5-style
                             inline GLSL ShaderEffects (closest to the IC7's
                             Qt 5.12).


<img width="1312" height="1104" alt="GARWSimulator" src="https://github.com/user-attachments/assets/3a0173d4-1513-4560-883d-7c69ce989f43" />

## Download (no Python needed)

Ready-to-run apps for **macOS (Apple Silicon)** and **Windows** are on the
[Releases page](https://github.com/dustinsterk/GARWDashSimulator/releases).
Unzip, keep the app and its `dashes/` folder together, and read
`README-FIRST.txt` (first-launch steps for macOS Gatekeeper / Windows SmartScreen).

* **GARW Dash Simulator** -- Qt 6, use this normally.
* **GARW Dash Simulator Qt5** -- only for dashes using Qt 5-style inline shaders.

## Run from source

**You need the following package installed:**
* PySide6
* PyQt5 (for the QT5 version if using inline shaders in your design)
  
**OSX environments:**
* python3 -m pip install PySide6
* brew install pyside (possibly not needed)
* brew install qt5compat (possibly not needed)
  
**Windows environments:**
* python -m pip install PySide6

**If using the QT5 simulator file (if you want to render shaders inline)**
**OSX environments:**
* brew install pyqt@5

**Windows environments:**
* python -m pip install PyQt5

**Run the simulator via terminal with these commands (so you can see errors in the output too):**
* python3 dash_sim.py **OR** python3 dash_sim_qt5.py (OSX)
* python dash_sim.py **OR** python dash_sim_qt5.py (Windows)

* * Add new dashed by adding the files into the 'dashes' folder (you may need to restart the sim to see them).
* * All settings are saved to the local "screen_configs" folder even when there is a hardcoded path when on device for easy use/testing.


## Hot reload (build dashes live)

Pick a dash and click **⟳ Hot reload**. Every time you save a `.qml`, `.js` or
`qmldir` file in that dash's folder (including child components it imports), the
dash reloads within about half a second. Simulated RPM/speed/inputs carry over;
only the dash's own QML state (an open menu, a running animation) restarts.

* **F5** reloads once at any time. `--hot` on the command line starts with it on.
* A broken save shows the error (file, line, message) in the status bar -- fix it,
  save again, no restart needed. `let`/`const` (unsupported on the IC7) is flagged too.
* Works with any editor, including ones that save via temp-file-and-rename
  (VS Code, vim, Qt Creator).
* Images aren't watched (Qt caches them); restart to see a changed PNG.
* **Open dashes folder** (bottom-right) opens the folder in use.

**Console output in the packaged apps:** on Windows run *GARW Dash Simulator Console.exe*; on macOS double-click *Run with Terminal.command* (both ship in the release zip). Output is also written to `simulator_log.txt` beside `dashes/`.

## Building the apps

`.github/workflows/build.yml` builds both versions for macOS and Windows with
PyInstaller, launches each built app with `--smoke-test` to make sure it can
load dashes, and zips it with an editable `dashes/` folder.

* **Actions → Build simulator apps → Run workflow** builds them (download from the run's *Artifacts*).
* Pushing a version tag also publishes a Release:
  `git tag v1.0.0 && git push origin v1.0.0`

Build locally: `pip install pyinstaller PySide6` then
`pyinstaller --noconfirm packaging/GARWDashSimulator.spec`
(for the Qt 5 version: `pip install pyinstaller PyQt5`, and set `GARW_VARIANT=qt5`).
On macOS this also puts `Run with Terminal.command` (Qt5: `Run Qt5 with Terminal.command`) next to the `.app` in `dist/`.

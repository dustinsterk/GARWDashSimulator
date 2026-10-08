# -*- mode: python ; coding: utf-8 -*-
#
# PyInstaller spec for the GARW Dash Simulator.
#
#   GARW_VARIANT=qt6  (default) -> dash_sim.py      (PySide6 / Qt 6)
#   GARW_VARIANT=qt5            -> dash_sim_qt5.py  (PyQt5 / Qt 5, renders inline shaders)
#
# Build locally from the repo root:
#   pip install pyinstaller PySide6          (or PyQt5 for the qt5 variant)
#   pyinstaller --noconfirm packaging/GARWDashSimulator.spec
#
# Output: dist/<name>/ (Windows/Linux folder with the exe) or dist/<name>.app (macOS).
# The GitHub Actions workflow (.github/workflows/build.yml) runs this on macOS and
# Windows and zips the result together with an editable dashes/ folder.

import os
import sys

VARIANT = os.environ.get("GARW_VARIANT", "qt6").strip().lower()
VERSION = os.environ.get("GARW_VERSION", "0.0.0").lstrip("v") or "0.0.0"
ROOT = os.path.abspath(os.path.join(SPECPATH, ".."))

if VARIANT == "qt5":
    SCRIPT = "dash_sim_qt5.py"
    NAME = "GARW Dash Simulator Qt5"
    EXCLUDES = ["PySide6", "shiboken6", "PyQt6"]
else:
    SCRIPT = "dash_sim.py"
    NAME = "GARW Dash Simulator"
    EXCLUDES = ["PyQt5", "PyQt6"]

EXCLUDES += ["tkinter", "unittest", "pydoc_data"]

SKIP_FILES = {".DS_Store", "Thumbs.db", "desktop.ini"}
SKIP_DIRS = {".git", "__pycache__", "__MACOSX"}


def tree(sub):
    """(source, dest_dir) pairs for every file under ROOT/sub, minus OS junk."""
    out = []
    for dirpath, dirnames, filenames in os.walk(os.path.join(ROOT, sub)):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            if fn in SKIP_FILES or fn.startswith("._"):
                continue
            out.append((os.path.join(dirpath, fn), os.path.relpath(dirpath, ROOT)))
    return out


# qmlcompat is required at runtime. dashes/ + screen_configs/ are bundled as the
# sample set that seeds Documents/GARW Dash Simulator/ when the app runs without
# an editable dashes/ folder beside it (see app_paths.py).
datas = tree("qmlcompat") + tree("dashes") + tree("screen_configs")

a = Analysis(
    [os.path.join(ROOT, SCRIPT)],
    pathex=[ROOT],
    binaries=[],
    datas=datas,
    hiddenimports=["hot_reload", "app_paths"],
    hookspath=[],
    runtime_hooks=[],
    excludes=EXCLUDES,
    noarchive=False,
)

# PyInstaller collects Qt's whole QML tree. Drop the heavy modules no IC7 dash
# can use (the cluster runs Qt 5.12 QtQuick) -- WebEngine alone is ~150 MB.
# QtQuick, Shapes, Qt5Compat/QtGraphicalEffects, Multimedia, Charts are kept.
DROP = ("webengine", "webview", "quick3d", "qt63d", "qt53d", "/qt3d", "\\qt3d",
        "qtpdf", "qt6pdf", "virtualkeyboard", "datavisualization", "qt6graphs",
        "/qtgraphs", "\\qtgraphs", "spatialaudio", "texttospeech", "scxml",
        "remoteobjects", "designer", "qtquickeffectmaker")


def _keep(entry):
    dest = entry[0].lower()
    return not any(k in dest for k in DROP)


a.binaries = [e for e in a.binaries if _keep(e)]
a.datas = [e for e in a.datas if _keep(e)]

pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name=NAME,
    debug=False,
    strip=False,
    upx=False,
    console=False,          # windowed: QML errors go to simulator_log.txt + status bar
    argv_emulation=False,
)

coll = COLLECT(exe, a.binaries, a.datas, strip=False, upx=False, name=NAME)

if sys.platform == "darwin":
    app = BUNDLE(
        coll,
        name=NAME + ".app",
        bundle_identifier="com.github.dustinsterk.garwdashsimulator" + ("-qt5" if VARIANT == "qt5" else ""),
        version=VERSION,
        info_plist={
            "CFBundleDisplayName": NAME,
            "CFBundleShortVersionString": VERSION,
            "NSHighResolutionCapable": True,
            "LSMinimumSystemVersion": "11.0",
        },
    )

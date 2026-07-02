#!/usr/bin/env python3
"""
IC7 Dash Simulator
==================

A cross-platform (macOS / Windows / Linux) real-time simulator for GARW IC7
instrument-cluster QML designs.

It renders a dash QML exactly the way the car does -- by exposing a global
"rpmtest" context property carrying the same fields the IC7 firmware provides
(rpmdata, speeddata, geardata, watertempdata, fueldata, batteryvoltagedata,
inputsdata bit flags, ...).  A live control panel drives those fields so you can
see the dash react in real time, and a demo loop can play a full driving cycle.

Run:  python dash_sim.py
Deps: PySide6   (pip install -r requirements.txt)
"""

import os
import sys
import json
import glob

from PySide6.QtCore import (Qt, QObject, Property, Signal, Slot, QUrl, QTimer,
                            QEvent, qInstallMessageHandler, QtMsgType)
from PySide6.QtGui import QFont, QKeyEvent
from PySide6.QtQml import qmlRegisterType
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QHBoxLayout, QVBoxLayout, QGridLayout,
    QLabel, QSlider, QCheckBox, QComboBox, QPushButton, QGroupBox, QScrollArea,
    QSizePolicy, QFrame, QLineEdit, QMessageBox,
)
from PySide6.QtQuickWidgets import QQuickWidget

HERE = os.path.dirname(os.path.abspath(__file__))


def _find_dir(name):
    """Return <HERE>/<name> if it exists, else <HERE> if it directly contains
    the expected pieces (flat layout), else <HERE>/<name> anyway."""
    nested = os.path.join(HERE, name)
    if os.path.isdir(nested):
        return nested
    return nested


def _find_stage():
    """Stage.qml normally lives in qmlcompat/, but tolerate a flat layout
    where it sits next to dash_sim.py."""
    for cand in (os.path.join(QMLCOMPAT, "Stage.qml"),
                 os.path.join(HERE, "Stage.qml")):
        if os.path.isfile(cand):
            return cand
    return os.path.join(QMLCOMPAT, "Stage.qml")   # report the expected path


QMLCOMPAT = _find_dir("qmlcompat")
DASHES_DIR = _find_dir("dashes")
STAGE_QML = None   # resolved at window build time (after QMLCOMPAT is set)


def _pyside_qml_dir():
    """Path to the QML modules bundled inside the installed PySide6."""
    try:
        import PySide6
        base = os.path.dirname(PySide6.__file__)
        for sub in ("Qt/qml", "qml"):
            cand = os.path.join(base, sub)
            if os.path.isdir(cand):
                return cand
    except Exception:
        pass
    return None


def _has_qt5compat_effects():
    """True if Qt5Compat.GraphicalEffects (the real effects module that the
    forwarding shim depends on) is present in this PySide6 install."""
    qml = _pyside_qml_dir()
    if not qml:
        return False
    return os.path.isfile(
        os.path.join(qml, "Qt5Compat", "GraphicalEffects", "qmldir"))


# ---------------------------------------------------------------------------
#  Data model -- mirrors the IC7 firmware's "rpmtest" context object.
#  Every property the bundled dashes read is present here.
#
#  Each field has its OWN change signal. This matters: on the real car the
#  firmware updates each field independently, so a binding like
#  `udp_message: rpmtest.udp_packetdata` only re-evaluates when udp_packetdata
#  actually changes. If every field shared one signal, writing an unrelated
#  field (e.g. the screen writing settings_on_offdata when its menu opens)
#  would re-fire the udp_message binding too -- and that cross-coupling can trip
#  Qt's binding-loop detector, which then freezes the binding so the joystick
#  input is never seen again. Per-field signals avoid that entirely.
# ---------------------------------------------------------------------------
class DashData(QObject):
    rpmdataChanged             = Signal()
    speeddataChanged           = Signal()
    geardataChanged            = Signal()
    watertempdataChanged       = Signal()
    fueldataChanged            = Signal()
    oiltempdataChanged         = Signal()
    oilpressuredataChanged     = Signal()
    batteryvoltagedataChanged  = Signal()
    inputsdataChanged          = Signal()
    odometer0dataChanged       = Signal()
    tripmileage0dataChanged    = Signal()
    udp_packetdataChanged      = Signal()
    mafdataChanged             = Signal()
    mapdataChanged             = Signal()
    o2dataChanged              = Signal()
    settings_on_offdataChanged = Signal()
    symbolsdataChanged         = Signal()
    symbols2dataChanged        = Signal()
    can203dataChanged          = Signal()
    canasciidataChanged        = Signal()

    def __init__(self):
        super().__init__()
        self._v = {
            "rpmdata": 0.0,
            "speeddata": 0.0,
            "geardata": 0,
            "watertempdata": 80.0,
            "fueldata": 60.0,
            "oiltempdata": 90.0,
            "oilpressuredata": 4.0,
            "batteryvoltagedata": 13.8,
            "inputsdata": 0,
            "odometer0data": 42000,
            "tripmileage0data": 1234,     # tenths of a unit (dash /10)
            "udp_packetdata": 0,
            "mafdata": 8.0,
            "mapdata": 100.0,
            "o2data": 1.0,
            "settings_on_offdata": 0,
            "symbolsdata": 0,
            "symbols2data": 0,
            "can203data": [0] * 16,
            "canasciidata": "",
        }

    def _notify(self, key):
        sig = getattr(self, key + "Changed", None)
        if sig is not None:
            sig.emit()

    def set(self, key, value):
        if self._v.get(key) != value:
            self._v[key] = value
            self._notify(key)

    def set_bit(self, mask, on):
        cur = self._v["inputsdata"]
        new = (cur | mask) if on else (cur & ~mask)
        if new != cur:
            self._v["inputsdata"] = new
            self.inputsdataChanged.emit()

    def set_udp_bit(self, mask, on):
        cur = self._v["udp_packetdata"]
        new = (cur | mask) if on else (cur & ~mask)
        if new != cur:
            self._v["udp_packetdata"] = new
            self.udp_packetdataChanged.emit()

    # --- Qt properties read by QML (rpmtest.<name>) ------------------------
    def _g(k):
        return lambda self: self._v[k]

    def _set_settings(self, v):              # settings screens write this back
        if self._v["settings_on_offdata"] != v:
            self._v["settings_on_offdata"] = v
            self.settings_on_offdataChanged.emit()

    rpmdata            = Property(float, _g("rpmdata"),            notify=rpmdataChanged)
    speeddata          = Property(float, _g("speeddata"),          notify=speeddataChanged)
    geardata           = Property(int,   _g("geardata"),           notify=geardataChanged)
    watertempdata      = Property(float, _g("watertempdata"),      notify=watertempdataChanged)
    fueldata           = Property(float, _g("fueldata"),           notify=fueldataChanged)
    oiltempdata        = Property(float, _g("oiltempdata"),        notify=oiltempdataChanged)
    oilpressuredata    = Property(float, _g("oilpressuredata"),    notify=oilpressuredataChanged)
    batteryvoltagedata = Property(float, _g("batteryvoltagedata"), notify=batteryvoltagedataChanged)
    inputsdata         = Property(int,   _g("inputsdata"),         notify=inputsdataChanged)
    odometer0data      = Property(int,   _g("odometer0data"),      notify=odometer0dataChanged)
    tripmileage0data   = Property(int,   _g("tripmileage0data"),   notify=tripmileage0dataChanged)
    udp_packetdata     = Property(int,   _g("udp_packetdata"),     notify=udp_packetdataChanged)
    mafdata            = Property(float, _g("mafdata"),            notify=mafdataChanged)
    mapdata            = Property(float, _g("mapdata"),            notify=mapdataChanged)
    o2data             = Property(float, _g("o2data"),             notify=o2dataChanged)
    settings_on_offdata= Property(int,   _g("settings_on_offdata"), _set_settings,
                                  notify=settings_on_offdataChanged)
    symbolsdata        = Property(int,   _g("symbolsdata"),        notify=symbolsdataChanged)
    symbols2data       = Property(int,   _g("symbols2data"),       notify=symbols2dataChanged)
    can203data         = Property(list,  _g("can203data"),         notify=can203dataChanged)
    canasciidata       = Property(str,   _g("canasciidata"),       notify=canasciidataChanged)


# ---------------------------------------------------------------------------
#  FileIO  --  QML type matching the car's custom "FileIO 1.0" plugin, so dash
#  screens that read/write a config file work in the simulator.
#
#  Two APIs are supported, matching the car's plugin:
#
#  1) Simple:   cfg.write(text) -> bool ,  cfg.read() -> string
#
#  2) Line-based (used by the *_main.qml settings screens):
#         // write:
#         cfg.open()                       // open/truncate for writing
#         cfg.writetoopenfile("value")     // append text
#         cfg.writetoopenfile("\n")
#         cfg.close()                      // flush to disk
#         // read:
#         cfg.openforreading()             // load the file
#         var line = cfg.readopenfile(n)   // n-th line (0-based), "" if absent
#         cfg.close()
#
#  Where files go: all reads/writes land in a single top-level
#  <DashSimulator>/screen_configs/ directory (mirroring the car's
#  /opt/Garw_IC7/screen_configs/). A car-style absolute `source` is mapped there
#  by the part of its path after the "screen_configs" segment (else its
#  basename), so "/opt/Garw_IC7/screen_configs/lfa_config.txt" becomes
#  screen_configs/lfa_config.txt. On first read, if no file exists there yet, a
#  default shipped next to the dash with the same name is used (seed).
# ---------------------------------------------------------------------------
class FileIO(QObject):
    error = Signal(str, arguments=["msg"])
    sourceChanged = Signal(str, arguments=["source"])

    # Set by MainWindow. config_dir is the shared screen_configs directory;
    # dash_dir is the selected dash's folder (used to seed defaults).
    dash_dir = os.getcwd()
    config_dir = os.getcwd()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._source = ""
        self._mode = None        # "r" or "w" while a line-based file is open
        self._wbuf = []          # pending write text
        self._rlines = []        # loaded lines for readopenfile()

    def _get_source(self):
        return self._source

    def _set_source(self, s):
        if s != self._source:
            self._source = s
            self.sourceChanged.emit(s)

    source = Property(str, _get_source, _set_source, notify=sourceChanged)

    # -- path mapping ----------------------------------------------------
    @staticmethod
    def _rel(source):
        """Map a QML `source` to a safe relative name under screen_configs:
        the path tail after a 'screen_configs' segment, else the basename."""
        s = source
        if s.startswith("file://"):
            s = QUrl(s).toLocalFile()
        elif s.startswith("qrc:/"):
            s = s[5:]
        elif s.startswith("qrc:"):
            s = s[4:]
        s = s.replace("\\", "/")
        parts = [p for p in s.split("/") if p and p not in (".", "..")]
        if not parts:
            return "config.dat"
        if "screen_configs" in parts:
            tail = parts[parts.index("screen_configs") + 1:]
            if tail:
                return os.path.join(*tail)
        return parts[-1]                      # basename

    def _sandbox_path(self):
        return os.path.join(FileIO.config_dir, self._rel(self._source))

    def _seed_path(self):
        return os.path.join(FileIO.dash_dir, os.path.basename(self._rel(self._source)))

    def _load_text(self):
        for path in (self._sandbox_path(), self._seed_path()):
            try:
                if os.path.isfile(path):
                    with open(path, "r", encoding="utf-8", errors="replace") as f:
                        return f.read()
            except Exception as e:
                self.error.emit("FileIO read error: %s" % e)
                return ""
        return ""                              # no file yet -- normal first run

    # -- simple API ------------------------------------------------------
    @Slot(result=str)
    def read(self):
        if not self._source:
            self.error.emit("FileIO.read(): no source set")
            return ""
        return self._load_text()

    @Slot(str, result=bool)
    def write(self, data):
        if not self._source:
            self.error.emit("FileIO.write(): no source set")
            return False
        path = self._sandbox_path()
        try:
            os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
            with open(path, "w", encoding="utf-8") as f:
                f.write(data if isinstance(data, str) else str(data))
            return True
        except Exception as e:
            self.error.emit("FileIO.write(): %s" % e)
            return False

    @Slot(result=bool)
    def exists(self):
        return os.path.isfile(self._sandbox_path()) or os.path.isfile(self._seed_path())

    @Slot(result=str)
    def readAll(self):                                   # common alias
        return self.read()

    # -- line-based API (matches the car's *_main.qml usage) -------------
    @Slot()
    def open(self):
        """Open/truncate for writing (buffered until close())."""
        self._mode = "w"
        self._wbuf = []

    @Slot(str)
    @Slot(float)
    @Slot(int)
    def writetoopenfile(self, text):
        if self._mode != "w":
            self._mode = "w"
            self._wbuf = []
        self._wbuf.append(text if isinstance(text, str) else str(text))

    @Slot()
    def openforreading(self):
        """Load the file so readopenfile(n) can return line n."""
        self._mode = "r"
        self._rlines = self._load_text().split("\n")

    @Slot(int, result=str)
    @Slot(result=str)
    def readopenfile(self, index=0):
        if self._mode != "r":
            self._rlines = self._load_text().split("\n")
            self._mode = "r"
        try:
            return self._rlines[int(index)]
        except (IndexError, ValueError):
            return ""

    @Slot()
    def close(self):
        if self._mode == "w":
            path = self._sandbox_path()
            try:
                os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
                with open(path, "w", encoding="utf-8") as f:
                    f.write("".join(self._wbuf))
            except Exception as e:
                self.error.emit("FileIO.close()/write: %s" % e)
        self._mode = None
        self._wbuf = []
        self._rlines = []


# ---------------------------------------------------------------------------
#  inputsdata bit map (superset across the bundled dashes).
# ---------------------------------------------------------------------------
INPUT_BITS = [
    ("Ignition",          0x01),
    ("Battery warn",      0x02),
    ("Lap marker",        0x04),
    ("Rear fog",          0x08),
    ("Main beam",         0x10),
    ("Left indicator",    0x40),
    ("Right indicator",   0x80),
    ("Brake",             0x100),
    ("Oil warn",          0x200),
    ("Seatbelt",          0x400),
    ("Side lights",       0x800),
    ("Trip reset",        0x1000),
    ("Door open",         0x4000),
    ("Airbag",            0x8000),
    ("Traction ctrl",     0x10000),
    ("ABS",               0x20000),
    ("MIL (check engine)",0x40000),
    ("Shift light 1",     0x80000),
    ("Shift light 2",     0x100000),
    ("Shift light 3",     0x200000),
    ("Service",           0x400000),
    ("Race mode",         0x800000),
    ("Sport mode",        0x1000000),
    ("Cruise",            0x2000000),
    ("Reverse",           0x4000000),
    ("Handbrake",         0x8000000),
    ("TC off",            0x10000000),
]
# Note: the four joystick bits (up 0x20, down 0x2000, left 0x20000000,
# right 0x40000000) are intentionally not checkboxes -- they're driven by the
# Remote (D-pad) control instead.

GEARS = [("N", 0), ("1", 1), ("2", 2), ("3", 3), ("4", 4),
         ("5", 5), ("6", 6), ("7", 7), ("8", 8), ("P", 9), ("R", 10)]


# ---------------------------------------------------------------------------
#  A labeled slider row that reports float values (with optional scaling).
# ---------------------------------------------------------------------------
class SliderRow(QWidget):
    def __init__(self, label, lo, hi, init, scale=1.0, unit="", fmt="{:.0f}",
                 on_change=None):
        super().__init__()
        self.scale = scale
        self.fmt = fmt
        self.unit = unit
        self.on_change = on_change
        lay = QHBoxLayout(self)
        lay.setContentsMargins(0, 0, 0, 0)
        lay.setSpacing(8)
        self.name = QLabel(label)
        self.name.setMinimumWidth(120)
        self.slider = QSlider(Qt.Horizontal)
        self.slider.setMinimum(int(lo / scale))
        self.slider.setMaximum(int(hi / scale))
        self.slider.setValue(int(init / scale))
        self.value = QLabel()
        self.value.setMinimumWidth(74)
        self.value.setAlignment(Qt.AlignRight | Qt.AlignVCenter)
        self.slider.valueChanged.connect(self._changed)
        lay.addWidget(self.name)
        lay.addWidget(self.slider, 1)
        lay.addWidget(self.value)
        self._refresh()

    def _changed(self, _):
        self._refresh()
        if self.on_change:
            self.on_change(self.real_value())

    def real_value(self):
        return self.slider.value() * self.scale

    def set_real(self, v):
        self.slider.blockSignals(True)
        self.slider.setValue(int(round(v / self.scale)))
        self.slider.blockSignals(False)
        self._refresh()

    def set_real_max(self, real_max):
        """Set the slider's maximum in real (unscaled) units."""
        self.slider.setMaximum(int(round(real_max / self.scale)))

    def _refresh(self):
        txt = self.fmt.format(self.real_value())
        if self.unit:
            txt += " " + self.unit
        self.value.setText(txt)

    def setEnabled(self, on):
        self.slider.setEnabled(on)


# ---------------------------------------------------------------------------
#  Main window: QML render stage on the left, live controls on the right.
# ---------------------------------------------------------------------------
class MainWindow(QMainWindow):
    def __init__(self, data):
        super().__init__()
        self.data = data
        self.setWindowTitle("IC7 Dash Simulator")
        self.resize(1180, 620)

        central = QWidget()
        self.setCentralWidget(central)
        root = QHBoxLayout(central)
        root.setContentsMargins(8, 8, 8, 8)
        root.setSpacing(8)

        # --- QML render stage -------------------------------------------
        self.view = QQuickWidget()
        self.view.setResizeMode(QQuickWidget.SizeRootObjectToView)
        eng = self.view.engine()

        # Make sure PySide6's own bundled QML modules are findable (this is
        # where Qt5Compat.GraphicalEffects lives when it is installed).
        pyside_qml = _pyside_qml_dir()
        if pyside_qml:
            eng.addImportPath(pyside_qml)

        # QtGraphicalEffects shim: if the real Qt5Compat.GraphicalEffects module
        # is available, use the forwarding shim (full-fidelity effects). If it
        # is missing (e.g. a PySide6-Essentials install), fall back to a
        # self-contained no-op shim so effect-using dashes (LFA) still load --
        # they just render without the cosmetic effect.
        stub_dir = os.path.join(QMLCOMPAT, "stub")
        if _has_qt5compat_effects():
            eng.addImportPath(QMLCOMPAT)
        elif os.path.isdir(os.path.join(stub_dir, "QtGraphicalEffects")):
            eng.addImportPath(stub_dir)
            sys.stderr.write(
                "[dash_sim] Qt5Compat.GraphicalEffects not found -- using the "
                "no-op effects fallback.\n  Effect-based dashes will load but "
                "without graphical effects (e.g. the LFA needle shadow).\n  For "
                "full-fidelity effects, install full PySide6:  pip install "
                "PySide6\n")
        else:
            eng.addImportPath(QMLCOMPAT)   # last resort: try the forwarding shim

        eng.addImportPath(HERE)
        for d in self._dash_dirs():
            eng.addImportPath(d)
        # Expose the same data object under both names: older firmware/screens
        # bind to `rpmtest`, newer ones to `realtimedata`. Pointing both at the
        # same instance means a dash works with whichever name it references.
        self.view.rootContext().setContextProperty("rpmtest", self.data)
        self.view.rootContext().setContextProperty("realtimedata", self.data)

        stage_qml = _find_stage()
        if not os.path.isfile(stage_qml):
            sys.stderr.write(
                "\n[dash_sim] Cannot find Stage.qml.\n"
                "  Run dash_sim.py from inside the full DashSimulator folder,\n"
                "  which must contain:  qmlcompat/  and  dashes/\n"
                f"  Looked in: {QMLCOMPAT}\n\n")
        self.view.setSource(QUrl.fromLocalFile(stage_qml))
        self.view.setMinimumSize(720, 432)        # 1.5x of 480x288, keeps 5:3
        self.view.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.stage = self.view.rootObject()        # may be None if Stage.qml missing
        frame = QFrame()
        frame.setStyleSheet("QFrame{background:#000;border:1px solid #2a2f3a;}")
        fl = QVBoxLayout(frame)
        fl.setContentsMargins(1, 1, 1, 1)
        fl.addWidget(self.view)
        root.addWidget(frame, 1)

        # --- Control panel ----------------------------------------------
        root.addWidget(self._build_panel(), 0)

        # --- Demo loop --------------------------------------------------
        self.demo_timer = QTimer(self)
        self.demo_timer.setInterval(33)            # ~30 fps
        self.demo_timer.timeout.connect(self._demo_tick)
        self.demo_phase = 0.0

        self.dashes = self._load_dash_list()
        self.dash_combo.addItems([d["name"] for d in self.dashes])
        # Select the first dash in the list on launch.
        default_idx = 0
        self.dash_combo.setCurrentIndex(default_idx)
        self._select_dash(default_idx)
        self._push_all()

        # Route arrow keys to the D-pad (held = bit stays set, for value ramps).
        self._key_map = {Qt.Key_Up: "up", Qt.Key_Down: "down",
                         Qt.Key_Left: "left", Qt.Key_Right: "right"}
        QApplication.instance().installEventFilter(self)

        self._fit_window()

    def _fit_window(self):
        """Open large enough to show the whole control panel without scrolling,
        clamped to the available screen size, and centred."""
        body = getattr(self, "_scroll_body", None)
        # Height the control panel wants with nothing hidden: dropdown + note +
        # all the scrollable controls.
        panel_h = 24
        panel_h += self.dash_combo.sizeHint().height()
        panel_h += self.note.sizeHint().height()
        # Reserve space for the demo-speed row even though it's hidden at launch,
        # so toggling the demo on doesn't push content into a scroll.
        if getattr(self, "demo_speed_row", None) is not None:
            panel_h += self.demo_speed_row.sizeHint().height() + 6
        if body is not None:
            body.ensurePolished()
            panel_h += body.sizeHint().height()
        # The render area has its own minimum; take whichever side is taller.
        content_h = max(self.view.minimumHeight(), panel_h)
        win_w, win_h = 1200, content_h + 56     # + window chrome / margins

        screen = QApplication.primaryScreen()
        if screen is not None:
            avail = screen.availableGeometry()
            win_w = min(win_w, avail.width() - 40)
            win_h = min(win_h, avail.height() - 60)
        self.resize(win_w, win_h)
        if screen is not None:
            fg = self.frameGeometry()
            fg.moveCenter(screen.availableGeometry().center())
            self.move(fg.topLeft())

    def eventFilter(self, obj, event):
        et = event.type()
        if et in (QEvent.KeyPress, QEvent.KeyRelease) and isinstance(event, QKeyEvent):
            key = event.key()
            if key in self._key_map:
                name = self._key_map[key]
                if et == QEvent.KeyPress:
                    self._pad_press(name)
                    self.pad_buttons[name].setDown(True)
                elif not event.isAutoRepeat():
                    self._pad_release(name)
                    self.pad_buttons[name].setDown(False)
                return True   # arrow keys belong to the remote, not the sliders
        return super().eventFilter(obj, event)

    # ---- D-pad (remote) -------------------------------------------------
    # A direction's udp bit is set on press and cleared shortly after release.
    # The brief hold guarantees the QML side observes the rising edge even on a
    # very fast click (otherwise press+release can collapse into one binding
    # pass and the screen never sees the direction go high). Holding keeps the
    # bit set the whole time, so values still ramp.
    def _pad_press(self, name):
        t = self._pad_clear.get(name)
        if t is not None:
            t.stop()
        self.data.set_udp_bit(self.UDP[name], True)

    def _pad_release(self, name):
        t = self._pad_clear.get(name)
        if t is None:
            t = QTimer(self)
            t.setSingleShot(True)
            t.timeout.connect(lambda n=name: self.data.set_udp_bit(self.UDP[n], False))
            self._pad_clear[name] = t
        t.start(70)   # ms; clear shortly after release

    # ---- dash discovery -------------------------------------------------
    def _dash_dirs(self):
        return [p for p in glob.glob(os.path.join(DASHES_DIR, "*")) if os.path.isdir(p)]

    def _load_dash_list(self):
        out = []
        for d in sorted(self._dash_dirs()):
            meta_path = os.path.join(d, "dash.json")
            raw = {}
            if os.path.exists(meta_path):
                with open(meta_path) as f:
                    raw = json.load(f)
            # A folder may define a single dash ("entry") or several screens
            # ("entries": [ {name, entry, ...}, ... ]) sharing the same assets.
            if "entries" in raw:
                entries = raw["entries"]
            elif "entry" in raw:
                entries = [raw]
            else:
                qmls = [os.path.basename(q) for q in glob.glob(os.path.join(d, "*.qml"))
                        if os.path.basename(q) not in ("main.qml", "capture.qml")]
                if not qmls:
                    continue
                # A "Foo_main.qml" is the full screen (it embeds the bare
                # "Foo.qml" gauge and adds the settings menu). When present,
                # those are the selectable dashes; the embedded gauge files are
                # hidden. Otherwise every .qml is its own dash.
                mains = [q for q in qmls if q.endswith("_main.qml")]
                chosen = mains if mains else qmls
                entries = [{"name": os.path.splitext(q)[0][:-5] if q.endswith("_main.qml")
                            else os.path.splitext(q)[0],
                            "entry": q} for q in chosen]
            for e in entries:
                meta = dict(e)
                meta["dir"] = d
                meta["entry_path"] = os.path.join(d, meta["entry"])
                meta.setdefault("name", os.path.splitext(meta["entry"])[0])
                meta.setdefault("rpmmax", raw.get("rpmmax", 10000))
                meta.setdefault("speedmax", raw.get("speedmax", 320))
                out.append(meta)
        return out

    def _select_dash(self, idx):
        if not (0 <= idx < len(self.dashes)):
            return
        meta = self.dashes[idx]
        # rescale rpm / speed sliders to the dash's range (RPM capped at 10000)
        self.rpm.set_real_max(min(10000, meta["rpmmax"]))
        self.speed.set_real_max(meta["speedmax"])
        # Point FileIO at this dash (must happen before the dash loads, since
        # the dash creates FileIO objects during construction). All screens
        # share one screen_configs dir, mirroring the car.
        FileIO.dash_dir = meta["dir"]
        FileIO.config_dir = os.path.join(HERE, "screen_configs")
        url = QUrl.fromLocalFile(meta["entry_path"])
        if self.stage is not None:
            self.stage.setProperty("dashSource", url)
        self.note.setText(meta.get("notes", ""))
        # Warn if the dash's QML uses ES6 'let'/'const' declarations, which the
        # IC7's QML/JS engine (Qt 5.12 QV4) does not support.
        hits = self._scan_for_let(meta["dir"])
        if hits:
            if self.isVisible():
                self._warn_unsupported_js(hits)
            else:
                # Startup: the window isn't shown and the event loop isn't
                # running yet, so a popup created now never appears. Defer it
                # until the loop starts.
                QTimer.singleShot(0, lambda h=hits: self._warn_unsupported_js(h))

    # ---- IC7 compatibility checks --------------------------------------
    def _scan_for_let(self, dash_dir):
        """Find ES6 'let'/'const' declarations in the dash's QML files. Returns a
        list of (relative_path, line_number, keyword, line_text). Skips line
        comments and matches inside string literals to avoid false positives."""
        import re
        pat = re.compile(r"\b(let|const)\s+[A-Za-z_$\[{]")
        hits = []
        for root_, _dirs, files in os.walk(dash_dir):
            for fn in files:
                if not fn.lower().endswith(".qml"):
                    continue
                fp = os.path.join(root_, fn)
                try:
                    with open(fp, "r", encoding="utf-8", errors="replace") as fh:
                        for n, line in enumerate(fh, 1):
                            code = line.split("//", 1)[0]      # drop line comments
                            for m in pat.finditer(code):
                                before = code[:m.start()]
                                # crude: inside a string if an odd number of
                                # unescaped quotes precede the match
                                dq = before.count('"') - before.count('\\"')
                                sq = before.count("'") - before.count("\\'")
                                if dq % 2 == 0 and sq % 2 == 0:
                                    hits.append((os.path.relpath(fp, dash_dir),
                                                 n, m.group(1), line.strip()))
                except OSError:
                    pass
        return hits

    def _warn_unsupported_js(self, hits):
        kinds = sorted({kw for _rel, _ln, kw, _text in hits})
        quoted = " and ".join("'%s'" % k for k in kinds)   # 'const' / 'let' and 'const'
        msg = ("This code is using %s instead of var declarations which is "
               "unsupported on the IC7 hardware. Please update the code to use "
               "'var' declarations." % quoted)
        sys.stderr.write("\n[IC7 compatibility] " + msg + "\n")
        for rel, ln, kw, text in hits:
            sys.stderr.write("    %s:%d   (%s)  %s\n" % (rel, ln, kw, text))
        sys.stderr.flush()
        detail = "\n".join("%s : line %d  (%s)\n    %s" % (rel, ln, kw, text)
                           for rel, ln, kw, text in hits)
        box = getattr(self, "_js_warn_box", None)
        if box is not None:
            box.close()
        box = QMessageBox(self)
        box.setIcon(QMessageBox.Warning)
        box.setWindowTitle("Unsupported QML/JS on IC7")
        box.setText(msg)
        box.setDetailedText(detail)
        box.setStandardButtons(QMessageBox.Ok)
        box.setModal(False)
        box.show()
        self._js_warn_box = box

    # ---- control panel widgets -----------------------------------------
    def _build_panel(self):
        PANEL_W = 410
        panel = QWidget()
        panel.setFixedWidth(PANEL_W)          # fixed, not max: nothing renegotiates
        outer = QVBoxLayout(panel)
        outer.setContentsMargins(0, 0, 0, 0)
        outer.setSpacing(4)

        # dash selector + demo toggle
        top = QHBoxLayout()
        top.addWidget(QLabel("Dash:"))
        self.dash_combo = QComboBox()
        self.dash_combo.currentIndexChanged.connect(self._on_dash_changed)
        top.addWidget(self.dash_combo, 1)
        self.demo_btn = QPushButton("\u25b6  Demo")
        self.demo_btn.setCheckable(True)
        self.demo_btn.toggled.connect(self._toggle_demo)
        top.addWidget(self.demo_btn)
        outer.addLayout(top)

        # demo speed (0 .. 2x) with a perceptual (quadratic) response: the slow
        # end gets most of the slider travel (fine control), so the 0.15x default
        # sits at a natural position rather than jammed against the left. 2x is
        # still reachable at the far right.
        self.DEMO_SPEED_MAX = 2.0
        self.demo_speed = 0.15
        self.demo_speed_row = QWidget()
        sp = QHBoxLayout(self.demo_speed_row)
        sp.setContentsMargins(0, 0, 0, 0)
        sp.addWidget(QLabel("Demo speed"))
        self.demo_speed_slider = QSlider(Qt.Horizontal)
        self.demo_speed_slider.setMinimum(0)
        self.demo_speed_slider.setMaximum(1000)
        self.demo_speed_slider.setSingleStep(5)
        self.demo_speed_slider.setPageStep(25)
        self.demo_speed_slider.setValue(self._demo_speed_to_pos(0.15))
        self.demo_speed_lbl = QLabel("0.15\u00d7")
        self.demo_speed_lbl.setFixedWidth(46)
        self.demo_speed_lbl.setAlignment(Qt.AlignRight | Qt.AlignVCenter)

        def _on_demo_speed(pos):
            self.demo_speed = round(self.DEMO_SPEED_MAX * (pos / 1000.0) ** 2, 3)
            self.demo_speed_lbl.setText(("%g" % self.demo_speed) + "\u00d7")
        self.demo_speed_slider.valueChanged.connect(_on_demo_speed)
        sp.addWidget(self.demo_speed_slider, 1)
        sp.addWidget(self.demo_speed_lbl)
        self.demo_speed_row.setVisible(False)     # only while demo runs
        outer.addWidget(self.demo_speed_row)

        self.note = QLabel("")
        self.note.setWordWrap(True)
        self.note.setFixedWidth(PANEL_W - 6)  # fixed width -> deterministic wrap height
        self.note.setStyleSheet("color:#8a93a3;font-size:11px;")
        outer.addWidget(self.note)

        # scrollable controls
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QFrame.NoFrame)
        # Always reserve the vertical scrollbar and never show a horizontal one.
        # If the bar could appear/disappear it would change the content width,
        # which (with word-wrapping anywhere) can drive an endless relayout
        # "shake" -- pinning it removes that whole failure mode.
        scroll.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOn)
        scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        body = QWidget()
        v = QVBoxLayout(body)
        v.setContentsMargins(0, 0, 4, 0)

        # --- analog group ---
        g_an = QGroupBox("Analog signals")
        gv = QVBoxLayout(g_an)
        gv.setSpacing(2)
        gv.setContentsMargins(8, 4, 8, 4)
        self.rpm   = SliderRow("RPM", 0, 10000, 900, scale=5, unit="rpm",
                               on_change=lambda x: self.data.set("rpmdata", x))
        self.speed = SliderRow("Speed", 0, 320, 0, scale=1, unit="km/h",
                               on_change=lambda x: self.data.set("speeddata", x))
        self.fuel  = SliderRow("Fuel", 0, 100, 60, scale=1, unit="%",
                               on_change=lambda x: self.data.set("fueldata", x))
        self.batt  = SliderRow("Battery", 8.0, 16.0, 13.8, scale=0.1, unit="V",
                               fmt="{:.1f}",
                               on_change=lambda x: self.data.set("batteryvoltagedata", x))
        self.water = SliderRow("Coolant", 0, 140, 80, scale=1, unit="\u00b0C",
                               on_change=lambda x: self.data.set("watertempdata", x))
        self.oilt  = SliderRow("Oil temp", 0, 160, 90, scale=1, unit="\u00b0C",
                               on_change=lambda x: self.data.set("oiltempdata", x))
        self.oilp  = SliderRow("Oil press", 0.0, 10.0, 4.0, scale=0.1, unit="bar",
                               fmt="{:.1f}",
                               on_change=lambda x: self.data.set("oilpressuredata", x))
        self.o2    = SliderRow("O2 sensor", 0.70, 1.30, 1.00, scale=0.01, unit="\u03bb",
                               fmt="{:.2f}",
                               on_change=lambda x: self.data.set("o2data", x))
        for w in (self.rpm, self.speed, self.fuel, self.batt,
                  self.water, self.oilt, self.oilp, self.o2):
            gv.addWidget(w)
        # gear selector
        gr = QHBoxLayout()
        gr.addWidget(QLabel("Gear"))
        self.gear = QComboBox()
        for label, _ in GEARS:
            self.gear.addItem(label)
        self.gear.currentIndexChanged.connect(
            lambda i: self.data.set("geardata", GEARS[i][1]))
        gr.addWidget(self.gear, 1)
        gv.addLayout(gr)
        v.addWidget(g_an)
        self.analog_rows = [self.rpm, self.speed, self.fuel, self.batt,
                            self.water, self.oilt, self.oilp, self.o2]

        # --- inputs group ---
        g_in = QGroupBox("Inputs  (inputsdata bit flags)")
        ig = QGridLayout(g_in)
        ig.setContentsMargins(8, 4, 8, 4)
        ig.setHorizontalSpacing(6)
        ig.setVerticalSpacing(2)
        self.input_boxes = {}
        for n, (label, mask) in enumerate(INPUT_BITS):
            cb = QCheckBox(label)
            cb.toggled.connect(lambda on, m=mask: self._on_input(m, on))
            self.input_boxes[mask] = cb
            ig.addWidget(cb, n // 2, n % 2)
        self.input_boxes[0x01].setChecked(True)   # ignition on by default
        v.addWidget(g_in)

        # --- ECU ASCII text (canasciidata) ---
        # Free-text the ECU pushes to the cluster; screens read it from
        # rpmtest/realtimedata.canasciidata. Type here to drive it live.
        g_txt = QGroupBox("ECU text  (canasciidata)")
        tv = QVBoxLayout(g_txt)
        self.canascii_edit = QLineEdit()
        self.canascii_edit.setPlaceholderText("Type text to display on canasciidata\u2026")
        self.canascii_edit.setMaxLength(64)
        self.canascii_edit.textChanged.connect(
            lambda s: self.data.set("canasciidata", s))
        tv.addWidget(self.canascii_edit)
        v.addWidget(g_txt)

        # --- remote / D-pad ---
        # Settings screens (the *_main.qml) are driven by a remote. The four
        # directions arrive as udp_packetdata bits (up=0x01 down=0x02 left=0x04
        # right=0x08), which the screens read as their joystick inputs. Buttons
        # are momentary: the bit stays set while held, so holding a direction
        # ramps a value just like the real remote. Arrow keys work too.
        g_pad = QGroupBox("Remote (D-pad)")
        pv = QVBoxLayout(g_pad)
        pv.setContentsMargins(6, 2, 6, 4)
        pv.setSpacing(3)
        hint = QLabel("Up opens menu \u00b7 Up/Down change \u00b7 Left/Right move \u00b7 "
                      "hold to ramp (arrow keys too)")
        hint.setWordWrap(True)
        hint.setStyleSheet("color:#8a93a3;font-size:10px;")
        pv.addWidget(hint)
        grid = QGridLayout()
        grid.setSpacing(2)
        self.UDP = {"up": 0x01, "down": 0x02, "left": 0x04, "right": 0x08}
        self.pad_buttons = {}
        self._pad_clear = {}        # per-direction "release" timers
        def mkpad(label, key, r, c):
            b = QPushButton(label)
            b.setFixedSize(40, 26)
            b.setAutoRepeat(False)
            b.pressed.connect(lambda k=key: self._pad_press(k))
            b.released.connect(lambda k=key: self._pad_release(k))
            grid.addWidget(b, r, c)
            self.pad_buttons[key] = b
        mkpad("\u25b2", "up", 0, 1)
        mkpad("\u25c0", "left", 1, 0)
        mkpad("\u25b6", "right", 1, 2)
        mkpad("\u25bc", "down", 2, 1)
        wrap = QHBoxLayout(); wrap.addStretch(1); wrap.addLayout(grid); wrap.addStretch(1)
        pv.addLayout(wrap)
        v.addWidget(g_pad)

        # --- odometer / trip ---
        g_od = QGroupBox("Odometer / trip")
        ov = QVBoxLayout(g_od)
        ov.setSpacing(2)
        ov.setContentsMargins(8, 4, 8, 4)
        self.odo  = SliderRow("Odometer", 0, 200000, 42000, scale=100, unit="",
                              on_change=lambda x: self.data.set("odometer0data", int(x)))
        self.trip = SliderRow("Trip", 0, 9999, 123, scale=1, unit="",
                              on_change=lambda x: self.data.set("tripmileage0data", int(x) * 10))
        ov.addWidget(self.odo)
        ov.addWidget(self.trip)
        v.addWidget(g_od)
        self.analog_rows += [self.odo, self.trip]

        # reset
        reset = QPushButton("Reset to idle")
        reset.clicked.connect(self._reset)
        v.addWidget(reset)
        v.addStretch(1)

        scroll.setWidget(body)
        outer.addWidget(scroll, 1)
        self._scroll_body = body
        return panel

    # ---- events --------------------------------------------------------
    def _on_dash_changed(self, idx):
        self._select_dash(idx)

    def _on_input(self, mask, on):
        self.data.set_bit(mask, on)
        # "Trip reset" (0x1000): zero the trip meter when the input is asserted,
        # the way the car's firmware would. The simulator owns tripmileage0data
        # (the dash only displays it), so the reset has to happen here.
        if mask == 0x1000 and on:
            self.data.set("tripmileage0data", 0)
            self.trip.set_real(0)
            self._demo_trip = 0.0      # keep a running demo counting up from 0
        # "Ignition" (0x01): turning the key off stops the engine (rpm and oil
        # pressure fall to zero); turning it on starts it at idle. This makes the
        # engine-off state visible even on dashes that don't gate on the bit, and
        # stacks with the shutdown animations on dashes that do.
        elif mask == 0x01:
            if on:
                self.rpm.set_real(900);  self.data.set("rpmdata", 900)
                self.oilp.set_real(4.0); self.data.set("oilpressuredata", 4.0)
            else:
                self.rpm.set_real(0);    self.data.set("rpmdata", 0)
                self.oilp.set_real(0);   self.data.set("oilpressuredata", 0)

    def _reset(self):
        if self.demo_btn.isChecked():
            self.demo_btn.setChecked(False)
        self.rpm.set_real(900)
        self.speed.set_real(0)
        self.fuel.set_real(60)
        self.batt.set_real(13.8)
        self.water.set_real(80)
        self.oilt.set_real(90)
        self.oilp.set_real(4.0)
        self.o2.set_real(1.0)
        self.gear.setCurrentIndex(0)
        for mask, cb in self.input_boxes.items():
            cb.setChecked(mask == 0x01)
        self.canascii_edit.clear()
        self._push_all()

    def _push_all(self):
        self.data.set("rpmdata", self.rpm.real_value())
        self.data.set("speeddata", self.speed.real_value())
        self.data.set("fueldata", self.fuel.real_value())
        self.data.set("batteryvoltagedata", self.batt.real_value())
        self.data.set("watertempdata", self.water.real_value())
        self.data.set("oiltempdata", self.oilt.real_value())
        self.data.set("oilpressuredata", self.oilp.real_value())
        self.data.set("o2data", self.o2.real_value())
        self.data.set("geardata", GEARS[self.gear.currentIndex()][1])
        self.data.set("odometer0data", int(self.odo.real_value()))
        self.data.set("tripmileage0data", int(self.trip.real_value()) * 10)

    # ---- demo loop -----------------------------------------------------
    def _demo_speed_to_pos(self, speed):
        """Slider position (0..1000) for a given speed, inverting the quadratic
        response used by the demo-speed slider."""
        import math
        return int(round(1000 * math.sqrt(max(0.0, speed) / self.DEMO_SPEED_MAX)))

    def _toggle_demo(self, on):
        self.demo_speed_row.setVisible(on)
        for w in self.analog_rows:
            w.setEnabled(not on)
        self.gear.setEnabled(not on)
        self.demo_btn.setText("\u25a0  Stop" if on else "\u25b6  Demo")
        if on:
            # ensure engine is "on" for the show
            self.input_boxes[0x01].setChecked(True)
            # start at the default 0.15x playback speed
            self.demo_speed_slider.setValue(self._demo_speed_to_pos(0.15))
            # start the odometer/trip accumulators from their current values
            self._demo_odo  = float(self.data._v["odometer0data"])
            self._demo_trip = float(self.data._v["tripmileage0data"])
            self.demo_phase = 0.0
            self.demo_timer.start()
        else:
            self.demo_timer.stop()
            # turn every demo-driven input back off (leave ignition on)
            for _label, m in INPUT_BITS:
                if m != 0x01:
                    self._demo_input(m, False)

    def _demo_tick(self):
        import math
        self.demo_phase += 0.012 * self.demo_speed
        t = self.demo_phase % 1.0          # 0..1 over the cycle

        # ---- realistic shift sequence ------------------------------------
        # Launch from idle, rev to a shift point just shy of redline, then each
        # upshift drops the rpm less than the last (close-ratio box). Speed
        # climbs smoothly and only rpm drops on a shift, like a real car.
        redline   = self.rpm.slider.maximum() * self.rpm.scale
        speedmax  = self.speed.slider.maximum() * self.speed.scale
        idle      = 500
        shift_rpm = min(9500, redline)         # upshift just before redline
        n_gears   = 6
        T_accel   = 0.82                        # cycle fraction spent accelerating

        if t < T_accel:
            g_pos = (t / T_accel) * n_gears     # 0 .. n_gears
            gear  = min(n_gears, int(g_pos) + 1)
            gear_frac = g_pos - int(g_pos)      # 0..1 progress within the gear
            # rpm the engine catches at right after each shift (gear 1 launches
            # from idle); higher gears are closer ratios, so the drop shrinks.
            bottoms = [idle / shift_rpm, 0.72, 0.77, 0.81, 0.84, 0.87]
            bottom  = bottoms[gear - 1] * shift_rpm
            # slight ease so it "hangs" near the top before the shift
            rpm   = bottom + (gear_frac ** 0.9) * (shift_rpm - bottom)
            speed = (g_pos / n_gears) * speedmax * 0.92
        else:
            # lift off and coast back down toward idle
            de        = (t - T_accel) / (1.0 - T_accel)     # 0..1
            gear_frac = 0.0
            gear      = max(1, n_gears - int(de * (n_gears - 1)))
            rpm       = idle + (1.0 - de) * (shift_rpm * 0.5 - idle)
            speed     = max(0.0, speedmax * 0.92 * (1.0 - de))
        rpm   = max(idle, min(rpm, redline))

        # Round display values to whole numbers (the dashes show these directly,
        # so raw floats would render as ugly long decimals).
        rpm   = round(rpm)
        speed = round(speed)
        # coolant: warm up, then ride around operating temp with load + a slow
        # oscillation (so it visibly moves up and down rather than pinning).
        warm  = min(1.0, self.demo_phase / 2.5)
        water = round(45 + warm * 40 + math.sin(self.demo_phase * 1.3) * 5 + (rpm / 8000) * 3)
        water = max(40, min(108, water))
        fuel  = round(max(8.0, 60.0 - (self.demo_phase * 3) % 55))
        oilp  = round(1.8 + (rpm / 8000) * 3.2, 1)        # bar: ~1.8 idle .. ~5.0
        oilt  = round(min(110.0, 70 + self.demo_phase * 12))
        # battery: alternator output rises with rpm and oscillates with load.
        batt  = round(13.6 + (rpm / 8000) * 0.7 + math.sin(self.demo_phase * 2.1) * 0.3, 1)
        batt  = max(12.5, min(15.0, batt))
        # odometer / trip: accumulate distance from the current speed.
        self._demo_odo  += speed * 0.05
        self._demo_trip += speed * 0.05
        odo  = int(self._demo_odo)
        trip = int(self._demo_trip)
        # O2 sensor: closed-loop lambda swing rich<->lean around stoich (1.00)
        o2v  = round(max(0.80, min(1.20, 1.0 + math.sin(self.demo_phase * 8.0) * 0.12)), 2)

        self.data.set("rpmdata", rpm)
        self.data.set("speeddata", speed)
        self.data.set("geardata", gear)
        self.data.set("watertempdata", water)
        self.data.set("fueldata", fuel)
        self.data.set("oilpressuredata", oilp)
        self.data.set("oiltempdata", oilt)
        self.data.set("batteryvoltagedata", batt)
        self.data.set("odometer0data", odo)
        self.data.set("tripmileage0data", trip)
        self.data.set("o2data", o2v)

        # ---- inputs: a startup lamp-test flash + contextual toggles ----------
        blink        = int(self.demo_phase * 4) % 2 == 0
        lamp         = t < 0.10                       # key-on self-test each cycle
        night        = 0.30 < t < 0.62               # lights-on stretch
        decel        = t > 0.82                       # coast/brake phase
        hard_accel   = (gear_frac > 0.55) and (gear < 6) and not decel
        near_redline = (gear_frac > 0.85) and not decel

        # indicators / lights
        self._demo_input(0x40,       blink and t < 0.25)            # left indicator
        self._demo_input(0x80,       blink and 0.55 < t < 0.80)     # right indicator
        self._demo_input(0x10,       night)                         # main beam
        self._demo_input(0x800,      night or lamp)                 # side lights
        self._demo_input(0x08,       night)                         # rear fog
        # braking / traction
        self._demo_input(0x100,      decel or lamp)                 # brake
        self._demo_input(0x20000,    decel or lamp)                 # ABS
        self._demo_input(0x10000,    hard_accel or lamp)            # traction ctrl
        self._demo_input(0x10000000, (0.62 < t < 0.90) or lamp)     # TC off
        # occupant / access (on at key-on, then settle as the car sets off)
        self._demo_input(0x400,      lamp or t < 0.15)              # seatbelt
        self._demo_input(0x4000,     lamp or t < 0.06)              # door open
        self._demo_input(0x8000000,  lamp or t < 0.06)              # handbrake
        self._demo_input(0x4000000,  t > 0.985)                     # reverse (stopped)
        # warning lamps -- only during the self-test, so the drive looks healthy
        self._demo_input(0x02,       lamp)                          # battery warn
        self._demo_input(0x200,      lamp)                          # oil warn
        self._demo_input(0x8000,     lamp)                          # airbag
        self._demo_input(0x40000,    lamp)                          # MIL
        self._demo_input(0x04,       lamp)                          # lap marker
        self._demo_input(0x400000,   lamp)                          # service
        self._demo_input(0x1000,     lamp)                          # trip reset
        # drive-mode flags cycle through the run
        self._demo_input(0x1000000,  0.20 < t < 0.45)               # sport mode
        self._demo_input(0x2000000,  0.45 < t < 0.62)               # cruise
        self._demo_input(0x800000,   0.62 < t < 0.90)               # race mode
        # shift lights climb as revs approach redline
        self._demo_input(0x80000,    near_redline)                  # shift 1
        self._demo_input(0x100000,   near_redline and gear_frac > 0.90)   # shift 2
        self._demo_input(0x200000,   near_redline and gear_frac > 0.95)   # shift 3

        # Mirror the whole control panel so the UI tracks the demo live: every
        # analog slider follows its value, the gear box follows, and the input
        # checkboxes above flip on/off as the demo toggles them.
        self.rpm.set_real(rpm)
        self.speed.set_real(speed)
        self.fuel.set_real(fuel)
        self.batt.set_real(batt)
        self.water.set_real(water)
        self.oilt.set_real(oilt)
        self.oilp.set_real(oilp)
        self.o2.set_real(o2v)
        self.odo.set_real(odo)
        self.trip.set_real(trip / 10.0)        # trip slider value = data / 10
        self.gear.blockSignals(True)
        self.gear.setCurrentIndex(gear if 0 <= gear < self.gear.count() else 0)
        self.gear.blockSignals(False)

    def _demo_input(self, mask, on):
        """Set an inputsdata bit AND reflect it on its checkbox (without
        re-triggering the checkbox's own handler)."""
        on = bool(on)
        cb = self.input_boxes.get(mask)
        if cb is not None and cb.isChecked() != on:
            cb.blockSignals(True)
            cb.setChecked(on)
            cb.blockSignals(False)
        self.data.set_bit(mask, on)


def _qt_message_filter(mode, ctx, msg):
    # Some dashes read rpmtest.<field> / realtimedata.<field> without a null
    # guard. While a dash is being (re)instantiated by the Loader, those bindings
    # fire once before the context property resolves, emitting a harmless
    # TypeError that immediately re-evaluates correctly. Drop only those
    # transients; pass the rest through so real errors stay visible.
    transient = (
        ("Cannot read property" in msg and ("of null" in msg or "of undefined" in msg))
        or "Unable to assign [undefined]" in msg
    )
    if transient:
        return
    stream = sys.stderr
    stream.write(msg + "\n")
    stream.flush()


def main():
    qInstallMessageHandler(_qt_message_filter)
    # Qt picks the native scene-graph backend per OS (Metal on macOS, D3D on
    # Windows, OpenGL on Linux). If a machine has flaky GPU drivers, set the
    # env var QT_QUICK_BACKEND=software before launching (see README).
    app = QApplication(sys.argv)
    app.setApplicationName("IC7 Dash Simulator")
    app.setFont(QFont(app.font().family(), 10))
    # Register the FileIO type so dash screens can `import FileIO 1.0`.
    qmlRegisterType(FileIO, "FileIO", 1, 0, "FileIO")
    data = DashData()
    win = MainWindow(data)
    win.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()

"""Where the simulator keeps its folders -- running from source vs. a packaged app.

From source (python dash_sim.py) nothing changes: dashes/, screen_configs/ and
qmlcompat/ are the folders next to the script.

In a packaged build (the PyInstaller apps made by the GitHub Actions workflow)
the code runs from a read-only bundle, but dashes must stay editable on disk so
you can build them and use hot reload. So:

  * "portable" -- if a writable dashes/ folder sits next to the app (the
    release zips ship one), use that folder and its sibling screen_configs/.
  * "documents" -- otherwise (app moved on its own, installed somewhere
    read-only like Program Files, or macOS running a quarantined copy from a
    temporary location) use  Documents/GARW Dash Simulator/ , seeding it on
    first run with the sample dashes bundled inside the app.

qmlcompat/ (the Stage + QtGraphicalEffects shims) always comes from the bundle.

A double-clicked app has no terminal, so packaged builds also write everything
that would go to the console (QML errors, warnings) to simulator_log.txt in the
same folder as dashes/.
"""
import os
import shutil
import sys

APP_NAME = "GARW Dash Simulator"
LOG_NAME = "simulator_log.txt"


class Paths(object):
    def __init__(self, mode, bundle, user):
        self.mode = mode                     # "source" | "portable" | "documents"
        self.bundle = bundle                 # read-only app resources
        self.user = user                     # editable root (dashes/, screen_configs/)
        self.qmlcompat = os.path.join(bundle, "qmlcompat")
        self.dashes = os.path.join(user, "dashes")
        self.configs = os.path.join(user, "screen_configs")
        self.log = os.path.join(user, LOG_NAME) if mode != "source" else None
        self.note = ""                       # why this folder was chosen (if noteworthy)

    def __repr__(self):
        return "Paths(mode=%s, dashes=%s)" % (self.mode, self.dashes)


def is_frozen():
    return bool(getattr(sys, "frozen", False))


def _app_bundle():
    """On macOS, the .app containing the running executable (else None)."""
    d = os.path.dirname(os.path.abspath(sys.executable))
    tail = os.path.join("Contents", "MacOS")
    if d.endswith(os.sep + tail):
        app = d[: -len(tail) - 1]
        if app.endswith(".app"):
            return app
    return None


def _untranslocate(app_path):
    """macOS App Translocation: an app opened while it still carries the
    download quarantine flag is run from a randomized read-only copy
    (/private/var/folders/.../AppTranslocation/<id>/d/X.app), so nothing next to
    it is visible. Ask the Security framework for the original location.
    Returns the original .app path, or None (not translocated / lookup failed)."""
    if sys.platform != "darwin" or not app_path or "/AppTranslocation/" not in app_path:
        return None
    try:
        import ctypes
        cf = ctypes.CDLL("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation")
        sec = ctypes.CDLL("/System/Library/Frameworks/Security.framework/Security")
        cf.CFURLCreateFromFileSystemRepresentation.restype = ctypes.c_void_p
        cf.CFURLCreateFromFileSystemRepresentation.argtypes = [
            ctypes.c_void_p, ctypes.c_char_p, ctypes.c_long, ctypes.c_bool]
        cf.CFURLGetFileSystemRepresentation.restype = ctypes.c_bool
        cf.CFURLGetFileSystemRepresentation.argtypes = [
            ctypes.c_void_p, ctypes.c_bool, ctypes.c_char_p, ctypes.c_long]
        cf.CFRelease.argtypes = [ctypes.c_void_p]
        fn = sec.SecTranslocateCreateOriginalPathForURL      # macOS 10.12+
        fn.restype = ctypes.c_void_p
        fn.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_void_p)]
        raw = app_path.encode("utf-8")
        url = cf.CFURLCreateFromFileSystemRepresentation(None, raw, len(raw), True)
        if not url:
            return None
        err = ctypes.c_void_p()
        orig = fn(url, ctypes.byref(err))
        cf.CFRelease(url)
        if err.value:
            cf.CFRelease(err)
        if not orig:
            return None
        buf = ctypes.create_string_buffer(4096)
        ok = cf.CFURLGetFileSystemRepresentation(orig, True, buf, len(buf))
        cf.CFRelease(orig)
        path = buf.value.decode("utf-8") if ok else None
        return path if path and "/AppTranslocation/" not in path else None
    except Exception:
        return None


def _exe_dir():
    """(folder the app lives in, note). On macOS that's the folder containing
    the .app -- its ORIGINAL location even if macOS translocated it."""
    app = _app_bundle()
    if app is None:
        return os.path.dirname(os.path.abspath(sys.executable)), ""
    if "/AppTranslocation/" in app:
        orig = _untranslocate(app)
        if orig:
            return os.path.dirname(orig), "macOS ran a quarantined copy; using the original folder"
        return os.path.dirname(app), "translocated"
    return os.path.dirname(app), ""


def _probe(d):
    """(usable, reason) for an editable dashes folder at d."""
    try:
        os.listdir(d)
    except FileNotFoundError:
        return False, "no dashes/ folder next to the app"
    except PermissionError:
        return False, "no permission to read it (macOS privacy)"
    except OSError as e:
        return False, "can't read it (%s)" % e.strerror
    probe = os.path.join(d, ".garw_write_test")
    try:
        with open(probe, "w"):
            pass
        os.remove(probe)
        return True, ""
    except OSError as e:
        return False, "it's read-only (%s)" % (e.strerror or e)


def _documents_root():
    docs = os.path.join(os.path.expanduser("~"), "Documents")
    if not os.path.isdir(docs):
        docs = os.path.expanduser("~")
    return os.path.join(docs, APP_NAME)


def resolve(here):
    """Work out the folder layout. `here` = the directory of dash_sim*.py."""
    if not is_frozen():
        return Paths("source", here, here)

    bundle = getattr(sys, "_MEIPASS", here)
    exe_dir, where_note = _exe_dir()
    usable, why = _probe(os.path.join(exe_dir, "dashes"))
    if usable:
        p = Paths("portable", bundle, exe_dir)
        p.note = where_note
    else:
        p = Paths("documents", bundle, _documents_root())
        if where_note == "translocated":
            p.note = ("macOS is running a quarantined copy of the app from a temporary "
                      "location, so the dashes/ folder beside it can't be seen. Fix: in "
                      "Terminal run  xattr -dr com.apple.quarantine  on the app's folder, "
                      "then relaunch.")
        else:
            p.note = "Not using %s: %s." % (os.path.join(exe_dir, "dashes"), why)
            if "macOS privacy" in why:
                p.note += (" Allow access in System Settings > Privacy & Security > "
                           "Files and Folders, or move the folder out of Downloads/Desktop.")
        os.makedirs(p.user, exist_ok=True)
        for name in ("dashes", "screen_configs"):
            dst = os.path.join(p.user, name)
            src = os.path.join(bundle, name)
            if not os.path.exists(dst):
                if os.path.isdir(src):
                    shutil.copytree(src, dst)     # first run: seed the samples
                else:
                    os.makedirs(dst, exist_ok=True)
    os.makedirs(p.configs, exist_ok=True)
    return p


class _Tee(object):
    """Write to the log file and (if there is one) the original console."""

    def __init__(self, fh, orig):
        self._fh, self._orig = fh, orig

    def write(self, s):
        try:
            self._fh.write(s)
            self._fh.flush()
        except Exception:
            pass
        if self._orig is not None:
            try:
                self._orig.write(s)
            except Exception:
                pass
        return len(s)

    def flush(self):
        for f in (self._fh, self._orig):
            try:
                if f is not None:
                    f.flush()
            except Exception:
                pass

    def isatty(self):
        return False


def install_log(paths):
    """Packaged builds: route stdout/stderr into the log file (fresh each run).
    Also guarantees sys.stderr is never None (windowed Windows builds), so the
    simulator's own error output can't crash it."""
    if paths.log is None:
        return
    try:
        fh = open(paths.log, "w", encoding="utf-8", errors="replace")
    except OSError:
        fh = None
    if fh is None:
        if sys.stderr is None:
            sys.stderr = open(os.devnull, "w")
        if sys.stdout is None:
            sys.stdout = open(os.devnull, "w")
        return
    sys.stderr = _Tee(fh, sys.stderr)
    sys.stdout = _Tee(fh, sys.stdout)
    sys.stderr.write("[%s] dashes folder (%s mode): %s\n" % (APP_NAME, paths.mode, paths.dashes))
    sys.stderr.write("[%s] app executable: %s\n" % (APP_NAME, sys.executable))
    if paths.note:
        sys.stderr.write("[%s] %s\n" % (APP_NAME, paths.note))

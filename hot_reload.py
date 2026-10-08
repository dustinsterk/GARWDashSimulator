"""Hot reload for the IC7 simulators.

Watches a dash's folder for saved .qml / .js / qmldir changes and calls back so
the host can re-load the dash from disk.

Why polling instead of QFileSystemWatcher: most editors (VS Code, vim, Qt
Creator, Sublime) save "atomically" -- write a temp file then rename it over the
original. QFileSystemWatcher then loses track of the file after the first save
and needs fragile re-adding. A cheap mtime/size snapshot every few hundred ms is
editor-proof, cross-platform, and costs nothing for a dash-sized folder.

A change is only reported once the snapshot has been stable for one extra poll,
so an editor writing a file in several steps triggers ONE reload, not three.
"""
import os
import sys

# Use whichever Qt binding the host simulator already imported.
if "PySide6" in sys.modules:
    from PySide6.QtCore import QTimer
else:
    from PyQt5.QtCore import QTimer

WATCH_EXT = (".qml", ".js", ".mjs")
WATCH_NAMES = ("qmldir",)
SKIP_DIRS = ("__pycache__", ".git", "node_modules")


def snapshot(roots):
    """{path: (mtime, size)} for every watched file under the given folders."""
    snap = {}
    for root in roots:
        if not root or not os.path.isdir(root):
            continue
        for dirpath, dirnames, filenames in os.walk(root):
            dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
            for fn in filenames:
                if fn.endswith(WATCH_EXT) or fn in WATCH_NAMES:
                    p = os.path.join(dirpath, fn)
                    try:
                        st = os.stat(p)
                    except OSError:
                        continue          # vanished mid-scan (atomic save in progress)
                    snap[p] = (st.st_mtime_ns, st.st_size)
    return snap


def diff(old, new):
    """Paths that were added, removed or modified between two snapshots."""
    return sorted(p for p in set(old) | set(new) if old.get(p) != new.get(p))


class HotReloader(object):
    """Polls folders and calls on_change(list_of_changed_paths) after a save."""

    def __init__(self, parent, on_change, interval_ms=400):
        self._on_change = on_change
        self._roots = []
        self._snap = {}
        self._pending = None
        self._timer = QTimer(parent)
        self._timer.setInterval(interval_ms)
        self._timer.timeout.connect(self.poll)

    def set_roots(self, roots):
        """Watch these folders (re-baselines, so switching dashes never fires)."""
        self._roots = [r for r in roots if r]
        self._snap = snapshot(self._roots)
        self._pending = None

    def set_enabled(self, on):
        if on:
            self._snap = snapshot(self._roots)   # ignore edits made while off
            self._pending = None
            self._timer.start()
        else:
            self._timer.stop()

    def is_enabled(self):
        return self._timer.isActive()

    def poll(self):
        cur = snapshot(self._roots)
        if cur == self._snap:
            self._pending = None
            return
        if self._pending is None or cur != self._pending:
            self._pending = cur                   # still being written: wait a tick
            return
        changed = diff(self._snap, cur)
        self._snap = cur
        self._pending = None
        self._on_change(changed)

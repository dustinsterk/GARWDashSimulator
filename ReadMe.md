
<img width="1312" height="1104" alt="GARWSimulator" src="https://github.com/user-attachments/assets/3a0173d4-1513-4560-883d-7c69ce989f43" />

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



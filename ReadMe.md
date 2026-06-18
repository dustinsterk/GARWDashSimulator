

You need the following package installed:
PySide6 >=6.5


OSX environments:
python3 -m pip install PySide6
brew install pyside (not sure if needed)
brew install qt5compat (not sure if needed)

Windows environments:
python -m pip install PySide6



Run the simulator via terminal (so you can see errors in the output too):
python3 dash_sim.py (OSX)
python dash_sim.py  (Windows)

-Add new dashed by adding the files into the 'dashes' folder (you may need to restart the sim to see them).

-All settings are saved to the local "screen_configs" folder even when "/opt/Garw_IC7/screen_configs/" is seen in the code for easy of use.

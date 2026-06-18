<img width="800" height="480" alt="image" src="https://github.com/user-attachments/assets/e7f18dfe-1887-4fdb-b5f3-c249a0b47e20" />

# Age Solo Dash

Dashboard View for Lotus Elise GARW dash

###

Inspired by the Ridge Racer 7 Age (pronounced Ah-dge, it's *French*) tachometer for the Age cars. I might make an alternate view mode where one can use the indiglo blue numbers instead of an orange. 

This dash will require you to update your gear settings (under settings -> gears) for the calculated gear (unless you're very fancy and running a sequential with a canbus output), the following works decently for me currently with a stock C64 transmission:

(1st) 123 (2nd) 83 (3rd) 60 (4th) 47 (5th) 37 (6th) 33

###

TO DO:

- Full Screen takeover so we can use the qml warning icons instead of the new ones. 
- Better animation in onLoad
- Integrate a second mode with the down button to allow an alternative view for more information (eg wideband/pressure/air temp)

## Design notes:

- Updated water temp gauge to be bigger and easier to read, also to reflect more of an aftermarket circa late 90's/early 2000's period correct Greddy gauge.

- Changed the numbers for better legibility on the tachometer. The Roland Font just wasn't working out for me on extended testing.

- Added Shift indicator and improved gauge edge legibility.

# Installation notes:

1) Obtain the GARW dash installer here: https://github.com/dustinsterk/GARWDashUploader
2) You will need to unzip this dashboard file, rename the folder to "AgeSolo_Main" (Don't use the quotes), and recompress it. (I know, it's a pain)
3) Upload the dash via the uploader while connected to the GAWR Wifi.
4) Follow the rest of the aforementioned instructions.

There are some prebuilt releases for the uploader, check with the Discord Channel here: [https://discord.gg/36kybUTW](https://discord.gg/bmKFrt8XP6)

import QtQuick 2.3
import QtGraphicalEffects 1.0
import "danver"

Item {
    id: root
    ////////// IC7 LCD RESOLUTION ////////////////////////////////////////////
    width: 800
    height: 480
    x: 0
    y: 0
    z: 0
    
    property int myyposition: 0
    property int udp_message: rpmtest.udp_packetdata

    property bool udp_up: udp_message & 0x01
    property bool udp_down: udp_message & 0x02
    property bool udp_left: udp_message & 0x04
    property bool udp_right: udp_message & 0x08

    property int membank2_byte7: rpmtest.can203data[10]
    property int inputs: rpmtest.inputsdata

    //Inputs//31 max!!
    property bool ignition: inputs & 0x01
    property bool battery: inputs & 0x02
    property bool lapmarker: inputs & 0x04
    property bool rearfog: inputs & 0x08
    property bool mainbeam: inputs & 0x10
    property bool up_joystick: inputs & 0x20 || root.udp_up
    property bool leftindicator: inputs & 0x40
    property bool rightindicator: inputs & 0x80
    property bool brake: inputs & 0x100
    property bool oil: inputs & 0x200
    property bool seatbelt: inputs & 0x400
    property bool sidelight: inputs & 0x800
    property bool tripresetswitch: inputs & 0x1000
    property bool down_joystick: inputs & 0x2000 || root.udp_down
    property bool doorswitch: inputs & 0x4000
    property bool airbag: inputs & 0x8000
    property bool tc: inputs & 0x10000
    property bool abs: inputs & 0x20000
    property bool mil: inputs & 0x40000
    property bool shift1_id: inputs & 0x80000
    property bool shift2_id: inputs & 0x100000
    property bool shift3_id: inputs & 0x200000
    property bool service_id: inputs & 0x400000
    property bool race_id: inputs & 0x800000
    property bool sport_id: inputs & 0x1000000
    property bool cruise_id: inputs & 0x2000000
    property bool reverse: inputs & 0x4000000
    property bool handbrake: inputs & 0x8000000
    property bool tc_off: inputs & 0x10000000
    property bool left_joystick: inputs & 0x20000000 || root.udp_left
    property bool right_joystick: inputs & 0x40000000 || root.udp_right

    property int odometer: rpmtest.odometer0data/10*0.62 //Need to div by 10 to get 6 digits with leading 0
    property int tripmeter: rpmtest.tripmileage0data*0.62
    property real value: 0
    property real shiftvalue: 0

    property real rpm: rpmtest.rpmdata
    property real rpmlimit: 8000 //Originally was 7k, switched to 8000 -t
    property real rpmdamping: 5
    property real speed: rpmtest.speeddata
    property int speedunits: 2

    property real watertemp: rpmtest.watertempdata
    property real waterhigh: 0
    property real waterlow: 80
    property real waterunits: 1

    property real fuel: rpmtest.fueldata
    property real fuelhigh: 0
    property real fuellow: 0
    property real fuelunits
    property real fueldamping

    property real o2: rpmtest.o2data
    property real map: rpmtest.mapdata
    property real maf: rpmtest.mafdata

    property real oilpressure: rpmtest.oilpressuredata
    property real oilpressurehigh: 0
    property real oilpressurelow: 0
    property real oilpressureunits: 0

    property real oiltemp: rpmtest.oiltempdata
    property real oiltemphigh: 90
    property real oiltemplow: 90
    property real oiltempunits: 1

    property real batteryvoltage: rpmtest.batteryvoltagedata

    property int mph: (speed * 0.62)

    property int gearpos: rpmtest.geardata

    property real speed_spring: 1
    property real speed_damping: 1

    property real rpm_needle_spring: 3.0 //if(rpm<1000)0.6 ;else 3.0
    property real rpm_needle_damping: 0.2 //if(rpm<1000).15; else 0.2

    property bool changing_page: rpmtest.changing_pagedata

    property string white_color: "#FFFFFF"
    property string primary_color: "#64E3D4"; //Kind of an off CYAN color (darker than night light color)
    property string night_light_color: "#C7F8FD"  //Sort of blown out cyan
    property string sweetspot_color: "#FFA500" //Cam Changeover Rev colpr
    property string warning_red: "#E12910" //Redline/Warning colors
    property string night_salmon_red: "#F85653" //For redline reference
    property string engine_warmup_color: "#eb7500"
    property string background_color: "#000000"
    property string displayBkg: "#00003B"
    property string displayDigits: "#8BAEF0"
    property string displayPlaceholder: "#001C29"
  

    /* ########################################################################## */
    /* Fonts */
    /* ########################################################################## */
    FontLoader{
        id: greddy_segment
        source: "./fonts/GreddySegment.ttf"
    }
    FontLoader{
        id: geist
        source: "./fonts/GeistVariableVF.ttf"
    }

    /* ########################################################################## */
    /* Main Layout items */
    /* ########################################################################## */
    Image{
        x: 0; y:0
        z: 0
        height: 480
        width: 800
        source: "./danver/background.png"
    }
    Image{

    }
    Text{
        text: "rpm x1000"
        font.family: geist.name
        font.bold: true
        font.pixelSize: 22
        x: 15.1; y: 108
        z: 4
        color: if(!root.sidelight) root.primary_color; else root.night_light_color
        transform:
            Rotation{
                angle: -11.7
            }
    }
    Image{
        x: 14; y: 28
        z:3
        height: 217
        width: 774
        source: "./danver/rpm_mask.png"
    }
    Rectangle{
        id: rpm_action
        x: 16; y: 33
        z:2
        height: 200
        width: Math.floor(root.rpm * .004) * 19.2 //Chunk-style
        // width: 768 * (root.rpm/10000) //Percentage
        clip: true
        color: "black"
        Image{
            z: 2
            height: 200
            width: 768
            source: if(!root.sidelight) "./danver/cyanRPM.png"; else "./danver/cyanBrightRPM.png"
        }
    }
    Image{
        x: 16; y:33
        z:1
        height: 200
        width: 768
        source: "./danver/rpm_background.png"
    }
    Image{
        x: 15; y: 237
        z: 2
        height: 53
        width: 770
        source: if(!root.sidelight) "./danver/daylight_rpm_marks.png"; else "./danver/dark_rpm_marks.png"
    }
    Item{
        id: water_display
        z:3
        Rectangle{
            x: 16; y: 296
            z: 2
            height: 55.6
            width: 184
            radius: 5
            color: root.displayBkg
        }
        Text{
            text: "288"
            x: 24; y: 306
            z:3
            width: 209.6
            height: 40.3
            font.pixelSize: 64
            font.family: greddy_segment.name
            color: root.displayPlaceholder
        }
        Text{
            text: "1"
            x: 24; y: 306
            z:3
            width: 209.6
            height: 40.3
            font.pixelSize: 64
            font.family: greddy_segment.name
            color: root.displayPlaceholder
        }
        Text{
            text: if(root.waterunits !== 0)((((root.watertemp.toFixed(0))*9)/5)+32).toFixed(0); else root.watertemp.toFixed(0)
            x: -33; y: 306
            z:3
            width: 209.6
            height: 40.3
            font.pixelSize: 64
            font.family: greddy_segment.name
            color: if(!root.sidelight){
                    if(root.watertemp < root.waterhigh) root.displayDigits; else root.warning_red
                    }
                else{ 
                    if(root.watertemp < root.waterhigh) root.night_light_color; else root.night_salmon_red
                }
            horizontalAlignment: Text.AlignRight
        }
        Text{
            text: "water"
            z: 99
            x: 175; y:346
            font.pixelSize: 16
            font.family: geist.name
            font.bold: true
            color: if(!root.sidelight){
                    if(root.watertemp < root.waterhigh) root.displayDigits; else root.warning_red
                    }
                else{ 
                    if(root.watertemp < root.waterhigh) root.night_light_color; else root.night_salmon_red
                }
            transform:
                Rotation{
                    angle: 270
                }
        }
    }
    Item{
        id: speed_display
        z:3
        Rectangle{
            x: 308; y: 296
            z: 2
            height: 55.6
            width: 184
            radius: 5
            color: root.displayBkg
        }
        Text{
            text: "288"
            x: 318; y: 306
            z:3
            width: 209.6
            height: 40.3
            font.pixelSize: 64
            font.family: greddy_segment.name
            color: root.displayPlaceholder
        }
        Text{
            text: "1"
            x: 318; y: 306
            z:3
            width: 209.6
            height: 40.3
            font.pixelSize: 64
            font.family: greddy_segment.name
            color: root.displayPlaceholder
        }
        Text{
            text: if (root.speedunits === 0){
                        root.speed.toFixed(0) 
                    }
                    else{
                        root.mph.toFixed(0)
                    }
            x: 262; y: 306
            z:4
            width: 209.6
            height: 40.3
            font.pixelSize: 64
            font.family: greddy_segment.name
            color: if(!root.sidelight) root.displayDigits; else root.night_light_color
            horizontalAlignment: Text.AlignRight
        }
        Text{
            text: if(root.speedunits === 0){
                    "kmh"
                    } 
                    else{
                    "mph"
                    }
            z: 99
            x: 468; y:342
            font.pixelSize: 18
            font.family: geist.name
            font.bold: true
            color: if(!root.sidelight) root.displayDigits; else root.night_light_color
            transform:
                Rotation{
                    angle: 270
                }
        }
    }
    Item{
        id: rpm_display
        z:3
        Rectangle{
            x: 532; y: 296
            z: 2
            height: 55.6
            width: 250
            radius: 5
            color: root.displayBkg
        }
        Text{
            text: "18888"
            x: 507; y: 306
            z:3
            width: 209.6
            height: 40
            font.pixelSize: 64
            font.family: greddy_segment.name
            color: root.displayPlaceholder
        }
        Text{
            text: root.rpm
            x: 552; y: 306
            z:4
            width: 209.6
            height: 40
            font.pixelSize: 64
            font.family: greddy_segment.name
            color: if(!root.sidelight){
                    if(root.rpm < root.rpmlimit) root.displayDigits; else root.warning_red
                    }
                else{ 
                    if(root.rpm < root.rpmlimit) root.night_light_color; else root.night_salmon_red
                }
            horizontalAlignment: Text.AlignRight
        }
        Text{
            text: "rpm"
            z: 99
            x: 758; y:340
            font.pixelSize: 18
            font.family: geist.name
            font.bold: true
            color: if(!root.sidelight){
                    if(root.rpm < root.rpmlimit) root.displayDigits; else root.warning_red
                    }
                else{ 
                    if(root.rpm < root.rpmlimit) root.night_light_color; else root.night_salmon_red
                }
            transform:
                Rotation{
                    angle: 270
                }
        }
    }
    Item{
        id: other_gauges
        Item{
            id: oil_temp_module
            Text{
                text: "Oil Temp"
                x: 47.2; y: 388.4
                z: 1
                font.family: geist.name
                font.bold: true
                font.pixelSize: 16
                color: if(!root.sidelight){
                    if(root.oiltemp < root.oiltemphigh) root.primary_color; else root.warning_red
                    }
                else{ 
                    if(root.oiltemp < root.oiltemphigh) root.night_light_color; else root.night_salmon_red
                }
            }
            Text{
            text: if(root.oiltempunits !== 0)((((root.oiltemp.toFixed(0))*9)/5)+32).toFixed(0); else root.oiltemp.toFixed(0)
                x: 139; y: 384
                z: 1
                width: 69.4
                height: 19.4
                font.family: greddy_segment.name
                font.pixelSize: 40
                color: if(!root.sidelight){
                    if(root.oiltemp < root.oiltemphigh) root.primary_color; else root.warning_red
                    }
                else{ 
                    if(root.oiltemp < root.oiltemphigh) root.night_light_color; else root.night_salmon_red
                }
                horizontalAlignment: Text.AlignRight
            }
        }
        Item{
            id: oil_pressure_module
            Text{
                text: "Oil Pressure"
                x: 24.2; y: 436.4
                z: 1
                font.family: geist.name
                font.bold: true
                font.pixelSize: 16
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
            }
            Text{
                text: root.oilpressure.toFixed(0)
                x: 139; y: 431
                z: 1
                width: 69.4
                height: 19.4
                font.family: greddy_segment.name
                font.pixelSize: 40
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                horizontalAlignment: Text.AlignRight
            }
        }
        Item{
            id: fuel_module
            Text{
                text: "Fuel"
                x: 304; y: 388.4
                z: 1
                font.family: geist.name
                font.bold: true
                font.pixelSize: 16
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
            }
            Rectangle{
                x: 347; y: 389.4
                z: 2
                width: 142*(root.fuel/100)
                height: 17
                color: if(!root.sidelight){
                    if(root.fuel > root.fuellow) root.primary_color; else root.warning_red
                    }
                else{ 
                    if(root.fuel > root.fuellow) root.night_light_color; else root.night_salmon_red
                }
            }
            Rectangle{
                x: 346; y: 388.4
                z: 1
                width: 144
                height: 19
                gradient: Gradient {
                        GradientStop { position: 0.0; color: root.displayBkg }
                        GradientStop { position: 1.0; color: "black" }
                    }
                border.width: 1
                border.color: if(!root.sidelight) root.primary_color; else root.night_light_color
            }
            Rectangle{
                x: 346; y: 410
                z: 1
                width: 144; height: 1;
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
            }
            Rectangle{
                x: 346; y: 410
                z: 1
                width: 1; height: 8;
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
            } 
            Rectangle{
                x: 417; y: 410
                z: 1
                width: 1; height: 8;
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
            }
            Rectangle{
                x: 489; y: 410
                z: 1
                width: 1; height: 8;
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
            }
        }
        Item{ 
            id: mileage_module
            Text{
                text: "Mileage"
                x: 304; y: 436.4
                z: 1
                font.family: geist.name
                font.bold: true
                font.pixelSize: 16
                color: if(!root.sidelight) "#5AB6B5"; else root.night_light_color
            }
            Text{
                text: if (root.speedunits === 0)
                        (root.odometer/.62).toFixed(0)
                    else if(root.speedunits === 1)
                        root.odometer
                    else
                        root.odometer
                x: 405; y: 439
                width: 87; height: 13.5
                font.family: greddy_segment.name
                font.pixelSize: 24
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                horizontalAlignment: Text.AlignRight
            }
        }
    }
    Item{
        id: idiot_lights
        Image{
            x: 717.1; y: 380.9
            width: 33; height: 34 
            z: 1
            source: "./danver/gas-light.png"
            visible: root.fuel < root.fuellow
        }
        Image{
            x: 679.3; y: 380.9
            width: 33; height: 34 
            z: 1
            source: "./danver/oil-light.png"
            visible: root.oil
        }
        Image{
            x: 641.3; y: 380.9
            width: 33; height: 34 
            z: 1
            source: "./danver/brake-light.png"
            visible: root.brake
        }
        Image{
            x: 603.7; y: 380.9
            width: 33; height: 34 
            z: 1
            source: "./danver/seatbelt-light.png"
            visible: root.seatbelt
        }
        Image{
            x: 565.8; y: 380.9
            width: 33; height: 34 
            z: 1
            source: "./danver/blinker-light.png"
            visible: root.leftindicator || root.rightindicator
        }
        Image{
            x:735.9; y: 418
             width: 33; height: 34 
            z: 1
            source: "./danver/checkengine-light.png"
            visible: root.mil
        }
        Image{
            x:660.3; y: 418
            width: 33; height: 34 
            z: 1
            source: "./danver/battery-light.png"
            visible: root.battery
        }
        Image{
            x:622.5; y: 418
            width: 33; height: 34 
            z: 1
            source: "./danver/airbag-light.png"
            visible: root.airbag
        }
        Image{
            x:584.7; y: 418
            width: 33; height: 34 
            z: 1
            source: "./danver/hibeams-light.png"
            visible: root.mainbeam
        }
        Image{
            x:546.8; y: 418
            width: 33; height: 34 
            z: 1
            source: "./danver/abs-light.png"
            visible: root.abs
        }

    }
} //End Danver
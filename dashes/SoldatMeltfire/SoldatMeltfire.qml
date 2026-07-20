import QtQuick 2.3
import QtGraphicalEffects 1.0

import "images"

/***
 *          ::::::::       ::::::::       :::        :::::::::           :::    :::::::::::                                           
 *        :+:    :+:     :+:    :+:      :+:        :+:    :+:        :+: :+:      :+:                                                
 *       +:+            +:+    +:+      +:+        +:+    +:+       +:+   +:+     +:+                                                 
 *      +#++:++#++     +#+    +:+      +#+        +#+    +:+      +#++:++#++:    +#+                                                  
 *            +#+     +#+    +#+      +#+        +#+    +#+      +#+     +#+    +#+                                                   
 *    #+#    #+#     #+#    #+#      #+#        #+#    #+#      #+#     #+#    #+#                                                    
 *    ########       ########       ########## #########       ###     ###    ###                                                     
 *                                                                                                                                    
 *                                                                                                                                    
 *                                                                                                                                    
 *                                                                                                                                    
 *                                                                                                                                    
 *                                                                                                                                    
 *                                                                                                                                    
 *            :::   :::       ::::::::::       :::    :::::::::::       ::::::::::       :::::::::::       :::::::::       :::::::::: 
 *          :+:+: :+:+:      :+:              :+:        :+:           :+:                  :+:           :+:    :+:      :+:         
 *        +:+ +:+:+ +:+     +:+              +:+        +:+           +:+                  +:+           +:+    +:+      +:+          
 *       +#+  +:+  +#+     +#++:++#         +#+        +#+           :#::+::#             +#+           +#++:++#:       +#++:++#      
 *      +#+       +#+     +#+              +#+        +#+           +#+                  +#+           +#+    +#+      +#+            
 *     #+#       #+#     #+#              #+#        #+#           #+#                  #+#           #+#    #+#      #+#             
 *    ###       ###     ##########       ########## ###           ###              ###########       ###    ###      ##########       
 */

Item {
    /*#########################################################################
      #############################################################################
      Imported Values From GAWR inits
      #############################################################################
      #############################################################################
     */
    id: root

    ////////// IC7 LCD RESOLUTION ////////////////////////////////////////////
    width: 800
    height: 480
    
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
    property real rpmlimit: 8000 
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
    property real oiltemppeak: 0

    property real batteryvoltage: rpmtest.batteryvoltagedata

    property int mph: (speed * 0.62)

    property int gearpos: rpmtest.geardata

    property real speed_spring: 1
    property real speed_damping: 1

    property real rpm_needle_spring: 3.0 //if(rpm<1000)0.6 ;else 3.0
    property real rpm_needle_damping: 0.2 //if(rpm<1000).15; else 0.2

    property bool changing_page: rpmtest.changing_pagedata


    property string white_color: "#FFFFFF"
    property string primary_color: "#FFFF00" //Strong Yellow
    property string lit_primary_color: "#F59713" //lit orange
    property string warning_color: "#FF1100" //Warning Red
    property string salmon_warning_color: "#FA6464"
    property string engine_warmup_color: "#eb7500"
    property string background_color: "#000000"
    property string display_grey: "#313331"
    property string digital_gauge_grey: "#282028"

    property int timer_time: 1

    //Peak Values

    property int peak_rpm: 0
    property int peak_speed: 0
    property int peak_water: 0
    property int peak_oil: 0
    property bool car_movement: false
    x: 0
    y: 0

    FontLoader {
        id: digital7monoItalic
        source: "./fonts/digital7monoitalic.ttf"
    }
    FontLoader{
        id: boosted
        source: "./fonts/BoostedRegular.ttf"
    }

    // Peak values
    onRpmChanged: if (rpm > peak_rpm) peak_rpm = rpm
    onSpeedChanged: if (speed > peak_speed) peak_speed = speed
    onWatertempChanged: if (watertemp > peak_water) peak_water = watertemp
    onOiltempChanged: if (oiltemp > peak_oil) peak_oil = oiltemp
   
    //Utilities  
    function easyFtemp(degreesC){
        return ((((degreesC.toFixed(0))*9)/5)+32).toFixed(0)
    }
    
    function getPeakSpeed(){
        if (root.speedunits === 0) return root.peak_speed.toFixed(0); else return (root.peak_speed*.62).toFixed(0)
    }

    function getTemp(fluid){
        if(fluid == "COOLANT"){
            if(root.seatbelt && root.car_movement && root.speed === 0){ 
                 if(root.waterunits !== 1)
                    return easyFtemp(root.peak_water)
                else 
                    return root.peak_water.toFixed(0)
            }
            else{
                if(root.waterunits !== 1)
                    return easyFtemp(root.watertemp)
                else 
                    return root.watertemp.toFixed(0)
            }
        }
        else{
            if(root.seatbelt && root.car_movement && root.speed === 0){
                 if(root.oiltempunits !== 1)
                    return easyFtemp(root.peak_oil)
                else 
                    return root.peak_oil.toFixed(0)
            }
            else{
                if(root.oiltempunits !== 1)
                    return easyFtemp(root.oiltemp)
                else 
                    return root.oiltemp.toFixed(0)
            }
        }
    }
    function tempColors(fluid){
        if((fluid === 'COOLANT' && root.watertemp >= root.waterhigh) || (fluid === 'OIL' && root.oiltemp >= root.oiltemphigh)){
            return root.warning_color
        }
        else{
            if(root.sidelight){
                return root.lit_primary_color
            }
            else{
                return root.primary_color
            }
        }
    }
    function tempWarningColor(){
        if(root.sidelight){
            return root.salmon_warning_color
        }
        else{
            return root.warning_color
        }
    }
    function getGear(){
        switch(rpmtest.geardata){
            case 0:
                return './images/n.png'
            case 1:
                return './images/1.png'
            case 2:
                return './images/2.png'
            case 3:
                return './images/3.png'
            case 4:
                return './images/4.png'
            case 5:
                return './images/5.png'
            case 6:
                return './images/6.png'
            case 10:
                return './images/r.png'
            default:
                return './images/dash.png'
        }
    }
    

    /* ########################################################################## */
    /* Main Layout items */
    /* ########################################################################## */
    Rectangle {
        id: background_rect
        x: 0
        y: 0
        width: 800
        height: 480
        color: root.background_color
        border.width: 0
        z: 0
    }
    Image{
        id: silver_mask_overlay
        x: 0; y:0
        z: 10
        source: if(!root.sidelight) './images/meltfire_mask.png'; else './images/meltfire_mask_dark.png'
    }

    Image{
        id: tach_bkg
        z: 2
        x: 190; y: 30
        source: './images/tach_bkg.png'
    }

    Image{
        id: shift_light
        z: 3
        x: 561; y: 258
        source: './images/shift_light_dim.png'
    }

    Image{
        id: shift_light_blink
        z: 4
        x: 547; y: 245
        source: './images/shift_light_lit.png'
        visible: if(root.rpm >= root.rpmlimit) true; else false
        Timer{
            id: rpm_shift_blink
            running: true
            interval: 50
            repeat: true
            onTriggered: if(parent.opacity === 0){
                parent.opacity = 100
            }
            else{
                parent.opacity = 0
            } 
        }
    }

    Image{
        id: tach_indicators
        z: 3
        x: 209.5; y: 49
        source: if(!root.sidelight) './images/tach_markers_unlit.png'; else './images/tach_markers_lit.png'
    }
    
    Image{
        id: tach_needle
        z: 6
        x: 222.6; y: 237
        source: './images/tach_needle.png'
        transform:[
                Rotation {
                    id: tachneedle_rotate
                    origin.y: 2
                    origin.x: 178
                    // angle: ((root.rpm/1000)*26 - 90)
                    angle: if(root.rpm <= 1000){
                            Math.min(Math.max(-90, Math.round((root.rpm/1000)*21) - 90), 180)
                        }   
                        else{
                            Math.min(Math.max(-90, Math.round((root.rpm/1000)*27.8) - 96.8), 180) 
                        }                
                    Behavior on angle{
                        SpringAnimation {
                            spring: 1.2
                            damping:.16
                        }
                    }
                }
            ]
            
    }


    Image{
        id: tach_needle_dropshadow
        z: 5
        x: 222.6; y: 238
        source: './images/tach_needle_dropshadow.png'
        transform:[
                Rotation {
                    id: tachneedle_dropshadow_rotate
                    origin.y: 2+(root.rpm/10000*6)
                    origin.x: 178
                    angle: if(root.rpm <= 1000){
                            Math.min(Math.max(-90, Math.round((root.rpm/1000)*21) - 90), 180)
                        }   
                        else{
                            Math.min(Math.max(-90, Math.round((root.rpm/1000)*27.8) - 96.8), 180) 
                        }                
                    Behavior on angle{
                        SpringAnimation {
                            spring: 1.2
                            damping:.16
                        }
                    }
                }
            ]    
    }
    
    Image{
        id: needle_center
        z: 10
        x: 377; y: 220
        source: './images/tach_center.png'
    }

    //Shift Indicator
    Item{
        x:374;y:137;z: 3
        Image{
            source: getGear()
        }
    }

    Item{
        z:5
        visible: !root.seatbelt
        Text{
            id: speed_text
            x: 446.3; y: 355;
            font.family: boosted.name
            font.pixelSize: 48
            color: root.primary_color
            width: 160
            height: 54
            clip: true
            text: if(root.speedunits === 0) root.speed.toFixed(0); else (root.speed*.62).toFixed(0)
            horizontalAlignment: Text.AlignRight
        }
    }

    Item{
        id: peakrpm_speed
        visible: root.seatbelt 
        z:8
        Text{
            x: 446.3; y: 360; 
            font.family: boosted.name
            font.pixelSize: 10
            color: root.primary_color
            text: "PEAK\nSPEED:" 
        }
        Text{ 
            x: 537; y: 360
            font.family: boosted.name
            font.pixelSize: 20
            color: root.primary_color
            text: getPeakSpeed()
        }
        Text{
            x: 446.3; y: 390;
            font.family: boosted.name
            font.pixelSize: 10
            color: root.primary_color
            text: "PEAK\nRPM:"
        }
        Text{ 
            x: 515; y: 391
            font.family: boosted.name
            font.pixelSize: 20
            color: root.primary_color
            text: root.peak_rpm
        }
    }
    
    Image{
        id: speed_label
        x: 540; y: 426; z: 5
        source: {
                if(root.speedunits === 0) './images/km_marker.png'; else './images/mi_marker.png'
            }
    }

    //Blinkers
    Item{
        id: blinkers
        x: 445; y: 345; z:10
        visible: root.leftindicator || root.rightindicator
        Rectangle{
            width: 160; height: 70
            color: root.display_grey
            opacity: 1
        }
        Image{
            source: if(root.leftindicator) './images/ind_left.png'; else './images/ind_right.png'
            x: 60; y: 15;           
        }
    }

    Item{
        id: fuel_system
        x: 652; y: 383; z: 10
        Image{ 
            source: './images/fuel_lines.png'
            x:6;y:-2;z:10
        }
        Image{
            source: './images/fuel_icon.png'
            x:0;y:-8;z:10
            opacity: 1
            visible: root.fuel>root.fuellow
        }
        Image{
            source: './images/fuel_icon.png'
            x:0;y:-8;z:10
            opacity: 1
            Timer{
                id: fuel_indicator_blink
                running: root.fuel<=root.fuellow
                interval: 500
                repeat: true
                onTriggered: if(parent.opacity === 0){
                    parent.opacity = 100
                }
                else{
                    parent.opacity = 0
                } 
            }
        }
        Rectangle{
            width: 107*(root.fuel/100); height: 51
            clip: true
            color: '#000000'
            Image{
                source: './images/fuel_curve.png'
            }
        }
    }
    Image{
        source: './images/unleaded_fuel_only.png'
        x: 655;y:439;z:10
    }
    //Bottom Row
    Image{
        x: 170; y: 429; z:4
        source: if(root.airbag) './images/warning_lit/airbag.png'; else './images/warning_unlit/airbag.png'       
    }
    Image{
        x: 104; y: 428; z:4
        source: if(root.oil) './images/warning_lit/oilpressure.png';else './images/warning_unlit/oilpressure.png'
    }
    Image{
        x: 100; y: 394; z:4
        source: if (root.brake) './images/warning_lit/brake.png'; else 'images/warning_unlit/brake.png'
   
    }
    Image{
        x: 172.4; y: 393; z:4
        source: if (root.abs) './images/warning_lit/abs.png'; else 'images/warning_unlit/abs.png'
    }
    Image{
        x: 31; y: 347; z:4
        source: if (root.doorswitch) './images/warning_lit/door.png'; else 'images/warning_unlit/door.png'

    }    
    Image{
        x: 89; y: 347.5; z:4
        source: if (root.seatbelt) './images/warning_lit/seatbelt.png'; else 'images/warning_unlit/seatbelt.png'

    }    
    //Top Row
    Image{
        x: 141.6; y: 347; z: 4
        source: if (root.battery)  './images/warning_lit/battery.png'; else 'images/warning_unlit/battery.png'

    }
    Image{
        x: 42; y: 386; z: 4
        source: if (root.mil) './images/warning_lit/cel.png'; else 'images/warning_unlit/cel.png'
 
    }
    Image{
        x: 209; y: 429; z: 4
        source: if (root.sidelight) './images/warning_lit/sidelights.png'; else 'images/warning_unlit/sidelights.png'
   
    }
    Image{
        x: 49; y: 429; z: 4
        source: if (root.mainbeam) './images/warning_lit/highbeams.png'; else 'images/warning_unlit/highbeams.png'
    }

    //Water Temperature
        Item{
            id: water_temp
            x:25;y:169;z:8
            Rectangle{
                width: 125; height:125
                radius: width*0.5
                clip: true
                color: root.digital_gauge_grey 
                Rectangle{
                    id: water_1_box
                    x:61;y:61;
                    height:61; width:61
                    color: if(root.watertemp < root.waterhigh) root.primary_color; else tempWarningColor()
                    transform:[
                        Rotation{
                            id: water1rotate
                            origin.x: 0
                            origin.y: 0
                            angle: Math.min(Math.max(0,(root.watertemp-40)*3.375),90)
                        }
                    ]
                }
                Rectangle{
                    id: water_2_box
                    x:61;y:61;
                    height:61; width:61
                    color: if(root.watertemp < root.waterhigh) root.primary_color; else tempWarningColor()
                    transform:[
                        Rotation{
                            id: water2rotate
                            origin.x: 0
                            origin.y: 0
                            angle: Math.min(Math.max(0,(root.watertemp-40)*3.375),180)
                        }
                    ]
                }
                Rectangle{
                    id: water_3_box
                    x:61;y:61;
                    height:61; width:61
                    color: if(root.watertemp < root.waterhigh) root.primary_color; else tempWarningColor()
                    transform:[
                        Rotation{
                            id: water3rotate
                            origin.x: 0
                            origin.y: 0
                            angle: Math.min(Math.max(0,(root.watertemp-40)*3.375),270)
                        }
                    ]
                }
                Rectangle{
                    id: water_4_mask
                    x:61;y:61;
                    height:65; width:61
                    color: "#000000"
                }
                Rectangle{
                    id: ring_mask
                    height: 101;width:101
                    x:11;y:11;z: 9
                    color: "#000000"
                    radius: width*0.5
                }
                Repeater{  //270/5 54
                    model: 9
                    property int index
                    Rectangle{
                        id: coolant_limit
                        x:61;y:61
                        height: 63; width: 2
                        antialiasing: true
                        color: if(index*(270/8) >= (root.waterhigh-40)*3.375 && (root.watertemp-40)*3.375 < index * (270/8)) tempWarningColor();else if((root.watertemp-40)*3.375 < index * (270/8)) root.primary_color; else "#000000"
                        transform:[
                            Rotation{
                                origin.x: 1;
                                origin.y: 0;
                                angle: index * (270/8)
                            }
                        ]
                    }
                }
                Rectangle{
                        id: coolant_limit
                        x:61;y:61;z:2
                        height: 61; width: 6
                        color: if(root.watertemp > root.waterhigh) "#000000"; else tempWarningColor()
                        antialiasing: true
                        transform:[
                            Rotation{
                                origin.x: 1.5;
                                origin.y: 0;
                                angle: (root.waterhigh-40)*3.375
                            }
                        ]
                    }
                Image{
                    x:38;y:80;z:15;
                    source: if(root.waterunits!==1) './images/coolant_f.png'; else './images/coolant_c.png'
                }
                Text{
                    font.family: boosted.name
                    font.pixelSize: 24
                    text: getTemp("COOLANT")
                    x:0; y:48; z: 10
                    color: if(root.watertemp < root.waterhigh) root.primary_color; else tempWarningColor()
                    width: 100
                    horizontalAlignment: Text.AlignRight
                }

            }
        }
    
    //Oil Temperature
        Item{
        id: oil_temp_gauge
        x:654;y:169;z:8
        Rectangle{
            width: 125; height:125
            radius: width*0.5
            clip: true
            color: root.digital_gauge_grey

            //Range 40-160 270/120 =2.25
            Rectangle{
                id: oil_1_box
                x:61;y:61;
                height:61; width:61
                color: if(root.oiltemp < root.oiltemphigh) root.primary_color; else tempWarningColor()
                transform:[
                    Rotation{
                        id: oil1rotate
                        origin.x: 0
                        origin.y: 0
                        angle: Math.min(Math.max(0,(root.oiltemp-40)*2.25),90)
                    }
                ]
            }
            Rectangle{
                id: oil_2_box
                x:61;y:61;
                height:61; width:61
                color: if(root.oiltemp < root.oiltemphigh) root.primary_color; else tempWarningColor()
                transform:[
                    Rotation{
                        id: oil2rotate
                        origin.x: 0
                        origin.y: 0
                        angle: Math.min(Math.max(0,(root.oiltemp-40)*2.25),180)
                    }
                ]
            }
            Rectangle{
                id: oil_3_box
                x:61;y:61;
                height:61; width:61
                color: if(root.oiltemp < root.oiltemphigh) root.primary_color; else tempWarningColor()
                transform:[
                    Rotation{
                        id: oil3rotate
                        origin.x: 0
                        origin.y: 0
                        angle: Math.min(Math.max(0,(root.oiltemp-40)*2.25),270)
                    }
                ]
            }
            Rectangle{
                id: oil_4_mask
                x:61;y:61;
                height:61; width:61
                color: "#000000"
            }
            Rectangle{
                id: ring_mask2
                height: 101;width:101
                x:11;y:11;z: 9
                color: "#000000"
                radius: width*0.5
            }
            Image{
                x:38;y:80;z:15;
                source: if(root.oiltempunits!==1) './images/oiltemp_f.png'; else './images/oiltemp_c.png'
            }
            //Range 40C to 120C = range of 80 degrees 270/80 =
            Rectangle{
                        id: oiltemp_limit
                        x:61;y:61;z:2
                        height: 61; width: 6
                        color: if(root.oiltemp < root.oiltemphigh) tempWarningColor(); else "#000000"
                        antialiasing: true
                        transform:[
                            Rotation{
                                origin.x: 1.5;
                                origin.y: 0;
                                angle: (root.oiltemphigh-40)*2.25
                            }
                        ]
                    }
            Repeater{  //270/5 54
                    model: 13
                    property int index
                    Rectangle{
                        id: oiltemp_limit
                        x:61;y:61
                        height: 63; width: 2
                        antialiasing: true
                        color: if(index*(270/12) >= (root.oiltemphigh-40)*2.25 && (root.oiltemp-40)*2.25 < index * (270/12)) tempWarningColor(); else if((root.oiltemp-40)*2.25 < index * (270/12)) root.primary_color; else "#000000"
                        transform:[
                            Rotation{
                                origin.x: 1;
                                origin.y: 0;
                                angle: index * (270/12)
                            }
                        ]
                    }
                }
            Text{
                font.family: boosted.name
                font.pixelSize: 24
                text: getTemp("OIL")
                x:0; y:48; z: 10
                color: if(root.oiltemp < root.oiltemphigh) root.primary_color; else tempWarningColor()
                width: 100
                horizontalAlignment: Text.AlignRight
            }

        }
    }
    //Oil Pressure
        Item{
            id:oil_pressure_gauge
            x:607;y:25;z:8
            
            Rectangle{
                width:125;height:125
                color: root.digital_gauge_grey
                clip: true;
                //color: "red"
                Rectangle{
                    height: 70; width: 10
                    x:61;y:61;z: 9;
                    color: if(root.oilpressurelow < root.oilpressure) root.primary_color; else tempWarningColor()
                    antialiasing: true
                    transform:[
                        Rotation{  //10 bar max, start 0 270
                            id: oilpressurerotation
                            origin.x:5;origin.y:0
                            angle:Math.min(Math.max(0, root.oilpressure*27),270)
                        }
                    ]
                }
                Repeater{
                    model: 11
                    property int index
                    Rectangle{
                        height: 61; width: 2
                        x:61;y:61;z:8
                        color: if(index>root.oilpressurelow) root.primary_color; else tempWarningColor()
                        antialiasing: true
                        transform:[
                            Rotation{
                                origin.x: 1.5;origin.y:0
                                angle:index*27
                                Behavior on angle{
                                    SpringAnimation {
                                        spring: 1.2
                                        damping:.16
                                    }
                                }
                            }
                        ]
                    }
                }
                Rectangle{
                    id: ring_mask3
                    height: 101;width:101
                    x:11;y:11;z: 9
                    color: "#000000"
                    radius: width*0.5
                }
                Text{
                    font.family: boosted.name
                    font.pixelSize: 24
                    text: root.oilpressureunits === 1 ? root.oilpressure.toFixed(1):(root.oilpressure*14.5038).toFixed(0)
                    x:0; y:48; z: 10
                    color: if(root.oilpressurelow < root.oilpressure) root.primary_color; else tempWarningColor()
                    width: 100
                    horizontalAlignment: Text.AlignRight
                }
                Image{
                    x:36;y:80;z:15;
                    source: if(root.oilpressureunits !==1) './images/oil_psi.png'; else './images/oil_bar.png'
                }
            }
        }
    Text{
        id: mileage
        x: 466; y: 424; z:9
        opacity: 0;
        color: root.primary_color
        text: if (root.speedunits === 0)
                        (root.odometer/.62).toFixed(0) 
                    else if(root.speedunits === 1)
                        root.odometer 
                    else
                        root.odometer
        // text: '234561'
        font.family: digital7monoItalic.name
        font.pixelSize: 24
        width: 67.3
        horizontalAlignment: Text.AlignRight
        Timer{
                interval: 1500; running: root.ignition; repeat: false
                onTriggered: animateMileage.start()
            }
    }
    SequentialAnimation{
        id: animateMileage
        NumberAnimation{
            target: mileage; property: "opacity"; from: 0.00; to: 1.00; duration: 500
        }
    }

    
} //End Meltfire Item




import QtQuick 2.3
import QtGraphicalEffects 1.0 as Effects
import QtQuick.Shapes 1.0

//                          @@%@@                                                   @@@@                                 
//                    @@@@@#++#@@@                                             @@@#+++++%@@                              
//              @@@%#++++++=++++#@@                     @@@           %@%@@  @%=======++++@@                             
//          @@#+========++==:=====+@                   @==#@         @@::=@@#:::=%%+::::::@@@                            
//       @@=::::+@@:.:+@@@@@@%.....+@                 @=::@@@        @=...%..:@@@@#%%....:@@@                            
//     @#....#@@@...+@@@     @@.. ..@@               @+..#@@         @=    =@@@@    @....+@@                     @@      
//   @% . .%@@@...=@@@        @:   :@@       @@@    @@. .%#%@        @.   @@@@      %   :@@@     @@@     @@@  @@#=++@@   
//  @:   .@@@.   @@@          @    +@#:+@   @+:.@@@#.       @@       @   =@@       @    @%+@@   @#=:@@  @::=@@:......@@  
// @:    @@%   .@@@           @    %#  .@@ @=   @#       @@@@@      %    %@@      @    @#  :@@ @#   @@ @=  ##  @@   .@@  
// %     @#   .@@            @    +%   @@@@%   @@@@@   @@@        @#     @@@     @    @@   %@@ %   @@@ @     +@@@   @@@  
// @     +    #@            @+    @   +@@@#    @@  %   @@        @=  #   @@   @@    @@@.   @@ %    @@ @#     @@@   .@@@  
// @%%@%%%%%%@@@%#@@       #@@@%  @. .@@@      %% @:  =@@@@@    @:  @=    @@@:    @@@@@ . .@@@=+#%@@@%@####.:@ @%%%@@::@@
//  @%+++++++===+@@@      @%+##@@@%######%@%%= =+%@%%%#%%%%@@  @@@@@@%%%#%%%%%@@@@@@ %%+++##+=%===++=+@+=:=@@  %:====:@@@
//    @%====@@@@@@@      @#===@@@%%   ..%@@+::::%@@%::::==@@@ @%#+@@@+++#++++@@@@    @%::...:@@#.   :@@   @@@  @%   @@@@ 
//    @....:@@         @@::.=@@@   @ .@@@@ @@@@@@@  @%#@@@@@  %==+@@%==+@====#@@      %:   @@@@@@@@@@@ @@@@@     @@@@@   
//    %     @@       @@.   @@@#     @@@%              %@@    @=::@@@=::%@%::..@@@       @@@@@     #%     @@              
//    %      @    @@=    @@@@                                %  .@@%   @@@=    @@                                        
//    @.               @@@@                                 @=  =@@   %@@ @.    @@                                       
//     @.           @@@@@                                   @.       :@@   %     @@                                      
//       @@     #@@@@@                                      +.      :@@%    @     @@                                     
//         @@@@@@@                                           @     @@@%      @      ..%@                                 
//                                                            %@@@@@@         @#      %@@                                
//                                                                              @@@@@@@@                                 

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
    property string primary_color: "#FFFFFF" //#FFBF00 for amber
    property string daylight_lcd_color: "#000000" //Daylight LCD should be black (tbd)
    property string night_light_color: "#CDFFBE" //Pale Green for LCD
    property string sweetspot_color: "#FFA500" //Cam Changeover Rev colpr
    property string warning_red: "#FF0000" //Redline/Warning colors
    property string engine_warmup_color: "#eb7500"
    property string background_color: "#000000"
    
    x: 0; y: 0

    //Fonts
    FontLoader {
        id: sonicMono
        source: "./fonts/sonicMono.ttf"
    }
    FontLoader {
        id: spaceHarrier
        source: "./fonts/spaceHarrier.ttf"
    }
    FontLoader {
        id: outrunDigital
        source: "./fonts/outrunSpeedoBlock.ttf"
    }
    //Utilities

    function getGear(){
        switch(rpmtest.geardata){
            case 0:
                return 'n'
            case 1:
                return 1
            case 2:
                return 2
            case 3:
                return 3
            case 4:
                return 4
            case 5:
                return 5
            case 6:
                return 6
            case 10:
                return 'r'
            default:
                return '-'
        }
    }
    function easyFtemp(degreesC){
        return ((((degreesC.toFixed(0))*9)/5)+32).toFixed(0)
    }
    /* ########################################################################## */
    /* Main Layout items */
    /* ########################################################################## */
    Rectangle {
        id: background_rect
        x: 0; y: 0
        width: 800
        height: 480
        color: root.background_color
        border.width: 0
        z: 0
    }

    PseudoRoad {
        id: pseudoRoad
        x: 0; y: 0; z:0
        width: 800; height: 640
        vehicleSpeed: root.speed
        laneMarkingColor: root.sidelight ?  "#E9C100" : "#ffffff"
        skyColorTop: root.sidelight ? "#100058": "#0092FB"
        skyColorBottom: root.sidelight ? "#44024C": "#8DCFFF"
        nightMode: root.sidelight
        roadColorOn: root.sidelight ? "#000000" : "#949494"
        roadColorOff: root.sidelight ? "#0A0A0A" : "#9c9c9c"
        terrainColorOn: root.sidelight ? "#1C180B" : "#efdece"
        terrainColorOff: root.sidelight ? "#231F13" : "#e6d6c5"
        cloudSource: root.sidelight ? './images/nightcloud.png' :  './images/daycloud.png'
        cloudWidth: 1400          // however wide you want ONE tile to render
        cloudHeight: 246
        cloudSpeed: 3        // slow ambient drift
        secondLayerSource: root.sidelight ? './images/night_back.png' : './images/back.png'
        horizonStripeSource: root.sidelight ? './images/night_horizonstripe.png' : './images/horizonstripe.png'
        trafficMinScale: 0.03
        spriteDefs:[
            {source: './images/windsurfchick.png', nightSource:'', side: "left", interval: 100, sideGap: 1000, width: 112*5, height: 169*5, yOffset: -100},
            {source: './images/windsurfchickblue.png', nightSource: '', side: "left", interval: 137, sideGap: 1000, width: 112*5, height: 169*5, yOffset: -100},
            {source: './images/greenwindsurf.png', nightSource: '', side: "left", interval: 132, sideGap: 1300, width: 112*5, height: 169*5, yOffset: -100},
            {source: './images/wavewater3.png', nightSource: './images/night_wavewater3.png', side: "left", interval: 3, sideGap: 3700, width: 1249*5, height: 64*5, yOffset: 200},
            // {source: './images/wavewater2.png', side: "left", interval: 3, sideGap: 1500, width: 488*5, height: 57*5, yOffset: 200},
            {source: './images/boathouse.png', nightSource: './images/night_boathouse.png', side: "right", interval: 40, sideGap: 1500, width: 240*4, height: 171*4},
            {source: './images/icecream.png', nightSource: './images/night_icecream.png', side: "right", interval: 317, sideGap: 300, width: 213*4, height: 201*4},
            {source: './images/palmtree.png', nightSource: './images/night_palmtree.png', side: "right", interval: 19, sideGap: 100},
            {source: './images/palmtree.png', nightSource: './images/night_palmtree.png', side: "right", interval: 20, sideGap: 700},
            {source: './images/palmtree.png', nightSource: './images/night_palmtree.png', side: "right", interval: 12, sideGap: 900},
            {source: './images/shrub.png', nightSource: './images/night_shrub.png', side: "right", interval: 14, sideGap: 900, yOffset: 370},
            {source: './images/shrub.png', nightSource: './images/night_shrub.png', side: "right", interval: 16, sideGap: 300, yOffset: 370},
            {source: './images/shrub.png', nightSource: './images/night_shrub.png', side: "right", interval: 20, sideGap: 1100, yOffset: 370},



        ]
        trafficDefs: [
            // { source: 'img/car_sedan.png', lane: 'left', speed: 0, count: 1 },
                // { source: 'img/car_sedan.png', lane: 'random', speed: 0, speedVariance: 0.2, yOffset: 15, count: 2 }

            { source: './images/beetle16.png', lane: 'right', speed: 60,speedVariance: 0.2,  yOffset: 340, count: 1,scalePercent: 70},
            { source: './images/truck16.png', lane: 'right', speed: 60,speedVariance: 0.2,  yOffset: 340, count: 1,scalePercent: 100},
            { source: './images/bmw13.png', lane: 'left', speed:100, speedVariance: 0.2, yOffset: 340,  count: 1,scalePercent: 70},
            { source: './images/porsche13.png', lane: 'left', speed:120, speedVariance: 0.2, yOffset: 340,  count: 1,scalePercent: 70}
            

        ]
    }
    Item{
        x: 320; y: 353
        Image{
            id: left_indicator
            x: 25; y: 31;z:2
            opacity: root.leftindicator ? 1 : 0
            source: './images/car_blinker.png'

        }
        Image{
            id: right_indicator
            x: 125; y: 31;z:2
            opacity: root.rightindicator ? 1 : 0
            source: './images/car_blinker.png'

        }

        Image{
            id: lotus
            x:0; y:0; z:1
            source: !root.sidelight ? './images/lotus.png' : './images/darklotus.png'
        }
    }
    Text{
        x: 20;
        y: 380;
        z: 2
        color: '#FB2808'
        font.family: outrunDigital.name
        font.pixelSize: 80
        horizontalAlignment: Text.AlignRight
        width: 140
        text: if (root.speedunits === 0) root.speed.toFixed(0); else (root.speed*.62).toFixed(0)
    }
    Text{
        x: 23;
        y: 383;
        z: 1
        color: '#000000'
        font.family: outrunDigital.name
        font.pixelSize: 80
        horizontalAlignment: Text.AlignRight
        width: 140
        text: if (root.speedunits === 0) root.speed.toFixed(0); else (root.speed*.62).toFixed(0)
    }
    Image{
        id: speed_units
        x: 170; y: 385
        source: root.speedunits === 0 ? './images/km_hour.png' : './images/mi_hour.png'
    }
Item {
    id: funkygauge
    x: 150; y: 100
    // ---- Public API ----
    property real currentRpm: root.rpm        // drive this from your engine/animation
    property int  maxRpm: 10000
    property int  rpmPerUnit: 500      // 1000 RPM / 2 units = 500 RPM per unit
    property int  unitWidth: 23
    property int  unitGap: 2

    property int  minBarHeight: 100
    property int  maxBarHeight: 200
    property int  rampStartRpm: 5000
    property int  rampEndRpm: 8000

    property color colorNormal: "#c5a1e1eb"
    property color colorRamp: "#c5e6b800"
    property color colorRedline: "#c5e63946"
    property color colorUnlit: "#02ffffff"

    // ---- Derived geometry ----
    readonly property int unitCount: Math.round(maxRpm / rpmPerUnit)

    implicitWidth: unitsRow.width
    implicitHeight: maxBarHeight

    // Maps an RPM value to a bar-top height (100px -> 200px ramp between
    // rampStartRpm and rampEndRpm, flat outside that range)
    function heightForRpm(rpm) {
        if (rpm <= rampStartRpm)
            return minBarHeight
        if (rpm >= rampEndRpm)
            return maxBarHeight
        var t = (rpm - rampStartRpm) / (rampEndRpm - rampStartRpm)
        return minBarHeight + t * (maxBarHeight - minBarHeight)
    }

    // Optional: color coding by zone (feel free to just use colorNormal everywhere)
    function colorForRpm(rpm) {
        if (rpm >= rampEndRpm)
            return colorRedline
        if (rpm >= rampStartRpm)
            return colorRamp
        return colorNormal
    }

    Row {
        id: unitsRow
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        spacing: funkygauge.unitGap

        Repeater {
            model: funkygauge.unitCount

            delegate: Item {
                id: bar
                width: funkygauge.unitWidth
                height: funkygauge.maxBarHeight

                readonly property real leftRpm: index * funkygauge.rpmPerUnit
                readonly property real rightRpm: (index + 1) * funkygauge.rpmPerUnit
                readonly property real leftH: funkygauge.heightForRpm(leftRpm)
                readonly property real rightH: funkygauge.heightForRpm(rightRpm)
                property color barColor: funkygauge.colorForRpm(leftRpm)

                // 0 = not reached yet, 1 = fully passed, in-between = partial
                readonly property real fillFraction: Math.max(0, Math.min(1,(funkygauge.currentRpm - leftRpm) / (rightRpm - leftRpm)))

                // antialiasing: true
                // ---- background (clipped to the fill amount) ----
                Item {
                    width: bar.width * bar.fillFraction   // <- the pixel-by-pixel bit
                    height: parent.height
                    clip: true

                    Shape {
                        width: bar.width      // full shape width, gets visually cropped by clip
                        height: bar.height
                        ShapePath {
                            fillColor: bar.barColor
                            strokeWidth: -1
                                startX: 0
                                startY: bar.height
                                PathLine { x: 0;             y: bar.height - bar.leftH }
                                PathLine { x: bar.width;      y: bar.height - bar.rightH }
                                PathLine { x: bar.width;      y: bar.height }
                                PathLine { x: 0;              y: bar.height }
                                }
                            
                            }
                        }//Fill Item
                Shape {
                    anchors.fill: parent
                    ShapePath {
                        property real r: index === funkygauge.unitCount - 1 ? 8 : 2
                        strokeWidth: -1
                        // fillColor: bar.barColor
                        fillGradient: LinearGradient {
                                x1: 0;         y1: 0
                                x2: 0;         y2: bar.height
                                GradientStop { position: 0.0; color: "#88FFFFFF" }
                                GradientStop { position: 0.30; color: "#00ffffff" }
                                GradientStop { position: 0.70; color: "#00ffffff" }
                                GradientStop { position: 1.0; color: "#88FFFFFF" }
                            }

                        startX: 0
                        startY: bar.height
                        PathLine { x: 0;             y: bar.height - bar.leftH }
                        PathLine { x: bar.width;      y: bar.height - bar.rightH }
                        PathLine { x: bar.width;      y: bar.height }
                        PathLine { x: 0;              y: bar.height }
                    }

                    // Behavior on barColor {
                    //     ColorAnimation { duration: 120 }
                    // }   
                    }//End Shape     
            
                
                    }//End delegate
                }//End Repeater
            }//End Row
        }//End Item
    Image{
        id: revcounter
        x: 130; y: 310
        source: root.sidelight ? './images/dark_revcounter.png' : './images/light_revcounter.png'
    }
    Item {
    width: 138; height: 18
    x: 500; y: 352

    // Outline layer: stamp the text 8x around a 2px ring, all solid black
    Item {
        id: outline_layer
        anchors.fill: parent
        Repeater {
            model: [
                Qt.point(-2,0), Qt.point(2,0), Qt.point(0,-2), Qt.point(0,2),
                Qt.point(-2,-2), Qt.point(2,-2), Qt.point(-2,2), Qt.point(2,2)
            ]
            Text {
                x: modelData.x; y: modelData.y
                width: 138; height: 18
                horizontalAlignment: Text.AlignRight
                color: "black"
                font.family: spaceHarrier.name
                font.pixelSize: 24
                text: root.odometer.toFixed(0)
            }
        }
    }

    // Gradient-filled fill layer on top
    Text{
        id: odometer_text
        width: 138; height: 24
        horizontalAlignment: Text.AlignRight
        color: "#B200A2"
        font.family: spaceHarrier.name
        text: root.odometer.toFixed(0)
        font.pixelSize: 24
    }
    Effects.LinearGradient {
        anchors.fill: odometer_text
        source: odometer_text
        start: Qt.point(0, 0)
        end: Qt.point(0, height)
        gradient: Gradient {
            GradientStop { position: 0; color: "#FF4DEF" }
            GradientStop { position: 1; color: "#B200A2" }
        }
    }
}
    Image{
        id: odometer_label
        x: 640; y: 357
        source: root.speedunits === 0 ? './images/km.png' : './images/mi.png'
    }
    Item{
        x: 576; y: 419
        Text{
            x:0;y:0;z:1
            id: fuel_label
            text: 'FUEL'
            font.family: sonicMono.name
            font.pixelSize: 26
            color: "#F3F300"
        }
        Text{
            x:3;y:3;z:0
            id: fuel_shadow
            text: 'FUEL'
            font.family: sonicMono.name
            font.pixelSize: 26
            color: "#000000"
        }
        Rectangle{
            x:90;y:0;z:1
            width: 120; height: 30
            gradient: Gradient{
                GradientStop{position: 0.0; color: "#A0A9B0"}
                GradientStop{position: 0.20; color: "#00CDDDED"}
                GradientStop{position: 0.80; color: "#00CDDDED"}
                GradientStop{position: 1.0; color: "#A0A9B0"}
            }
        }
        Rectangle{
            x:90;y:0;z:0
            width: root.fuel/100 * 120; height: 30
            color: "#ffffff"
        }
        Repeater{
            model: 11
            Rectangle{
                x: 90 + index * 12; y:0; z:1
                width: 2; height: 30
                gradient: Gradient{
                    GradientStop{position: 0.0; color: "#CECECE"}
                    GradientStop{position: 0.20; color: "#AFB9C3"}
                    GradientStop{position: 0.80; color: "#AFB9C3"}
                    GradientStop{position: 1.0; color: "#CECECE"}
                }
            }
        }
    }//End Fuel Gauge

    //Digital Meters

        Item{
            id: coolant_meter
            x: 16; y:25
            height: 30
            Image{
                x: 0; y: 0
                source: './images/coolant_label.png'
            }
            Text{
                x: 50; y: 0; z: 2
                text:root.waterunits === 1 ? root.watertemp.toFixed(0) :  easyFtemp(root.watertemp)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#F3F300"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 148; y: 12; z:2
                text: root.waterunits === 1 ? 'C' : 'F'
                font.family: sonicMono.name
                font.pixelSize: 12
                color: "#F3F300"
            }
            Text{
                x: 52; y: 2; z: 1
                text: easyFtemp(root.watertemp)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#000000"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 150; y: 14; z:1
                text: root.waterunits === 1 ? 'C' : 'F'
                font.family: sonicMono.name
                font.pixelSize: 12
                color: "#000000"
            }

        }
        Item{
            id: oilpress_meter
            x: 175; y:25
            height: 30
            Image{
                x: 0; y: 0
                source: './images/oilpress_label.png'
            }
            Text{
                x: 52; y: 0; z: 2
                text: if(root.oilpressureunits === 1) root.oilpressure.toFixed(1); else (root.oilpressure.toFixed(1) * 14.504).toFixed(0)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#F3F300"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 150; y: 12; z:2
                text: root.oilpressureunits === 0 ? 'PSI' : 'BAR'
                font.family: sonicMono.name
                font.pixelSize: 12
                color: "#F3F300"
            }
            Text{
                x: 52; y: 2; z: 1
                text: if(root.oilpressureunits === 1) root.oilpressure.toFixed(1); else (root.oilpressure.toFixed(1) * 14.504).toFixed(0)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#000000"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 150; y: 14; z:1
                text: root.oilpressureunits === 1 ? 'PSI' : 'BAR'
                font.family: sonicMono.name
                font.pixelSize: 12
                color: "#000000"
            }
        }
        Item{
            id: oiltemp_meter
            x: 460; y:25
            height: 30
            Image{
                x: 0; y: 0
                source: './images/oiltemp_label.png'
            }
            Text{
                x: 60; y: 0; z: 2
                text: easyFtemp(root.oiltemp)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#F3F300"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 158; y: 12; z:2
                text: root.oiltempunits === 1 ? 'C' : 'F'
                font.family: sonicMono.name
                font.pixelSize: 12
                color: "#F3F300"
            }
            Text{
                x: 60; y: 2; z: 1
                text: easyFtemp(root.oiltemp)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#000000"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 158; y: 14; z:1
                text: root.oiltempunits === 1 ? 'C' : 'F'
                font.family: sonicMono.name
                font.pixelSize: 12
                color: "#000000"
            }
        }
        Item{
            id: wideband_meter
            x: 633; y:25
            height: 30
            Image{
                x: 0; y: 0
                source: './images/wideband_label.png'
            }
            Text{
                x: 60; y: 0; z: 2
                text: root.o2.toFixed(1)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#F3F300"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 60; y: 2; z: 1
                text: root.o2.toFixed(1)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#000000"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
        }

    Item{
        id: idiot_lights
        x: 16; y: 80
        Text{
            x:0;y:0;z:1
            id: check_engine
            text: 'Check Engine'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#F3F300"
            opacity: root.mil ? 1 : 0
        }
        Text{
            x:0;y:15;z:0
            id: emergency_brake
            text: 'Brake'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#FF0000"
            opacity: root.brake ? 1 : 0
        }
        Text{
            x:0;y:30;z:0
            id: seatbelt_light
            text: 'Seatbelt'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#FF0000"
            opacity: root.seatbelt ? 1 : 0
        }
        Text{
            x:0;y:45;z:0
            id: airbag_light
            text: 'Airbag'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#F3F300"
            opacity: root.airbag ? 1 : 0
        }
        Text{
            x:0;y:60;z:0
            id: tc_light
            text: 'TC'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#F3F300"
            opacity: root.tc ? 1 : 0
        }
        Text{
            x:0;y:75;z:0
            id: abs_light
            text: 'ABS'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#F3F300"
            opacity: root.abs ? 1 : 0
        }
        Text{
            x:0;y:90;z:0
            id: tc_off_light
            text: 'TC OFF'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#F3F300"
            opacity: root.tc_off ? 1 : 0
        }
        Text{
            x:0;y:105;z:0
            id: cruise_light
            text: 'Cruise'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#F3F300"
            opacity: root.cruise_id ? 1 : 0
        }
        Text{
            x:0;y:120;z:0
            id: reverse_light
            text: 'Reverse'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#F3F300"
            opacity: root.reverse ? 1 : 0
        }
        Text{
            x:0;y:135;z:0
            id: battery_light
            text: 'Battery'
           font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#FF0000"
            opacity: root.battery ? 1 : 0
        }
 
    }
    Image{
        id: mainbeam_light
        x: 380; y: 30
        source: './images/highbeams.png'
        opacity: root.mainbeam ? 1 : 0
    }

} //End Outrun


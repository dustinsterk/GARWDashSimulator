/****************************************************************************
**
** Copyright (C) 2012 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

//! [imports]
import QtQuick 2.3

import FileIO 1.0
import QtGraphicalEffects 1.0
import "images"
//import QtGraphicalEffects 1.0
//! [imports]

//! [0]
Item{
    id:root

    property int udp_message:rpmtest.udp_packetdata
   // onUdp_messageChanged: console.log(" UDP is "+udp_message)

    property bool udp_up:udp_message&0x01
    property bool udp_down:udp_message&0x02
    property bool udp_left:udp_message&0x04
    property bool udp_right:udp_message&0x08
    property int odometer:if(speedunits==0)rpmtest.odometer0data;else rpmtest.odometer0data*0.62
    property int tripmeter:if(speedunits==0)rpmtest.tripmileage0data;else rpmtest.tripmileage0data*0.62
    property real rpm:rpmtest.rpmdata
    property real speed:rpmtest.speeddata
    property int speedunits:0
    property real watertemp:rpmtest.watertempdata
    property real fuel:rpmtest.fueldata
    property real o2:rpmtest.o2data
    property real map:rpmtest.mapdata
    property real maf:rpmtest.mafdata
    property real oilpressure:rpmtest.oilpressuredata
    property real oiltemp: rpmtest.oiltempdata
    property real batteryvoltage:rpmtest.batteryvoltagedata

    property real symbols:rpmtest.symbolsdata
    property real symbols2:rpmtest.symbols2data

    property real gearpos:rpmtest.geardata

    property real rpmlimit:4000
    property real shiftvalue:0
    property string colorscheme: "green"
    property int red: 255
    property int green: 128
    property int blue: 100

    property real rpmdamping:1
   // property real fueldamping:7
  //  onFueldampingChanged: if(fueldamping<7)fueldamping=7

    property real batterylow:0
    property real batteryhigh:0
    property real batteryunits:0

    property real afrlow:0
    property real afrhigh:0
    property real afrunits:0

    property int waterlow:0
    property int waterhigh:0
    property int waterunits:0
    property int fuellow:0
    property int fuelhigh:0
    property int fuelunits:1
    property int oiltemplow:0
    property int oiltemphigh:0
    property int oiltempunits:0
    property int oilpressurelow:0
    property int oilpressurehigh:0
    property int oilpressureunits:0
    property real night_time_hue:0

    property bool settings_on_off:false//put back to false
    property bool menu_on_off:rpmtest.settings_on_offdata&0x02

    onSettings_on_offChanged: {if(settings_on_off){rpmtest.settings_on_offdata=rpmtest.settings_on_offdata|0x01;}//console.log("settings are"+settings_on_off)}
                                else rpmtest.settings_on_offdata=rpmtest.settings_on_offdata&~0x01}

width:800
height:480
FontLoader{
        id:basicfont;
        source: "./fonts/GeistVariableVF.ttf"
    }
Item{
    x: 800
    y: 50

    opacity:if(settings_on_off&&dial.x==80)1.0;else 0
    Behavior on opacity{ NumberAnimation{duration: 2000}}

///////left column/////////



    Text {
        id: watertemp_
        x: -768
        y: -38
        color: "#0000ff"
        text: qsTr("Coolant")
        font.pixelSize: 17
        font.family: basicfont.name
        Text{x: 17;y: 26; width: 37; height: 17;color:if(currentindex.position===4)"green";else "#ffffff";text:"High"}
        Text{x: 17;y: 49; width: 37; height: 17;color:if(currentindex.position===5)"green";else "#ffffff";text:"Low"}
        Text{x: 17;y: 72; width: 37; height: 17;color:if(currentindex.position===6)"green";else "#ffffff";text:"Units"}
        Text{x: 82;y: 72; width: 37; height: 17;color:if(currentindex.position===7)"green";else "#ffffff";text:if(root.waterunits===1)"C";else "F"}
        Text{id: waterlowvalue;x: 82;y: 49; width: 37; height: 17;color: "#ffffff";text:root.waterlow}
        Text{id: waterhighvalue;x: 82;y: 26; width: 27;color: "#ffffff";text:root.waterhigh}
         }

    Text {
        id: fuel_
        x: -768
        y: 56
        color: "#0000ff"
        text: qsTr("Fuel")
        font.pixelSize: 17
        font.family: basicfont.name
        Text{x: 17;y: 26; width: 37; height: 17;color:if(currentindex.position===8)"green";else "#ffffff";text:"High"}
        Text{x: 17;y: 49; width: 37; height: 17;color:if(currentindex.position===9)"green";else "#ffffff";text:"Low"}
        Text{x: 17;y: 72; width: 37; height: 17;color:if(currentindex.position===10)"green";else "#ffffff";text:"Damp"}
      //  Text{x: 82;y: 72; width: 37; height: 17;color:if(currentindex.position===11)"green";else "#ffffff";text:root.fueldamping }
        Text {id: fuellowvalue;x: 82;y: 49;width: 37;height: 17;color: "#ffffff"; text: root.fuellow;  }
        Text {id: fuelhighvalue;x: 82;y: 26;width: 27;color: "#ffffff";text: root.fuelhigh;}
         }
    Text {
        id: oiltemp_
        x: -766
        y: 149
        color: "#0000ff"
        text: qsTr("Oiltemp")
        font.pixelSize: 17
        font.family: basicfont.name
        Text{x: 17;y: 26; width: 37; height: 17;color:if(currentindex.position===12)"green";else "#ffffff";text:"High"}
        Text{x: 17;y: 49; width: 37; height: 17;color:if(currentindex.position===13)"green";else "#ffffff";text:"Low"}
        Text{x: 17;y: 72; width: 37; height: 17;color:if(currentindex.position===14)"green";else"#ffffff";text:"Units"}
        Text{x: 82;y: 72; width: 37; height: 17;color:if(currentindex.position===15)"green";else "#ffffff";text:if(root.oiltempunits===1)"C";else "F"}
        Text {id: oiltemplowvalue;x: 82;y: 49;width: 37;height: 17;color: "#ffffff"; text: root.oiltemplow;  }
        Text {id: oiltemphighvalue;x: 82;y: 26;width: 27;color: "#ffffff";text: root.oiltemphigh;}
         }
    Text {
        id: oilpressure_
        x: -768
        y: 242
        color: "#0000ff"
        text: qsTr("Oilpressure")
        font.pixelSize: 17
        font.family: basicfont.name
        Text{x: 17;y: 26; width: 37; height: 17;color:if(currentindex.position===16)"green";else "#ffffff";text:"High"}
        Text{x: 17;y: 49; width: 37; height: 17;color:if(currentindex.position===17)"green";else "#ffffff";text:"Low"}
        Text{x: 17;y: 72; width: 37; height: 17;color:if(currentindex.position===18)"green";else "#ffffff";text:"Units"}
        Text{x: 82;y: 72; width: 37; height: 17;color:if(currentindex.position===19)"green";else "#ffffff";text:if(root.oilpressureunits===1)"Bar";else "Psi"}
        Text {id: oilpressurelowvalue;x: 82;y: 49;width: 37;height: 17;color: "#ffffff"; text: root.oilpressurelow;  }
        Text {id: oilpressurehighvalue;x: 82;y: 26;width: 27;color: "#ffffff";text: root.oilpressurehigh;}
         }
    Text {
        id: battery_
        x: -768
        y: 330
        color: "#0000ff"
        text: qsTr("Battery")
        font.pixelSize: 17
        font.family: basicfont.name
        Text{x: 17;y: 26; width: 37; height: 17;color:if(currentindex.position===20)"green";else "#ffffff";text:"High"}
        Text{x: 17;y: 49; width: 37; height: 17;color:if(currentindex.position===21)"green";else "#ffffff";text:"Low"}
        Text{x: 17;y: 72; width: 37; height: 17;color: "#ffffff";text:"Units"}
        Text{x: 82;y: 72; width: 37; height: 17;color: "#ffffff";text:"V"}
        Text{id: batterylowvalue;x: 82;y: 49; width: 37; height: 17;color: "#ffffff";text:root.batterylow.toFixed(1)}
        Text{id: batteryhighvalue;x: 82;y: 26; width: 27;color: "#ffffff";text:root.batteryhigh.toFixed(1)}
         }
    Text {
        id: afr_
        x: -649
        y: -45
        color: "#0000ff"
        text: qsTr("AFR")
        font.pixelSize: 17
        font.family: basicfont.name
        Text{x: 17;y: 26; width: 37; height: 17;color:if(currentindex.position===27)"green";else "#ffffff";text:"High"}
        Text{x: 17;y: 49; width: 37; height: 17;color:if(currentindex.position===28)"green";else "#ffffff";text:"Low"}
        Text{x: 17;y: 72; width: 37; height: 17;color: "#ffffff";text:"Units"}
        Text{x: 82;y: 72; width: 37; height: 17;color: "#ffffff";text:"L"}
        Text{id: afrlowvalue;x: 82;y: 49; width: 37; height: 17;color: "#ffffff";text:root.afrlow.toFixed(1)}
        Text{id: afrhighvalue;x: 82;y: 26; width: 27;color: "#ffffff";text:root.afrhigh.toFixed(1)}
         }

    /////////top row/////////

    Text {
        id: red
        x: -500
        y: -38
        color:if(currentindex.position===1)"green";else "#ffffff"
        text: qsTr("Red")
        font.pixelSize: 19
        font.family: basicfont.name
        Text{id: redvalue;x: 61;y: 0;color: "#ffffff";text:root.red ;font.pointSize: 15}
    }

    Text {
        id: green
        x: -500
        y: -10
        color:if(currentindex.position===2)"green";else "#ffffff"
        text: qsTr("Green")
        font.pixelSize: 19
        font.family: basicfont.name
        Text{id: greenvalue;x: 61;y: 0;color: "#ffffff";text:root.green ;font.pointSize: 15}
    }

    Text {
        id: blue
        x: -500
        y: 18
        color:if(currentindex.position===3)"green";else "#ffffff"
        text: qsTr("Blue")
        font.pixelSize: 19
        font.family: basicfont.name
        Text{id: bluevalue;x: 61;y: 0;color: "#ffffff";text:root.blue ;font.pointSize: 15}
    }

    Text {
        id: speedunit
        x: -391
        y: -38
        color:if(currentindex.position===22)"green";else "#ffffff"
        text: qsTr("Speed units")
        font.pixelSize: 19
        font.family: basicfont.name
        Text{id: speedunitvalue;x: 113;y: 0;color: "#ffffff";text:if(root.speedunits===1)"MPH";else if(root.speedunits===0) "KMH";else "BOTH";font.pointSize: 15}
    }

    Text {
        id: exit
        x: -80
        y: -38
        color:if(currentindex.position===0)"green";else "#ffffff"
        text: qsTr("Exit")
        font.pixelSize: 19
        font.family: basicfont.name
        
    }

    Text {
        id: rpmlimit_
        x: -391
        y: -10
        color: if(currentindex.position===23)"green";else "#ffffff"
        text: qsTr("Rpm limit")
        font.pixelSize: 19
        font.family: basicfont.name
        Text {id: rpmlimitvalue;x: 83;y: 0;color: "#ffffff";text: root.rpmlimit; font.pointSize: 15}



    }
    Text {
        id: shiftvalue_
        x: -391
        y: 18
        color: if(currentindex.position===24)"green";else "#ffffff"
        text: qsTr("Shift rpm")
        font.pixelSize: 19
        font.family: basicfont.name
        Text {id: shiftvaluevalue;x: 113;y: 0;color: "#ffffff";text: root.shiftvalue; font.pointSize: 15}

    }

    Text {
        id: nighthue
        x: -216
        y: -38
        color: if(currentindex.position===25)"green";else "#ffffff"
        text: qsTr("Nightlight")
        font.family: basicfont.name
        font.pixelSize: 19
        Text {
            id: nighthuevalue
            x: 113
            y: 0
            color: "#ffffff"
            text: root.night_time_hue
            font.pointSize: 15
        }
    }

    Text {
        id: rpmdamping_
        x: -235
        y: -10  
        color: if(currentindex.position===26)"green";else "#ffffff"
        text: qsTr("Rpm damping")
        font.pixelSize: 19
        font.family: basicfont.name
        Text {id: rpmdampvalue;x: 132;y: 0;color: "#ffffff";text: root.rpmdamping; font.pointSize: 15}



    }
     }

///////////////////////////////
//////////////////////////////


FileIO {
    id: config_file
    source: "/opt/IC7/screen_configs/Meltfire_config.txt"
    onError: console.log(msg)
       }

 property int counter:0
 property var  configstring:[25]


    Component.onCompleted: {

    // Tell the host firmware that warnings are handled locally so it does NOT draw its own
    // warning-light overlay over the dash (matching GTDash). The property is absent on older
    // firmware / the desktop sim, so the write is guarded with try/catch.
    try { rpmtest.DISABLE_WARNING_OVERLAY = "YES_WARNINGS_HANDLED_LOCALLY"; } catch (e) {}

    for(counter=0;counter<26;counter++){
    config_file.openforreading()
    root.configstring[counter]=config_file.readopenfile(counter)
    config_file.close()
    //console.log("config"+counter+" string for race screen is "+root.configstring[counter])
                                       }

    colorscheme=configstring_function(0)

     root.red=configstring_function(1)
//console.log("red "+root.red)

     root.green=configstring_function(2)
//console.log("green "+root.green)

     root.blue=configstring_function(3)
//console.log("blue "+root.blue)

    root.waterlow = configstring_function(4)
    //console.log("waterlow "+waterlow)
    root.waterhigh = configstring_function(5)
    //console.log("waterhigh "+waterhigh)
    root.waterunits= configstring_function(6)

   root.fuellow= configstring_function(7)
    //console.log("fuellow "+fuellow)
   root.fuelhigh= configstring_function(8)
    //console.log("fuelhigh "+fuelhigh)
                  // root.fuelunits=configstring_function(9)

   root.oiltemplow= configstring_function(10)
    //console.log("oiltemplow "+oiltemplow)
   root.oiltemphigh= configstring_function(11)
    //console.log("oiltemphigh "+oiltemphigh)
    root.oiltempunits=configstring_function(12)

   root.oilpressurelow= configstring_function(13)
    //console.log("oilpressurelow "+oilpressurelow)
   root.oilpressurehigh= configstring_function(14)
    //console.log("oilpressurehigh "+oilpressurehigh)
    root.oilpressureunits=configstring_function(15)

    root.speedunits=configstring_function(16)
    root.rpmlimit=configstring_function(17)
    root.shiftvalue=configstring_function(18)
    root.night_time_hue=configstring_function(19)

    root.batterylow=configstring_function(20)
    root.batteryhigh=configstring_function(21)

    root.rpmdamping=configstring_function(22)
  //  root.fueldamping=configstring_function(23)

    root.afrhigh=configstring_function(24)
    root.afrlow=configstring_function(25)
                            }



 function save_settings()
     {
     configstring[1]=root.red
     configstring[2]=root.green
     configstring[3]=root.blue
     configstring[4]=root.waterlow
     configstring[5]=root.waterhigh
     configstring[6]=root.waterunits
     configstring[7]=root.fuellow
     configstring[8]=root.fuelhigh
     configstring[9]=root.fuelunits
     configstring[10]=root.oiltemplow
     configstring[11]=root.oiltemphigh
     configstring[12]=root.oiltempunits
     configstring[13]=root.oilpressurelow
     configstring[14]=root.oilpressurehigh
     configstring[15]=root.oilpressureunits
     configstring[16]=root.speedunits
     configstring[17]=root.rpmlimit
      configstring[18]=root.shiftvalue
     configstring[19]=root.night_time_hue
     configstring[20]=root.batterylow
     configstring[21]=root.batteryhigh
     configstring[22]=root.rpmdamping
   //  configstring[23]=root.fueldamping
     configstring[24]=root.afrhigh
     configstring[25]=root.afrlow
          //////////
          config_file.open()
          for(counter=0;counter<26;counter++){

              config_file.writetoopenfile(root.configstring[counter])
              config_file.writetoopenfile("\n")

                                             }
          config_file.close()

          //console.log("config string "+configstring)

     }

    function configstring_function(config_number){

    //  console.log("config string for race screen is "+root.configstring[0] +" and "+ root.configstring[1]+" and "+ root.configstring[2]+" and "+ root.configstring[3])

    return   root.configstring[config_number]
                                                 }

    property int inputs:rpmtest.inputsdata

    //Inputs//31 max!!
    property bool ignition      :inputs&0x01
    property bool battery       :inputs&0x02
    property bool lapmarker     :inputs&0x04
    property bool rearfog       :inputs&0x08
    property bool mainbeam      :inputs&0x10
    property bool up_joystick   :inputs&0x20 || root.udp_up
    property bool leftindicator :inputs&0x40
    property bool rightindicator:inputs&0x80
    property bool brake         :inputs&0x100
    property bool oil           :inputs&0x200
    property bool seatbelt      :inputs&0x400
    property bool sidelight     :inputs&0x800
    property bool tripresetswitch     :inputs&0x1000
    property bool down_joystick :inputs&0x2000 || root.udp_down
    property bool doorswitch    :inputs&0x4000
    property bool airbag        :inputs&0x8000
    property bool tc            :inputs&0x10000
    property bool abs           :inputs&0x20000
    property bool mil           :inputs&0x40000
    property bool shift1_id     :inputs&0x80000
    property bool shift2_id     :inputs&0x100000
    property bool shift3_id     :inputs&0x200000
    property bool service_id    :inputs&0x400000
    property bool race_id       :inputs&0x800000
    property bool sport_id      :inputs&0x1000000
    property bool cruise_id     :inputs&0x2000000
    property bool reverse:inputs&0x4000000
    property bool handbrake :inputs&0x8000000
    property bool tc_off     :inputs&0x10000000
    property bool left_joystick :inputs&0x20000000 || root.udp_left
    property bool right_joystick:inputs&0x40000000 || root.udp_right

    onUp_joystickChanged: console.log("up")
    onDown_joystickChanged: console.log("down")
    onLeft_joystickChanged: console.log("left")
    onRight_joystickChanged: console.log("right")

  property bool movedown:left_joystick //p1_11//if((lamps&0x01)==0x01)true;else false   //left indicator

  property bool moveup:right_joystick// p1_12//if((lamps&0x02)==0x02)true;else false        //right indicator


  property bool increament:up_joystick//p1_9||p2_20

  property bool decreament:down_joystick
    x: 0//p1_18||p2_19



    onMovedownChanged: if(movedown&&settings_on_off)currentindex.position-=1
    onMoveupChanged: if(moveup&&settings_on_off)currentindex.position+=1

  //  onMovedownChanged:{ if(!movedown)savetimer.start();else savetimer.stop;settings_on_off=true}
  //  onMoveupChanged:{if(!moveup)savetimer.start();else savetimer.stop;settings_on_off=false}



    Timer{
        id:redtimer
        interval: 100
        onTriggered:{if(increament){ root.red+=1;if(root.red>255)root.red=0;}
            else if(decreament){root.red-=1;if(root.red<0)root.red=255}
           }

        repeat: true
    }
    Timer{
        id:greentimer
        interval: 100
        onTriggered: {if(increament){ root.green+=1;if(root.green>255)root.green=0;}
                      else if(decreament){root.green-=1;if(root.green<0)root.green=255}
                     }
        repeat: true
    }
    Timer{
        id:bluetimer
        interval: 100
        onTriggered: {if(increament){ root.blue+=1;if(root.blue>255)root.blue=0;}
            else if(decreament){root.blue-=1;if(root.blue<0)root.blue=255}
           }
        repeat: true
    }

    Timer{
        id:waterhightimer
        interval: 100
        onTriggered:{if(increament)root.waterhigh+=1
                else if(decreament)root.waterhigh-=1}
        repeat: true
    }
    Timer{
        id:waterlowtimer
        interval: 100
        onTriggered:{if(increament)root.waterlow+=1
            else if(decreament)root.waterlow-=1
                    if(root.waterlow<0)root.waterlow=0 }
        repeat: true
    }


    Timer{
        id:fuelhightimer
        interval: 100
        onTriggered:{if(increament)root.fuelhigh+=1
            else if(decreament)root.fuelhigh-=1}
        repeat: true
    }
    Timer{
        id:fuellowtimer
        interval: 100
        onTriggered:{if(increament)root.fuellow+=1
            else if(decreament)root.fuellow-=1}
        repeat: true
    }

    Timer{
        id:oiltemphightimer
        interval: 100
        onTriggered: {if(increament)root.oiltemphigh+=1
            else if(decreament)root.oiltemphigh-=1
              if(root.oiltemphigh<0)root.oiltemphigh =0 }
        repeat: true
    }
    Timer{
        id:oiltemplowtimer
        interval: 100
        onTriggered:{if(increament)root.oiltemplow+=1
            else if(decreament)root.oiltemplow-=1}
        repeat: true
    }

    Timer{
        id:oilpressurehightimer
        interval: 100
        onTriggered: {if(increament)root.oilpressurehigh+=1
            else if(decreament)root.oilpressurehigh-=1}
        repeat: true
    }
    Timer{
        id:oilpressurelowtimer
        interval: 100
        onTriggered: {if(increament)root.oilpressurelow+=1
            else if(decreament)root.oilpressurelow-=1
                if(root.oilpressurelow<0)root.oilpressurelow=0  }
        repeat: true
    }
    Timer{
        id:batterylowtimer
        interval: 100
        onTriggered: {if(increament)root.batterylow+=0.1
            else if(decreament)root.batterylow-=0.1
              if(root.batterylow<0)root.batterylow=0 }
        repeat: true
    }
    Timer{
        id:batteryhightimer
        interval: 100
        onTriggered: {if(increament)root.batteryhigh+=0.1
            else if(decreament)root.batteryhigh-=0.1}
        repeat: true
    }
    Timer{
        id:afrlowtimer
        interval: 100
        onTriggered: {if(increament)root.afrlow+=0.1
            else if(decreament)root.afrlow-=0.1
        if(root.afrlow<0)root.afrlow=0}
        repeat: true
    }
    Timer{
        id:afrhightimer
        interval: 100
        onTriggered: {if(increament)root.afrhigh+=0.1
            else if(decreament)root.afrhigh-=0.1
             }
        repeat: true
    }
    Timer{
        id:rpmlimittimer
        interval: 100
        onTriggered:{if(increament){root.rpmlimit+=100;if(root.rpmlimit>9000)root.rpmlimit=0 }
            else if(decreament){root.rpmlimit-=100;if(root.rpmlimit<0)root.rpmlimit=9000 }}
        repeat: true
    }
    Timer{
        id:shiftvaluetimer
        interval: 100
        onTriggered:{if(increament){root.shiftvalue+=100;if(root.shiftvalue>9000)root.shiftvalue=0 }
            else if(decreament){root.shiftvalue-=100;if(root.shiftvalue<0)root.shiftvalue=9000 }}
        repeat: true
    }
    Text{
         id:currentindex
         property real position:0
         x:0


         y: 0
         onPositionChanged:
                            {if(position>28)position=0;
                            else if(position<0)position=28;

                             }

          width: 40
         height: 36
         visible: false
         color: "#ff0000"
         text: "--->"
         font.pointSize: 23
          //font.family: sevensegfont.name


     }

    /////////////select button////
    onIncreamentChanged: if((increament)&&!settings_on_off&&!menu_on_off)settings_on_off=true

                               else if(increament&&!menu_on_off)
                               {
                                   if(currentindex.position===0){settings_on_off=false;save_settings()}//exit the sttings and save them to file

                                   else if(currentindex.position===1)redtimer.start()
                                   else if(currentindex.position===2)greentimer.start()
                                   else if(currentindex.position===3)bluetimer.start()
                                   else if(currentindex.position===3)bluetimer.start()

                                   else if(currentindex.position===4)waterhightimer.start()
                                   else if(currentindex.position===5)waterlowtimer.start()
                                   else if(currentindex.position===6){root.waterunits+=1;if(root.waterunits>1)root.waterunits=0}

                                   else if(currentindex.position===8)fuelhightimer.start()
                                   else if(currentindex.position===9)fuellowtimer.start()
                                 //  else if(currentindex.position===10){root.fueldamping+=1;if(root.fueldamping>15)root.fueldamping=15}

                                   else if(currentindex.position===12)oiltemphightimer.start()
                                   else if(currentindex.position===13)oiltemplowtimer.start()
                                   else if(currentindex.position===14){root.oiltempunits+=1;if(root.oiltempunits>1)root.oiltempunits=0}

                                   else if(currentindex.position===16)oilpressurehightimer.start()
                                   else if(currentindex.position===17)oilpressurelowtimer.start()
                                   else if(currentindex.position===18){root.oilpressureunits+=1;if(root.oilpressureunits>1)root.oilpressureunits=0}

                                   else if(currentindex.position===20)batteryhightimer.start()
                                   else if(currentindex.position===21)batterylowtimer.start()

                                   else if(currentindex.position===22){root.speedunits+=1;if(root.speedunits>2)root.speedunits=0}

                                   else if(currentindex.position===23)rpmlimittimer.start()
                                   else if(currentindex.position===24)shiftvaluetimer.start()

                                   else if(currentindex.position===25){root.night_time_hue+=0.05;if(root.night_time_hue>1)night_time_hue=1}

                                     else if(currentindex.position===26){root.rpmdamping+=1;if(root.rpmdamping>10)root.rpmdamping=0}

                                   else if(currentindex.position===27)afrhightimer.start()
                                   else if(currentindex.position===28)afrlowtimer.start()
                               }



                               else{redtimer.stop();greentimer.stop();bluetimer.stop();waterhightimer.stop();waterlowtimer.stop();
                                    fuelhightimer.stop();fuellowtimer.stop();oiltemphightimer.stop();oiltemplowtimer.stop();
                                     oilpressurehightimer.stop();oilpressurelowtimer.stop();rpmlimittimer.stop() ;shiftvaluetimer.stop()
                                                            ;batteryhightimer.stop();                batterylowtimer.stop();
                                                              afrlowtimer.stop(); afrhightimer.stop() }


    onDecreamentChanged: if(decreament&&settings_on_off)
                                        {
                                         if(currentindex.position===0){settings_on_off=false;save_settings()}//exit the sttings and save them to file
                                          else if(currentindex.position===1)redtimer.start()
                                          else if(currentindex.position===2)greentimer.start()
                                          else if(currentindex.position===3)bluetimer.start()
                                          else if(currentindex.position===3)bluetimer.start()

                                          else if(currentindex.position===4)waterhightimer.start()
                                          else if(currentindex.position===5)waterlowtimer.start()
                                          else if(currentindex.position===6){root.waterunits+=1;if(root.waterunits>1)root.waterunits=0}

                                          else if(currentindex.position===8)fuelhightimer.start()
                                          else if(currentindex.position===9)fuellowtimer.start()
                                         // else if(currentindex.position===10){root.fueldamping-=1;if(root.fueldamping<7)root.fueldamping=7}

                                          else if(currentindex.position===12)oiltemphightimer.start()
                                          else if(currentindex.position===13)oiltemplowtimer.start()
                                          else if(currentindex.position===14){root.oiltempunits+=1;if(root.oiltempunits>1)root.oiltempunits=0}

                                          else if(currentindex.position===16)oilpressurehightimer.start()
                                          else if(currentindex.position===17)oilpressurelowtimer.start()
                                          else if(currentindex.position===18){root.oilpressureunits+=1;if(root.oilpressureunits>1)root.oilpressureunits=0}




                                                else if(currentindex.position===20)batteryhightimer.start()
                                                  else if(currentindex.position===21)batterylowtimer.start()

                                           else if(currentindex.position===22){root.speedunits+=1;if(root.speedunits>2)root.speedunits=0}

                                         else if(currentindex.position===23)rpmlimittimer.start()
                                         else if(currentindex.position===24)shiftvaluetimer.start()

                                         else if(currentindex.position===25){root.night_time_hue-=0.05;if(root.night_time_hue<0.05)night_time_hue=0}

                                          else if(currentindex.position===26){root.rpmdamping-=1;if(root.rpmdamping<0)root.rpmdamping=10}

                                         else if(currentindex.position===27)afrhightimer.start()
                                         else if(currentindex.position===28)afrlowtimer.start()
                                        }

                                        else{redtimer.stop();greentimer.stop();bluetimer.stop();waterhightimer.stop();waterlowtimer.stop();
                                             fuelhightimer.stop();fuellowtimer.stop();oiltemphightimer.stop();oiltemplowtimer.stop();
                                              oilpressurehightimer.stop();oilpressurelowtimer.stop();rpmlimittimer.stop();shiftvaluetimer.stop();batteryhightimer.stop();
                                              batterylowtimer.stop();afrlowtimer.stop(); afrhightimer.stop()}

///////////////////////////////
////////////////////////////
///////////////////////////////
///////////////////////////////////
////////////////////////////////////
//////////////////////////////////

Item {

    /*#########################################################################
      #############################################################################
      Imported Values From GAWR inits
      #############################################################################
      #############################################################################
     */
    id: dial

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
    property bool up_joystick: inputs & 0x20 || dial.udp_up
    property bool leftindicator: inputs & 0x40
    property bool rightindicator: inputs & 0x80
    property bool brake: inputs & 0x100
    property bool oil: inputs & 0x200
    property bool seatbelt: inputs & 0x400
    property bool sidelight: inputs & 0x800
    property bool tripresetswitch: inputs & 0x1000
    property bool down_joystick: inputs & 0x2000 || dial.udp_down
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
    property bool left_joystick: inputs & 0x20000000 || dial.udp_left
    property bool right_joystick: inputs & 0x40000000 || dial.udp_right

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
        if (dial.speedunits === 0) return dial.peak_speed.toFixed(0); else return (dial.peak_speed*.62).toFixed(0)
    }

    function getTemp(fluid){
        if(fluid == "COOLANT"){
            if(dial.seatbelt && dial.car_movement && dial.speed === 0){ 
                 if(dial.waterunits !== 1)
                    return dial.easyFtemp(dial.peak_water)
                else 
                    return dial.peak_water.toFixed(0)
            }
            else{
                if(dial.waterunits !== 1)
                    return dial.easyFtemp(dial.watertemp)
                else 
                    return dial.watertemp.toFixed(0)
            }
        }
        else{
            if(dial.seatbelt && dial.car_movement && dial.speed === 0){
                 if(dial.oiltempunits !== 1)
                    return dial.easyFtemp(dial.peak_oil)
                else 
                    return dial.peak_oil.toFixed(0)
            }
            else{
                if(dial.oiltempunits !== 1)
                    return dial.easyFtemp(dial.oiltemp)
                else 
                    return dial.oiltemp.toFixed(0)
            }
        }
    }
    function tempColors(fluid){
        if((fluid === 'COOLANT' && dial.watertemp >= dial.waterhigh) || (fluid === 'OIL' && dial.oiltemp >= dial.oiltemphigh)){
            return dial.warning_color
        }
        else{
            if(dial.sidelight){
                return dial.lit_primary_color
            }
            else{
                return dial.primary_color
            }
        }
    }
    function tempWarningColor(){
        if(dial.sidelight){
            return dial.salmon_warning_color
        }
        else{
            return dial.warning_color
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
        color: dial.background_color
        border.width: 0
        z: 0
    }
    Image{
        id: silver_mask_overlay
        x: 0; y:0
        z: 10
        source: if(!dial.sidelight) './images/meltfire_mask.png'; else './images/meltfire_mask_dark.png'
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
        visible: if(dial.rpm >= dial.rpmlimit) true; else false
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
        source: if(!dial.sidelight) './images/tach_markers_unlit.png'; else './images/tach_markers_lit.png'
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
                    // angle: ((dial.rpm/1000)*26 - 90)
                    angle: if(dial.rpm <= 1000){
                            Math.min(Math.max(-90, Math.round((dial.rpm/1000)*21) - 90), 180)
                        }   
                        else{
                            Math.min(Math.max(-90, Math.round((dial.rpm/1000)*27.8) - 96.8), 180) 
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
                    origin.y: 2+(dial.rpm/10000*6)
                    origin.x: 178
                    angle: if(dial.rpm <= 1000){
                            Math.min(Math.max(-90, Math.round((dial.rpm/1000)*21) - 90), 180)
                        }   
                        else{
                            Math.min(Math.max(-90, Math.round((dial.rpm/1000)*27.8) - 96.8), 180) 
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
            source: dial.getGear()
        }
    }

    Item{
        z:5
        visible: !dial.seatbelt
        Text{
            id: speed_text
            x: 446.3; y: 355;
            font.family: boosted.name
            font.pixelSize: 48
            color: dial.primary_color
            width: 160
            height: 54
            clip: true
            text: if(dial.speedunits === 0) dial.speed.toFixed(0); else (dial.speed*.62).toFixed(0)
            horizontalAlignment: Text.AlignRight
        }
    }

    Item{
        id: peakrpm_speed
        visible: dial.seatbelt 
        z:8
        Text{
            x: 446.3; y: 360; 
            font.family: boosted.name
            font.pixelSize: 10
            color: dial.primary_color
            text: "PEAK\nSPEED:" 
        }
        Text{ 
            x: 537; y: 360
            font.family: boosted.name
            font.pixelSize: 20
            color: dial.primary_color
            text: dial.getPeakSpeed()
        }
        Text{
            x: 446.3; y: 390;
            font.family: boosted.name
            font.pixelSize: 10
            color: dial.primary_color
            text: "PEAK\nRPM:"
        }
        Text{ 
            x: 515; y: 391
            font.family: boosted.name
            font.pixelSize: 20
            color: dial.primary_color
            text: dial.peak_rpm
        }
    }
    
    Image{
        id: speed_label
        x: 540; y: 426; z: 5
        source: {
                if(dial.speedunits === 0) './images/km_marker.png'; else './images/mi_marker.png'
            }
    }

    //Blinkers
    Item{
        id: blinkers
        x: 445; y: 345; z:10
        visible: dial.leftindicator || dial.rightindicator
        Rectangle{
            width: 160; height: 70
            color: dial.display_grey
            opacity: 1
        }
        Image{
            source: if(dial.leftindicator) './images/ind_left.png'; else './images/ind_right.png'
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
            visible: dial.fuel>dial.fuellow
        }
        Image{
            source: './images/fuel_icon.png'
            x:0;y:-8;z:10
            opacity: 1
            Timer{
                id: fuel_indicator_blink
                running: dial.fuel<=dial.fuellow
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
            width: 107*(dial.fuel/100); height: 51
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
        source: if(dial.airbag) './images/warning_lit/airbag.png'; else './images/warning_unlit/airbag.png'       
    }
    Image{
        x: 104; y: 428; z:4
        source: if(dial.oil) './images/warning_lit/oilpressure.png';else './images/warning_unlit/oilpressure.png'
    }
    Image{
        x: 100; y: 394; z:4
        source: if (dial.brake) './images/warning_lit/brake.png'; else 'images/warning_unlit/brake.png'
   
    }
    Image{
        x: 172.4; y: 393; z:4
        source: if (dial.abs) './images/warning_lit/abs.png'; else 'images/warning_unlit/abs.png'
    }
    Image{
        x: 31; y: 347; z:4
        source: if (dial.doorswitch) './images/warning_lit/door.png'; else 'images/warning_unlit/door.png'

    }    
    Image{
        x: 89; y: 347.5; z:4
        source: if (dial.seatbelt) './images/warning_lit/seatbelt.png'; else 'images/warning_unlit/seatbelt.png'

    }    
    //Top Row
    Image{
        x: 141.6; y: 347; z: 4
        source: if (dial.battery)  './images/warning_lit/battery.png'; else 'images/warning_unlit/battery.png'

    }
    Image{
        x: 42; y: 386; z: 4
        source: if (dial.mil) './images/warning_lit/cel.png'; else 'images/warning_unlit/cel.png'
 
    }
    Image{
        x: 209; y: 429; z: 4
        source: if (dial.sidelight) './images/warning_lit/sidelights.png'; else 'images/warning_unlit/sidelights.png'
   
    }
    Image{
        x: 49; y: 429; z: 4
        source: if (dial.mainbeam) './images/warning_lit/highbeams.png'; else 'images/warning_unlit/highbeams.png'
    }

    //Water Temperature
        Item{
            id: water_temp
            x:25;y:169;z:8
            Rectangle{
                width: 125; height:125
                radius: width*0.5
                clip: true
                color: dial.digital_gauge_grey 
                Rectangle{
                    id: water_1_box
                    x:61;y:61;
                    height:61; width:61
                    color: if(dial.watertemp < dial.waterhigh) dial.primary_color; else dial.tempWarningColor()
                    transform:[
                        Rotation{
                            id: water1rotate
                            origin.x: 0
                            origin.y: 0
                            angle: Math.min(Math.max(0,(dial.watertemp-40)*3.375),90)
                        }
                    ]
                }
                Rectangle{
                    id: water_2_box
                    x:61;y:61;
                    height:61; width:61
                    color: if(dial.watertemp < dial.waterhigh) dial.primary_color; else dial.tempWarningColor()
                    transform:[
                        Rotation{
                            id: water2rotate
                            origin.x: 0
                            origin.y: 0
                            angle: Math.min(Math.max(0,(dial.watertemp-40)*3.375),180)
                        }
                    ]
                }
                Rectangle{
                    id: water_3_box
                    x:61;y:61;
                    height:61; width:61
                    color: if(dial.watertemp < dial.waterhigh) dial.primary_color; else dial.tempWarningColor()
                    transform:[
                        Rotation{
                            id: water3rotate
                            origin.x: 0
                            origin.y: 0
                            angle: Math.min(Math.max(0,(dial.watertemp-40)*3.375),270)
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
                        color: if(index*(270/8) >= (dial.waterhigh-40)*3.375 && (dial.watertemp-40)*3.375 < index * (270/8)) dial.tempWarningColor();else if((dial.watertemp-40)*3.375 < index * (270/8)) dial.primary_color; else "#000000"
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
                        color: if(dial.watertemp > dial.waterhigh) "#000000"; else dial.tempWarningColor()
                        antialiasing: true
                        transform:[
                            Rotation{
                                origin.x: 1.5;
                                origin.y: 0;
                                angle: (dial.waterhigh-40)*3.375
                            }
                        ]
                    }
                Image{
                    x:38;y:80;z:15;
                    source: if(dial.waterunits!==1) './images/coolant_f.png'; else './images/coolant_c.png'
                }
                Text{
                    font.family: boosted.name
                    font.pixelSize: 24
                    text: dial.getTemp("COOLANT")
                    x:0; y:48; z: 10
                    color: if(dial.watertemp < dial.waterhigh) dial.primary_color; else dial.tempWarningColor()
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
            color: dial.digital_gauge_grey

            //Range 40-160 270/120 =2.25
            Rectangle{
                id: oil_1_box
                x:61;y:61;
                height:61; width:61
                color: if(dial.oiltemp < dial.oiltemphigh) dial.primary_color; else dial.tempWarningColor()
                transform:[
                    Rotation{
                        id: oil1rotate
                        origin.x: 0
                        origin.y: 0
                        angle: Math.min(Math.max(0,(dial.oiltemp-40)*2.25),90)
                    }
                ]
            }
            Rectangle{
                id: oil_2_box
                x:61;y:61;
                height:61; width:61
                color: if(dial.oiltemp < dial.oiltemphigh) dial.primary_color; else dial.tempWarningColor()
                transform:[
                    Rotation{
                        id: oil2rotate
                        origin.x: 0
                        origin.y: 0
                        angle: Math.min(Math.max(0,(dial.oiltemp-40)*2.25),180)
                    }
                ]
            }
            Rectangle{
                id: oil_3_box
                x:61;y:61;
                height:61; width:61
                color: if(dial.oiltemp < dial.oiltemphigh) dial.primary_color; else dial.tempWarningColor()
                transform:[
                    Rotation{
                        id: oil3rotate
                        origin.x: 0
                        origin.y: 0
                        angle: Math.min(Math.max(0,(dial.oiltemp-40)*2.25),270)
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
                source: if(dial.oiltempunits!==1) './images/oiltemp_f.png'; else './images/oiltemp_c.png'
            }
            //Range 40C to 120C = range of 80 degrees 270/80 =
            Rectangle{
                        id: oiltemp_limit
                        x:61;y:61;z:2
                        height: 61; width: 6
                        color: if(dial.oiltemp < dial.oiltemphigh) dial.tempWarningColor(); else "#000000"
                        antialiasing: true
                        transform:[
                            Rotation{
                                origin.x: 1.5;
                                origin.y: 0;
                                angle: (dial.oiltemphigh-40)*2.25
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
                        color: if(index*(270/12) >= (dial.oiltemphigh-40)*2.25 && (dial.oiltemp-40)*2.25 < index * (270/12)) dial.tempWarningColor(); else if((dial.oiltemp-40)*2.25 < index * (270/12)) dial.primary_color; else "#000000"
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
                text: dial.getTemp("OIL")
                x:0; y:48; z: 10
                color: if(dial.oiltemp < dial.oiltemphigh) dial.primary_color; else dial.tempWarningColor()
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
                color: dial.digital_gauge_grey
                clip: true;
                //color: "red"
                Rectangle{
                    height: 70; width: 10
                    x:61;y:61;z: 9;
                    color: if(dial.oilpressurelow < dial.oilpressure) dial.primary_color; else dial.tempWarningColor()
                    antialiasing: true
                    transform:[
                        Rotation{  //10 bar max, start 0 270
                            id: oilpressurerotation
                            origin.x:5;origin.y:0
                            angle:Math.min(Math.max(0, dial.oilpressure*27),270)
                        }
                    ]
                }
                Repeater{
                    model: 11
                    property int index
                    Rectangle{
                        height: 61; width: 2
                        x:61;y:61;z:8
                        color: if(index>dial.oilpressurelow) dial.primary_color; else dial.tempWarningColor()
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
                    text: dial.oilpressureunits === 1 ? dial.oilpressure.toFixed(1):(dial.oilpressure*14.5038).toFixed(0)
                    x:0; y:48; z: 10
                    color: if(dial.oilpressurelow < dial.oilpressure) dial.primary_color; else dial.tempWarningColor()
                    width: 100
                    horizontalAlignment: Text.AlignRight
                }
                Image{
                    x:36;y:80;z:15;
                    source: if(dial.oilpressureunits !==1) './images/oil_psi.png'; else './images/oil_bar.png'
                }
            }
        }
    Text{
        id: mileage
        x: 466; y: 424; z:9
        opacity: 0;
        color: dial.primary_color
        text: if (dial.speedunits === 0)
                        (dial.odometer/.62).toFixed(0) 
                    else if(dial.speedunits === 1)
                        dial.odometer 
                    else
                        dial.odometer
        // text: '234561'
        font.family: digital7monoItalic.name
        font.pixelSize: 24
        width: 67.3
        horizontalAlignment: Text.AlignRight
        Timer{
                interval: 1500; running: dial.ignition; repeat: false
                onTriggered: animateMileage.start()
            }
    }
    SequentialAnimation{
        id: animateMileage
        NumberAnimation{
            target: mileage; property: "opacity"; from: 0.00; to: 1.00; duration: 500
        }
    }

    

    // --- animations carried over from the wrapper's instantiation ---
    Behavior on x {NumberAnimation{duration: 500}}
    Behavior on y {NumberAnimation{duration: 500}}
    Behavior on scale {NumberAnimation{duration: 500}}
}

// --- property forwards carried over from the wrapper's <SoldatMeltfire>{} instantiation.
//     Binding overrides at run time, so the inlined design is left untouched. ---
Binding { target: dial; property: "odometer"; value: root.odometer/10 }
Binding { target: dial; property: "tripmeter"; value: root.tripmeter }
Binding { target: dial; property: "shiftvalue"; value: root.shiftvalue }
Binding { target: dial; property: "rpm"; value: root.rpm }
Binding { target: dial; property: "rpmlimit"; value: root.rpmlimit }
Binding { target: dial; property: "rpmdamping"; value: root.rpmdamping }
Binding { target: dial; property: "speed"; value: root.speed }
Binding { target: dial; property: "speedunits"; value: root.speedunits }
Binding { target: dial; property: "watertemp"; value: root.watertemp }
Binding { target: dial; property: "waterhigh"; value: root.waterhigh }
Binding { target: dial; property: "waterlow"; value: root.waterlow }
Binding { target: dial; property: "waterunits"; value: root.waterunits }
Binding { target: dial; property: "fuel"; value: root.fuel }
Binding { target: dial; property: "fuelhigh"; value: root.fuelhigh }
Binding { target: dial; property: "fuellow"; value: root.fuellow }
Binding { target: dial; property: "fuelunits"; value: root.fuelunits }
Binding { target: dial; property: "o2"; value: root.o2 }
Binding { target: dial; property: "map"; value: root.map }
Binding { target: dial; property: "maf"; value: root.maf }
Binding { target: dial; property: "oilpressure"; value: root.oilpressure }
Binding { target: dial; property: "oilpressurehigh"; value: root.oilpressurehigh }
Binding { target: dial; property: "oilpressurelow"; value: root.oilpressurelow }
Binding { target: dial; property: "oilpressureunits"; value: root.oilpressureunits }
Binding { target: dial; property: "oiltemp"; value: root.oiltemp }
Binding { target: dial; property: "oiltemphigh"; value: root.oiltemphigh }
Binding { target: dial; property: "oiltemplow"; value: root.oiltemplow }
Binding { target: dial; property: "oiltempunits"; value: root.oiltempunits }
Binding { target: dial; property: "batteryvoltage"; value: root.batteryvoltage }
Binding { target: dial; property: "gearpos"; value: root.gearpos }
Binding { target: dial; property: "udp_message"; value: root.udp_message }
Binding { target: dial; property: "inputs"; value: root.inputs }
Binding { target: dial; property: "x"; value: if(root.settings_on_off) 80;else 0 }
Binding { target: dial; property: "y"; value: if(root.settings_on_off) 50;else 0 }
Binding { target: dial; property: "scale"; value: if(root.settings_on_off) 0.8;else 1.0 }
Binding { target: dial; property: "z"; value: 0 }
Binding { target: dial; property: "opacity"; value: 1 }
Binding { target: dial; property: "width"; value: 800 }
Binding { target: dial; property: "height"; value: 480 }
Binding { target: dial; property: "antialiasing"; value: true }
Binding { target: dial; property: "clip"; value: true }

Rectangle {
    id: rectangle
    x: 0
    y: 0
    width: 800
    height: 480
    color: "#000000"
    z: -1
}



}
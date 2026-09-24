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
import QtGraphicalEffects 1.0 as Effects
import QtQuick.Shapes 1.0
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
    source: "/opt/IC7/screen_configs/Outrun.txt"
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
        color: dial.background_color
        border.width: 0
        z: 0
    }

    PseudoRoad {
        id: pseudoRoad
        x: 0; y: 0; z:0
        width: 800; height: 640
        vehicleSpeed: dial.speed
        laneMarkingColor: dial.sidelight ?  "#E9C100" : "#ffffff"
        skyColorTop: dial.sidelight ? "#100058": "#0092FB"
        skyColorBottom: dial.sidelight ? "#44024C": "#8DCFFF"
        nightMode: dial.sidelight
        roadColorOn: dial.sidelight ? "#000000" : "#949494"
        roadColorOff: dial.sidelight ? "#0A0A0A" : "#9c9c9c"
        terrainColorOn: dial.sidelight ? "#1C180B" : "#efdece"
        terrainColorOff: dial.sidelight ? "#231F13" : "#e6d6c5"
        cloudSource: dial.sidelight ? './images/nightcloud.png' :  './images/daycloud.png'
        cloudWidth: 1400          // however wide you want ONE tile to render
        cloudHeight: 246
        cloudSpeed: 3        // slow ambient drift
        secondLayerSource: dial.sidelight ? './images/night_back.png' : './images/back.png'
        horizonStripeSource: dial.sidelight ? './images/night_horizonstripe.png' : './images/horizonstripe.png'
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
            opacity: dial.leftindicator ? 1 : 0
            source: './images/car_blinker.png'

        }
        Image{
            id: right_indicator
            x: 125; y: 31;z:2
            opacity: dial.rightindicator ? 1 : 0
            source: './images/car_blinker.png'

        }

        Image{
            id: lotus
            x:0; y:0; z:1
            source: !dial.sidelight ? './images/lotus.png' : './images/darklotus.png'
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
        text: if (dial.speedunits === 0) dial.speed.toFixed(0); else (dial.speed*.62).toFixed(0)
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
        text: if (dial.speedunits === 0) dial.speed.toFixed(0); else (dial.speed*.62).toFixed(0)
    }
    Image{
        id: speed_units
        x: 170; y: 385
        source: dial.speedunits === 0 ? './images/km_hour.png' : './images/mi_hour.png'
    }
Item {
    id: funkygauge
    x: 150; y: 100
    // ---- Public API ----
    property real currentRpm: dial.rpm        // drive this from your engine/animation
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
        source: dial.sidelight ? './images/dark_revcounter.png' : './images/light_revcounter.png'
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
                text: dial.odometer.toFixed(0)
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
        text: dial.odometer.toFixed(0)
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
        source: dial.speedunits === 0 ? './images/km.png' : './images/mi.png'
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
            width: dial.fuel/100 * 120; height: 30
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
                text:dial.waterunits === 1 ? dial.watertemp.toFixed(0) :  dial.easyFtemp(dial.watertemp)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#F3F300"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 148; y: 12; z:2
                text: dial.waterunits === 1 ? 'C' : 'F'
                font.family: sonicMono.name
                font.pixelSize: 12
                color: "#F3F300"
            }
            Text{
                x: 52; y: 2; z: 1
                text: dial.easyFtemp(dial.watertemp)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#000000"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 150; y: 14; z:1
                text: dial.waterunits === 1 ? 'C' : 'F'
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
                text: if(dial.oilpressureunits === 1) dial.oilpressure.toFixed(1); else (dial.oilpressure.toFixed(1) * 14.504).toFixed(0)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#F3F300"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 150; y: 12; z:2
                text: dial.oilpressureunits === 0 ? 'PSI' : 'BAR'
                font.family: sonicMono.name
                font.pixelSize: 12
                color: "#F3F300"
            }
            Text{
                x: 52; y: 2; z: 1
                text: if(dial.oilpressureunits === 1) dial.oilpressure.toFixed(1); else (dial.oilpressure.toFixed(1) * 14.504).toFixed(0)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#000000"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 150; y: 14; z:1
                text: dial.oilpressureunits === 1 ? 'PSI' : 'BAR'
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
                text: dial.easyFtemp(dial.oiltemp)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#F3F300"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 158; y: 12; z:2
                text: dial.oiltempunits === 1 ? 'C' : 'F'
                font.family: sonicMono.name
                font.pixelSize: 12
                color: "#F3F300"
            }
            Text{
                x: 60; y: 2; z: 1
                text: dial.easyFtemp(dial.oiltemp)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#000000"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 158; y: 14; z:1
                text: dial.oiltempunits === 1 ? 'C' : 'F'
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
                text: dial.o2.toFixed(1)
                font.family: sonicMono.name
                font.pixelSize: 24
                color: "#F3F300"
                horizontalAlignment: Text.AlignRight
                width: 100
            }
            Text{
                x: 60; y: 2; z: 1
                text: dial.o2.toFixed(1)
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
            opacity: dial.mil ? 1 : 0
        }
        Text{
            x:0;y:15;z:0
            id: emergency_brake
            text: 'Brake'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#FF0000"
            opacity: dial.brake ? 1 : 0
        }
        Text{
            x:0;y:30;z:0
            id: seatbelt_light
            text: 'Seatbelt'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#FF0000"
            opacity: dial.seatbelt ? 1 : 0
        }
        Text{
            x:0;y:45;z:0
            id: airbag_light
            text: 'Airbag'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#F3F300"
            opacity: dial.airbag ? 1 : 0
        }
        Text{
            x:0;y:60;z:0
            id: tc_light
            text: 'TC'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#F3F300"
            opacity: dial.tc ? 1 : 0
        }
        Text{
            x:0;y:75;z:0
            id: abs_light
            text: 'ABS'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#F3F300"
            opacity: dial.abs ? 1 : 0
        }
        Text{
            x:0;y:90;z:0
            id: tc_off_light
            text: 'TC OFF'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#F3F300"
            opacity: dial.tc_off ? 1 : 0
        }
        Text{
            x:0;y:105;z:0
            id: cruise_light
            text: 'Cruise'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#F3F300"
            opacity: dial.cruise_id ? 1 : 0
        }
        Text{
            x:0;y:120;z:0
            id: reverse_light
            text: 'Reverse'
            font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#F3F300"
            opacity: dial.reverse ? 1 : 0
        }
        Text{
            x:0;y:135;z:0
            id: battery_light
            text: 'Battery'
           font.family: spaceHarrier.name
            font.pixelSize: 14
            color: "#FF0000"
            opacity: dial.battery ? 1 : 0
        }
 
    }
    Image{
        id: mainbeam_light
        x: 380; y: 30
        source: './images/highbeams.png'
        opacity: dial.mainbeam ? 1 : 0
    }

    // --- animations carried over from the wrapper's instantiation ---
    Behavior on x {NumberAnimation{duration: 500}}
    Behavior on y {NumberAnimation{duration: 500}}
    Behavior on scale {NumberAnimation{duration: 500}}
}

// --- property forwards carried over from the wrapper's <Outrun>{} instantiation.
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
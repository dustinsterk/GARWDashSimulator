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
import "img"
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
FontLoader{id:basicfont; source: "HelveticaBlackOB.ttf"}
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
    source: "/opt/IC7/screen_configs/LeMansGT_config.txt"
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

    id: dial
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
    property string primary_color: "#FFFFFF"; //#FFBF00 for amber
    property string night_light_color: "#9c7200"
    property string sweetspot_color: "#FFA500" //Cam Changeover Rev colpr
    property string warning_red: "#FF0000" //Redline/Warning colors
    property string engine_warmup_color: "#eb7500"
    property string background_color: "#000000"
  

    /* ########################################################################## */
    /* Fonts */
    /* ########################################################################## */
    FontLoader {
        id: helvetica_black_oblique
        source: "./HelveticaBlackOB.ttf"
    }


    /* ########################################################################## */
    /* Main Layout items */
    /* ########################################################################## */
    Rectangle {
        id: background_rect
        y: 0
        width: 800
        height: 480
        color: dial.background_color
        border.width: 0
        z: 0
    }

    Rectangle {
        id: rev_splitter
        y: 256
        x: 0
        z: 2
        width: 800
        height: 2
        color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
    }
    //Added static items for better visibility rules
    Text {
        id: rpm_display_val
        text: dial.rpm + " rpm"
        font.pixelSize: 32
        horizontalAlignment: Text.AlignRight
        font.family: helvetica_black_oblique.name
        x: 608
        y: 203
        z: 2
        width: 174
        opacity: 100
        visible: dial.rpm < dial.rpmlimit
        color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
    }
    Text {
        id: rpm_display_val_blinking
        text: dial.rpm + " rpm"
        font.pixelSize: 32
        horizontalAlignment: Text.AlignRight
        font.family: helvetica_black_oblique.name
        x: 608
        y: 203
        z: 2
        width: 174
        opacity: 100
        visible: dial.rpm >= dial.rpmlimit
        color: dial.warning_red
        Timer{
            id: rpm_shift_blink
            running: true
            interval: 60
            repeat: true
            onTriggered: if(parent.opacity === 0){
                parent.opacity = 100
            }
            else{
                parent.opacity = 0
            } 
        }
    }

    Text {
        id: watertemp_display_val
        text: dial.watertemp.toFixed(
                  0) + "°" // Alec added toFixed(0) to have no decimal places
        font.pixelSize: 32
        font.family: helvetica_black_oblique.name
        width: 128
        height: 32
        x: 36
        y: 396
        z: 2
        color: if (dial.watertemp < dial.waterlow)
                    dial.engine_warmup_color
                else if (dial.watertemp > dial.waterlow && dial.watertemp < dial.waterhigh)
                   if(!dial.sidelight) dial.primary_color; else dial.night_light_color
               else
                   dial.warning_red
    }

    Text {
        id: oiltemp_display_val
        font.pixelSize: 32
        font.family: helvetica_black_oblique.name
        width: 128
        height: 32
        x: 36
        y: 338
        z: 2
        color: if (dial.oiltemp < dial.oiltemphigh)
                   if(!dial.sidelight) dial.primary_color; else dial.night_light_color
               else
                   dial.warning_red
        text: dial.oiltemp.toFixed(0) + "°" // "100°"
        visible: if(dial.oiltemphigh === 0)false; else true
    }

    Text {
        id: oilpressure_display_val
        text: dial.oilpressure.toFixed(0) //Alec added toFixed(0)
        font.pixelSize: 32
        font.family: helvetica_black_oblique.name
        width: 128
        height: 32
        x: 36
        y: 284
        z: 2
        color: if (dial.oilpressure < dial.oilpressurelow)
                    dial.warning_red
                else
                    if(!dial.sidelight) dial.primary_color; else dial.night_light_color
        visible: if(dial.oilpressurehigh === 0)false; else true
    }
    Rectangle {
        id: oilpressure_line
        x: 16
        y: 327
        width: 256
        height: 2
        color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
        visible: if(dial.oilpressurehigh === 0)false; else true

    }

    Text {
        id: speed_display_val
        font.pixelSize: 72
        horizontalAlignment: Text.AlignRight
        font.family: helvetica_black_oblique.name
        x: 553
        y: 358
        width: 148
        color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
        text: if (dial.speedunits === 0){
                    dial.speed.toFixed(0) //"0"   // Alec added speed
                }
                else{
                    dial.mph.toFixed(0)
                }

        z: 2
    }

    Rectangle {
        id: oiltemp_line
        x: 16
        y: 385
        width: 256
        height: 2
        color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
        visible: if(dial.oiltemphigh === 0)false; else true

    }
    Rectangle {
        id: oiltemp_line_vert
        x: 270
        y: 280
        height: 159
        width: 2
        color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
    }

    Text {
        id: odometer_display_val
        text: if (dial.speedunits === 0)
                (dial.odometer/.62).toFixed(0) + " km"
                else if(dial.speedunits === 1)
                dial.odometer.toFixed(0) + " mi"
                else
                dial.odometer.toFixed(0)
        font.pixelSize: 24
        horizontalAlignment: Text.AlignRight
        font.family: helvetica_black_oblique.name
        x: 618
        y: 440 //480 - 16 - 12
        z: 2
        width: 164
        color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
    }

    Text {
        id: speed_label
        x: 707
        y: 396
        color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
        text: if (dial.speedunits === 0)
                "km/h"
                else if(dial.speedunits === 1)
                "mi/h"
                else
                ""
        font.pixelSize: 32
        horizontalAlignment: Text.AlignRight
        z: 2
        font.family: helvetica_black_oblique.name
    }

    //Masking with opacity for better performance
    Rectangle{
            id: opacity_increase
            height: 128
            width: Math.floor(dial.rpm / 100) * 7.68 - 7.68
            x:16
            y: 16
            color: 'black'
            z:4
            opacity: .35
        }
    
    Rectangle{
            id: opacity_decrease
            height: 128
            width: 768
            x: Math.floor(dial.rpm / 100) * 7.68 + 15.32
            y: 16
            color: 'black'
            z:3
            opacity: .85
        }

        
    // RPM Marks
    Row {
        id: rpmLights
        x: 16
        y: 16
        width: 768
        height: 128
        layoutDirection: Qt.LeftToRight
        layer.enabled: true
        smooth: false
        clip: false
        z: 2
        
        Repeater {
            property int index
            z: 2
            model: 100
            Row {
                Rectangle {
                    height: 128
                    opacity: 1
                    width: 3.68

                    //Settings for how our RPM colors are set
                    color: if (index < 59)
                            if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                    //Cam Changeover
                           else if (index >= 59 && index < 79)
                               dial.sweetspot_color
                    //Redline
                           else
                               dial.warning_red
                    radius: 2
                }
                Rectangle {
                    id: rpm_marker_spacer
                    height: 128
                    opacity: 1
                    width: 4
                    color: dial.background_color
                    radius: 1
                    border.width: 0
                }
            }
        }
    }

    //Actual RPM marks
    Item {
        id: rev_system
        x: 16

        //Tic Marks
        Rectangle {
            id: ticmark_line
            width: 763
            height: 2
            x: 0
            y: 160
            z: 1
            color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
        }
        Rectangle {
            id: tickmark_redline
            x: 609
            width: 153
            height: 2
            color: dial.warning_red
            y: 160
            z: 2
        }

        Item {
            id: mainTicks
            x: 0
            y: 158
            width: 765
            height: 16
            antialiasing: true
            z: 2
            Rectangle {
                y: 0
                x: 73.8
                width: 6
                height: 18
                color: if (dial.watertemp < 80) 
                    dial.engine_warmup_color
                else
                   if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                border.color: dial.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 0
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if (dial.watertemp < 80) 
                    dial.engine_warmup_color
                else
                   if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                border.color: dial.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 68
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if (dial.watertemp < 80) 
                    dial.engine_warmup_color
                else
                   if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                border.color: dial.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 144
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if (dial.watertemp < 80) 
                    dial.engine_warmup_color
                else
                   if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                border.color: dial.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 221
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if (dial.watertemp < 80) 
                    dial.engine_warmup_color
                else
                   if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                border.color: dial.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 298
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                border.color: dial.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 375
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                border.color: dial.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 452
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                border.color: dial.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 529
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                border.color: dial.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 605
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                border.color: dial.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 682
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                border.color: dial.background_color
                border.width: 2
                anchors.right: parent.right
                anchors.rightMargin: 0
            }
        }
                Row {
                    id: subTicks
                    x: 30
                    y: 160
                    width: 710
                    height: 16
                    antialiasing: true
                    z: 3
                    Repeater {
                        model: 8
                        property int index
                        Row {
                            id: subTickRow
                            width: 77

                            Rectangle {
                                width: 6
                                height: 13
                                x: 0
                                y: -2
                                border.color: dial.background_color
                                border.width: 2
                                color: if (dial.watertemp < 80) {
                                           if (index <= 3)
                                               dial.engine_warmup_color
                                           else
                                            if(!dial.sidelight) dial.primary_color; else dial.night_light_color

                                       } else
                                            if(!dial.sidelight) dial.primary_color; else dial.night_light_color

    

                            }
                        }
                    }
                }
        Rectangle {
            id: engine_warmup_line
            x: 2
            y: 160
            width: 297
            height: 2
            z: 4
            color: dial.engine_warmup_color
            visible: dial.watertemp < 80
        }

        //RPM Numbers
        //Changed to Manual position as the alignment wasn't nice enough for my preferences
        Item {
            id: numbers
            x: 0
            y: 180
            height: 16
            width: 768
            Text {
                id: rev_zero
                x: 0
               color: if (dial.watertemp < 80) 
                    dial.engine_warmup_color
                else
                    if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                text: "0"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: helvetica_black_oblique.name
            }
            Text {
                id: rev_one
                color: if (dial.watertemp < 80) 
                    dial.engine_warmup_color
                else
                    if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                text: "1"
                anchors.left: parent.left
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                anchors.leftMargin: 65
                font.family: helvetica_black_oblique.name
            }
            Text {
                id: rev_two
                color: if (dial.watertemp < 80) 
                    dial.engine_warmup_color
                else
                    if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                text: "2"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: helvetica_black_oblique.name
                anchors.leftMargin: 141
                anchors.left: parent.left
            }
            Text {
                id: rev_three
                color: if (dial.watertemp < 80) 
                    dial.engine_warmup_color
                else
                    if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                text: "3"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: helvetica_black_oblique.name
                anchors.leftMargin: 218
                anchors.left: parent.left
            }
            Text {
                id: rev_four
                color: if (dial.watertemp < 80) 
                    dial.engine_warmup_color
                else
                    if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                text: "4"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: helvetica_black_oblique.name
                anchors.leftMargin: 295
                anchors.left: parent.left
            }
            Text {
                id: rev_five
                color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                text: "5"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: helvetica_black_oblique.name
                anchors.leftMargin: 373
                anchors.left: parent.left
            }
            Text {
                id: rev_six
                color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                text: "6"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: helvetica_black_oblique.name
                anchors.leftMargin: 449
                anchors.left: parent.left
            }
            Text {
                id: rev_seven
                color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                text: "7"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: helvetica_black_oblique.name
                anchors.leftMargin: 526
                anchors.left: parent.left
            }
            Text {
                id: numba_eight
                color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                text: "8"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: helvetica_black_oblique.name
                anchors.leftMargin: 602
                anchors.left: parent.left
            }
            Text {
                id: rev_9
                color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                text: "9"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: helvetica_black_oblique.name
                anchors.rightMargin: 78
                anchors.right: parent.right
            }
            Text {
                id: rev_10
                x: 0
                y: 0
                color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                text: "10"
                anchors.right: parent.right
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                anchors.rightMargin: 0
                transformOrigin: Item.Right
                font.family: helvetica_black_oblique.name
            }
        }

        Text {
            id: watertemp_label
            x: 113
            y: 410
            color: if (dial.watertemp < dial.waterlow)
                    dial.engine_warmup_color
                else if (dial.watertemp > dial.waterlow && dial.watertemp < dial.waterhigh)
                   if(!dial.sidelight) dial.primary_color; else dial.night_light_color
               else
                   dial.warning_red
            text: "Water Temp °C"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            font.family: helvetica_black_oblique.name
        }

        Text {
            id: oiltemp_label
            x: 113
            y: 353
            color: if (dial.oiltemp < dial.oiltemphigh)
                       if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                   else
                       dial.warning_red
            text: "Oil Temp °C"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            font.family: helvetica_black_oblique.name
            visible: if(dial.oiltemphigh === 0)false; else true

        }

        Text {
            id: oilpressure_label
            x: 113
            y: 298
            color: if (dial.oilpressure < dial.oilpressurelow)
                    dial.warning_red
                else
                    if(!dial.sidelight) dial.primary_color; else dial.night_light_color
            text: "Oil Pressure"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            font.family: helvetica_black_oblique.name
            visible: if(dial.oilpressurehigh === 0)false; else true

        }

        Text {
            id: fuel_label
            x: 321
            y: 431
            width: 128
            color: if (dial.fuel > dial.fuellow)
                       if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                   else
                       dial.warning_red
            text: if (dial.fuel > dial.fuellow)
                      dial.fuel + " %"
                  else
                      "LOW FUEL!!"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            font.family: helvetica_black_oblique.name
        }
    }

    Item {
        id: fueling_system
        x: 336
        y: 402
        width: 128
        height: 32
        Row {
            id: gasgauge
            x: 0
            y: -8
            width: 128
            height: 32
            antialiasing: true
            z: 3
            Repeater {
                model: 10
                //  required
                property int index
                Row {
                    Rectangle {
                        width: 11
                        height: 32
                        color: if (Math.floor(dial.fuel / 10) > index) {
                                   if (dial.fuel > 30)
                                       if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                                   else
                                       dial.warning_red
                               } else
                                   "#0A0A0A"
                        radius: 2
                        border.width: if (Math.floor(dial.fuel / 10) > index) {
                                          0
                                      } else
                                          1
                        border.color: if(!dial.sidelight) dial.primary_color; else dial.night_light_color
                        z: 1
                    }
                    Rectangle {
                        width: 2
                        height: 32
                        color: dial.background_color
                        z: 1
                    }
                }
            }
        }
    }
    Item {
        id: icons
        Image {
            id: brights
            x: 378
            y: 296
            height: 29
            width: 46
            source: "./img/brights.png"
            visible: dial.mainbeam
        }
        Image{
            x: 285
            y: 301
            height: 17
            width: 49
            source: "./img/parking_lights.png"
            visible: dial.sidelight
        }

        Image {
            id: left_blinker
            x: 341
            y: 295
            source: "./img/left_blinker.png"
            visible: dial.leftindicator
        }
        Image {
            id: right_blinker
            x: 432
            y: 295
            source: "./img/right_blinker.png"
            visible: dial.rightindicator
        }
        Image {
            id: battery_image
            x: 731
            y: 293
            width: 47
            height: 32
            source: "./img/battery.png"
            visible: dial.battery
        }
        Image {
            id: cel_image
            x: 671
            y: 293
            width: 52
            source: "./img/cel.png"
            antialiasing: true
            height: 32
            visible: dial.mil
        }

        Image {
            id: ebrake_image
            x: 569
            y: 295
            width: 96
            height: 32
            source: "./img/e-brake.png"
            visible: dial.brake|dial.handbrake //This is the way it is set in main.qml so trying this to see if it shows.
        }
        Image {
            id: tcs_image
            x: 531
            y: 295
            width: 43
            height: 32
            source: "./img/tcs.png"
            visible: dial.tc
        }
        Image {
            id: oil_pressure_lamp
            x: 467
            source: "img/oillight.png"
            y: 298
            width: 61
            height: 23
            visible: dial.oil
        }

        Image {
            id: abs_image
            x: 333
            y: 349
            source: "./img/abs.png"
            sourceSize.width: 42
            sourceSize.height: 32
            visible: dial.abs
        }
        Image {
            id: seatbelt_warning_lamp
            x: 390
            y: 349
            source: "./img/seatbelt.png"
            visible: dial.seatbelt
        }
        Image {
            id: door_ajar_lamp
            x: 433
            y: 349
            source: "./img/doorajar.png"
            visible: dial.doorswitch
        }
        Item {
            x: 469
            y: 407

            Image {
                id: fuel_icon
                width: 17
                height: 19
                source: "./img/fuel_icon_white.png"
            }
            ColorOverlay{
                    color: dial.night_light_color
                    source: fuel_icon
                    enabled: dial.sidelight
                    anchors.fill: fuel_icon
                    opacity: 1
                    visible: dial.sidelight
                }
        }
    }

    // --- animations carried over from the wrapper's instantiation ---
    Behavior on x {NumberAnimation{duration: 500}}
    Behavior on y {NumberAnimation{duration: 500}}
    Behavior on scale {NumberAnimation{duration: 500}}
}

// --- property forwards carried over from the wrapper's <LeMansGT>{} instantiation.
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
//! [0]

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
    source: "/opt/IC7/screen_configs/Taikyu_config.txt"
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
    
    z: 0
    
    property int myyposition: 0
    property int udp_message: rpmtest.udp_packetdata

    property bool udp_up: dial.udp_message & 0x01
    property bool udp_down: dial.udp_message & 0x02
    property bool udp_left: dial.udp_message & 0x04
    property bool udp_right: dial.udp_message & 0x08

    property int membank2_byte7: rpmtest.can203data[10]
    property int inputs: rpmtest.inputsdata

    //Inputs//31 max!!
    property bool ignition: dial.inputs & 0x01
    property bool battery: dial.inputs & 0x02
    property bool lapmarker: dial.inputs & 0x04
    property bool rearfog: dial.inputs & 0x08
    property bool mainbeam: dial.inputs & 0x10
    property bool up_joystick: dial.inputs & 0x20 || dial.udp_up
    property bool leftindicator: dial.inputs & 0x40
    property bool rightindicator: dial.inputs & 0x80
    property bool brake: dial.inputs & 0x100
    property bool oil: dial.inputs & 0x200
    property bool seatbelt: dial.inputs & 0x400
    property bool sidelight: dial.inputs & 0x800
    property bool tripresetswitch: dial.inputs & 0x1000
    property bool down_joystick: dial.inputs & 0x2000 || dial.udp_down
    property bool doorswitch: dial.inputs & 0x4000
    property bool airbag: dial.inputs & 0x8000
    property bool tc: dial.inputs & 0x10000
    property bool abs: dial.inputs & 0x20000
    property bool mil: dial.inputs & 0x40000
    property bool shift1_id: dial.inputs & 0x80000
    property bool shift2_id: dial.inputs & 0x100000
    property bool shift3_id: dial.inputs & 0x200000
    property bool service_id: dial.inputs & 0x400000
    property bool race_id: dial.inputs & 0x800000
    property bool sport_id: dial.inputs & 0x1000000
    property bool cruise_id: dial.inputs & 0x2000000
    property bool reverse: dial.inputs & 0x4000000
    property bool handbrake: dial.inputs & 0x8000000
    property bool tc_off: dial.inputs & 0x10000000
    property bool left_joystick: dial.inputs & 0x20000000 || dial.udp_left
    property bool right_joystick: dial.inputs & 0x40000000 || dial.udp_right

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

    property int mph: (dial.speed * 0.62)

    property int gearpos: rpmtest.geardata

    property real speed_spring: 1
    property real speed_damping: 1

    property real rpm_needle_spring: 3.0 //if(rpm<1000)0.6 ;else 3.0
    property real rpm_needle_damping: 0.2 //if(rpm<1000).15; else 0.2

    property bool changing_page: rpmtest.changing_pagedata

    property string white_color: "#FFFFFF"
    property string primary_color: "#000000"; //#FFBF00 for amber
    property string night_light_color: "#ACFAFF"  //Pale Indiglo Blue
    property string sweetspot_color: "#FFA500" //Cam Changeover Rev colpr
    property string warning_red: "#C60000" //Redline/Warning colors
    property string nightlight_pink: "#F85653"
    property string nightlight_orange: "#F89553"
    property string engine_warmup_color: "#eb7500"
    property string background_color: "#000000"
    property string soft_bkg_color: "#222222"

    x: 0
    y: 0

    //Fonts
    FontLoader {
        id: twentytwosegment
        source: "./fonts/22Segment.ttf"
    }

    //Peak Values

    property int peak_rpm: 0
    property int peak_speed: 0
    property int peak_water: 0
    property int peak_oil: 0
    property bool car_movement: false

    onRpmChanged: if (dial.rpm > dial.peak_rpm) dial.peak_rpm = dial.rpm

    onSpeedChanged: {
        if (dial.speed > dial.peak_speed) dial.peak_speed = dial.speed
        if (dial.speed > 10 && !dial.car_movement) dial.car_movement = true
    }

    onWatertempChanged: if (dial.watertemp > dial.peak_water) dial.peak_water = dial.watertemp

    onOiltempChanged: if (dial.oiltemp > dial.peak_oil) dial.peak_oil = dial.oiltemp
   
    //Utility  
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
                    return dial.easyFtemp(dial.peak_water) + "F"
                else 
                    return dial.peak_water.toFixed(0) + "C"
            }
            else{
                if(dial.waterunits !== 1)
                    return dial.easyFtemp(dial.watertemp) + "F"
                else 
                    return dial.watertemp.toFixed(0) + "C"
            }
        }
        else{
            if(dial.seatbelt && dial.car_movement && dial.speed === 0){
                 if(dial.oiltempunits !== 1)
                    return dial.easyFtemp(dial.peak_oil) 
                else 
                    return dial.peak_oil.toFixed(0) + "C"
            }
            else{
                if(dial.oiltempunits !== 1)
                    return dial.easyFtemp(dial.oiltemp) 
                else 
                    return dial.oiltemp.toFixed(0) + "C"
            }
        }
    }

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

    function interpolateColor(rpm, startRpm, endRpm, startColor, endColor) {
        // Ensure RPM is within bounds
        var progress = Math.max(0, Math.min(1, (rpm - startRpm) / (endRpm - startRpm)));

        // Convert hex colors to RGB
        var startR = parseInt(startColor.slice(1, 3), 16);
        var startG = parseInt(startColor.slice(3, 5), 16);
        var startB = parseInt(startColor.slice(5, 7), 16);

        var endR = parseInt(endColor.slice(1, 3), 16);
        var endG = parseInt(endColor.slice(3, 5), 16);
        var endB = parseInt(endColor.slice(5, 7), 16);

        // Interpolate RGB values
        var r = Math.round(startR + (endR - startR) * progress).toString(16).padStart(2, '0');
        var g = Math.round(startG + (endG - startG) * progress).toString(16).padStart(2, '0');
        var b = Math.round(startB + (endB - startB) * progress).toString(16).padStart(2, '0');

        // Return hex color
        return `#${r}${g}${b}`;
    }

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
    Rectangle {
        id: rpm_thing
        x: 0
        y: 70
        z: 4
        height: 188
        width: dial.rpm <= 5000 ? 30 + (dial.rpm * 0.049) : (dial.rpm * 0.1) - 224
        property color currentColor: dial.rpm < 7500 ? 
            dial.interpolateColor(dial.rpm, 4500, 5000, 
                !dial.sidelight ? dial.white_color : dial.night_light_color, 
                !dial.sidelight ? dial.sweetspot_color : dial.nightlight_orange) :
            dial.interpolateColor(dial.rpm, 7500, 8000, 
                !dial.sidelight ? dial.sweetspot_color : dial.nightlight_orange, 
                !dial.sidelight ? dial.warning_red : dial.nightlight_pink)
        color: currentColor
        Behavior on color {
            ColorAnimation { duration: 50 }  // Smooth over one frame
        }
    }
    Item{
        id: rpm_line
        x: if(dial.rpm <= 5000){28 + (dial.rpm * 0.049)} else{
            (dial.rpm * 0.1) - 225
        }
        opacity: 0
        y:70;z:9
        Rectangle{
            height: 188; width: 4
            color: dial.white_color
        }
    }
    Image{
        x:0; y:0; z: 10
        id: rpm_line_mask
        source: !dial.sidelight ? './taikyu/tach-marker-mask.png' : './taikyu/indiglo/tach-marker-mask.png'
        opacity:0
    } 
    Image{
        id: tach_mask 
        x:0; y:0; z:8
        source: './taikyu/tach-mask.png'
    }
    Image{
        id: tach_outlines
        x: 28; y: 70; z: 11;
        source: if(!dial.sidelight) './taikyu/tach-outlines.png'; else './taikyu/indiglo/tach-outlines.png'
        opacity: 0;
    }  
    Image{
        id: red_zone
        x: 576;y:70;z:1
        source: './taikyu/red-zone.png'
    }

    
    Timer{
        interval:0; running:dial.ignition; repeat: false
        onTriggered: first_step.start()
    }
    
    ParallelAnimation{
        id: first_step
        NumberAnimation{
            target: tach_outlines; property: "opacity"; from: 0.00; to: 1.0; duration: 1000
        }
    }
    Timer{
        interval: 1000; running:dial.ignition; repeat: false
        onTriggered: second_step.start()
    }
    ParallelAnimation{
        id: second_step
        NumberAnimation{
                target: rpm_line_mask; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
            }
        
        NumberAnimation{
            target: speed_text; property: "opacity"; from: 0.00; to: 1.00; duration: 1000;
        }
        NumberAnimation{
            target: gear_display_char; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: rpm_display; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: rpm_display; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: speed_teller; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: gear_label; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }

    Timer{
        interval: 1500; running: dial.ignition; repeat: false
        onTriggered: third_step.start()
    }
    ParallelAnimation{
        id: third_step
        NumberAnimation{
            target: divider; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: coolant_temp_display; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: fuel_level_display; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
                target: rpm_line; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
            }
    }
    Timer{
        interval: 2000; running: dial.ignition; repeat: false
        onTriggered: fourth_step.start()
    }
    ParallelAnimation{
        id: fourth_step
        NumberAnimation{
            target: optional_inputs; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }
    Timer{
            interval: 2500; running: dial.ignition; repeat: false
            onTriggered: fifth_step.start()
        }
    ParallelAnimation{
        id: fifth_step
        NumberAnimation{
            target: cool_coolant_bar; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: hot_coolant_bar; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: coolant_soft_bkg; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: fuel_bar; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: fuel_soft_bkg; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }
    Image{
        id: divider
        x: 20; y:277; z: 4
        opacity: 0
        source: if(!dial.sidelight) './taikyu/divider.png'; else './taikyu/indiglo/divider.png'
    }
    Item{
        z:12
        property string speedtext: if(dial.peak_speed === 0 && dial.rpm === 0) "Push Start Button"; else "Peak Speed "+ dial.getPeakSpeed() + "   Peak RPM " + dial.peak_rpm
            property string spacing: "   "
            property string combined: speedtext + spacing
            property string display: combined.substring(step) + combined.substring(0, step)
            property int step: 0
            Timer {
                interval: 250
                running: true
                repeat: true
                onTriggered: parent.step = (parent.step + 1) % parent.combined.length
            }
        Text{
            id: speed_text
            x: 567; y: 165; z: 11
            width: 208
            font.family: twentytwosegment.name
            font.italic: true
            font.pixelSize: 100
            horizontalAlignment: Text.AlignRight
            color: if(!dial.sidelight) dial.white_color; else dial.night_light_color
            renderType: Text.NativeRendering
            opacity: 0
            clip: true
                text: if((dial.speed === 0 && !dial.car_movement && dial.rpm === 0) || (dial.speed === 0 && dial.seatbelt && dial.car_movement)){
                        parent.display
                    }
                    else{
                        if (dial.speedunits === 0) dial.speed.toFixed(0); else (dial.speed*.62).toFixed(0)
                    }
        }
    }
    Text{
        id: speed_text_bkg
        x: 621; y: 165; z: 11
        width: 152
        font.family: twentytwosegment.name
        font.italic: true
        font.pixelSize: 100
        horizontalAlignment: Text.AlignRight
        color: "#222222"
        text: "@@@"
        renderType: Text.NativeRendering
    }
    Image{
        id: speed_teller
        x: 726; y:250; z: 11
        opacity: 0
        source: if (dial.speedunits === 0){
                    if(!dial.sidelight)'./taikyu/kmh.png'
                    else './taikyu/indiglo/kmh.png'
                    }
                else {
                    if(!dial.sidelight)'./taikyu/mph.png'
                    else './taikyu/indiglo/mph.png'
                    }
    }
    Item{
        id: rpm_display
        z: 14
        opacity: 0
        Text{
            color: "#000000"
            text: dial.rpm
            font.family: twentytwosegment.name
            font.bold: false
            font.pixelSize: 30
            renderType: Text.NativeRendering
            x: 640; y: 132; z:17
            horizontalAlignment: Text.AlignRight
            width: 85
        }
        Image{
            x:586; y: 130; z:16
            visible: if(dial.rpm < dial.rpmlimit) true; else false
            source: if(!dial.sidelight)'./taikyu/rpm-container.png'; else './taikyu/indiglo/rpm-container.png'
        }
        Image{
            id: rpm_container_blink
            x:586; y: 130; z:16
            visible: if(dial.rpm >= dial.rpmlimit) true; else false
            source: if(!dial.sidelight)'./taikyu/rpm-container-warning.png'; else './taikyu/indiglo/rpm-container-warning.png'
            SequentialAnimation {
                id: shiftBlinkAnimation
                running: dial.rpm >= dial.rpmlimit
                loops: Animation.Infinite
                
                NumberAnimation {
                    target: rpm_container_blink
                    property: "opacity"
                    to: 100
                    duration: 50
                }
                NumberAnimation {
                    target: rpm_container_blink
                    property: "opacity"
                    to: 0
                    duration: 50
                }
            }
        }
        
    }
    Item{
        id: geardisplay
        z: 11
        Text{
            id: gear_display_char
            z:2
            font.family: twentytwosegment.name
            font.bold: false
            font.pixelSize: 144
            x: 354; y: 125
            text: dial.getGear()
            color: if(!dial.sidelight) dial.white_color; else dial.night_light_color
            renderType: Text.NativeRendering
            opacity: 0
        }
        Text{
            z:1
            font.family: twentytwosegment.name
            font.bold: false
            font.pixelSize: 144
            x: 354; y: 125
            text: '@'
            color: "#222222"
            renderType: Text.NativeRendering
        }
        Image{
            id: gear_label
            opacity: 0
            source:if(!dial.sidelight) './taikyu/gear.png'; else './taikyu/indiglo/gear.png'
            x: 373; y: 250; z:2
        }
    }


    Item{
         id: coolant_temp_display
        opacity: 0        
        Image{
            //124 px high
            source:if(!dial.sidelight) './taikyu/coolant-mask.png'; else  './taikyu/indiglo/coolant-mask.png'
            x: 20; y:312; z: 4

        }
        Rectangle{
            id: cool_coolant_bar
            x: 20
            y: if (dial.watertemp <= 100)432 - ((dial.watertemp.toFixed(0) - 20) * 1.2125); else 335
            z:3
            color: if(!dial.sidelight) dial.white_color; else dial.night_light_color
            width: 116 
            opacity: 0
            height: if (dial.watertemp <= 100)(dial.watertemp.toFixed(0) - 20) * 1.2125; else 97
        }
        Rectangle{
            id: hot_coolant_bar
            x: 20
            y:if (dial.watertemp <= 120) 432 - ((dial.watertemp - 20) * 1.2); else 313
            color: if(!dial.sidelight) dial.warning_red; else dial.nightlight_pink
            width: 116;
            opacity: 0
            height:if (dial.watertemp <= 120)(dial.watertemp - 20) * 1.2; else 119
            z:2
        }
        Rectangle{
            id: coolant_soft_bkg
            opacity: 0
            x:20; y: 313; z: 1
            height: 119; width: 116
            color: dial.soft_bkg_color
        }
        Text{
            x: 42; y: 440
            font.family: twentytwosegment.name
            font.bold: false
            font.pixelSize: 30
            renderType: Text.NativeRendering
            color: if(dial.watertemp.toFixed(0) < dial.waterhigh){
                if(!dial.sidelight) dial.white_color; else dial.night_light_color}
                else{
                    if(!dial.sidelight) dial.warning_red; else dial.nightlight_pink
                }
            text: dial.getTemp("COOLANT")
            horizontalAlignment: Text.AlignRight
            width:58
        }
    }
    Item{
        id: fuel_level_display
        opacity: 0
        Image{
            source:if(!dial.sidelight) './taikyu/fuel-mask.png'; else  './taikyu/indiglo/fuel-mask.png'
            x: 672; y: 312;
            z: 3
        }
        Rectangle{
            id: fuel_bar
            x: 672
            y: 432 - (dial.fuel * 1.19)
            width: 116 
            height: dial.fuel * 1.19
            opacity: 0
            color: if (dial.fuel > 30){
                    if(!dial.sidelight) dial.white_color; else dial.night_light_color
                }else{
                    if(!dial.sidelight) dial.warning_red; else dial.nightlight_pink
                }
            z:2
        }
        Rectangle{
            id: fuel_soft_bkg
            opacity: 0
            x:672; y: 313; z: 1
            height: 119; width: 116
            color: dial.soft_bkg_color
        }

    }
    Item{
        id: optional_inputs
        opacity: 0
        Item{
            id: oil_pressure_group
            visible: if(dial.oilpressurehigh !== 0 ) true; else false
            Image{
                source: if(!dial.sidelight) './taikyu/info-stripe.png'; else './taikyu/indiglo/info-stripe.png'
                x: 150; y: 310; z:2;
            }
            Image{
                source: if(!dial.sidelight) './taikyu/oil-press.png'; else './taikyu/indiglo/oil-press.png'
                x:152;y:333;z:2;
            }
            Text{
                x:280; y: 315; z:2
                width: 93
                font.family: twentytwosegment.name
                font.bold: false
                font.pixelSize: 48
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignRight
                text: if(dial.oilpressureunits === 1) dial.oilpressure.toFixed(1); else (dial.oilpressure.toFixed(1) * 14.504).toFixed(0)
                color: if(!dial.sidelight) dial.white_color; else dial.night_light_color
            }
            Text{
                x:280; y: 315; z:1
                width: 93
                font.family: twentytwosegment.name
                font.bold: false
                font.pixelSize: 48
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignRight
                text: "1@@@"
                color: dial.soft_bkg_color
            }
        }
        Item{
            id: oil_temp_group
            visible: if(dial.oiltemphigh !== 0 ) true; else false
            Image{
                source: if(!dial.sidelight) './taikyu/info-stripe.png'; else './taikyu/indiglo/info-stripe.png'
                x: 150; y: 380; z:2;
            }
            Image{
                source: if(!dial.sidelight) './taikyu/oil-temp.png'; else './taikyu/indiglo/oil-temp.png'
                x:152;y:400;z:2;
            }
            Text{
                x:280; y: 383; z:2
                width: 93
                font.family: twentytwosegment.name
                font.bold: false
                font.pixelSize: 48
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignRight
                text: dial.getTemp("OIL")
                color: if(dial.oiltemp.toFixed(0) < dial.oiltemphigh){
                    if(!dial.sidelight) dial.white_color; else dial.night_light_color}
                    else{
                        if(!dial.sidelight) dial.warning_red; else dial.nightlight_pink
                    }
            }
            Text{
                x:280; y: 383; z:1
                width: 93
                font.family: twentytwosegment.name
                font.bold: false
                font.pixelSize: 48
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignRight
                text: "1@@@"
                color: dial.soft_bkg_color
            }
        }
        Item{
            id: afr_group
            visible: if(dial.afrhigh !== 0) true; else false
            Image{
                source: if(!dial.sidelight) './taikyu/info-stripe.png'; else './taikyu/indiglo/info-stripe.png'
                x: 423; y: 310; z:2;
            }
            Image{
                source: if(!dial.sidelight) './taikyu/afr.png'; else './taikyu/indiglo/afr.png'
                x:425;y:333;z:2;
            }
            Text{
                x:552; y: 315; z:2
                width: 93
                font.family: twentytwosegment.name
                font.bold: false
                font.pixelSize: 48
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignRight
                text: dial.o2.toFixed(2)
                color: if(!dial.sidelight) dial.white_color; else dial.night_light_color
            }
            Text{
                x:552; y: 315; z:1
                width: 93
                font.family: twentytwosegment.name
                font.bold: false
                font.pixelSize: 48
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignRight
                text: "1@@@"
                color: dial.soft_bkg_color
            }
        }
    }
    Text{ 
        id: odometer
        x: 671; y: 450
        width: 77
        color: if(!dial.sidelight) dial.white_color; else dial.night_light_color
        font.family: twentytwosegment.name
        font.bold: false
        font.pixelSize: 20
        renderType: Text.NativeRendering
        horizontalAlignment: Text.AlignRight
        text: if (dial.speedunits === 0)
                        (dial.odometer/.62).toFixed(0) 
                    else if(dial.speedunits === 1)
                        dial.odometer 
                    else
                        dial.odometer
    }
    Image{
        x: 751; y:453;
        source: if (dial.speedunits === 0){
            if(!dial.sidelight) './taikyu/km.png'; else './taikyu/indiglo/km.png'
        }else{
            if(!dial.sidelight) './taikyu/mi.png'; else './taikyu/indiglo/mi.png'
        }
    }
    Item{
        id: idiot_lights
        Image{
            x: 346; y: 440
            width: 33; height: 34 
            z: 1
            source: "./taikyu/warning-lights/gas-light.png"
            visible: dial.fuel < dial.fuellow
        }
        Image{
            x: 308; y: 440
            width: 33; height: 34 
            z: 1
            source: "./taikyu/warning-lights/oil-light.png"
            visible: dial.oil
        }
        Image{
            x: 270; y: 440
            width: 33; height: 34 
            z: 1
            source: "./taikyu/warning-lights/brake-light.png"
            visible: dial.brake
        }
        Image{
            x: 233; y: 440
            width: 33; height: 34 
            z: 1
            source: "./taikyu/warning-lights/seatbelt-light.png"
            visible: dial.seatbelt
        }
        Image{
            x: 195; y: 440
            width: 33; height: 34 
            z: 1
            source: "./taikyu/warning-lights/blinker-light.png"
            visible: dial.leftindicator || dial.rightindicator
        }
        Image{
            x:573; y: 440
             width: 33; height: 34 
            z: 1
            source: "./taikyu/warning-lights/checkengine-light.png"
            visible: dial.mil
        }
        Image{
            x:498; y: 440
            width: 33; height: 34 
            z: 1
            source: "./taikyu/warning-lights/battery-light.png"
            visible: dial.battery
        }
        Image{
            x:460; y: 440
            width: 33; height: 34 
            z: 1
            source: "./taikyu/warning-lights/airbag-light.png"
            visible: dial.airbag
        }
        Image{
            x:422; y: 440
            width: 33; height: 34 
            z: 1
            source: "./taikyu/warning-lights/hibeams-light.png"
            visible: dial.mainbeam
        }
        Image{
            x:384; y: 440
            width: 33; height: 34 
            z: 1
            source: "./taikyu/warning-lights/abs-light.png"
            visible: dial.abs
        }
    }

    // --- animations carried over from the wrapper's instantiation ---
    Behavior on x {NumberAnimation{duration: 500}}
    Behavior on y {NumberAnimation{duration: 500}}
    Behavior on scale {NumberAnimation{duration: 500}}
}

// --- property forwards carried over from the wrapper's <Taikyu>{} instantiation.
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
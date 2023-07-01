using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;
using Toybox.ActivityMonitor as Am;
using Toybox.Activity as Act;
using Toybox.Sensor;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Math;
using Toybox.Lang;

class YumView extends Ui.WatchFace {

    hidden var inLowPower = false;
    hidden var time;
    hidden var hour = 0;
    hidden var dateString;
    hidden var steps;
    hidden var stepGoal;
    hidden var heartRate;
    hidden var batteryRemaining;
    hidden var info;
    hidden var activityInfo;
    hidden var now;
    hidden var distance;
    hidden var floorsClimbed;

    //Fonts
    hidden var FONT_RAJ_BIG;
    hidden var FONT_RAJ_BIG_OUTLINE;
    hidden var FONT_RAJ_SMALL;

    //Colors
    hidden var COLOR_TEAL = 0x00E39F;
    hidden var COLOR_LIGHTGREY = 0xD6D6D6;
    hidden var COLOR_DARKGREY = 0x232323;
    hidden var COLOR_YELLOW = 0xE0D785;
    hidden var COLOR_ORANGE = 0xE79356;
    hidden var COLOR_AMBER = 0xFF6C2E;
    hidden var COLOR_RED = 0xD80D00;
    hidden var COLOR_DARKRED = 0x770700;

    // Bitmaps
    hidden var hourPattern;
    hidden var hourPatternRed;
    hidden var batteryIcon;
    hidden var batteryIconNightmode;
    hidden var batteryIconIndex = 0;
    hidden var hrIcon;
    hidden var hrIconNightmode;
    hidden var stepsIcon;
    hidden var stepsIconNightmode;
    hidden var distanceIcon;
    hidden var distanceIconNightmode;
    hidden var floorsIcon;
    hidden var floorsIconNightmode;

    hidden var mockup;

    function initialize() {
        Ui.WatchFace.initialize();
        FONT_RAJ_BIG = App.loadResource(Rez.Fonts.RAJ_BIG);
        FONT_RAJ_BIG_OUTLINE = App.loadResource(Rez.Fonts.RAJ_BIG_OUTLINE);
        FONT_RAJ_SMALL = App.loadResource(Rez.Fonts.RAJ_SMALL);
        // mockup = App.loadResource(Rez.Drawables.mockup);
        hourPattern = App.loadResource(Rez.Drawables.hourPattern);
        hourPatternRed = App.loadResource(Rez.Drawables.hourPatternRed);
        batteryIcon = [
            App.loadResource(Rez.Drawables.battery_5),
            App.loadResource(Rez.Drawables.battery_15),
            App.loadResource(Rez.Drawables.battery_25),
            App.loadResource(Rez.Drawables.battery_35),
            App.loadResource(Rez.Drawables.battery_45),
            App.loadResource(Rez.Drawables.battery_55),
            App.loadResource(Rez.Drawables.battery_65),
            App.loadResource(Rez.Drawables.battery_75),
            App.loadResource(Rez.Drawables.battery_85),
            App.loadResource(Rez.Drawables.battery_95)
        ];
        batteryIconNightmode = [
            App.loadResource(Rez.Drawables.battery_5_nightmode),
            App.loadResource(Rez.Drawables.battery_15_nightmode),
            App.loadResource(Rez.Drawables.battery_25_nightmode),
            App.loadResource(Rez.Drawables.battery_35_nightmode),
            App.loadResource(Rez.Drawables.battery_45_nightmode),
            App.loadResource(Rez.Drawables.battery_55_nightmode),
            App.loadResource(Rez.Drawables.battery_65_nightmode),
            App.loadResource(Rez.Drawables.battery_75_nightmode),
            App.loadResource(Rez.Drawables.battery_85_nightmode),
            App.loadResource(Rez.Drawables.battery_95_nightmode)
        ];
        hrIcon = [
            App.loadResource(Rez.Drawables.hr_low),
            App.loadResource(Rez.Drawables.hr_elevated),
            App.loadResource(Rez.Drawables.hr_high),
            App.loadResource(Rez.Drawables.hr_max),
        ];
        hrIconNightmode = App.loadResource(Rez.Drawables.hr_nightmode);
        stepsIcon = [
            App.loadResource(Rez.Drawables.steps_incomplete),
            App.loadResource(Rez.Drawables.steps_complete),
        ];
        stepsIconNightmode = App.loadResource(Rez.Drawables.steps_nightmode);
        distanceIcon = App.loadResource(Rez.Drawables.distance);
        distanceIconNightmode = App.loadResource(Rez.Drawables.distance_nightmode);
        floorsIcon = App.loadResource(Rez.Drawables.floors);
        floorsIconNightmode = App.loadResource(Rez.Drawables.floors_nightmode);
        updateData();
    }

    function updateData() {
        info = Am.getInfo();
        activityInfo = Act.getActivityInfo();
        now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        dateString = Lang.format(
            "$1$ $2$",
            [
                now.day_of_week,
                now.day
            ]
        );

        time = System.getClockTime();
        steps = info.steps;
        stepGoal = info.stepGoal;
        batteryRemaining = Math.floor(System.getSystemStats().battery);
        heartRate = activityInfo.currentHeartRate;
        distance = (info.distance/(100000.0)).format("%.1f");
        floorsClimbed = info.floorsClimbed || 0;
    }

    function onUpdate(dc) {
        updateData();
        var color = isNightMode() ? COLOR_RED : COLOR_LIGHTGREY;
        dc.setColor(color, Gfx.COLOR_BLACK);
        dc.clear();

        drawBattery(dc);
        drawTime(dc);
        drawDate(dc);
        drawSteps(dc);
        drawStats(dc);

        // Mockup time
        // dc.drawBitmap(0,0, mockup);

    }

    function isNightMode() {
        // Night mode is between 11pm - 8am
        return (time.hour <= 7 || time.hour >= 23);
    }

    function drawBattery(dc) {
        // Battery remaining
        if(!inLowPower) {
            if(batteryRemaining > 95) {
                batteryIconIndex = 9;
            }
            else if(batteryRemaining > 85) {
                batteryIconIndex = 8;
            }
            else if(batteryRemaining > 75) {
                batteryIconIndex = 7;
            }
            else if(batteryRemaining > 65) {
                batteryIconIndex = 6;
            }
            else if(batteryRemaining > 55) {
                batteryIconIndex = 5;
            }
            else if(batteryRemaining > 45) {
                batteryIconIndex = 4;
            }
            else if(batteryRemaining > 35) {
                batteryIconIndex = 3;
            }
            else if(batteryRemaining > 25) {
                batteryIconIndex = 2;
            }
            else if(batteryRemaining > 15) {
                batteryIconIndex = 1;
            }
            else {
                batteryIconIndex = 0;
            }
            
            var icon = isNightMode() ? batteryIconNightmode : batteryIcon;
            dc.drawBitmap(
                (dc.getWidth() / 2)-42, 
                28,
                icon[batteryIconIndex]
            );
            dc.drawText(
                dc.getWidth() / 2, 
                27, 
                FONT_RAJ_SMALL, 
                batteryRemaining.format("%d").toString() + "%", 
                Gfx.TEXT_JUSTIFY_LEFT
            );
        }
    }

    function drawTime(dc) {
        /** Time **/
        
        if(time.hour == 0) {
            hour = 12;
        }
        else if(time.hour > 12) {
            hour = time.hour - 12;
        }
        else {
            hour = time.hour;
        }

        var hourWidthInPx = dc.getTextWidthInPixels(hour.toString(), FONT_RAJ_BIG);
        var minWidthInPx = dc.getTextWidthInPixels(time.min.format("%02d"), FONT_RAJ_BIG);
        var timeWidthInPx = hourWidthInPx + minWidthInPx;
        var hourPosX = (dc.getWidth() / 2) - (timeWidthInPx / 2);
        var secondsPosX = (dc.getWidth() / 2) + (timeWidthInPx / 2) + 4;
        
        var pattern = isNightMode() ? hourPatternRed : hourPattern;

        // Hour
        
        dc.drawBitmap(
            hourPosX, 
            136,
            pattern
        );
        
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);

        dc.drawText(
            hourPosX,
            109,
            FONT_RAJ_BIG, 
            hour, 
            Gfx.TEXT_JUSTIFY_LEFT
        );
        

        // Minute
        var font = isNightMode() ? FONT_RAJ_BIG_OUTLINE : FONT_RAJ_BIG;
        var color = isNightMode() ? COLOR_RED : COLOR_TEAL;
        dc.setColor(color, Gfx.COLOR_BLACK);

        dc.drawText(
            hourPosX + hourWidthInPx,
            109, 
            font, 
            time.min.format("%02d"), 
            Gfx.TEXT_JUSTIFY_LEFT
        );
        color = isNightMode() ? COLOR_RED : COLOR_LIGHTGREY;
        dc.setColor(color, Gfx.COLOR_BLACK);

        // Second
        if(!inLowPower) {
            dc.drawText(
                secondsPosX,
                187, 
                FONT_RAJ_SMALL, 
                time.sec.format("%02d"), 
                Gfx.TEXT_JUSTIFY_LEFT
            );
        }
    }

    function drawDate(dc) {
        /** Date **/
        if(!inLowPower) {
            dc.drawText(
                dc.getWidth() / 2,
                98, 
                FONT_RAJ_SMALL, 
                dateString.toUpper(), 
                Gfx.TEXT_JUSTIFY_CENTER
            );
        }
    }

    function drawSteps(dc) {
        /** Steps ring **/
        if(!inLowPower) {
            var icon;
            if(isNightMode()) {
                icon = stepsIconNightmode;
            }
            else if(steps >= stepGoal) {
                icon = stepsIcon[1];
            }
            else {
                icon = stepsIcon[0];
            }
            // Steps
            dc.drawBitmap(
                134, 
                303,
                icon
            );
            dc.drawText(
                153, 
                339,
                FONT_RAJ_SMALL, 
                steps, 
                Gfx.TEXT_JUSTIFY_CENTER
            );

            // Ring
            var ringColor = COLOR_LIGHTGREY;
            var ringRadius = 52;
            var ringX = 152;
            var ringY = 340;
            var top = 90;
            var stepPercent = (steps.toFloat() / stepGoal.toFloat()) as Lang.Float;
            var angle = top+(360-(stepPercent*360));
            if(angle > 360) {
                angle -= 360;
            }

            dc.setPenWidth(6);
            dc.setColor(COLOR_DARKGREY, Gfx.COLOR_BLACK);
            dc.drawArc(ringX, ringY, ringRadius, Gfx.ARC_CLOCKWISE , 0, 360);
            if(steps > 0) {
                var x = ringX + ringRadius * Math.cos(Math.toRadians(-angle));
                var y = ringY + ringRadius * Math.sin(Math.toRadians(-angle));
                if(steps > stepGoal) {
                    ringColor = isNightMode() ? COLOR_RED : COLOR_TEAL;
                    dc.setColor(ringColor, Gfx.COLOR_BLACK);
                    dc.drawArc(ringX, ringY, ringRadius, Gfx.ARC_CLOCKWISE , 0, 360);
                }
                else {
                    ringColor = isNightMode() ? COLOR_DARKRED : COLOR_LIGHTGREY;
                    dc.setColor(ringColor, Gfx.COLOR_BLACK);
                    dc.fillCircle(ringX, ringY-ringRadius, 3);
                    dc.drawArc(ringX, ringY, ringRadius, Gfx.ARC_CLOCKWISE, top, angle);
                    dc.fillCircle(x, y, 3);
                }
            }
            dc.setColor(COLOR_LIGHTGREY, Gfx.COLOR_BLACK);
        }
    }

    function drawStats(dc) {
        /** Stats **/
        if(!inLowPower) {
            var iconLeftPos = 221;
            var textLeftPos = iconLeftPos + 42;
            var hrTextColor = COLOR_LIGHTGREY;
            var icon = {
                :hr => isNightMode() ? hrIconNightmode : hrIcon[0],
                :distance => isNightMode() ? distanceIconNightmode : distanceIcon,
                :floors => isNightMode() ? floorsIconNightmode : floorsIcon
            };
            // Heart rate
            var hrLabel = heartRate == null ? 0 : heartRate;
            if(!isNightMode()) {
                if(hrLabel > 140) {
                    icon[:hr] = hrIcon[3];
                    hrTextColor = COLOR_AMBER;
                }
                else if(hrLabel > 110) {
                    icon[:hr] = hrIcon[2];
                    hrTextColor = COLOR_ORANGE;
                }
                else if(hrLabel > 85) {
                    icon[:hr] = hrIcon[1];
                    hrTextColor = COLOR_YELLOW;
                }
            }
            hrTextColor = isNightMode() ? COLOR_RED : hrTextColor;
            dc.setColor(hrTextColor, Gfx.COLOR_BLACK);
            dc.drawBitmap(
                iconLeftPos, 
                282,
                icon[:hr]
            );
            dc.drawText(
                textLeftPos, 
                279, 
                FONT_RAJ_SMALL, 
                (heartRate == null) ? "-" : hrLabel, 
                Gfx.TEXT_JUSTIFY_LEFT
            );
            var color = isNightMode() ? COLOR_RED : COLOR_LIGHTGREY;
            dc.setColor(color, Gfx.COLOR_BLACK);
            
            // Distance
            dc.drawBitmap(
                iconLeftPos, 
                322,
                icon[:distance]
            );
            dc.drawText(
                textLeftPos, 
                319, 
                FONT_RAJ_SMALL, 
                distance+"km", 
                Gfx.TEXT_JUSTIFY_LEFT
            );

            // Floors
            dc.drawBitmap(
                iconLeftPos, 
                362,
                icon[:floors]
            );
            dc.drawText(
                textLeftPos, 
                359, 
                FONT_RAJ_SMALL, 
                floorsClimbed, 
                Gfx.TEXT_JUSTIFY_LEFT
            );
        }
    }


    function onShow() {
    }

    function onHide() {
    }

    function onDestroy() {
    }

    function onButton(button, type) {
    }

    function onExitSleep() {
        inLowPower = false;
    	Ui.requestUpdate(); 
    }

    function onEnterSleep() {
    	inLowPower = true;
    	Ui.requestUpdate(); 
    }
}
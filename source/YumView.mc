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

    hidden var themeChoices = {
        "day" => "teal",
        "night" => "blue"   // "red", "blue"
    };
    hidden var activeTheme;
    hidden var nightModeEnabled = false;

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
    hidden var COLOR_VERYDARKGREY = 0x151515;
    hidden var COLOR_YELLOW = 0xE0D785;
    hidden var COLOR_ORANGE = 0xE79356;
    hidden var COLOR_AMBER = 0xFF6C2E;
    hidden var COLOR_RED = 0xD80D00;
    hidden var COLOR_DARKRED = 0x770700;
    hidden var COLOR_BLUE = 0x0400C6;

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
        mockup = App.loadResource(Rez.Drawables.mockup);
        FONT_RAJ_BIG = App.loadResource(Rez.Fonts.RAJ_BIG);
        FONT_RAJ_BIG_OUTLINE = App.loadResource(Rez.Fonts.RAJ_BIG_OUTLINE);
        FONT_RAJ_SMALL = App.loadResource(Rez.Fonts.RAJ_SMALL);
        updateData();
        nightModeEnabled = isNightMode();
        activeTheme = loadTheme(nightModeEnabled ? themeChoices["night"] : themeChoices["day"]);
    }

    function loadTheme(theme) {
        var baseTheme = {
            :textColorPrimary => COLOR_LIGHTGREY,
            :textColorSecondary => COLOR_YELLOW, // JUST TO TEST THIS ACTUALLY OVERRIDES PROPERLY
            :batteryIcon => [
                App.loadResource(Rez.Drawables.battery_5__base),
                App.loadResource(Rez.Drawables.battery_15__base),
                App.loadResource(Rez.Drawables.battery_25__base),
                App.loadResource(Rez.Drawables.battery_35__base),
                App.loadResource(Rez.Drawables.battery_45__base),
                App.loadResource(Rez.Drawables.battery_55__base),
                App.loadResource(Rez.Drawables.battery_65__base),
                App.loadResource(Rez.Drawables.battery_75__base),
                App.loadResource(Rez.Drawables.battery_85__base),
                App.loadResource(Rez.Drawables.battery_95__base)
            ],
            :hourPattern => App.loadResource(Rez.Drawables.hourPattern__base),
            :hrIcon => [
                App.loadResource(Rez.Drawables.hr_low__base),
                App.loadResource(Rez.Drawables.hr_elevated__base),
                App.loadResource(Rez.Drawables.hr_high__base),
                App.loadResource(Rez.Drawables.hr_max__base),
            ],
            :hrLabelColor => [
                COLOR_LIGHTGREY,
                COLOR_YELLOW,
                COLOR_ORANGE,
                COLOR_AMBER
            ],
            :stepRingIncompleteColor => COLOR_LIGHTGREY,
            :stepRingCompleteColor => COLOR_TEAL,
            :stepRingBaseColor => COLOR_VERYDARKGREY,
            :stepsIcon => [
                App.loadResource(Rez.Drawables.steps_incomplete__base),
                App.loadResource(Rez.Drawables.steps_complete__base),
            ],
            :distanceIcon => App.loadResource(Rez.Drawables.distance__base),
            :floorsIcon => App.loadResource(Rez.Drawables.floors__base)
        };

        /* Theme defs */

        var tealTheme = {
            :textColorSecondary => COLOR_TEAL,
            :hourPattern => App.loadResource(Rez.Drawables.hourPattern__teal),
            :showHourPattern => true,
        };
        var redTheme = {
            :textColorPrimary => COLOR_RED,
            :textColorSecondary => COLOR_RED,
            :batteryIcon => [
                App.loadResource(Rez.Drawables.battery_5__red),
                App.loadResource(Rez.Drawables.battery_15__red),
                App.loadResource(Rez.Drawables.battery_25__red),
                App.loadResource(Rez.Drawables.battery_35__red),
                App.loadResource(Rez.Drawables.battery_45__red),
                App.loadResource(Rez.Drawables.battery_55__red),
                App.loadResource(Rez.Drawables.battery_65__red),
                App.loadResource(Rez.Drawables.battery_75__red),
                App.loadResource(Rez.Drawables.battery_85__red),
                App.loadResource(Rez.Drawables.battery_95__red)
            ],
            :hourPattern => App.loadResource(Rez.Drawables.hourPattern__red),
            :showHourPattern => false,
            :hrIcon => [
                App.loadResource(Rez.Drawables.hr__red),
                App.loadResource(Rez.Drawables.hr__red),
                App.loadResource(Rez.Drawables.hr__red),
                App.loadResource(Rez.Drawables.hr__red),
            ],
            :hrLabelColor => [
                COLOR_RED,
                COLOR_RED,
                COLOR_RED,
                COLOR_RED
            ],
            :stepRingIncompleteColor => COLOR_DARKRED,
            :stepRingCompleteColor => COLOR_RED,
            :stepsIcon => [
                App.loadResource(Rez.Drawables.steps__red),
                App.loadResource(Rez.Drawables.steps__red),
            ],
            :distanceIcon => App.loadResource(Rez.Drawables.distance__red),
            :floorsIcon => App.loadResource(Rez.Drawables.floors__red)
        };
        var blueTheme = {
            :textColorPrimary => COLOR_BLUE,
            :textColorSecondary => COLOR_BLUE,
            :batteryIcon => [
                App.loadResource(Rez.Drawables.battery_5__blue),
                App.loadResource(Rez.Drawables.battery_15__blue),
                App.loadResource(Rez.Drawables.battery_25__blue),
                App.loadResource(Rez.Drawables.battery_35__blue),
                App.loadResource(Rez.Drawables.battery_45__blue),
                App.loadResource(Rez.Drawables.battery_55__blue),
                App.loadResource(Rez.Drawables.battery_65__blue),
                App.loadResource(Rez.Drawables.battery_75__blue),
                App.loadResource(Rez.Drawables.battery_85__blue),
                App.loadResource(Rez.Drawables.battery_95__blue)
            ],
            :hourPattern => App.loadResource(Rez.Drawables.hourPattern__blue),
            :showHourPattern => false,
            :hrIcon => [
                App.loadResource(Rez.Drawables.hr__blue),
                App.loadResource(Rez.Drawables.hr__blue),
                App.loadResource(Rez.Drawables.hr__blue),
                App.loadResource(Rez.Drawables.hr__blue),
            ],
            :hrLabelColor => [
                COLOR_BLUE,
                COLOR_BLUE,
                COLOR_BLUE,
                COLOR_BLUE
            ],
            :stepRingIncompleteColor => COLOR_BLUE,
            :stepRingCompleteColor => COLOR_BLUE,
            :stepsIcon => [
                App.loadResource(Rez.Drawables.steps__blue),
                App.loadResource(Rez.Drawables.steps__blue),
            ],
            :distanceIcon => App.loadResource(Rez.Drawables.distance__blue),
            :floorsIcon => App.loadResource(Rez.Drawables.floors__blue)
        };

        var themeMap = {
            "teal" => tealTheme,
            "red" => redTheme,
            "blue" => blueTheme
        };

        // Monkey C has no way to combine/override dictionaries, like the spread operator in JS.
        // Garmin, Monkey C is a disaster :'(

        // Build a completely new object one key at a time I guess

        // Start with just the base theme
        var theTheme = baseTheme;

        // List the themed keys
        var themeKeys = themeMap[theme].keys();
        // For each key in the theme dict, overwrite it
        for(var i = 0; i < themeKeys.size(); i++) {
            theTheme[themeKeys[i]] = themeMap[theme][themeKeys[i]];
        }
        return theTheme;
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

        nightModeEnabled = isNightMode();
    }

    function onUpdate(dc) {
        updateData();
        dc.setColor(activeTheme[:textColorPrimary], Gfx.COLOR_BLACK);
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
        var isNight = (time.hour <= 5 || time.hour >= 23); // Night mode is between 11pm - 6am
        if(isNight) {
            // If it just switched to night mode, load the night theme
            if(!nightModeEnabled) {
                activeTheme = loadTheme(themeChoices["night"]);
            }
            nightModeEnabled = true; // update class var state
        }
        else {
            // If it just switched to day mode, load the day theme
            if(nightModeEnabled) {
                activeTheme = loadTheme(themeChoices["day"]);
            }
            nightModeEnabled = false; // update class var state
        }
        return isNight;
        
        // return (time.hour <= 7 || time.hour >= 23);
        // return false;
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
            
            var icon = activeTheme[:batteryIcon];
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
        
        var pattern = activeTheme[:hourPattern];
        var showPattern = activeTheme[:showHourPattern];

        var font = FONT_RAJ_BIG;

        // Hour
        if(showPattern == true) {
            dc.drawBitmap(
                hourPosX, 
                136,
                pattern
            );
            dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);
        }
        else {
            dc.setColor(activeTheme[:textColorSecondary], Gfx.COLOR_BLACK);
        }

        dc.drawText(
            hourPosX,
            109,
            FONT_RAJ_BIG, 
            hour, 
            Gfx.TEXT_JUSTIFY_LEFT
        );
        

        // Minute
        dc.setColor(activeTheme[:textColorSecondary], Gfx.COLOR_BLACK);

        dc.drawText(
            hourPosX + hourWidthInPx,
            109, 
            font, 
            time.min.format("%02d"), 
            Gfx.TEXT_JUSTIFY_LEFT
        );
        dc.setColor(activeTheme[:textColorPrimary], Gfx.COLOR_BLACK);

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
            if(steps >= stepGoal) {
                icon = activeTheme[:stepsIcon][1];
            }
            else {
                icon = activeTheme[:stepsIcon][0];
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
            var ringColor = activeTheme[:stepRingBaseColor];
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
            dc.setColor(activeTheme[:stepRingBaseColor], Gfx.COLOR_BLACK);
            dc.drawArc(ringX, ringY, ringRadius, Gfx.ARC_CLOCKWISE , 0, 360);
            if(steps > 0) {
                var x = ringX + ringRadius * Math.cos(Math.toRadians(-angle));
                var y = ringY + ringRadius * Math.sin(Math.toRadians(-angle));
                if(steps > stepGoal) {
                    ringColor = activeTheme[:stepRingCompleteColor];
                    dc.setColor(ringColor, Gfx.COLOR_BLACK);
                    dc.drawArc(ringX, ringY, ringRadius, Gfx.ARC_CLOCKWISE , 0, 360);
                }
                else {
                    ringColor = activeTheme[:stepRingIncompleteColor];
                    dc.setColor(ringColor, Gfx.COLOR_BLACK);
                    dc.fillCircle(ringX, ringY-ringRadius, 3);
                    dc.drawArc(ringX, ringY, ringRadius, Gfx.ARC_CLOCKWISE, top, angle);
                    dc.fillCircle(x, y, 3);
                }
            }
            dc.setColor(activeTheme[:textColorPrimary], Gfx.COLOR_BLACK);
        }
    }

    function drawStats(dc) {
        /** Stats **/
        if(!inLowPower) {
            var iconLeftPos = 221;
            var textLeftPos = iconLeftPos + 42;
            var hrTextColor;
            var icon = {
                :hr => activeTheme[:hrIcon],
                :distance => activeTheme[:distanceIcon],
                :floors => activeTheme[:floorsIcon]
            };
            // Heart rate
            var hrLabel = heartRate == null ? 0 : heartRate;
            if(hrLabel > 140) {
                icon[:hr] = activeTheme[:hrIcon][3];
                hrTextColor = activeTheme[:hrLabelColor][3];
            }
            else if(hrLabel > 110) {
                icon[:hr] = activeTheme[:hrIcon][2];
                hrTextColor = activeTheme[:hrLabelColor][2];
            }
            else if(hrLabel > 85) {
                icon[:hr] = activeTheme[:hrIcon][1];
                hrTextColor = activeTheme[:hrLabelColor][1];
            }
            else {
                icon[:hr] = activeTheme[:hrIcon][0];
                hrTextColor = activeTheme[:hrLabelColor][0];
            }

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
            dc.setColor(activeTheme[:textColorPrimary], Gfx.COLOR_BLACK);
            
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
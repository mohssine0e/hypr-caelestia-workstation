pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia

Singleton {
    id: root

    readonly property int workMinutes: 25
    readonly property int shortBreakMinutes: 5
    readonly property int longBreakMinutes: 15
    readonly property int longBreakEvery: 4

    property alias activeTool: state.activeTool
    property alias mode: state.mode
    property alias running: state.running
    property alias remaining: state.remaining
    property alias addedSeconds: state.addedSeconds
    property alias focusRounds: state.focusRounds
    property alias focusTitle: state.focusTitle
    property alias timerTitle: state.timerTitle
    property alias timerDuration: state.timerDuration
    property alias timerRemaining: state.timerRemaining
    property alias timerRunning: state.timerRunning
    property alias stopwatchElapsed: state.stopwatchElapsed
    property alias stopwatchRunning: state.stopwatchRunning
    property alias overlayHidden: state.hidden

    property bool attention: false
    property string attentionTitle: ""
    property string attentionBody: ""
    property string attentionIcon: "timer"
    property real stopwatchPulse: Date.now()

    readonly property int total: durationForMode(mode) + addedSeconds
    readonly property int activeTotal: activeTool === "stopwatch" ? Math.max(1, stopwatchElapsed) : activeTool === "timer" ? timerDuration : total
    readonly property int activeRemaining: activeTool === "stopwatch" ? stopwatchElapsed : activeTool === "timer" ? timerRemaining : remaining
    readonly property bool activeRunning: activeTool === "stopwatch" ? stopwatchRunning : activeTool === "timer" ? timerRunning : running
    readonly property bool hasActiveSession: attention || activeRunning || (activeTool === "stopwatch" ? stopwatchDisplayMs > 0 : activeRemaining !== activeTotal)
    readonly property real progress: activeTool === "stopwatch" ? 1 : activeTotal > 0 ? 1 - activeRemaining / activeTotal : 0
    readonly property string label: {
        if (mode === "work")
            return qsTr("Focus");
        if (mode === "longBreak")
            return qsTr("Long break");
        return qsTr("Break");
    }
    readonly property string shortLabel: activeTool === "stopwatch" ? "SW" : activeTool === "timer" ? "TM" : mode === "work" ? "FO" : mode === "longBreak" ? "LB" : "BR"
    readonly property string icon: activeTool === "stopwatch" ? "timer" : activeTool === "timer" ? "hourglass_top" : mode === "work" ? "timer" : mode === "longBreak" ? "self_improvement" : "coffee"
    readonly property string timeText: formatSeconds(activeRemaining)
    readonly property int stopwatchDisplayMs: stopwatchElapsed * 1000 + state.stopwatchMsRemainder + (stopwatchRunning ? Math.max(0, Math.floor(stopwatchPulse - state.lastTick)) : 0)
    readonly property string stopwatchTimeText: formatMilliseconds(stopwatchDisplayMs)
    readonly property string activeTitle: activeTool === "stopwatch" ? qsTr("Stopwatch") : activeTool === "timer" ? (timerTitle || qsTr("Timer")) : (focusTitle || label)
    readonly property string activeModeLabel: activeTool === "stopwatch" ? qsTr("Elapsed") : activeTool === "timer" ? qsTr("Timer") : label

    function durationForMode(nextMode: string): int {
        if (nextMode === "work")
            return workMinutes * 60;
        if (nextMode === "longBreak")
            return longBreakMinutes * 60;
        return shortBreakMinutes * 60;
    }

    function formatSeconds(seconds: int): string {
        const safe = Math.max(0, seconds);
        const hours = Math.floor(safe / 3600);
        const minutes = Math.floor((safe % 3600) / 60);
        const secs = safe % 60;
        if (hours > 0)
            return `${hours}:${minutes.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
        return `${minutes}:${secs.toString().padStart(2, "0")}`;
    }

    function formatStopwatch(seconds: int, milliseconds: int): string {
        return `${formatSeconds(seconds)}.${Math.floor(milliseconds / 10).toString().padStart(2, "0")}`;
    }

    function formatMilliseconds(milliseconds: int): string {
        const safe = Math.max(0, milliseconds);
        return formatStopwatch(Math.floor(safe / 1000), safe % 1000);
    }

    function parseDuration(input: string): int {
        const clean = input.trim();
        if (!clean)
            return 0;

        const parts = clean.split(":").map(p => Number(p));
        if (parts.some(p => !Number.isFinite(p) || p < 0))
            return 0;

        if (parts.length === 1)
            return Math.max(0, Math.round(parts[0] * 60));
        if (parts.length === 2)
            return Math.max(0, Math.round(parts[0] * 60 + parts[1]));
        if (parts.length === 3)
            return Math.max(0, Math.round(parts[0] * 3600 + parts[1] * 60 + parts[2]));
        return 0;
    }

    function saveTickTime(): void {
        state.lastTick = Date.now();
        stopwatchPulse = state.lastTick;
    }

    function captureStopwatchNow(): void {
        if (!stopwatchRunning)
            return;

        const delta = Math.max(0, Math.floor(Date.now() - state.lastTick));
        state.stopwatchMsRemainder += delta;
        stopwatchElapsed += Math.floor(state.stopwatchMsRemainder / 1000);
        state.stopwatchMsRemainder %= 1000;
        saveTickTime();
    }

    function activatePomodoro(): void {
        captureStopwatchNow();
        activeTool = "pomodoro";
        timerRunning = false;
        stopwatchRunning = false;
    }

    function activateTimer(): void {
        captureStopwatchNow();
        activeTool = "timer";
        running = false;
        stopwatchRunning = false;
    }

    function activateStopwatch(): void {
        activeTool = "stopwatch";
        running = false;
        timerRunning = false;
    }

    function setMode(nextMode: string): void {
        activatePomodoro();
        mode = nextMode;
        addedSeconds = 0;
        remaining = durationForMode(nextMode);
        running = false;
        saveTickTime();
    }

    function startPomodoro(title = ""): void {
        activatePomodoro();
        if (title)
            focusTitle = title;
        running = true;
        overlayHidden = false;
        saveTickTime();
    }

    function startPomodoroFor(title: string): void {
        focusTitle = title;
        setMode("work");
        startPomodoro(title);
    }

    function togglePomodoro(): void {
        activatePomodoro();
        running = !running;
        if (running)
            overlayHidden = false;
        saveTickTime();
    }

    function start(): void {
        startPomodoro(focusTitle);
    }

    function pause(): void {
        if (activeTool === "stopwatch") {
            captureStopwatchNow();
            stopwatchRunning = false;
        } else if (activeTool === "timer")
            timerRunning = false;
        else
            running = false;
        saveTickTime();
    }

    function toggle(): void {
        if (activeTool === "stopwatch")
            toggleStopwatch();
        else if (activeTool === "timer")
            toggleTimer();
        else
            togglePomodoro();
    }

    function showOverlay(): void {
        overlayHidden = false;
    }

    function hideOverlay(): void {
        overlayHidden = true;
    }

    function resetPomodoro(): void {
        addedSeconds = 0;
        remaining = durationForMode(mode);
        running = false;
        if (mode === "work")
            focusTitle = "";
        saveTickTime();
    }

    function reset(): void {
        if (activeTool === "stopwatch")
            resetStopwatch();
        else if (activeTool === "timer")
            resetTimer();
        else
            resetPomodoro();
    }

    function resetRounds(): void {
        focusRounds = 0;
    }

    function addMinutes(minutes: int): void {
        if (activeTool === "stopwatch")
            return;

        if (activeTool === "timer") {
            addTimerMinutes(minutes);
            return;
        }

        const seconds = Math.max(1, minutes) * 60;
        addedSeconds += seconds;
        remaining += seconds;
        saveTickTime();
    }

    function configureTimer(title: string, seconds: int): bool {
        const safeSeconds = Math.max(60, seconds);
        timerTitle = title.trim() || qsTr("Timer");
        timerDuration = safeSeconds;
        timerRemaining = safeSeconds;
        timerRunning = false;
        activeTool = "timer";
        saveTickTime();
        return true;
    }

    function startTimer(title: string, seconds: int): void {
        configureTimer(title, seconds);
        activateTimer();
        timerRunning = true;
        overlayHidden = false;
        saveTickTime();
    }

    function startTimerFromInput(title: string, durationText: string): bool {
        const seconds = parseDuration(durationText);
        if (seconds <= 0)
            return false;
        startTimer(title, seconds);
        return true;
    }

    function startTimerFor(title: string, minutes = 30): void {
        startTimer(title, Math.max(1, minutes) * 60);
    }

    function toggleTimer(): void {
        activateTimer();
        timerRunning = !timerRunning;
        if (timerRunning)
            overlayHidden = false;
        saveTickTime();
    }

    function resetTimer(): void {
        timerRunning = false;
        timerRemaining = timerDuration;
        saveTickTime();
    }

    function addTimerMinutes(minutes: int): void {
        const seconds = Math.max(1, minutes) * 60;
        timerDuration += seconds;
        timerRemaining += seconds;
        activeTool = "timer";
        saveTickTime();
    }

    function startStopwatch(): void {
        activateStopwatch();
        stopwatchRunning = true;
        overlayHidden = false;
        saveTickTime();
    }

    function toggleStopwatch(): void {
        activateStopwatch();
        if (stopwatchRunning) {
            captureStopwatchNow();
            stopwatchRunning = false;
        } else {
            stopwatchRunning = true;
            overlayHidden = false;
        }
        saveTickTime();
    }

    function resetStopwatch(): void {
        stopwatchRunning = false;
        stopwatchElapsed = 0;
        state.stopwatchMsRemainder = 0;
        activeTool = "stopwatch";
        saveTickTime();
    }

    function playFinishSound(): void {
        Quickshell.execDetached(["sh", "-c", "sound=/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga; [ -r \"$sound\" ] || sound=/usr/share/sounds/freedesktop/stereo/complete.oga; if command -v paplay >/dev/null 2>&1; then paplay \"$sound\"; elif command -v pw-play >/dev/null 2>&1; then pw-play \"$sound\"; fi"]);
    }

    function announceFinish(title: string, body: string, alertIcon: string): void {
        attentionTitle = title;
        attentionBody = body;
        attentionIcon = alertIcon;
        attention = true;
        overlayHidden = false;
        attentionTimer.restart();

        playFinishSound();
        Toaster.toast(title, body, alertIcon, Toast.Warning);
        Quickshell.execDetached(["notify-send", "-a", "Focus", "-u", "critical", "-t", "10000", "-i", "appointment-soon", title, body]);
    }

    function skip(): void {
        if (activeTool === "timer") {
            finishTimer(true);
            return;
        }
        finishPhase(false);
    }

    function finishTimer(showToast = true): void {
        timerRemaining = 0;
        timerRunning = false;
        activeTool = "timer";
        saveTickTime();

        if (showToast)
            announceFinish(qsTr("Timer complete"), timerTitle || qsTr("Your timer finished."), "hourglass_empty");
    }

    function finishPhase(showToast = true): void {
        const finishedMode = mode;

        if (finishedMode === "work") {
            focusRounds++;
            mode = focusRounds % longBreakEvery === 0 ? "longBreak" : "shortBreak";
            focusTitle = "";
        } else {
            mode = "work";
        }

        addedSeconds = 0;
        remaining = durationForMode(mode);
        running = false;
        activeTool = "pomodoro";
        saveTickTime();

        if (showToast) {
            const title = finishedMode === "work" ? qsTr("Focus complete") : qsTr("Break complete");
            const body = mode === "work" ? qsTr("Ready for the next focus block.") : qsTr("Time to take %1.").arg(mode === "longBreak" ? qsTr("a long break") : qsTr("a short break"));
            announceFinish(title, body, finishedMode === "work" ? "timer" : "coffee");
        }
    }

    function tickOneSecond(): void {
        if (running) {
            if (remaining > 1)
                remaining--;
            else {
                remaining = 0;
                finishPhase(true);
            }
        }

        if (timerRunning) {
            if (timerRemaining > 1)
                timerRemaining--;
            else
                finishTimer(true);
        }

        if (stopwatchRunning)
            stopwatchElapsed++;

        saveTickTime();
    }

    function restoreElapsed(): void {
        const elapsed = Math.floor((Date.now() - state.lastTick) / 1000);
        if (elapsed <= 0)
            return;

        if (running) {
            if (elapsed >= remaining) {
                remaining = 0;
                finishPhase(true);
            } else {
                remaining -= elapsed;
            }
        }

        if (timerRunning) {
            if (elapsed >= timerRemaining) {
                timerRemaining = 0;
                finishTimer(true);
            } else {
                timerRemaining -= elapsed;
            }
        }

        if (stopwatchRunning)
            stopwatchElapsed += elapsed;

        saveTickTime();
    }

    Component.onCompleted: restoreElapsed()

    PersistentProperties {
        id: state

        property string activeTool: "pomodoro"
        property string mode: "work"
        property bool running: false
        property int remaining: 1500
        property int addedSeconds: 0
        property int focusRounds: 0
        property string focusTitle: ""
        property string timerTitle: "Timer"
        property int timerDuration: 900
        property int timerRemaining: 900
        property bool timerRunning: false
        property int stopwatchElapsed: 0
        property int stopwatchMsRemainder: 0
        property bool stopwatchRunning: false
        property bool hidden: false
        property real lastTick: Date.now()

        reloadableId: "focusState"
    }

    Timer {
        interval: 1000
        running: root.running || root.timerRunning || root.stopwatchRunning
        repeat: true
        onTriggered: root.tickOneSecond()
    }

    Timer {
        interval: 100
        running: root.stopwatchRunning
        repeat: true
        onTriggered: root.stopwatchPulse = Date.now()
    }

    Timer {
        id: attentionTimer

        interval: 10000
        onTriggered: root.attention = false
    }

    IpcHandler {
        function toggle(): void {
            root.toggle();
        }

        function start(): void {
            root.start();
        }

        function pause(): void {
            root.pause();
        }

        function showOverlay(): void {
            root.showOverlay();
        }

        function hideOverlay(): void {
            root.hideOverlay();
        }

        function reset(): void {
            root.reset();
        }

        function resetStopwatch(): void {
            root.resetStopwatch();
        }

        function resetRounds(): void {
            root.resetRounds();
        }

        function addMinutes(minutes: int): void {
            root.addMinutes(minutes);
        }

        function skip(): void {
            root.skip();
        }

        target: "pomodoro"
    }
}

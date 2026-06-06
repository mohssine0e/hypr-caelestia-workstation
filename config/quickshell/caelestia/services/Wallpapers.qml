pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.Config
import Caelestia.Models
import qs.services
import qs.utils

Searcher {
    id: root

    readonly property string currentNamePath: `${Paths.state}/wallpaper/path.txt`
    readonly property list<string> smartArg: GlobalConfig.services.smartScheme ? [] : ["--no-smart"]

    property bool showPreview: false
    readonly property string current: showPreview ? previewPath : actualCurrent
    property string previewPath
    property string actualCurrent
    property bool previewColourLock
    property string importTarget
    property string deleteTarget
    property string deleteReplacement

    function setWallpaper(path: string): void {
        actualCurrent = path;
        Quickshell.execDetached(["caelestia", "wallpaper", "-f", path, ...smartArg]);
    }

    function basename(path: string): string {
        return String(path).split("/").filter(Boolean).pop() ?? `wallpaper-${Date.now()}.jpg`;
    }

    function safeName(path: string): string {
        const name = basename(path).replace(/[^A-Za-z0-9._-]/g, "_");
        return name.length > 0 ? name : `wallpaper-${Date.now()}.jpg`;
    }

    function isLibraryWallpaper(path: string): bool {
        const dir = Paths.wallsdir.endsWith("/") ? Paths.wallsdir : `${Paths.wallsdir}/`;
        return String(path).startsWith(dir);
    }

    function importWallpaper(path: string): void {
        if (!path)
            return;

        if (isLibraryWallpaper(path)) {
            setWallpaper(path);
            return;
        }

        importTarget = `${Paths.wallsdir}/${Date.now()}-${safeName(path)}`;
        importProc.command = ["bash", "-lc", "mkdir -p \"$1\" && cp -- \"$2\" \"$3\"", "caelestia-wallpaper-import", Paths.wallsdir, path, importTarget];
        importProc.running = true;
    }

    function deleteWallpaper(path: string): void {
        if (!isLibraryWallpaper(path))
            return;

        deleteTarget = path;
        deleteReplacement = "";

        if (path === actualCurrent) {
            for (const wall of list) {
                if (wall.path !== path) {
                    deleteReplacement = wall.path;
                    break;
                }
            }
        }

        deleteProc.command = ["rm", "-f", "--", path];
        deleteProc.running = true;
    }

    function preview(path: string): void {
        previewPath = path;
        showPreview = true;

        if (Colours.scheme === "dynamic")
            getPreviewColoursProc.running = true;
    }

    function stopPreview(): void {
        showPreview = false;
        if (!previewColourLock)
            Colours.showPreview = false;
    }

    list: wallpapers.entries
    key: "relativePath"
    useFuzzy: GlobalConfig.launcher.useFuzzy.wallpapers
    extraOpts: useFuzzy ? ({}) : ({
            forward: false
        })

    IpcHandler {
        function get(): string {
            return root.actualCurrent;
        }

        function set(path: string): void {
            root.setWallpaper(path);
        }

        function list(): string {
            return root.list.map(w => w.path).join("\n");
        }

        target: "wallpaper"
    }

    FileView {
        path: root.currentNamePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.actualCurrent = text().trim();
            root.previewColourLock = false;
        }
    }

    FileSystemModel {
        id: wallpapers

        recursive: true
        path: Paths.wallsdir
        filter: FileSystemModel.Images
    }

    Process {
        id: getPreviewColoursProc

        command: ["caelestia", "wallpaper", "-p", root.previewPath, ...root.smartArg]
        stdout: StdioCollector {
            onStreamFinished: {
                Colours.load(text, true);
                Colours.showPreview = true;
            }
        }
    }

    Process {
        id: importProc

        onExited: code => { // qmllint disable signal-handler-parameters
            if (code === 0 && root.importTarget)
                root.setWallpaper(root.importTarget);
            root.importTarget = "";
        }
    }

    Process {
        id: deleteProc

        onExited: code => { // qmllint disable signal-handler-parameters
            if (code === 0 && root.deleteTarget === root.actualCurrent) {
                if (root.deleteReplacement)
                    root.setWallpaper(root.deleteReplacement);
                else
                    root.actualCurrent = "";
            }

            root.deleteTarget = "";
            root.deleteReplacement = "";
        }
    }
}

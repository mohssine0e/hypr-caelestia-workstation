import "./state"
import QtQuick
import qs.modules.controlcenter

QtObject {
    readonly property list<string> panes: PaneRegistry.labels

    required property var root
    property bool floating: false
    property string active: "appearance"
    property int activeIndex: 0
    property bool navExpanded: false

    readonly property BluetoothState bt: BluetoothState {}
    readonly property NetworkState network: NetworkState {}
    readonly property EthernetState ethernet: EthernetState {}
    readonly property LauncherState launcher: LauncherState {}
    readonly property VpnState vpn: VpnState {}

    onActiveChanged: {
        const index = panes.indexOf(active);
        if (index >= 0) {
            activeIndex = index;
        } else if (panes.length > 0) {
            active = panes[0];
        }
    }
    onActiveIndexChanged: if (panes[activeIndex])
        active = panes[activeIndex]
}

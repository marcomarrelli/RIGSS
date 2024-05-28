pragma Singleton

import QtQuick 2.15
import QtQuick.Window 2.15

QtObject {
    id: theme

    property int mode: Theme.Mode.Dark

    property color text: theme.getColorFromMode().text
    property color light: theme.getColorFromMode().light
    property color mid: theme.getColorFromMode().mid
    property color dark: theme.getColorFromMode().dark
    property color border: theme.getColorFromMode().border
    property color highlight: theme.getColorFromMode().highlight

    function getColorFromMode(mode = theme.mode) {
        switch(mode) {
            case Theme.Mode.Light: return {
                "text": "#151515",
                "light": "#DDDDDD",
                "mid": "#C4C4C4",
                "dark": "#9C9C9C",
                "border": "#121212", // "#EDEDED"
                "highlight": "#FFA652"
            }
            case Theme.Mode.Dark: return {
                "text": "#EAEAEA",
                "light": "#636363",
                "mid": "#3B3B3B",
                "dark": "#222222",
                "border": "#121212",
                "highlight": "#FF8D21"
            }
        }
    }

    function isDarkMode() {
        return theme.mode === Theme.Mode.Dark    
    }

    function switchMode(mode = -1) {
        if(mode === -1) {
            if(theme.mode === Theme.Mode.Light) theme.mode = Theme.Mode.Dark
            else theme.mode = Theme.Mode.Light 
            
            return
        }

        theme.mode = mode
    }

    enum Mode {
        Light,
        Dark
    }

    onModeChanged: {
        theme.text = theme.getColorFromMode().text
        theme.light = theme.getColorFromMode().light
        theme.mid = theme.getColorFromMode().mid
        theme.dark = theme.getColorFromMode().dark
        theme.border = theme.getColorFromMode().border
        theme.highlight = theme.getColorFromMode().highlight
    }
}

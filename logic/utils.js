function perc(num, perc) {
    return (num*(perc/100))
}

function getIcon(code) {
    return String.fromCodePoint(code)
}

function exists(component) {
    return ((component !== undefined) && (component !== null))
}

function existsEvery(...components) {
    return components.every(c => exists(c))
}
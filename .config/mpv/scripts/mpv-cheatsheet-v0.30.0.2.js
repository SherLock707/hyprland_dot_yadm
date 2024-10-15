(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
// referene: http://docs.aegisub.org/3.2/ASS_Tags/
// based on mpv's assdraw.lua

var c = 0.551915024494 // circle approximation

function Assdraw() {
  this.scale = 4;
  this.text = ""
}

Assdraw.SMART_WRAPPING = 0
Assdraw.EOL_WRAPPING = 1
Assdraw.NO_WORD_WRAPPING = 2
Assdraw.SMART_WRAPPING_WIDER = 3
Assdraw.BOTTOM_LEFT = 1
Assdraw.BOTTOM_CENTER = 2
Assdraw.BOTTOM_RIGHT = 3
Assdraw.MIDDLE_LEFT = 4
Assdraw.MIDDLE_CENTER = 5
Assdraw.MIDDLE_RIGHT = 6
Assdraw.TOP_LEFT = 7
Assdraw.TOP_CENTER = 8
Assdraw.TOP_RIGHT = 9

Assdraw.escape = function(s) {
  return s.replace(/([{}])/g, "\\$1")
}

Assdraw.bolden = function(s) {
  return '{\\b1}' + s + '{\\b0}'
}

Assdraw.prototype.newEvent = function() {
  // osd_libass.c adds an event per line
  if (this.text.length > 0) {
    this.text = this.text + "\n"
  }
}

Assdraw.prototype.override = function(callback) {
  this.append('{')
  callback.call(this);
  this.append('}')
}

Assdraw.prototype.primaryFillColor = function(hex) {
  this.append('\\1c&H' + hex + '&')
  return this;
}

Assdraw.prototype.secondaryFillColor = function(hex) {
  this.append('\\2c&H' + hex + '&')
  return this;
}

Assdraw.prototype.borderColor = function(hex) {
  this.append('\\3c&H' + hex + '&')
  return this;
}

Assdraw.prototype.shadowColor = function(hex) {
  this.append('\\4c&H' + hex + '&')
  return this;
}

Assdraw.prototype.primaryFillAlpha = function(hex) {
  this.append('\\1a&H' + hex + '&')
  return this;
}

Assdraw.prototype.secondaryFillAlpha = function(hex) {
  this.append('\\2a&H' + hex + '&')
  return this;
}

Assdraw.prototype.borderAlpha = function(hex) {
  this.append('\\3a&H' + hex + '&')
  return this;
}

Assdraw.prototype.shadowAlpha = function(hex) {
  this.append('\\4a&H' + hex + '&')
  return this;
}

Assdraw.prototype.fontName = function(s) {
  this.append('\\fn' + s)
  return this;
}

Assdraw.prototype.fontSize = function(s) {
  this.append('\\fs' + s)
  return this;
}

Assdraw.prototype.borderSize = function(n) {
  this.append('\\bord' + n)
  return this;
}

Assdraw.prototype.xShadowDistance = function(n) {
  this.append('\\xshad' + n)
  return this;
}

Assdraw.prototype.yShadowDistance = function(n) {
  this.append('\\yshad' + n)
  return this;
}

Assdraw.prototype.letterSpacing = function(n) {
  this.append('\\fsp' + n)
  return this;
}

Assdraw.prototype.wrapStyle = function(n) {
  this.append('\\q' + n)
  return this;
}

Assdraw.prototype.drawStart = function() {
  this.text = this.text + "{\\p"+ this.scale + "}"
}

Assdraw.prototype.drawStop = function() {
  this.text = this.text + "{\\p0}"
}

Assdraw.prototype.coord = function(x, y) {
  var scale = Math.pow(2, (this.scale - 1))
  var ix = Math.ceil(x * scale)
  var iy = Math.ceil(y * scale)
  this.text = this.text + " " + ix + " " + iy
}

Assdraw.prototype.append = function(s) {
  this.text = this.text + s
}

Assdraw.prototype.appendLn = function(s) {
  this.append(s + '\\n')
}

Assdraw.prototype.appendLN = function(s) {
  this.append(s + '\\N')
}

Assdraw.prototype.merge = function(other) {
  this.text = this.text + other.text
}

Assdraw.prototype.pos = function(x, y) {
  this.append("\\pos(" + x.toFixed(0) + "," + y.toFixed(0) + ")")
}

Assdraw.prototype.lineAlignment = function(an) {
  this.append("\\an" + an)
}

Assdraw.prototype.moveTo = function(x, y) {
  this.append(" m")
  this.coord(x, y)
}

Assdraw.prototype.lineTo = function(x, y) {
  this.append(" l")
  this.coord(x, y)
}

Assdraw.prototype.bezierCurve = function(x1, y1, x2, y2, x3, y3) {
  this.append(" b")
  this.coord(x1, y1)
  this.coord(x2, y2)
  this.coord(x3, y3)
}


Assdraw.prototype.rectCcw = function(x0, y0, x1, y1) {
  this.moveTo(x0, y0)
  this.lineTo(x0, y1)
  this.lineTo(x1, y1)
  this.lineTo(x1, y0)
}

Assdraw.prototype.rectCw = function(x0, y0, x1, y1) {
  this.moveTo(x0, y0)
  this.lineTo(x1, y0)
  this.lineTo(x1, y1)
  this.lineTo(x0, y1)
}

Assdraw.prototype.hexagonCw = function(x0, y0, x1, y1, r1, r2) {
  if (typeof r2 === 'undefined') {
    r2 = r1
  }
  this.moveTo(x0 + r1, y0)
  if (x0 != x1) {
    this.lineTo(x1 - r2, y0)
  }
  this.lineTo(x1, y0 + r2)
  if (x0 != x1) {
    this.lineTo(x1 - r2, y1)
  }
  this.lineTo(x0 + r1, y1)
  this.lineTo(x0, y0 + r1)
}

Assdraw.prototype.hexagonCcw = function(x0, y0, x1, y1, r1, r2) {
  if (typeof r2 === 'undefined') {
    r2 = r1
  }
  this.moveTo(x0 + r1, y0)
  this.lineTo(x0, y0 + r1)
  this.lineTo(x0 + r1, y1)
  if (x0 != x1) {
    this.lineTo(x1 - r2, y1)
  }
  this.lineTo(x1, y0 + r2)
  if (x0 != x1) {
    this.lineTo(x1 - r2, y0)
  }
}

Assdraw.prototype.roundRectCw = function(ass, x0, y0, x1, y1, r1, r2) {
  if (typeof r2 === 'undefined') {
    r2 = r1
  }
  var c1 = c * r1 // circle approximation
  var c2 = c * r2 // circle approximation
  this.moveTo(x0 + r1, y0)
  this.lineTo(x1 - r2, y0) // top line
  if (r2 > 0) {
    this.bezierCurve(x1 - r2 + c2, y0, x1, y0 + r2 - c2, x1, y0 + r2) // top right corner
  }
  this.lineTo(x1, y1 - r2) // right line
  if (r2 > 0) {
    this.bezierCurve(x1, y1 - r2 + c2, x1 - r2 + c2, y1, x1 - r2, y1) // bottom right corner
  }
  this.lineTo(x0 + r1, y1) // bottom line
  if (r1 > 0) {
    this.bezierCurve(x0 + r1 - c1, y1, x0, y1 - r1 + c1, x0, y1 - r1) // bottom left corner
  }
  this.lineTo(x0, y0 + r1) // left line
  if (r1 > 0) {
    this.bezierCurve(x0, y0 + r1 - c1, x0 + r1 - c1, y0, x0 + r1, y0) // top left corner
  }
}

Assdraw.prototype.roundRectCcw = function(ass, x0, y0, x1, y1, r1, r2) {
  if (typeof r2 === 'undefined') {
    r2 = r1
  }
  var c1 = c * r1 // circle approximation
  var c2 = c * r2 // circle approximation
  this.moveTo(x0 + r1, y0)
  if (r1 > 0) {
    this.bezierCurve(x0 + r1 - c1, y0, x0, y0 + r1 - c1, x0, y0 + r1) // top left corner
  }
  this.lineTo(x0, y1 - r1) // left line
  if (r1 > 0) {
    this.bezierCurve(x0, y1 - r1 + c1, x0 + r1 - c1, y1, x0 + r1, y1) // bottom left corner
  }
  this.lineTo(x1 - r2, y1) // bottom line
  if (r2 > 0) {
    this.bezierCurve(x1 - r2 + c2, y1, x1, y1 - r2 + c2, x1, y1 - r2) // bottom right corner
  }
  this.lineTo(x1, y0 + r2) // right line
  if (r2 > 0) {
    this.bezierCurve(x1, y0 + r2 - c2, x1 - r2 + c2, y0, x1 - r2, y0) // top right corner
  }
}

module.exports = Assdraw

},{}],2:[function(require,module,exports){
var assdraw = require('./assdraw.js')
var shortcuts = [
  {
    category: 'Navigation',
    shortcuts: [
      {keys: ', / .', effect: 'Seek by frame'},
      {keys: '← / →', effect: 'Seek by 5 seconds'},
      {keys: '↓ / ↑', effect: 'Seek by 1 minute'},
      {keys: '[Shift] PGDWN / PGUP', effect: 'Seek by 10 minutes'},
      {keys: '[Shift] ← / →', effect: 'Seek by 1 second (exact)'},
      {keys: '[Shift] ↓ / ↑', effect: 'Seek by 5 seconds (exact)'},
      {keys: '[Ctrl] ← / →', effect: 'Seek by subtitle'},
      {keys: '[Shift] BACKSPACE', effect: 'Undo last seek'},
      {keys: '[Ctrl+Shift] BACKSPACE', effect: 'Mark current position'},
      {keys: 'l', effect: 'Set/clear A-B loop points'},
      {keys: 'L', effect: 'Toggle infinite looping'},
      {keys: 'PGDWN / PGUP', effect: 'Previous/next chapter'},
      {keys: '< / >', effect: 'Go backward/forward in the playlist'},
      {keys: 'ENTER', effect: 'Go forward in the playlist'},
      {keys: 'F8', effect: 'Show playlist [UI]'},
    ]
  },
  {
    category: 'Playback',
    shortcuts: [
      {keys: 'p / SPACE', effect: 'Pause/unpause'},
      {keys: '[ / ]', effect: 'Decrease/increase speed [10%]'},
      {keys: '{ / }', effect: 'Halve/double speed'},
      {keys: 'BACKSPACE', effect: 'Reset speed'},
      {keys: 'o / P', effect: 'Show progress'},
      {keys: 'O', effect: 'Toggle progress'},
      {keys: 'i / I', effect: 'Show/toggle stats'},
    ]
  },
  {
    category: 'Subtitle',
    shortcuts: [
      {keys: '[Ctrl+Shift] ← / →', effect: 'Adjust subtitle delay [subtitle]'},
      {keys: 'z / Z', effect: 'Adjust subtitle delay [0.1sec]'},
      {keys: 'v', effect: 'Toggle subtitle visibility'},
      {keys: 'u', effect: 'Toggle subtitle style overrides'},
      {keys: 'V', effect: 'Toggle subtitle VSFilter aspect compatibility mode'},
      {keys: 'r / R', effect: 'Move subtitles up/down'},
      {keys: 'j / J', effect: 'Cycle subtitle'},
      {keys: 'F9', effect: 'Show audio/subtitle list [UI]'},
    ]
  },
  {
    category: 'Audio',
    shortcuts: [
      {keys: 'm', effect: 'Mute sound'},
      {keys: '#', effect: 'Cycle audio track'},
      {keys: '/ / *', effect: 'Decrease/increase volume'},
      {keys: '9 / 0', effect: 'Decrease/increase volume'},
      {keys: '[Ctrl] - / +', effect: 'Decrease/increase audio delay [0.1sec]'},
      {keys: 'F9', effect: 'Show audio/subtitle list [UI]'},
    ]
  },
  {
    category: 'Video',
    shortcuts: [
      {keys: '_', effect: 'Cycle video track'},
      {keys: 'A', effect: 'Cycle aspect ratio'},
      {keys: 'd', effect: 'Toggle deinterlacer'},
      {keys: '[Ctrl] h', effect: 'Toggle hardware video decoding'},
      {keys: 'w / W', effect: 'Decrease/increase pan-and-scan range'},
      {keys: '[Alt] - / +', effect: 'Zoom out/in'},
      {keys: '[Alt] ARROWS', effect: 'Move the video rectangle'},
      {keys: '[Alt] BACKSPACE', effect: 'Reset pan/zoom'},
      {keys: '1 / 2', effect: 'Decrease/increase contrast'},
      {keys: '3 / 4', effect: 'Decrease/increase brightness'},
      {keys: '5 / 6', effect: 'Decrease/increase gamma'},
      {keys: '7 / 8', effect: 'Decrease/increase saturation'},
    ]
  },
  {
    category: 'Application',
    shortcuts: [
      {keys: 'q', effect: 'Quit'},
      {keys: 'Q', effect: 'Save position and quit'},
      {keys: 's', effect: 'Take a screenshot'},
      {keys: 'S', effect: 'Take a screenshot without subtitles'},
      {keys: '[Ctrl] s', effect: 'Take a screenshot as rendered'},
    ]
  },
  {
    category: 'Window',
    shortcuts: [
      {keys: 'f', effect: 'Toggle fullscreen'},
      {keys: '[Command] f', effect: 'Toggle fullscreen [macOS]'},
      {keys: 'ESC', effect: 'Exit fullscreen'},
      {keys: 'T', effect: 'Toggle stay-on-top'},
      {keys: '[Alt] 0', effect: 'Resize window to 0.5x [macOS]'},
      {keys: '[Alt] 1', effect: 'Reset window size [macOS]'},
      {keys: '[Alt] 2', effect: 'Resize window to 2x [macOS]'},
    ]
  },
  {
    category: 'Multimedia keys',
    shortcuts: [
      {keys: 'PAUSE', effect: 'Pause'}, // keyboard with multimedia keys
      {keys: 'STOP', effect: 'Quit'}, // keyboard with multimedia keys
      {keys: 'PREVIOUS / NEXT', effect: 'Seek 1 minute'}, // keyboard with multimedia keys
    ]
  },
]

var State = {
  active: false,
  startLine: 0,
  startCategory: 0
}

var opts = {
  font: 'monospace',
  'font-size': 8,
  'usage-font-size': 6,
}

function repeat(s, num) {
  var ret = '';
  for (var i = 0; i < num; i++) {
    ret = ret + s;
  }
  return ret;
}

function renderCategory(category) {
  var lines = []
  lines.push(assdraw.bolden(category.category))
  var maxKeysLength = 0;
  category.shortcuts.forEach(function(shortcut) {
    if (shortcut.keys.length > maxKeysLength) maxKeysLength = shortcut.keys.length
  })
  category.shortcuts.forEach(function(shortcut) {
    var padding = repeat(" ", maxKeysLength - shortcut.keys.length)
    lines.push(assdraw.escape(shortcut.keys + padding + " " + shortcut.effect))
  })
  return lines
}

function render() {
  var screen = mp.get_osd_size()
  if (!State.active) {
    mp.set_osd_ass(0, 0, '{}')
    return
  }
  var ass = new assdraw()
  ass.newEvent()
  ass.override(function() {
    this.lineAlignment(assdraw.TOP_LEFT)
    this.primaryFillAlpha('00')
    this.borderAlpha('00')
    this.shadowAlpha('99')
    this.primaryFillColor('eeeeee')
    this.borderColor('111111')
    this.shadowColor('000000')
    this.fontName(opts.font)
    this.fontSize(opts['font-size'])
    this.borderSize(1)
    this.xShadowDistance(0)
    this.yShadowDistance(1)
    this.letterSpacing(0)
    this.wrapStyle(assdraw.EOL_WRAPPING)
  })
  var mainLines = [];
  var pushedCategory = false
  shortcuts.forEach(function(category, i) {
    if (i < State.startCategory) {
      return;
    }
    pushedCategory = true;
    if (pushedCategory) {
      mainLines.push("")
    }
    mainLines.push.apply(mainLines, renderCategory(category))
  })
  mainLines.slice(State.startLine).forEach(function(line) {
    ass.appendLN(line);
  })

  ass.newEvent()
  var sideLines = renderCategory({
    category: 'usage',
    shortcuts: Keybindings
  })
  ass.override(function() {
    this.lineAlignment(assdraw.TOP_RIGHT)
    this.fontSize(opts['usage-font-size'])
  })
  sideLines.forEach(function(line) {
    ass.appendLN(line);
  })

  mp.set_osd_ass(0, 0, ass.text)
}

function setActive(active) {
  if (active == State.active) return
  if (active) {
    State.active = true
    updateBindings(Keybindings, true)
  } else {
    State.active = false
    updateBindings(Keybindings, false)
  }
  render()
}

function updateBindings(bindings, enable) {
  bindings.forEach(function(binding, i) {
    var name = '__cheatsheet_binding_' + i
    if (enable) {
      mp.add_forced_key_binding(binding.keys, name, binding.callback, binding.options)
    } else {
      mp.remove_key_binding(name)
    }
  })
}

var Keybindings = [
  {
    keys: 'esc',
    effect: 'close',
    callback: function() { setActive(false) }
  },
  {
    keys: '?',
    effect: 'close',
    callback: function() { setActive(false) }
  },
  {
    keys: 'j',
    effect: 'next line',
    callback: function() {
      State.startLine += 1
      render()
    },
    options: 'repeatable'
  },
  {
    keys: 'k',
    effect: 'prev line',
    callback: function() {
      State.startLine = Math.max(0, State.startine - 1)
      render()
    },
    options: 'repeatable'
  },
  {
    keys: 'n',
    effect: 'next category',
    callback: function() {
      State.startCategory += 1
      State.startLine = 0
      render()
    },
    options: 'repeatable'
  },
  {
    keys: 'p',
    effect: 'prev category',
    callback: function() {
      State.startCategory = Math.max(0, State.startCategory - 1)
      State.startLine = 0
      render()
    },
    options: 'repeatable'
  },
]

mp.add_key_binding('?', 'cheatsheet-enable', function() { setActive(true) })

mp.observe_property('osd-width', 'native', render)
mp.observe_property('osd-height', 'native', render)

},{"./assdraw.js":1}]},{},[2]);

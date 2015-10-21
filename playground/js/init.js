"use strict";

function init() {
  var Rx            = App.Rx;
  var Morse         = App.Morse;
  var beep_button   = document.querySelector("#beep");
  var play_button   = document.querySelector("#play");
  var clear_btn     = document.querySelector("#clear");
  var code_textarea = document.querySelector('#code');
  var char_textarea = document.querySelector('#char');
  var pd            = typeof window.ontouchstart === "object" ? false : true;
  var p_end         = pd ? "mouseup"   : "touchend";
  var p_start       = pd ? "mousedown" : "touchstart";

  var fromCommandStringToBeep = (function()  {
    var ac = window.AudioContext
      ? new AudioContext()
      : new webkitAudioContext();
    var _osc;
    var _gain;
    var _tid = null;

    var create = function() {
      _gain = ac.createGain();
      _osc = ac.createOscillator();

      _osc.frequency.value = 880;
      _osc.connect(_gain);
      _gain.gain.value = 0.125;
      _gain.connect(ac.destination);
    };

    return function(message) {
      if(!_tid && message === "DOWN") {
        create();
        _osc.start()

        _tid = setTimeout(function() {
          _tid = null;
          _osc.stop()
        }, 1000)
      }

      if(_tid && (message === "UP" || message === "WINDOW_BLUR")) {
        clearTimeout(_tid);
        _tid = null;
        _osc.stop()
      }

      return message;
    }
  })();

  var playBeep = (function() {
    var _buffer = [];
    var _tid = null;

    return function(message) {
      if(_tid) {
        fromCommandStringToBeep("UP");
        clearInterval(_tid);
        _tid = null;
        return;
      }

      if(message !== "DOWN") {
        return;
      }

      _buffer = [].concat.apply(
        [],
        code_textarea.value
        .split("")
        .map(function(value) {
          return value === "."
            ? ["DOWN", "UP", "MUTE"]
            : value === "_"
              ? ["DOWN", "MUTE", "MUTE", "UP", "MUTE"]
              : ["MUTE", "MUTE", "MUTE", "MUTE"]
        })
      );

      _tid = setInterval(function() {
        if(_buffer.length === 1) {
          clearInterval(_tid);
          _tid = null;
        }

        fromCommandStringToBeep(_buffer.shift())
      }, 50);
    };
  })();

  var convertFrom = function(mode) {
    return function(event) {
      (mode === "char" ? code_textarea : char_textarea)
      .value = event.srcElement.value
      .split(mode === "char" ? "" : " ")
      .map(function(value) {
        var output_string = mode === "char"
          ? Morse.CHAR_TO_MORSE[value.toLowerCase()]
          : Morse.MORSE_TO_CHAR[value];

        return typeof output_string === "undefined"
          ? "?"
          : output_string;
      })
      .join(mode === "char" ? " " : "");
    };
  };

  var show = (function() {
    var _buffer   = [];
    var _previous = "";

    return function(value) {
      code_textarea.value += value;

      if(value === " " && _previous === " ") {
        _buffer = [];
        char_textarea.value += " ";
        return;
      }

      if(value === " ") {
        char_textarea.value += Morse.MORSE_TO_CHAR[_buffer.join("")] || "?";
        _buffer = [];
      }
      else {
        _buffer.push(value);
      }

      _previous = value;
    }
  })()

  var fromEventToCommandString = (function(event) {
    var commands = {
      window_focus: "WINDOW_FOCUS",
      window_blur:  "WINDOW_BLUR",
      focus:        "FOCUS",
      blur:         "BLUR",
      mousedown:    "DOWN",
      mouseup:      "UP",
      keydown:      "DOWN",
      keyup:        "UP",
      touchstart:   "DOWN",
      touchend:     "UP"
    };

    return function(event) {
      return event.target === window
        ? commands["window_" + event.type] || "MUTE"
        : commands[event.type] || "MUTE";
    };
  })();

  var whenFocused = (function() {
    var _isFocused = true;

    return function(message) {
      return _isFocused = message === "FOCUS"
        ? false
        : message === "BLUR"
          ? true
          : _isFocused;
    };
  })();

  Rx.Observable.fromEvent(beep_button,    p_start)
  .merge(Rx.Observable.fromEvent(beep_button, p_end))
  .merge(Rx.Observable.fromEvent(document, 'keydown'))
  .merge(Rx.Observable.fromEvent(document, 'keyup'))
  .merge(Rx.Observable.fromEvent(code_textarea, 'focus'))
  .merge(Rx.Observable.fromEvent(code_textarea, 'blur'))
  .merge(Rx.Observable.fromEvent(char_textarea, 'focus'))
  .merge(Rx.Observable.fromEvent(char_textarea, 'blur'))
  .merge(Rx.Observable.fromEvent(window, 'focus'))
  .merge(Rx.Observable.fromEvent(window, 'blur'))
  .map(fromEventToCommandString)
  .filter(whenFocused)
  .map(fromCommandStringToBeep)
  .bufferWithTime(50)
  .flatMap(Morse.fromArrayToStream("MUTE"))
  .map(Morse.fromCommandToCode())
  .filter(Morse.filterSpace(10))
  .subscribe(show)

  Rx.Observable.fromEvent(play_button, p_start)
  .merge(Rx.Observable.fromEvent(window, "blur"))
  .merge(Rx.Observable.fromEvent(window, "focus"))
  .map(fromEventToCommandString)
  .subscribe(playBeep);

  Rx.Observable.fromEvent(code_textarea, "input")
  .subscribe(convertFrom("code"))

  Rx.Observable.fromEvent(char_textarea, "input")
  .subscribe(convertFrom("char"))

  Rx.Observable.fromEvent(clear_btn, p_start)
  .subscribe(function() {
    char_textarea.value = "";
    code_textarea.value = "";
  });
};

window.addEventListener("load", init);

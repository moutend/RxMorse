import Rx from "rx";

var Morse = {
  fromArrayToStream: (padding) => {
    return (array) => {
      return Rx.Observable.fromArray(
        array.length === 0
          ? padding ? [padding] : []
          : array
      );
    };
  },
  fromCommandToCode: (code) => {
    var waitUp = (n) => {
      return (cmd) => {
        return {
          code: cmd === "UP" ? (n > 1 ? "_" : ".") : " ",
          fn: cmd === "UP" ? waitDown : waitUp(n + 1)
        };
      };
    };
    var waitDown = (cmd) => {
      return {
        code: " ",
        fn: cmd === 'DOWN' ? waitUp(0) : waitDown
      };
    };
    var _state = {
      code: " ",
      fn: waitDown
    };

    return (v) => {
      _state = _state.fn(v);
      return _state.code;
    };
  },
  filterSpace: (limit = 4) => {
    var c1 = (char) => {
      return {
        name: "c1",
        k: char === " " ? false : true,
        fn: char === "."
          ? cd(limit / 2)
          : char === "_"
            ? cu(limit / 2)
            : c1
      };
    };
    var cd = (n) => {
      return (char) => {
        return {
          name: "cd",
          k: n === 0 || char !== " " ? true : false,
          fn: char === "."
          ? cd(limit / 2)
          : char === "_"
              ? cu(limit / 2)
              : n > 0
                ? cd(n - 1)
                : c2(limit)
        };
      };
    };
    var cu = (n) => {
      return (char) => {
        return {
          name: "cu",
          k: n === 0 || char !== " " ? true : false,
          fn: char === "."
          ? cd(limit / 2)
          : char === "_"
            ? cu(limit / 2)
            : n > 0
              ? cu(n - 1)
              : c2(limit)
        };
      };
    };
    var c2 = (n) => {
      return (char) => {
        return {
          name: "c2",
          k: n === 0 ||  char !== " " ? true : false,
          fn: char === "."
          ? cd(limit / 2)
          : char === "_"
            ? cu(limit / 2)
            : n > 0
              ? c2(n - 1)
              : c1
        };
      }
    };
    var _state = c1(" ");

    return (v) => {
      _state = _state.fn(v);
      return _state.k;
    };
  },
  MORSE_TO_CHAR: {
    "":" "," ":" ","_____":"0",".____":"1","..___":"2","...__":"3","...._":"4",".....":"5","_....":"6","__...":"7","___..":"8","____.":"9","._":"a","_...":"b","_._.":"c","_..":"d",".":"e",".._.":"f","__.":"g","....":"h","..":"i",".___":"j","_._":"k","._..":"l","__":"m","_.":"n","___":"o",".__.":"p","__._":"q","._.":"r","...":"s","_":"t",".._":"u","..._":"v",".__":"w","_.._":"x","_.__":"y","__..":"z","._._._":".","__..__":",","..__..":"?",".____.":"'","_.._.":"/g","_.__.":"(","_.__._":")","._...":"&","___...":":","_._._.":";","_..._":"=","._._.":"+","_...._":"-","..__._":"_","._.._.":"\"","..._.._":"$","_._.__":"!",".__._.":"@"
  },
  CHAR_TO_MORSE: {
    " ":"","":" ","a":"._","b":"_...","c":"_._.","d":"_..","e":".","f":".._.","g":"__.","h":"....","i":"..","j":".___","k":"_._","l":"._..","m":"__","n":"_.","o":"___","p":".__.","q":"__._","r":"._.","s":"...","t":"_","u":".._","v":"..._","w":".__","x":"_.._","y":"_.__","z":"__..","1":".____","2":"..___","3":"...__","4":"...._","5":".....","6":"_....","7":"__...","8":"___..","9":"____.","0":"_____",".":"._._._",",":"__..__","?":"..__..","'":".____.","/":"_.._.","(":"_.__.",")":"_.__._","&":"._...",":":"___...",";":"_._._.","=":"_..._","+":"._._.","-":"_...._","_":"..__._","\"":"._.._.","$":"..._.._","!":"_._.__","@":".__._."
  }
};

export default Morse;

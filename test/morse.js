import assert from "power-assert";
import Util from "../src/util";
import Morse from "../src/morse";
import Rx from "rx";

const COMMANDS = [
  "MUTE",
  "DOWN",
  "UP"
];

const CODES = [
  ".",
  "_",
  " "
];

const COMMAND_TO_CODE = {
  "DOWN DOWN UP":   "  .",
  "DOWN MUTE UP":   "  .",
  "DOWN UP DOWN": " . ",
  "DOWN UP MUTE": " . ",
  "DOWN UP UP":   " . ",
  "DOWN UP":        " .",
  "MUTE DOWN UP":   "  .",
  "UP DOWN UP":   "  ."
};;

let createPattern = (seed, max_depth) => {
  let result = [];

  let dfs = (pattern, depth) => {
    if(depth > max_depth) {
      return;
    }

    result.push(pattern);

    seed.map((v) => {
      dfs(pattern + " " + v, depth + 1);
    });
  };

  seed.map((v) => {
    dfs(v, 0)
  });

  return result;
};

let command_array = createPattern(COMMANDS, 2);
let code_array = [
  ". ",
  ".     ",
  ". . ",
  ". .     "
];
const CODE_TO_STR = {
  " ":              "",
  "  ":             "",
  "   ":            "",
  "    ":           "",
  "_":              "_",
  "_ ":             "_",
  "_  ":            "_",
  "_   ":           "_ ",
  "_    ":          "_ ",
  "_     ":         "_ ",
  "_      ":        "_ ",
  "_       ":       "_ ",
  "_.":             "_.",
  "_ .":            "_.",
  "_  .":           "_.",
  "_   .":          "_ .",
  "_    .":         "_ .",
  "_     .":        "_ .",
  "_      .":       "_ .",
  "_       .":      "_ .",
  "_        .":     "_  .",
  "_  . ":          "_.",
  "_  .  ":         "_.",
  "_  .   ":        "_. ",
  "_  .    ":       "_. ",
  ".  .    ":       ".. ",
  "_  .     ":      "_. ",
  "_  .      ":     "_. ",
  "_  .       ":    "_. ",
//  "_  .        ":   "_.  ",
  ".":              ".",
  ". ":             ".",
  ".  ":            ".",
  ".   ":           ". ",
  ".    ":          ". ",
  ".     ":         ". ",
  ".      ":        ". ",
  ".       ":       ". ",
  ".        ":      ".  ",
  "..":             "..",
  ". .":            "..",
  ".  .":           "..",
  ".   .":          ". .",
  ".    .":         ". .",
  ".     .":        ". .",
  ".      .":       ". .",
  ".       .":      ". .",
  ".        .":     ".  .",
  ". . ":           "..",
  ".  .  ":         "..",
  ".   .  ":        ". .",
  ".   .   ":       ". . ",
  ".   _ ":         ". _",
  ".   _  ":        ". _",
  ".   _   ":       ". _ ",
  ".   _    ":      ". _ ",
  ".   _     ":     ". _ ",
  ".   _      ":    ". _ ",
  ".   _       ":   ". _ ",
  ".   _        ":  ". _  ",
};

describe("Morse", () => {
  describe(".fromCommandToCode", () => {
    command_array.map((v) => {
      it("Pattern: " + v, () => {
        let result = "";
        let cmd_array = v.split(/ +/);
        let code = COMMAND_TO_CODE[v] || Util.emptyString(cmd_array.length);

        Rx.Observable.fromArray(cmd_array)
        .map(Morse.fromCommandToCode())
        .subscribe((v) => {
          result += v;
        });

        assert(result === code);
      });
    });
  });

  describe(".filterSpace", () => {
   let a = []
   for(let key in CODE_TO_STR) {
     a.push(key);
   }

    a.map((v, n) => {
      it("Pattern: " + n + " \"" + v + "\"", () => {
        let result = "";
        let cmd_array = v.split("");

        Rx.Observable.fromArray(cmd_array)
        .filter(Morse.filterSpace(4))
        .subscribe((v) => {
          result += v;
        });
        assert(result === CODE_TO_STR[v]);
      });
    });
  });
});

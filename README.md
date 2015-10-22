# RxMorse
[![MIT License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](http://moutend.mit-license.org/)

This is the Morse code simulator app that is using RxJS.
When you push BEEP button or hit the any key,
You can receive audio feedback and convert Morse code into ASCII character in real time.
Ofcourse you can also convert from ASCII into Morse code automatically when you enter any ASCII characters.



# Demo

Let's try [moutend.github.io/RxMorse](https://moutend.github.io/RxMorse/)

Or, you can try the playground on your machine.

    % git clone -b gh-pages https://github.com/moutend/RxMorse.git
    % cd ./RxMorse
    % mkdir -p vendor/bundle
    % bundle install --path vendor/bundle
    % bundle exec jekyll server

Requirements:

* Node 0.12
* Ruby 2.1
  * bundler



# Features

* Convert from ASCII/Morse code to Morse code/ASCII in real time
* Morse code playback
* Audio Feedback



# TODO

* Add the settings pane



# LICENSE

MIT

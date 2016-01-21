Welcome
=======

Howdy,

*This is a preliminary version of the PdParty Composer Pack.*

This folder contains the basics you need in order to start creating scenes for the PdParty iOS app using Pure Data 0.46+ (vanilla).

Copyright (c) [Dan Wilcox](danomatika.com) 2011-16

User Guide
----------

First off, check out the User Guide as it explains what PdParty is, how it works, and the details of how to create & run patches/scenes on it:

https://github.com/danomatika/PdParty/blob/master/doc/PdParty_User_Guide.md

This short readme is just a small overview by comparison.

Requirements
------------

PdParty is built using libpd which is based on Pure Data "vanilla", *not* Pd-extended. It is recommended that you work with Pd vanilla versions 0.46+.

Download Pd vanilla here: http://msp.ucsd.edu/software.html

Abstraction Folders
-------------------

The following abstraction folders are provided:

* pd: stereo soundinput & soundoutput wrappers
* rj: rjdj-specific abstractions
* droidparty: droidparty UI abstractions

Add these to your Pure Data path settings.

### Useful Abstraction Libraries

There are a number of useful vanilla-only abstraction libraries that make working with vanilla/libpd-based projects easier:

* [rjlib](https://github.com/rjdj/rjlib): developed for the RjDj ecosystem
* [rc-patches](https://github.com/danomatika/rc-patches): extended patch set from the [robotcowboy project](http://robotcowboy.com), designed to work with rjlib

soundinput & soundoutput
------------------------

The [soundinput] & [soundoutput] abstractions provide expanded functionality around [adc~] and [dac~] respectively. It is recommended that you use these as the audio in and out objects within your patches for PdParty. Besides, they provide nice built in slider controls.

[soundoutput] is *required* in order for scene recording via the controls menu to function. If PdParty does not find an instance of [soundoutput] loaded from your patch/scene, the record button will be disabled.

You can freely bundle [soundinput] and/or [soundoutput] within your scene folders, however note that PdParty will automatically remove any extra copies it finds when the scene is loaded. This way, it's always using the preferred built-in version in the libs/pd folder.

Scene Types
-----------

PdParty supports running basic *.pd patches as well as the following scene types: RjDj, DroidParty, & PdParty. "Scenes" are basically folders with a specific layout that are treated as a single entity for encapsulation.

You can bundle abstractions & abstraction libraries within a scene folder and add the local path in your main patch using the [declare] object via the "-path" argument.

### RjDj scene
  
This scene type conforms to the original RjDj specification and has been tested with a number of the original Rj scenes.

  * a folder that ends in *.rj that contains a _main.pd patch
  * an optional background image named "image.jpg" which must have a square aspect ratio and a min size of 320x320
  * an optional browser icon named "thumb.jpg" and a min size of 55x55
  * an optional info xml file named "Info.plist" or "info.plist"
  * 20500 samplerate
  * portrait orientation only

### DroidParty scene

This scene type provided compatibility with PdDroidParty on Android, except for svg theming. Functionally, you should be able to run the same scene on both PdParty (iOS) and DroidParty (Android).

  * a folder that contains a droidparty_main.pd patch
  * an optional background image named "background.png" which should have a landscape aspect ratio
  * an optional font named "font.ttf" or "font-antialiased.ttf"
  * 44100 samplerate
  * landscape orientation only
  
### PdParty scene

This scene type basically acts as a wrapper around a patch folder.

  * a folder that contains a _main.pd patch
  * an optional info json file named "info.json"
  * requires all event types
  * 44100 samplerate
  * landscape or protrait orientation is interpretted from the canvas size
  
Running a regular .pd patch is the same as running a PdParty scene.

Open Sound Control Bridges
--------------------------

The patches in the osc folder provide basic Open Sound Control (OSC) communication between PdParty and Pure Data running on your desktop. Once osc sending is enabled in PdParty, you can send and receive PdParty events which allows you to develop & test patches. For instance, you can work with #touch events generated on PdParty which ptch on your computer.

The rj sensor objects are implemented using PdParty events, so they wil also work over OSC.

Templates
---------

Templates for each scene file type are provided in the templates folder.

Resources & Examples
--------------------

* [rjlib example RjDj scenes](https://github.com/rjdj/rjlib/tree/master/examplescenes)
* [DroidParty webpage](http://droidparty.net)
* [DroidParty demos](https://github.com/chr15m/PdDroidParty/tree/master/droidparty-demos)
* [PdParty tests](https://github.com/danomatika/PdParty/tree/master/res/patches/tests), includes all scene types, osc communication, sensors events, etc
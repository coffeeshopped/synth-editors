# Synth Editors

A collection of synthesizer editor/librarians written in Javascript.

This code currently only runs within a development version of a (potential) successor to Patch Base. While it isn't immediately useful to outside users at the moment, it is published with the intent of soliciting feedback from potential editor developers on how the editor architecture is set up.

Also, theoretically each editor *could* be run in any other environment that offers the necessary framework to run this code. Each editor code collection distills the logic and data needed to create an editor for a specific hardware synthesizer: the patch and bank structures, the MIDI communication logic, and a set of controllers to offer a GUI for the editor. 
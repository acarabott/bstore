~p3_drumVerb = Synth(\BSP3_Reverb, [\in, ~p3_drumVerbBus, \damp, 0.4, \mix, 0.8, \room, ~p3_drumRoomInit]);
~p3_guitarVerb = Synth(\BSP3_Reverb, [\in, ~p3_guitarVerbBus, \damp, ~p3_guitarDampInit, \mix, ~p3_guitarMixInit, \room, ~p3_guitarRoomInit]);
~p3_varsawVerb = Synth(\BSP3_Reverb, [\in, ~p3_varsawVerbBus, \damp, 0.1, \mix, 1, \room, ~p3_varsawRoomInit]);
~p3_bassVerb = Synth(\BSP3_Reverb, [\in, ~p3_bassVerbBus, \damp, 0.1, \mix, 0.8, \room, ~p3_bassRoomInit]);

"Synths started".postln;

~debug = true;
~debug = false;

s.options.memSize = 2**18;
~p3_path = "/Users/arthurc/Documents/programming/computerMusic/bstore/";

s.waitForBoot {
    var files = ["variables", "synthdefs", "busses", "responders", "functions", "buffers", "synths", "gui", "playRoutines", "controlRoutines"];
    var syncs = ["synthdefs", "buffers", "busses", "synths", "playRoutines"];
    {
        files.do { |item, i|
            (~path ++ item ++ ".scd").loadPath;
            
            if(syncs.includes(item)) {
                s.sync;
            };
        };
    }.fork
};

~p3_control.play
~p3_stop.();
~p3_reset.();

(
~p3_stop = {
    [~p3_control, ~p3_drumBuild, ~p3_bassline, ~p3_drumRoutine, ~p3_guitarStart, ~p3_guitarMelody, ~p3_interactiveGuitar, ~p3_drumVerbRoutine, ~p3_guitarVerbRoutine, ~p3_varsawVerbRoutine].do { |item, i|
        item.stop;
    };
};

~p3_reset = {
    ~p3_variables.();
    ~p3_responders.();
    ~p3_synths.();
    ~p3_playRoutines1.();
    ~p3_playRoutines2.();
    ~p3_playRoutines3.();    
    ~p3_playRoutines4.();
    ~p3_controlRoutines1.();    
};
)

(
    
~p3_control = Routine {
    "Bass start".postln;
    ~p3_bassline.play(~p3_clock, Quant(4));
    if(~debug) {
        1.wait;
    } {
        10.wait;
    };
    "Bass Moving".postln;
    ~p3_bassMove = true;
    if(~debug) {
        5.wait;
    } {
        60.wait;
    };
    "Drums start".postln;
    ~p3_drumRoutine.play(~p3_clock, Quant(4));
    ~p3_drumBuild.play;
    
    "Guitar starts".postln;
    ~p3_guitarStart.play(~p3_clock, Quant(4));
    // TODO have this accumlate activity, once it hits threshold move onto next section
    // (4 * 60).wait;
    if(~debug) {
        10.wait;
    } {
        (4 * 60).wait;
    };
    // When an activity level reaches 0.75 or so do
    ~p3_hatsPat = ~p3_hatsPats[\quavers];
    // (2 * 60).wait;
    if(~debug) {
        10.wait;
    } {
        (2*60).wait;
    };
    ~p3_guitarStart.stop;
    
    // Guitar melodies start
    ~p3_guitarMelodyActivityLevel = 0.2;
    ~p3_guitarMelody.play(~p3_clock, Quant(4));
    // as this acumulates and hits 0.75 then do 
    ~p3_guitarMelodyActivityLevel = 0.75;
    ~p3_snarePat = ~p3_snarePats[\active];
    if(~debug) {
        10.wait;
    } {
        (3*60).wait;
    };
    // Drums stop, guitar harmony thickens, bass changes to Lydian root
    ~p3_drumRoutine.stop;
    ~p3_guitarMelodyActivityLevel = 1;
    ~p3_bassNote = ~p3_root - 4;
    // TODO BASS COMES UP
    ~p3_thickGuitarHarmony = true;
    // TODO Make this interactive
    ~p3_guitarMelodyOctave = 2**(~p3_y*2).floor;
    
    // TODO fade ~p3_amps[\guitar] down to 0
    // TODO fade ~p3_amps[\varsaw] up to 0.8
    if(~debug) {
        10.wait;
    } {
        (3*60).wait;
    };

    ~p3_drumBuild.reset;
    ~p3_drumRoutine.reset;
    if(~debug) {
        10.wait;
    } {
        (3*60).wait;
    };

    ~p3_drumReset.();
    ~p3_drumRoutine.play(~p3_clock, Quant(4));
    ~p3_drumBuild.play;
    // TODO varsaw fade out
    ~p3_guitarMelody.stop;
    ~p3_bassNote = ~p3_root;
    
    {
        ~p3_drumRoutine.stop;
        ~p3_drumWildRoutine.play(~p3_clock, quant:Quant(4));
        ~p3_drumWildControl.play;
    }.fork(~p3_clock, quant:Quant(4));
    
    ~p3_controlCondition.wait;
    // Drum section?
    // TODO Change bass note back when stopping
    // ~p3_bassNote = 50;
    // TODO don't stop drums, just move to low grade
    // Guitar interactive
    ~p3_interactiveGuitar.play(~p3_clock, Quant(4));

    // TODO guitar volume down to 0 (better if guitar notes just stop)
    // TODO VARsaw continues, drums become more hectic
    // TODO Automate varsaw and guitar levels here. should this change GUI values? no
    // TODO varsaw can change to % 16
    // TODO Drums fade out and stop, bass fades out, guitar comes up to about 0.15-0.2
    // TODO varsaw fades out
    
};
);

// TODO deal with all ~p3_varsawVerbRoutine ~p3_guitarVerbRoutine ~p3_drumVerbRoutine
// TODO deal withi all ~p3_x and ~p3_y 
// TODO Capture melodic patterns
// TODO Guitar activity control
// TODO Guitar effects
// TODO Larger scale decisions - play / don't play for x time
// TODO Large pads every now and then
// TODO Changing from sets of drum patterns
// TODO Write possible structures for piece
// TODO Root note changes.
// TODO Guitar phrases of different no.
// TODO Mixing 
// TODO Have scale controls for activity levels.
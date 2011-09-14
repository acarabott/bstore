~debug = true;
~debug = false;

s.options.memSize = 2**18;
s.latency = 0.4;
~p3_path = "/Users/arthurc/Documents/programming/computerMusic/bstore/";
s.waitForBoot {
    ~p3_setup = {
        var files = ["variables", "synthdefs", "busses", "responders", "functions", "buffers", "synths", "gui", "playRoutines", "controlRoutines"];
        var syncs = ["synthdefs", "buffers", "busses", "synths", "playRoutines"];
        {
            files.do { |item, i|
                (~p3_path ++ item ++ ".scd").loadPath;
                if(syncs.includes(item)) {
                    s.sync;
                };
            };
        }.fork(AppClock); 
    };
    ~p3_setup.();
    ~p3_meterUp = true;
};


//Reset
~p3_stop.();
~p3_setup.();

~p3_section1Control.play;
~p3_section2Control.play;
~p3_section3Control.play;
~p3_section4Control.play;

~p3_sectionDuration = 300;
~p3_bassline.play(~p3_clock, Quant(4));
~p3_drumRoutine.play(~p3_clock, Quant(4));
~p3_hatsOn = true;
~p3_drumActivityChanging = false;
~p3_snarePat    = ~p3_snarePats[\main];
~p3_hatsPat     = ~p3_hatsPats[\main];
~p3_kickPat    = ~p3_kickPats[\main];
~p3_kickOn = true;
~p3_snareOn = true;


(
~p3_control = Routine {
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
    ~p3_guitarMelodyOctave = 2**(2*2).floor;
    
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
// TODO Guitar phrases of different no.
// TODO Mixing 
// TODO Have scale controls for activity levels.
// TODO Make rate and fgain interactive on varsaw?
// TODO varsaw overall level might need to come up?
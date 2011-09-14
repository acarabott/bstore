~p3_section1Control = Routine {
    var start, end, middle, index, div, inc, mWait;

    ~p3_bassMove = false;
    ~p3_bassEnd = true;
    ~p3_bassHigh = 0;
    ~p3_bassThresh = 1;


    index = 0;
    start = ~p3_sectionDuration/10;
    end = ~p3_sectionDuration/5;
    middle - ~p3_sectionDuration - start - end;
    div = 100;
    inc = 1/div;
    mWait = middle/div;
    
    ~p3_bassline.play(~p3_clock, Quant(4));
    start.wait;
    ~p3_bassMove = true;
    "moving".postln;
    while({index < 1}, {
        index = index + inc;
        ~p3_bassHigh = ~p3_bassHigh + inc;
        ~p3_bassThresh = ~p3_bassThresh - inc;
        ~p3_bassVerb.set(\room, ~p3_bassHigh.linlin(0, 1, 0.6, 1), \mix, ~p3_bassHigh.linlin(0, 1, 0.5, 0.9));
        if(index > 0.8) {
            ~p3_bassEnd = true;
        };
        index.postln;
        mWait.wait;
    });
    "at end".postln;
    end.wait;
    ~p3_bassMove = false;
    ~p3_bassHigh = 0;
    ~p3_bassThresh = 1;
    ~p3_bassVerb.set(\room, ~p3_bassRoomInit, \mix, ~p3_bassMixInit);
    "finished".postln;
};


~p3_section2Control = Routine {
    var start, middle, end, index, div, inc, mWait;
    index = 0;
    start = ~p3_sectionDuration/5;
    end = ~p3_sectionDuration/5;
    middle = ~p3_sectionDuration - start - end;
    div = 100;
    inc = 1/div;
    mWait = middle/div;
    
    ~p3_kickOn = false;
    ~p3_snareOn = false;
    ~p3_hatsOn = true;
    
    ~p3_drumActivityChanging = false;
    ~p3_snarePat    = ~p3_snarePats[\main];
    ~p3_hatsPat     = ~p3_hatsPats[\offbeat];
    ~p3_kickPat    = ~p3_kickPats[\main];

    "Starting".postln;
    ~p3_drumRoutine.play(~p3_clock, Quant(4));

    (start/4).wait;
    "Kick On".postln;
    ~p3_kickOn = true;
    
    (start/4).wait;
    "Snare on".postln;    
    ~p3_snareOn = true;
    "Hats Main".postln;
    ~p3_hatsPat = ~p3_hatsPats[\main];
    
    (start/4).wait;
    "Reverb and pan".postln;
    ~p3_drumPanMoving = true;
    "Drums more active".postln;
    ~p3_kickPat     = ~p3_kickPats[\active];
    ~p3_snarePat    = ~p3_snarePats[\active];
    ~p3_hatsPat     = ~p3_hatsPats[\quavers];
    
    "Middle section".postln;
    ~p3_drumActivityChanging = true;
    
    while({index < 1}, {
        index = index + inc;
        index.postln;
        ~p3_amps[\drums] = ~p3_data[\lowMax].linlin(0, 1, index.linlin(0, 1, 1, 1.5), 1);
        ~p3_drumVerb.set(\room, ~p3_data[\lowMax].linlin(0, 0.8, index.linlin(0, 1, 0.2, 1), 0.9));
        ~p3_drumDoubleMax = index.lincurve(0, 1, 0.05, 0.8, 4);
        ~p3_snarePat = ~p3_snarePats[\active].collect({ |item, i| 
            if(item == 1) {
                item
            } {
                item + ~p3_data[\lowMax].linlin(0, 1, index.linlin(0, 1, 100, 20), 5).floor;
                // item + ~p3_data[\lowMax].lincurve(0, 1, index.linlin(0, 1, 100, 10), 2, -4).floor;
            };
        });
        ~p3_hatsPat = ~p3_hatsPats[\quavers].collect({ |item, i| 
            if(item == 1) {
                item
            } {
                item + ~p3_data[\lowMax].linlin(0, 1, index.linlin(0, 1, 100, 20), 5).floor;
                // item + ~p3_data[\lowMax].lincurve(0, 1, index.linlin(0, 1, 100, 10), 2, -4).floor;
            };
        });
        
        mWait.wait
    });
    "end".postln;
    
    end.wait;
    "finished".postln;
    ~p3_drumActivityChanging = false;
    ~p3_snarePat    = ~p3_snarePats[\main];
    ~p3_hatsPat     = ~p3_hatsPats[\offbeat];
    ~p3_kickPat    = ~p3_kickPats[\main];
    ~p3_drumVerb.set(\room, ~p3_drumRoomInit);
};

~p3_section3Control = Routine {
    var start, middle, end, index, div, inc, mWait;
    index = 0;
    start = ~p3_sectionDuration/10;
    end = ~p3_sectionDuration/5;
    middle = ~p3_sectionDuration - start - end;
    div = 100;
    inc = 1/div;
    mWait = middle/div;
    
    "Started".postln;
    (start/2).wait;
    "Guitar begins".postln;
    ~p3_guitarStart.play(~p3_clock, Quant(4));
    (start/2).wait;

    "Middle start".postln;
    while({index < 1}, {
        index = index + inc;
        index.postln;
        ~p3_guitarStartActivityLevel = index.linlin(0, 1, 0.05, 1);
        ~p3_guitarVerb.set(\room, ~p3_data[\lowMax].linlin(0, 0.8, index.linlin(0, 1, 0.8, 1), 0.9));
        ~p3_guitarStartMult = index.linlin(0, 1, 1, 4).ceil;
        if(index >= 0.33 && ~p3_guitarStartTwo.not) {
            ~p3_guitarStartTwo = true;
            "Second guitar join".postln;
        };
        
        (middle/div).wait
    });
    "End start".postln;
    
    end.wait;
    
    ~p3_guitarVerb.set(\room, ~p3_guitarRoomInit);
    ~p3_guitarStart.stop;
    "Finished".postln;
    
};
    ~p3_guitarMelody.stop
Tdef(\section4Control, {
    ~p3_guitarMelody.play(~p3_clock, Quant(4));
    ~p3_kickOn = false;
    ~p3_snareOn = false;
    ~p3_guitarMelodyActivityLevel = 0.7;
    ~p3_bassNote = 58;
    ~p3_thickGuitarHarmony = true;
    ~p3_guitarVerb.set(\room, 1, \mix, 1);
    ~p3_amps[\drum_hats]=0;
    ~p3_amps[\guitar] = 0;
});
Tdef(\section4Control).stop
"Control Routines loaded".postln;
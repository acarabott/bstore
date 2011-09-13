~p3_section1Control = Routine {
    var start, end, index, div, inc;

    ~p3_bassMove = false;
    ~p3_bassEnd = true;
    ~p3_bassHigh = 0;
    ~p3_bassThresh = 1;


    index = 0;
    start = ~p3_sectionDuration/10;
    end = ~p3_sectionDuration/5;
    div = 100;
    inc = 1/div;

    ~p3_bassline.play(~p3_clock, Quant(4));
    start.wait;
    ~p3_bassMove = true;
    "moving".postln;
    while({index < 1}, {
        index = index + inc;
        ~p3_bassHigh = ~p3_bassHigh + inc;
        ~p3_bassThresh = ~p3_bassThresh - inc;

        if(index > 0.8) {
            ~p3_bassEnd = true;
        };

        ((~p3_sectionDuration-start-end) / div).wait;
    });
    "at end".postln;
    end.wait;
    ~p3_bassMove = false;
    ~p3_bassHigh = 0;
    ~p3_bassThresh = 1;
};


"Control Routines loaded".postln;

// ~p3_drumActivityChanging = false;
// ~p3_drumAmpChanging = false;
// ~p3_drumReverbChanging = false;
~p3_drumReverbFunc = {|data|
    var max = data.maxItem;
    ~p3_drumVerb.set(\room, max.linlin(0, 0.8, 0, 0.9));
    
};

~p3_drumAmpFunc = {|data|
    var max = data.maxItem;
    ~p3_amps[\drums] = max.linlin(0, 1, 0.4, 1);    
};

~p3_drumActivityFunc = {|data|    
    ~p3_snarePat = ~p3_snarePats[\active].collect({ |item, i| 
        if(item == 1) {
            item
        } {
            item + ~p3_data[\lowMax].lincurve(0, 1, 100, 2, -4).floor;
        };
    });
    ~p3_hatsPat = ~p3_hatsPats[\main].collect({ |item, i| 
        if(item == 1) {
            item
        } {
            item + ~p3_data[\lowMax].lincurve(0, 1, 100, 2, -4).floor;
        };
    });
};

~p3_section2Control = Routine {
    var start, end, index, div, inc;
    index = 0;
    start = ~p3_sectionDuration/10;
    end = ~p3_sectionDuration/5;
    div = 100;
    inc = 1/div;

    ~p3_kickOn = false;
    ~p3_snareOn = false;
    ~p3_hatsOn = true;
    
    ~p3_drumReverbChanging = false;
    ~p3_drumActivityChanging = false;
    ~p3_snarePat    = ~p3_snarePats[\main];
    ~p3_hatsPat     = ~p3_hatsPats[\offbeat];
    ~p3_kickPat    = ~p3_kickPats[\main];

    "Starting".postln;
    ~p3_drumRoutine.play(~p3_clock, Quant(4));

    (start/3).wait;
    "Kick On".postln;
    ~p3_kickOn = true;
    
    ~p3_snareOn = true;
    "Snare on".postln;
    (start/3).wait;
    "Hats Main".postln;
    ~p3_hatsPat = ~p3_hatsPats[\main];

    (start/3).wait;
    "Reverb and pan".postln;
    ~p3_drumReverbChanging = true;
    ~p3_drumPanMoving = true;
    // 5.wait;
    
    ~p3_drumActivityChanging = true;
    end.wait;
    // ~p3_snarePat = ~p3_snarePats[\active];
    // ~p3_snarePats[\active];
    // Slowly drift panning backwards and forwards?
};

~p3_section2Control.play
~p3_drumRoutine.stop
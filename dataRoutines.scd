c = Condition(false);
r = Routine {
    var dirs = true!4;
    inf.do {
        c.wait;
        ~p3_data.do { |item, i|
            if(dirs[i]) {
                if(item < 1) {
                    ~p3_data[i] = item + 0.01;
                } {
                    dirs[i] = false;
                };
            } {
                if(item > 0) {
                    ~p3_data[i] = item - 0.01;
                } {
                    dirs[i] = true
                };
            };
        };
                
        n.sendMsg("/activity", ~p3_data[0], ~p3_data[1], ~p3_data[2], ~p3_data[3]);
        (1/24).wait;
    }
};


r.play;
r.stop
c.test = false; c.signal;
c.test = true; c.signal;



~p3_drumActivityChanging = true;
~p3_drumAmpChanging = false;
~p3_drumReverbChanging = false;
~p3_drumReverbFunc = {|data|
    var max = data.maxItem;
    ~p3_drumVerb.set(\room, max.linlin(0, 0.8, 0, 0.9));
    
};

~p3_drumAmpFunc = {|data|
    var max = data.maxItem;
    ~p3_amps[\drums] = max.linlin(0, 1, 0.4, 1);    
}
~p3_drumActivityFunc = {|data|
    var min, val;
    
    min = ~p3_data[\left].min(~p3_data[\right]);
    if(min < 0.5) {
        val = ~p3_data[\left].max(~p3_data[\right]).linlin(0, 1, 10, 1).floor;
    } {
        val = (~p3_data[\left] + ~p3_data[\right]).linlin(0, 2, 10, 1).floor;
    };
    
    ~p3_snarePat = ~p3_snarePats[\active].collect({ |item, i| 
        if(item == 1) {
            item
        } {
            item + val;
        };
    });
    ~p3_hatsPat = ~p3_hatsPats[\main].collect({ |item, i| 
        if(item == 1) {
            item
        } {
            item + val;
        };
    });
    // ~p3_snarePat    = ~p3_snarePats[\active] + val;
};

~p3_section2Control = Routine {
    var start, end, index, div, inc;
    index = 0;
    start = ~p3_sectionDuration/10;
    end = ~p3_sectionDuration/5;
    div = 100;
    inc = 1/div;

    start.wait;
    ~p3_kickOn = false;
    ~p3_snareOn = false;
    ~p3_hatsOn = true;
    
    ~p3_drumReverbChanging = false;
    ~p3_drumActivityChanging = false;
    ~p3_snarePat    = ~p3_snarePats[\main];
    ~p3_hatsPat     = ~p3_hatsPats[\offbeat];
    ~p3_kickPat    = ~p3_kickPats[\main];

    ~p3_drumRoutine.play(~p3_clock, Quant(4));
    
    5.wait;
    ~p3_kickOn = true;
    
    5.wait;
    ~p3_hatsPat = ~p3_hatsPats[\main];
    ~p3_snareOn = true;
    
    ~p3_drumReverbChanging = true;
    ~p3_drumPanMoving = true;
    5.wait;
    
    ~p3_drumActivityChanging = true;
    ~p3_snarePat = ~p3_snarePats[\active];
    ~p3_snarePats[\active];
    // Slowly drift panning backwards and forwards?
};



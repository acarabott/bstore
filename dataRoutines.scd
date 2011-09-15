c = Condition(false);
r = Routine {
    var dirs = true!4;
    var inc = 0.01;
    inf.do {
        c.wait;
        if(~p3_testMove) {
            ~p3_testData.do { |item, i|
                if(dirs[i]) {
                    if(item < ~rmax) {
                        ~p3_testData[i] = item + inc;
                    } {
                        dirs[i] = false;
                    };
                } {
                    if(item > 0) {
                        ~p3_testData[i] = item - inc;
                    } {
                        dirs[i] = true;
                    };
                };
            
            };
        } {
            ~p3_testData = [0,0,0,0];
        };
        
        ~p3_netAddr.sendMsg("/activity", ~p3_testData[0], ~p3_testData[1], ~p3_testData[2], ~p3_testData[3]);
        (1/24).wait;
    }
};

~random = Routine {
    inf.do {
        if(~p3_testMove) {
            ~p3_testData.do { |item, i|
                if(0.25.coin) {
                    ~p3_testData[i] = 1.0.rand;
                };
            };
        };
        ~p3_netAddr.sendMsg("/activity", ~p3_testData[0], ~p3_testData[1], ~p3_testData[2], ~p3_testData[3]);
        ~rate.wait;
    };
}


~rate = 1/24;
~rmax = 1;
~p3_testData = [0,0,0,0];
~p3_testMove = true;
c.test = false; c.signal;
c.test = true; c.signal;
~random.play;
r.play;
r.stop

~p3_fakeupdate = Routine {
    inf.do {|i|
        ~p3_netAddr.sendMsg("/activity", 0,0,0,0);
        (1/24).wait;
    };
};

~p3_fakeupdate.stop;


Tdef(\p3_section4Control, {
    var start, startSplit, middle, end, index, div, inc, mWait, eWait;
    var tripsOn;
    index = 0;
    start = ~p3_sectionDuration/5;
    startSplit = start/6;
    end = ~p3_sectionDuration/5;
    middle = ~p3_sectionDuration - start - end;
    div = 100;
    inc = 1/div;
    mWait = middle/div;
    eWait = (end/2)/div;
    tripsOn = false;
    "Section started".postln;
    
    ~p3_drumWildRoutine.play(~p3_clock, quant:Quant(4));
    // 1/6
    startSplit.wait;
    "Hats enter on off beat".postln;
    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[1]);
    
    "Kick and snare more active".postln;
    // 2/6
    startSplit.wait;
    ~p3_drumWildPats.add(\kick  -> ~p3_drumWildKickPats[1]);
    ~p3_drumWildPats.add(\snare -> ~p3_drumWildSnarePats[1]); 

    "Hats switch between crotchets and dotted crotchets".postln;
    // 3/6
    startSplit.wait;
    ~p3_drumWildPats.add(\snare -> ~p3_drumWildSnarePats[2]); 
    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[2]);
    // 5/6
    4.do { |i|
        if(i.even) {
            ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[3]);
        } {
            ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[2]);            
        };
        (startSplit/2).wait;
    };
    // 6/6
    "Drums drop down".postln;
    ~p3_drumWildPats.add(\snare -> ~p3_drumWildSnarePats[3]);     
    ~p3_drumWildPats.add(\kick  -> ~p3_drumWildKickPats[2]);
    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[0]);
    startSplit.wait;
    
    "Wild drums start".postln;
    ~p3_drumWildPats.add(\all -> true);
    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[2]);
    while({index < 1}, {
        index.postln;
        ~p3_drumWildDontPlayNext = index.linlin(0, 0.5, 0.85, 0);
        ~p3_drumWildPlayNoteMin = index.linlin(0, 1, 0, 1);
        ~p3_drumWildMultMin = index.linlin(0, 0.5, 0, 0.9);
        ~p3_drumWildMultMax = index.linlin(0, 0.5, 0.25, 1);
        ~p3_drumVerb.set(\room, (~p3_data[\lowMax]* index.linlin(0, 1, 0.7, 1.5)).min(0.9));
        
        if(index > 0.3 && tripsOn.not) {
            "trips on".postln;
            tripsOn = true;
            ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[3]);
        };
        
        if(index > 0.5 && tripsOn) {
            "trips off".postln;
            tripsOn = false;
            ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[2]);
        };
        
        if(index > 0.7 && tripsOn.not) {
            "trips on".postln;            
            tripsOn = true;
            ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[3]);
        };
        
        if(index > 0.8 && tripsOn) {
            "trips off".postln;
            tripsOn = false;
            ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[2]);
        };
        
        if(index > 0.5 && ~p3_drumWildRateMoves.not) {
            "moves on".postln;
            ~p3_drumWildRateMoves = true;
            ~p3_drumWildPats.add(\kick  -> ~p3_drumWildKickPats[0]);
            ~p3_drumWildPats.add(\snare -> ~p3_drumWildSnarePats[0]); 
            
        };
        
        index = index + inc;
        mWait.wait;
    });
    "Reached ending".postln;
    index = 0;
    while({index < 1}, {
        index.postln;
        ~p3_drumWildDontPlayNext = index.linlin(0, 1, 0, 1);
        ~p3_drumWildPlayNoteMin = index.linlin(0, 1, 1, 0);
        ~p3_drumWildMultMin = index.linlin(0, 1, 1, 0);
        ~p3_drumWildMultMax = index.linlin(0, 1, 1, 0);
        ~p3_drumVerb.set(\room, (~p3_data[\lowMax]* index.linlin(0, 1, 1.5, ~p3_drumRoomInit)).min(0.9));
        
        index = index + inc;
        eWait.wait;
    });
    "Finished".postln;
    
}).play;

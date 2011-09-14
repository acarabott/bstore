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
    index = 0;
    start = ~p3_sectionDuration/5;
    startSplit = start/6;
    end = ~p3_sectionDuration/5;
    middle = ~p3_sectionDuration - start - end;
    div = 100;
    inc = 1/div;
    mWait = middle/div;
    eWait = (end/2)/div;
    "Section started".postln;
    
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
    
}).play;
~p3_drumWildControl = Routine {
    // 4:00 - All drum patterns drop out. 
    //      - More interactive drums start
    ~p3_drumWildPats.add(\snare -> ~p3_drumWildSnarePats[3]);     
    ~p3_drumWildPats.add(\kick  -> ~p3_drumWildKickPats[2]);
    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[0]);
    ~p3_drumWildPats.add(\all -> true);

    if(~debug) {
        5.wait;
    } {
        60.wait;        
    };
    // 5:00 - Hats enter with interactive drums

    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[1]);

    if(~debug) {
        5.wait;
    } {
        30.wait;        
    };
    // 5:30 - Hats on beat
    //      - Drums become a lot more active
    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[2]);
    ~p3_drumWildPlayNext = 0;
    ~p3_drumWildPlayNoteMin = 0.7;
    
    if(~debug) {
        5.wait;
    } {
        30.wait;        
    };
    
    // 6:00 - Hats switch between Crotchet/dotted crotchet for 0:40 - 2:00
    4.do { |i|
        if(~debug) {
            5.wait;
        } {
            [5,15].choose.wait;        
        };
        ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[3]);
        if(~debug) {
            5.wait;
        } {
            [5,15].choose.wait;        
        };
        ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[2]);
    };
    // 6:40-8:00 - Drums very active
    //           - Pitch shift rolls start
    ~p3_drumWildPlayNoteMin = 1;
    ~p3_drumWildRateMoves = true;
    ~p3_drumWildMultMin = 0.5;

    if(~debug) {
        5.wait;
    } {
        30.wait;        
    };
    // 7:10-8:30 - Kick and snare back in
    ~p3_drumWildPats.add(\kick  -> ~p3_drumWildKickPats[0]);
    ~p3_drumWildPats.add(\snare -> ~p3_drumWildSnarePats[0]); 

    if(~debug) {
        5.wait;
    } {
        30.wait;        
    };
    // 7:40-9:00 - Drums very cutty/rolly
    ~p3_drumWildMultMin = 1;
    ~p3_drumWildMultMax = 1;
    ~p3_drumWildPlayNext = 1;
    
    if(~debug) {
        5.wait;
    } {
        (60).wait;        
    };
    // 8:40-10:00 - Drums go back to a basic beat
    ~p3_drumWildPats.add(\all -> false);
    ~p3_drumWildPats.add(\kick  -> ~p3_drumWildKickPats[0]);
    ~p3_drumWildPats.add(\snare -> ~p3_drumWildSnarePats[0]); 
    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[0]);
    
    ~p3_controlCondition.test = true;
    ~p3_controlCondition.signal;
    
};

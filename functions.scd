~p3_updateData = {|mulAdd|
    ~p3_data[\1] = mulAdd[0];
    ~p3_data[\2] = mulAdd[1];
    ~p3_data[\3] = mulAdd[2];
    ~p3_data[\4] = mulAdd[3];
    ~p3_data[\left] = (mulAdd[0] + mulAdd[2]) / 2;
    ~p3_data[\right] = (mulAdd[1] + mulAdd[3]) / 2;
    ~p3_data[\top] = mulAdd[0..1].mean;
    ~p3_data[\bottom] = mulAdd[2..3].mean;
    ~p3_data[\total] = mulAdd.sum;
    ~p3_data[\lrdiff] = ~p3_data[\left].neg + ~p3_data[\right];
    ~p3_data[\tbdiff] = ~p3_data[\top].neg + ~p3_data[\bottom];
    ~p3_data[\mean] = mulAdd.mean;    

    ~p3_data[\lowMax] = ~p3_data[\left].min(~p3_data[\right]);
    
    if(~p3_data[\lowMax] < 0.35) {
        ~p3_data[\lowMax] = [~p3_data[\1], ~p3_data[\2], ~p3_data[\3], ~p3_data[\3]].maxItem;
    } {
        ~p3_data[\lowMax] = (~p3_data[\left] + ~p3_data[\right]).min(1);
    };
    
};


~p3_updateGUI = {|data, mulAdd|
    {
        data.linlin(0, 1, 0, 200).do { |item, i|
            var inBounds = ~p3_activityIn[i].bounds;
            var outBounds = ~p3_activityOut[i].bounds;
            var top;
            var out;
        
            if(i > 1) {
                top = 200;
            } {
                top = 0
            };
            
            out = mulAdd[i].linlin(0, 1, 0, 200);
    
            ~p3_activityIn[i].bounds = Rect(inBounds.left, top + 200 - item, 200, item);
            ~p3_activityOut[i].bounds = Rect(outBounds.left, top + 200 - out, 200, out);
        };
    }.fork(AppClock);
};

~p3_stop = {
    //Responder
    ~p3_responder.remove;    

    //Routines
    [~p3_bassline, ~p3_drumBuild, ~p3_drumRoutine, ~p3_drumWildRoutine, ~p3_guitarStart, ~p3_guitarMelody, ~p3_interactiveGuitar, ~p3_drumWildControl, ~p3_section1Control].do { |item, i|
        item.stop;
    };
    
    //Synths
    [~p3_drumVerb, ~p3_guitarVerb, ~p3_varsawVerb, ~p3_bassVerb].do { |item, i|
        item.free;
    };
    
    //Busses
    [~p3_drumVerbBus, ~p3_guitarVerbBus, ~p3_varsawVerbBus, ~p3_bassVerbBus].do { |item, i|
        item.free;
    };
    
    //Buffers
    ~p3_buffers.do { |item, i|
        if(item.class == Array) {
            item.do { |jtem, j|
                jtem.free;
            };
        } {
            item.free;
        };
    };
    
    //GUI
    [~p3_mixer, ~p3_activityWin].do { |item, i|
        item.close;
    };
};

~p3_drumReset = {
    //  Initialise
    ~p3_hatsOn     = false;
    ~p3_kickOn     = false;
    ~p3_snareOn    = false;
    ~p3_hatsPat    = ~p3_hatsPats[\offbeat];
    ~p3_snarePat    = ~p3_snarePats[\main];
    
    ~p3_drumVerbRoutine.stop;
    1.wait;
    ~p3_drumVerbRoutine.reset;
    ~p3_drumVerb.set(\room, ~p3_drumRoomInit);    
    
    "Drums reset".postln;
};

~p3_double = {|func, mult=2, div=2, wait=0.5|
    {
        mult.do { |i|
            func.(i);
            (wait / (div)).wait;
        };
    }.fork(~p3_clock)
};

~p3_getNeighbours = {|index, max, step=1|
    var ret = List[];
    if(index - step >= 0) {
        ret.add(index-step);
    };
    if((index + step) <= max) {
        ret.add(index+step);
    };
    
    ret;
};

~p3_setNeighbours = {|collection, neighbours, value|
    neighbours.do { |item, i|
        collection[item] = value;
    };
    
    collection;
};

~p3_guitarNote = {|rate=1, amp=1|
    var buffer, weights, nearest, sResolvers, neighbours;
    ~p3_guitarResolved = false;
    switch (~p3_guitarNoteCount)
        {1}  {
            ~p3_guitarResolved = true;
            weights = 0!8;
            if(~p3_guitarPhrasesCount == 1) {
                nearest = ~p3_lastGuitar.nearestInList(~p3_phraseResolvers);
                ~p3_guitarPhrasesCount = 5;
            } {
                nearest = ~p3_lastGuitar.nearestInList(~p3_guitarResolvers);                    
                sResolvers = ~p3_guitarResolvers.shallowCopy;
                sResolvers.remove(nearest);
                weights[~p3_lastGuitar.nearestInList(sResolvers)] = 1;
            };
            weights[nearest] = 1;
            ~p3_guitarNoteCount = 5;    // 5 as 1 will be subtracted            
            ~p3_guitarPhrasesCount = ~p3_guitarPhrasesCount - 1;
        }
        {4}  {
            if(~p3_lastStarter.notNil && 0.5.coin) {
                weights = ~p3_setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastStarter, ~p3_buffers[\guitar].size-1), 1);
                
            } {
                weights = [2,1,2,1,2,1,2,2];
                
            };
        }
        {~p3_guitarNoteCount}    {
            if(0.75.coin) {
                weights = ~p3_setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastGuitar, ~p3_buffers[\guitar].size-1), 1);
            } {
                weights = ~p3_setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastGuitar, ~p3_buffers[\guitar].size-1, 2), 1);                    
            };
        };
    
    ~p3_guitarNoteCount = ~p3_guitarNoteCount - 1;
    
    buffer = ~p3_buffers[\guitar].wchoose(weights.normalizeSum);
    ~p3_lastGuitar = ~p3_buffers[\guitar].indexOf(buffer);
    if(~p3_guitarNoteCount == 4) {
        ~p3_lastStarter = ~p3_lastGuitar;
    };
    Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, buffer, \pan, ~p3_y.linlin(0, 1, -1, 1), \amp, ~p3_amps[\guitar] * amp, \rate, 1*rate]);
};  

"Functions loaded".postln;
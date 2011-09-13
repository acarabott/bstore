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
            // "resolved!".postln;
            weights = 0!8;
            if(~p3_guitarPhrasesCount == 1) {
                nearest = ~p3_lastGuitar.nearestInList(~p3_phraseResolvers);
                // "phrases resolved!".postln;
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
            // "start".postln;
            if(~p3_lastStarter.notNil && 0.5.coin) {
                weights = ~p3_setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastStarter, ~p3_buffers[\guitar].size-1), 1);
                
            } {
                weights = [2,1,2,1,2,1,2,2];
                
            };
        }
        {~p3_guitarNoteCount}    {
            if(0.75.coin) {
                // "step".postln;
                weights = ~p3_setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastGuitar, ~p3_buffers[\guitar].size-1), 1);
            } {
                // "thirds".postln;
                weights = ~p3_setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastGuitar, ~p3_buffers[\guitar].size-1, 2), 1);                    
            };
        };
    
    // weights.postln;
    ~p3_guitarNoteCount = ~p3_guitarNoteCount - 1;
    
    buffer = ~p3_buffers[\guitar].wchoose(weights.normalizeSum);
    ~p3_lastGuitar = ~p3_buffers[\guitar].indexOf(buffer);
    if(~p3_guitarNoteCount == 4) {
        ~p3_lastStarter = ~p3_lastGuitar;
    };
    Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, buffer, \pan, ~p3_y.linlin(0, 1, -1, 1), \amp, ~p3_amps[\guitar] * amp, \rate, 1*rate]);
};  

"Functions loaded".postln;
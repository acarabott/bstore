~p3_server.();
~p3_loadsynthdefs.();
~p3_variables.();
~p3_busses.();
~p3_responders.();
~p3_functions.();
~p3_buffers.();
~p3_synths.();

~p3_stop.();
~p3_stop = {
    ~p3_mouseResponder.remove;
    ~control.stop;
    ~drums.stop;
    ~guitar.stop;
    ~p3_bassline_1.stop;
};
~control.play
~control.stop;
(
~control = Routine {
    "Bass start".postln;
    ~p3_bassline_1.play(~p3_clock, Quant(4));
    // 10.wait;
    1.wait;
    "Bass Moving".postln;
    ~p3_bassMove = true;
    // 10.wait;
    1.wait;
    "Drums start".postln;
    ~drums.play(~p3_clock, Quant(4));
    ~drumBuild.play;
    
    //  Guitar pre made
    
    // Guitar interactive
    
    // Guitar crazy
    // Drums On beat
    //
};

~drumBuild = Routine {
    //  Initialise
    ~p3_hatsOn     = false;
    ~p3_kickOn     = false;
    ~p3_snareOn    = false;
    ~p3_hatsPat    = ~p3_hatsPats[\offbeat];
    ~p3_drumVerbRoutine.stop;
    0.5.wait;
    ~p3_drumVerbRoutine.reset;
    ~p3_drumVerbRoutine.play;
    ~p3_drumVerb.set(\room, ~p3_drumRoomInit);
    
    5.wait;
    //  Start routine
    ~p3_hatsOn = true;
    // 20.wait;
    2.wait;
    "Kick start".postln;
    ~p3_kickOn = true;
    // 10.wait;
    2.wait;
    "Snare start, hats change.".postln;
    ~p3_hatsPat = ~p3_hatsPats[\main];
    ~p3_snareOn = true;
    // 20.wait;
    2.wait;
    "Drum reverb interactive".postln;
    ~p3_drumVerbRoutine.play;
};

~p3_bassline_1 = Routine {
    var next = true;
    
    inf.do{ |i|
        var amp;
        var note;
        var rand;
        
        if(i%4 == 0) {
            amp = 0.2;
        } {
            amp = 0.1;
        };
        
        note = ~p3_root;
        if(~p3_bassMove) {
            if(~p3_y <= 0.5 && next) {
                note = [~p3_root-5, ~p3_root+7].wchoose([0.25, 0.25]);
                if(0.9.coin) {
                    next = false;
                };
        
            } {
                if(0.1.coin) {
                    next = true;
                };
            };
        };
        
        Synth(\BSP3_Bass, [\freq, note.midicps, \amp, amp*~p3_bassamp]);        
        Synth(\BSP3_Bass, [\freq, (note-12).midicps, \amp, amp*~p3_bassamp]);
        
        0.5.wait;
    }
};

~drums = Routine {
    inf.do {|i|
        var index = i%16;
        var mult = 1;
        var kickWrap, snareWrap, hatsWrap;
        kickWrap = ~p3_kickPat.wrapAt(i);
        snareWrap = ~p3_snarePat.wrapAt(i);
        hatsWrap = ~p3_hatsPat.wrapAt(i);
        if(~p3_kickOn) {
            if(kickWrap == 1) {
                Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_kickBuffer, \pan, 0, \amp, ~p3_drumsamp, \out, ~p3_drumVerbBus]);
            };
        };
        if(~p3_snareOn) {
            if(snareWrap == 1) {
                Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_snareBuffer, \pan, 0, \amp, ~p3_drumsamp, \out, ~p3_drumVerbBus]);
            } {
                if(snareWrap == 2 && 0.1.coin) {
                    Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_snareBuffer, \pan, 0, \amp, ~p3_drumsamp, \out, ~p3_drumVerbBus]);
                };
            };
        };
        if(~p3_hatsOn) {
            if(hatsWrap == 1) {
                Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_hatsBuffer, \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_drumsamp, \out, ~p3_drumVerbBus]);
            } {
                if(hatsWrap == 2 && 0.25.coin) {
                    ~p3_double.({Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_hatsBuffer, \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_drumsamp, \out, ~p3_drumVerbBus])}, 2, 2);
                };
            };
        };
        0.5.wait;
    };
};

~p3_drumVerbRoutine = Routine {
    inf.do {|i|
        ~p3_drumVerb.set(\room, ~p3_y);   //  This should be overall activity level, all quarters
        0.1.wait;
    };
};


~guitar = Routine {
    var rand;
    inf.do { |i|        
        if(~p3_x >=0.5) {
            if(~rowdyguitar) {
                rand = [1, 2].choose;
                ~p3_double.(f, rand*4, rand);
            } {
                if(0.2.coin) {
                    ~p3_double.(f, 2)
                } {
                    f.();
                };
            
            };
        
            ~guitar = false;
        } {
            if(~p3_guitarRetrig.coin) {
                ~guitar = true;
            };
        };
    
        0.5.wait;
    };
};
)

(
~p3_server = {
    s.options.memSize = 2**18;
    s.waitForBoot {
        "Server Booted".postln;        
    };
};
~p3_variables = {
    ~p3_clock = TempoClock(160/60);
    ~p3_bassamp = 1;
    ~p3_guitaramp = 1;
    ~p3_drumsamp = 1;

    ~p3_root = 50;
    
    ~p3_bassMove = false;
    
    ~p3_kickOn     = false;
    ~p3_snareOn    = false;
    ~p3_hatsOn     = false;
    ~p3_kickPat    = [1, 0, 0, 0,      0, 0, 1, 1,     0, 0, 1, 0,     0, 0, 0, 0];
    ~p3_snarePat   = [0, 0, 0, 1,      0, 0, 0, 0,     0, 0, 0, 0,     1, 2, 2, 2];
    ~p3_hatsPats = Dictionary.new;
    ~p3_hatsPats.add(\offbeat -> [0, 0, 1, 0]);
    ~p3_hatsPats.add(\main -> [0, 2, 1, 0,      0, 1, 0, 0,     0, 1, 0, 2,     0, 0, 1, 0]);
    ~p3_hatsPats.add(\quavers -> [1, 0]);
    ~p3_hatsPat = ~p3_hatsPats[\offbeat];
    ~p3_hatsPat = ~p3_hatsPats[\main];
    
    ~p3_drumRoomInit = 0.2;
    ~p3_guitarRoomInit = 0.8;
    ~p3_varsawRoomInit = 1;
    
    ~p3_guitarRetrig = 0.3;
    
    ~p3_lastGuitar = nil;
    ~p3_lastStarter = nil;
    ~p3_guitarNoteCount = 4;
    ~p3_guitarPhrasesCount = 4;
    ~p3_guitarResolvers = [0, 1, 2, 4, 5, 7];
    ~p3_phraseResolvers = [0, 7];
    
    
    "Variables initialised".postln;
};

~p3_loadsynthdefs = {
    SynthDef(\BSP3_Bass) { |out=0, freq=110, amp=1|
        var saw = LFSaw.ar(freq, 0, amp/6);
        var sin = SinOsc.ar(freq, 0, amp);
        var env = Env.perc(0.01, 0.5, 1);
        // var env = Env.triangle(0.3, 1);        
        // var env = Env.linen(0.01, 0.05, 0.2, amp, 'sine');
        var envgen = EnvGen.ar(env, doneAction: 2);
        var sig = Mix.ar([saw, sin]);
        Out.ar(out,
            (sig*envgen).dup
        );
    
    }.add;

    SynthDef(\BSP3_Sampler) { |out=0, buf=0, amp=0.5, pan=0, rate=1|
        var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf)*rate)*amp;
        DetectSilence.ar(sig, 0.01, 2, 2);
        Out.ar(out,
            // Pan4
            Pan2.ar(sig, pan);
        );
    }.add;

    SynthDef(\BSP3_Mouse) { |out=0, rate=10|
        var imp = Impulse.kr(rate);
        var x = MouseX.kr(0, 1, 0, 0);
        var y = MouseY.kr(1, 0, 0, 0);
    
        SendReply.kr(imp, \xy, [x, y]);
    }.add;

    SynthDef(\BSP3_Reverb) { |in=0, out=0, mix=0.5, room=0.8, damp=0.4|
        var sig = In.ar(in, 2);
        var verb = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
    
        Out.ar(out,
            Mix.ar([sig, verb])
        );
    }.add;    
    
    SynthDef(\BSP3_VarSaw) { |out=0, freq=440, amp=0.25|
        var sig = Mix.new(VarSaw.ar(freq * [0.5,1,2], 0, LFNoise1.kr(0.3,0.1,0.1), 0.1));
        var line = Line.kr(20000, 1000, 1.5);
        var lpf = LPF.ar(sig, line);
        var env = EnvGen.ar(Env.linen(0.5, 0.75, 1, amp, 'sine'), doneAction: 2);

        Out.ar(out,
            lpf.dup * env
        );
    }.add;
    
    "SynthDefs loaded".postln;
};

~p3_busses = {
    // Will need to have 4 channel busses and two reverbs per bus
    ~p3_drumVerbBus = Bus.audio(s, 2);
    ~p3_guitarVerbBus = Bus.audio(s, 2);
    ~p3_varsawVerbBus = Bus.audio(s, 2);
    "Busses initialised".postln;
};

~p3_responders = {
    ~p3_mouseResponder = OSCresponderNode(s.addr, \xy, {|t, r, msg| }).add;

    ~p3_mouseResponder.action_({|t, r, msg|
        ~p3_x = msg[3];
        ~p3_y = msg[4];
    });
    
    "Responders loaded".postln;
};

~p3_functions = {
    ~p3_double = {|func, mult=2, div=2|
        {
            mult.do { |i|
                func.();
                (0.5 / div).wait;
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
    
    ~p3_guitarNote = {
        var buffer, weights, nearest, sResolvers, neighbours;
        
        switch (~p3_guitarNoteCount)
            {1}  {
                "resolved!".postln;
                weights = 0!8;
                if(~p3_guitarPhrasesCount == 1) {
                    nearest = ~p3_lastGuitar.nearestInList(~p3_phraseResolvers);
                    "phrases resolved!".postln;
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
                "start".postln;
                if(~p3_lastStarter.notNil && 0.5.coin) {
                    weights = ~setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastStarter, ~p3_guitarBuffers.size-1), 1);
                    
                } {
                    weights = [2,1,2,1,2,1,2,2];
                    
                };
            }
            {~p3_guitarNoteCount}    {
                if(0.75.coin) {
                    "step".postln;
                    weights = ~setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastGuitar, ~p3_guitarBuffers.size-1), 1);
                } {
                    "thirds".postln;
                    weights = ~setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastGuitar, ~p3_guitarBuffers.size-1, 2), 1);                    
                };
            };
        
        weights.postln;
        ~p3_guitarNoteCount = ~p3_guitarNoteCount - 1;
        
        buffer = ~p3_guitarBuffers.wchoose(weights.normalizeSum);
        ~p3_lastGuitar = ~p3_guitarBuffers.indexOf(buffer);
        if(~p3_guitarNoteCount == 4) {
            ~p3_lastStarter = ~p3_lastGuitar;
        };
        Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, buffer, \pan, ~p3_y.linlin(0, 1, -1, 1), \amp, ~p3_guitaramp, \rate, 1]);
    };  
    
    "Functions loaded".postln;
};

~p3_buffers = {
    ~p3_guitarBuffers = "/Users/arthurc/Documents/programming/computerMusic/bstore/audio/guitarD/*.aif".pathMatch.collect {|file| Buffer.read(s, file)};
    ~p3_kickBuffer = Buffer.read(s, "sounds/kick.aif");
    ~p3_snareBuffer = Buffer.read(s, "sounds/snare.aif");
    ~p3_hatsBuffer = Buffer.read(s, "sounds/hhc4.aif");
    
    "Buffers loaded".postln;
};

~p3_synths = {
    ~p3_mouseSynth = Synth(\BSP3_Mouse);
    ~p3_drumVerb = Synth(\BSP3_Reverb, [\in, ~p3_drumVerbBus, \damp, 0.4, \mix, 0.8, \room, ~p3_drumRoomInit]);
    ~p3_guitarVerb = Synth(\BSP3_Reverb, [\in, ~p3_guitarVerbBus, \damp, 0.4, \mix, 0.8, \room, ~p3_guitarRoomInit]);
    ~p3_varsawVerb = Synth(\BSP3_Reverb, [\in, ~p3_varsawVerbBus, \damp, 0.1, \mix, 1, \room, ~p3_varsawRoomInit]);
    "Synths started".postln;
};
)

~xo = 0;
x = [[4, 4], [3, 4], [5, 4], [1, 4],    [4, 4], [3, 4-~xo], [1, 1.5], [0, 1.5], [2, 1.5], [nil, 3.5]];
x = [[5, 4], [6, 4], [7, 4], [4, 4],    [5, 4], [6, 4], [4, 8]]
x = [[2, 2], [1, 2], [2, 1], [3, 2],    [2, 2], [1, 2], [2, 1], [0, 2],     [2, 2], [1, 2], [2, 1], [3, 2], [4, 4], [nil, 7]];
({
    ~xo.wait;
    
    10.do {
        x.do { |item, i|
            var wait = 0;
            if(item[0].notNil) {
                // Make these pan positions 4 way!
                Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, ~p3_guitarBuffers[item[0]], \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_guitaramp, \rate, 1]);
                Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, ~p3_guitarBuffers[item[0]], \pan, ~p3_x.linlin(0, 1, 1, -1), \amp, ~p3_guitaramp, \rate, 0.5]);
                
                Synth(\BSP3_VarSaw, [\freq, (~p3_root  + Scale.minor.degrees[item[0]]).midicps, \out, ~p3_varsawVerbBus]);
                Synth(\BSP3_VarSaw, [\freq, (~p3_root  + 12 + Scale.minor.degrees[item[0]]).midicps, \out, ~p3_varsawVerbBus]);
                
                wait = wait + (item[1]/8);

                (item[1]/8).wait;
                Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, ~p3_guitarBuffers[item[0]], \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_guitaramp/2, \rate, 2]);
                wait = wait + (item[1]/8);
                (item[1]/8).wait;
                Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, ~p3_guitarBuffers[item[0]], \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_guitaramp/2, \rate, 4]);
            
            };
            (item[1] - wait).wait;
        };
    }
}.fork(~p3_clock, quant:Quant(4))
)

 
// Capture melodic patterns
// Guitar activity control
// Guitar effects
// Larger scale decisions - play / don't play for x time
// Large pads every now and then
// Changing from sets of drum patterns
// Write possible structures for piece
// Root note changes.

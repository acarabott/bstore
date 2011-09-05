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
    ~p3_drumRoutine.stop;
    ~p3_drumBuild.stop;
    ~p3_interactiveGuitar.stop;
    ~p3_bassline_1.stop;
    ~p3_guitarStart.stop;
    ~p3_guitarMelody.stop;
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
    ~p3_drumRoutine.play(~p3_clock, Quant(4));
    ~p3_drumBuild.play;
    
    "Guitar starts".postln;
    ~p3_guitarStart.play(~p3_clock, Quant(4));
    // TODO have this accumlate activity, once it hits threshold move onto next section
    // (4 * 60).wait;
    10.wait;
    // When an activity level reaches 0.75 or so do
    ~p3_hatsPat = ~p3_hatsPats[\quavers];
    // (2 * 60).wait;
    10.wait;
    ~p3_guitarStart.stop;
    
    // Guitar melodies start
    ~p3_guitarMelody.play(~p3_clock, Quant(4));
    // as this acumulates and hits 0.75 then do 
    ~p3_guitarActivityLevel = 0.75;
    ~p3_snarePat = ~p3_snarePats[\active];
    (3 * 60).wait;
    // Drums stop, guitar harmony thickens, bass changes to Lydian root
    ~p3_drumRoutine.stop;
    ~p3_guitarActivityLevel = 1;
    ~p3_bassNote = ~p3_root - 4;
    ~p3_thickGuitarHarmony = true;
    // TODO fade ~p3_guitaramp down to 0
    // TODO fade ~p3_varsawamp up to 0.8
    (3 * 60).wait;    
    ~p3_drumBuild.reset;
    ~p3_drumRoutine.reset;
    10.wait;
    ~p3_drumReset.();
    ~p3_drumRoutine.play(~p3_clock, Quant(4));
    ~p3_drumBuild.play;
    
    ~p3_guitarMelody.stop;
    ~p3_bassNote = ~p3_root;
    // Guitar interactive
    // Guitar crazy
    // Drums On beat
};
)
(
~p3_drumBuild = Routine {
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
    
    
    // ~p3_guitarVerbRoutine.play;
    // ~p3_varsawVerbRoutine.play;
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
        
        note = ~p3_bassNote;
        if(~p3_bassMove) {
            if(~p3_y <= 0.5 && next) {
                note = [~p3_bassNote-5, ~p3_bassNote+7].wchoose([0.25, 0.25]);
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

~p3_drumRoutine = Routine {
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
                if(snareWrap > 1 && (1 / snareWrap).coin) {
                    Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_snareBuffer, \pan, 0, \amp, ~p3_drumsamp, \out, ~p3_drumVerbBus]);
                    
                };
            };
        };
        if(~p3_hatsOn) {
            if(hatsWrap == 1) {
                Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_hatsBuffer, \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_drumsamp, \out, ~p3_drumVerbBus]);
            } {
                if(hatsWrap > 1 && (1 / hatsWrap).coin) {
                    Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_hatsBuffer, \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_drumsamp, \out, ~p3_drumVerbBus]);
                };
                
                if(~p3_hatsPat === ~p3_hatsPats[\main] && (hatsWrap == 2)) {
                    ~p3_double.({Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_hatsBuffer, \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_drumsamp, \out, ~p3_drumVerbBus])}, 2, 2);
                };
            };
        };
        0.5.wait;
    };
};

~p3_drumVerbRoutine = Routine {
    inf.do {|i|
        ~p3_drumVerb.set(\room, ~p3_y);   // TODO  This should be overall activity level, all quarters
        0.1.wait;
    };
};

~p3_guitarVerbRoutine = Routine {
    inf.do {|i|
        ~p3_guitarVerb.set(\room, ~p3_y.linlin(0, 1, 0.6, 1));   // TODO  This should be overall activity level, all quarters
        0.1.wait;
    };
};

~p3_varsawVerbRoutine = Routine {
    inf.do {|i|
        ~p3_varsawVerb.set(\room, ~p3_y.linlin(0, 1, 0.6, 1));   // TODO  This should be overall activity level, all quarters
        0.1.wait;
    };
};

~p3_guitarStart = Routine {
    inf.do {|i|
        if(~p3_guitarResolved.not && (~p3_guitarStartProb).coin) {
            ~p3_guitarNote.();
        } {
            if(0.5.coin) {
                ~p3_guitarResolved = false;
            };
        };
        0.5.wait;
    };
};

// ~p3_guitarMelody.play(~p3_clock, Quant(4));
// ~p3_guitarMelody.stop
// ~p3_varsawamp = 0.5;
// ~p3_thickGuitarHarmony = true;
// ~p3_guitaramp = 1;
// ~p3_bassamp = 1
~p3_guitarMelody = Routine {
    inf.do {|i|
        var melody;
        i.postln;
        // TODO Make this cumulative activity level
        if(~p3_guitarActivityLevel.coin) {
            "play!".postln;
            melody = ~p3_guitarMelodies.choose;
            melody.do { |melody, j|
                var wait = 0;
                var synths = List[];
                
                if(melody[0].notNil) {
                    // TODO Make these pan positions 4 way!
                    Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, ~p3_guitarBuffers[melody[0]], \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_guitaramp, \rate, 1]);
                    Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, ~p3_guitarBuffers[melody[0]], \pan, ~p3_x.linlin(0, 1, 1, -1), \amp, ~p3_guitaramp, \rate, 0.5]);
                
                    if(~p3_guitarMelodyCount >= 3) {
                        synths.add([~p3_root  + Scale.minor.degrees.wrapAt(melody[0]), ~p3_x.linlin(0, 1, -1, 1)]);
                    };
                    if(~p3_guitarMelodyCount >= 7) {
                        synths.add([~p3_root  + 12 + Scale.minor.degrees.wrapAt(melody[0]), ~p3_x.linlin(0, 1, 1, -1)]);
                    };
                    if(~p3_thickGuitarHarmony) {
                        synths.add([~p3_root + Scale.minor.degrees.wrapAt(melody[0]-2), ~p3_x.linlin(0, 1, -1, 1)]);
                        synths.add([~p3_root + 12 + Scale.minor.degrees.wrapAt(melody[0]-2), ~p3_x.linlin(0, 1, 1, -1)]);
                        synths.add([~p3_root + 24 + Scale.minor.degrees.wrapAt(melody[0]+2), ~p3_x.linlin(0, 1, -1, 1)]);
                    };
                    
                    synths.do { |synth|
                        Synth(\BSP3_VarSaw, [\amp, ~p3_varsawamp/synths.size, \freq, synth[0].midicps, \out, ~p3_varsawVerbBus, \pan, synth[1]]);
                    };
                    wait = wait + (melody[1]/8);

                    (melody[1]/8).wait;
                    Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, ~p3_guitarBuffers[melody[0]], \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_guitaramp/2, \rate, 2]);
                    wait = wait + (melody[1]/8);
                    (melody[1]/8).wait;
                    Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, ~p3_guitarBuffers[melody[0]], \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_guitaramp/2, \rate, 4]);
            
                };
                (melody[1] - wait).wait;
            };
            ~p3_guitarMelodyCount = ~p3_guitarMelodyCount + 1;
        } {
            "no play".postln;
            8.wait;
        };
        
    }
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
    ~p3_varsawamp = 0.4;
    
    ~p3_root = 50;
    ~p3_bassNote = ~p3_root;
    
    ~p3_bassMove = false;
    
    ~p3_kickOn      = false;
    ~p3_snareOn     = false;
    ~p3_hatsOn      = false;
    ~p3_snarePats   = Dictionary.new;
    ~p3_hatsPats    = Dictionary.new;
    ~p3_kickPat     =               [1, 0, 0, 0,      0, 0, 1, 1,     0, 0, 1, 0,     0, 0, 0, 0];
    ~p3_snarePats.add(\main ->      [0, 0, 0, 1,      0, 0, 0, 0,     0, 0, 0, 0,     1, 10, 10, 10]);
    ~p3_snarePats.add(\active ->    [0, 0, 0, 1,      0, 0, 1, 2,     1, 0, 2, 0,     1, 5, 5, 5]);
    ~p3_hatsPats.add(\offbeat ->    [0, 0, 1, 0]);
    ~p3_hatsPats.add(\main ->       [0, 10, 1, 0,      0, 1, 0, 0,     0, 1, 0, 10,     0, 0, 1, 0]);
    ~p3_hatsPats.add(\quavers ->    [1, 5]);
    
    ~p3_snarePat    = ~p3_snarePats[\main];
    ~p3_hatsPat     = ~p3_hatsPats[\main];
    
    ~p3_drumRoomInit = 0.2;
    ~p3_guitarRoomInit = 0.8;
    ~p3_varsawRoomInit = 1;
    
    ~p3_guitarRetrig = 0.3;
    ~p3_guitarResolved = false;
    
    ~p3_lastGuitar = nil;
    ~p3_lastStarter = nil;
    ~p3_guitarNoteCount = 4;
    ~p3_guitarPhrasesCount = 4;
    ~p3_guitarResolvers = [0, 1, 2, 4, 5, 7];
    ~p3_phraseResolvers = [0, 7];
    
    ~p3_guitarMelodies = Dictionary.new;
    ~p3_guitarMelodies.add(\one ->      [[4, 4], [3, 4], [5, 4], [1, 4],    [4, 4], [3, 4], [1, 1.5],           [0, 1.5], [2, 1.5], [nil, 3.5]] );
    ~p3_guitarMelodies.add(\two ->      [[5, 4], [6, 4], [7, 4], [4, 4],    [5, 4], [6, 4], [4, 8]]);
    ~p3_guitarMelodies.add(\three ->    [[2, 2], [1, 2], [2, 1], [3, 2],    [2, 2], [1, 2], [2, 1], [0, 2],     [2, 2], [1, 2], [2, 1], [3, 2], [4, 4], [nil, 7]]);
    
    ~p3_thickGuitarHarmony = false;
    ~p3_guitarStartProb = 1/16;
    ~p3_guitarActivityLevel = 0;
    ~p3_guitarMelodyCount = 0;
    "Variables initialised".postln;
};

~p3_loadsynthdefs = {
    SynthDef(\BSP3_Bass) { |out=0, freq=110, amp=1|
        var saw = LFSaw.ar(freq, 0, amp/6);
        var sin = SinOsc.ar(freq, 0, amp);
        var env = Env.perc(0.01, 0.5, 1);
        var envgen = EnvGen.ar(env, doneAction: 2);
        var sig = Mix.ar([saw, sin]);
        Out.ar(out,
            (sig*envgen).dup
        );
    
    }.add;

    SynthDef(\BSP3_Sampler) { |out=0, buf=0, amp=0.5, pan=0, rate=1|
        var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf)*rate, doneAction: 2)*amp;
        Out.ar(out,
            // TODO Pan4
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
    
    SynthDef(\BSP3_VarSaw) { |out=0, freq=440, amp=0.25, pan=0|
        var sig = Mix.new(VarSaw.ar(freq * [0.5,1,2], 0, LFNoise1.kr(0.3,0.1,0.1), 0.1));
        var line = Line.kr(20000, 1000, 1.5);
        var lpf = LPF.ar(sig, line);
        var env = EnvGen.ar(Env.linen(0.2, 0.75, 1, amp, 'sine'), doneAction: 2);

        Out.ar(out,
            // TODO Pan4
            Pan2.ar(lpf * env, 0);
            
        );
    }.add;
    
    "SynthDefs loaded".postln;
};

~p3_busses = {
    // TODO Will need to have 4 channel busses and two reverbs per bus
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
        // Move updating routines to here...
    });
    
    "Responders loaded".postln;
};
)
(
~p3_functions = {
    ~p3_drumReset = {
        //  Initialise
        ~p3_hatsOn     = false;
        ~p3_kickOn     = false;
        ~p3_snareOn    = false;
        ~p3_hatsPat    = ~p3_hatsPats[\offbeat];
        ~p3_snarePat    = ~p3_snarePats[\main];
        
        // ~p3_drumVerbRoutine.stop;
        // 0.5.wait;
        // ~p3_drumVerbRoutine.reset;
        // ~p3_drumVerbRoutine.play;
        ~p3_drumVerb.set(\room, ~p3_drumRoomInit);    
        
        "Drums reset".postln;
    };
    
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
        ~p3_guitarResolved = false;
        switch (~p3_guitarNoteCount)
            {1}  {
                ~p3_guitarResolved = true;
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
                    weights = ~p3_setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastStarter, ~p3_guitarBuffers.size-1), 1);
                    
                } {
                    weights = [2,1,2,1,2,1,2,2];
                    
                };
            }
            {~p3_guitarNoteCount}    {
                if(0.75.coin) {
                    "step".postln;
                    weights = ~p3_setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastGuitar, ~p3_guitarBuffers.size-1), 1);
                } {
                    "thirds".postln;
                    weights = ~p3_setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastGuitar, ~p3_guitarBuffers.size-1, 2), 1);                    
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


 
// TODO Capture melodic patterns
// TODO Guitar activity control
// TODO Guitar effects
// TODO Larger scale decisions - play / don't play for x time
// TODO Large pads every now and then
// TODO Changing from sets of drum patterns
// TODO Write possible structures for piece
// TODO Root note changes.
// TODO Guitar phrases of different no.

~p3_interactiveGuitar = Routine {
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
        } {
        };
    
        0.5.wait;
    };
};

~p3_guitarMelodies.add(\four -> [[7, 1.5], [4, 1.5], [5, 1.5], [2, 1.5], [nil, 4], [4, 1.5], [2, 1.5], [3, 1.5], [0, 1.5], [nil, 8]])
~p3_guitarMelodies.add(\five -> [[7, 4], [4, 4], [5, 4], [2, 4], [nil, 8], [4, 4], [2, 4], [4, 4], [0, 4], [nil, 16]])
~p3_guitarMelodies.add(\six -> [[0, 4], [1, 4], [2, 8],    [2, 4], [3, 4], [4, 8]])

~p3_guitaramp = 1
~p3_varsawamp = 1
~p3_thickGuitarHarmony = false
~p3_guitarMelodies = Dictionary.new;

~p3_guitarMelodies.add(\four -> [[4, 4], [3, 6], [0, 2], [1, 8]])
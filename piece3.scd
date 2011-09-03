s.options.memSize = 32768;
s.boot;

t = TempoClock(160/60);
~bassamp = 1;
~guitaramp = 1;
~drumsamp = 1;
SynthDef(\BStorePiece3_Bass) { |out=0, freq=110, amp=1|
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

SynthDef(\BStorePiece3_Sampler) { |out=0, buf=0, amp=0.5, pan=0, rate=1|
    var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf)*rate)*amp;
    DetectSilence.ar(sig, 0.01, 2, 2);
    Out.ar(out,
        // Pan4
        Pan2.ar(sig, pan);
    );
}.add;

SynthDef(\BStorePiece3_Mouse) { |out=0, rate=10|
    var imp = Impulse.kr(rate);
    var x = MouseX.kr(0, 1, 0, 0);
    var y = MouseY.kr(1, 0, 0, 0);
    
    SendReply.kr(imp, \xy, [x, y]);
}.add;

SynthDef(\BStorePiece3_Reverb) { |in=0, out=0, mix=1, room=0.9, damp=0.01|
    var sig = In.ar(in, 2);
    var verb = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
    
    Out.ar(out,
        verb
    );
}.add;

~verbBus = Bus.audio(s, 2);
~reverb = Synth(\BStorePiece3_Reverb, [\in, ~verbBus]);

Synth.before(~reverb, \BStorePiece3_Sampler, [\out, ~verbBus, \buf, ~guitarBuffers.choose, \pan, ~pan, \amp, ~guitaramp, \rate, 1]);



x = Synth(\BStorePiece3_Mouse);

o = OSCresponderNode(s.addr, \xy, {|t, r, msg| }).add;

o.action_({|t, r, msg|
    ~pan = msg[3].linlin(0, 1, -1, 1);
    if(msg[4] >= 0.5) {
        ~trig = true;
    } {
        ~trig = false;
    };
    
    ~x = msg[3];
    ~y = msg[4];
});

~guitarBuffers = "/Users/arthurc/Documents/programming/computerMusic/bstore/audio/guitarD/*.aif".pathMatch.collect {|file| Buffer.read(s, file)};

~kick = Buffer.read(s, "sounds/kick.aif");
~snare = Buffer.read(s, "sounds/snare.aif");
~hats = Buffer.read(s, "sounds/hhc4.aif");

Tdef(\bassline).play(t, quant:Quant(4));
Tdef(\bassline).stop;

~rowdyguitar = false;
~rowdyguitar = true;

(
    ~root = 50;
    ~next = true;
    ~guitar = true;
    Tdef(\bassline, {
    inf.do{ |i|
        var amp;
        var note;
        
        if(i%4 == 0) {
            amp = 0.2;
        } {
            amp = 0.1;
        };
        
        if(~trig.not && ~next) {
            // note = [57, 62, 53].choose;
            note = [~root, ~root-5, ~root+7].wchoose([0.5, 0.25, 0.25]);
            if(0.5.coin) {
                ~next = false;
            };
            
        } {
            note = ~root;
            ~next = true;
        };

        Synth(\BStorePiece3_Bass, [\freq, note.midicps, \amp, amp*~bassamp]);        
        Synth(\BStorePiece3_Bass, [\freq, (note-12).midicps, \amp, amp*~bassamp]);
        
        
        if(~trig && ~guitar) {
            if(~rowdyguitar) {
                ~double.(f, [4].choose, [2, 4].choose);
            } {
                if(0.2.coin) {
                    ~double.(f, 2)
                } {
                    f.();
                };
                
            };
            
            ~guitar = false;
        } {
            if(0.666666.coin) {
                ~guitar = true;
            };
        };
        
        0.5.wait;
    }
});

)

(
f  = {|pan=0|
    var size = ~guitarBuffers.size;
    var rate = 1;
    if(~last.isNil) {
        ~last = size.rand;        
    } {
        ~prev = ~last;
        ~last = ~nextCol.choose;
        
        if(~prev == ~last) {
            ~direction = 'same';
        } {
            if(~prev < ~last) {
                ~direction = 'up';
            } {
                ~direction = 'down';
            };
        };
    };
    // ~nextCol = List[~last];
    ~nextCol = List[];

    //  Third up or down if possible
    if(0.25.coin) {
        if(~last < (size - 2)) {
            ~nextCol = ~nextCol.add(~last + 2);
        };
    
        if(~last > 1) {
            ~nextCol = ~nextCol.add(~last - 2);
        };
    };
    
    // Step
    if(~last < (size -1)) {
        ~nextCol = ~nextCol.add(~last + 1);
    };
    
    if(~last > 0) {
        ~nextCol = ~nextCol.add(~last - 1);
    };
    
    if(~rowdyguitar && 0.5.coin) {
        rate = (~x.linlin(0, 1.0, 0, 3).ceil)
        // rate = [0.5, 1.5, 2, 3].wchoose([4,1,4,4].normalizeSum);
    };
    
    Synth(\BStorePiece3_Sampler, [\buf, ~last, \mix, 1, \room, 0.9, \damp, 0.01, \pan, ~pan, \amp, ~guitaramp, \rate, rate]);
};
)
w = Window("BStorePiece3 Mixer", Rect(100, 100, 400, 300)).front;
w.view.addFlowLayout;
EZSlider(w, 50@(w.bounds.height*0.9), "Bass", \unipolar, layout:\vert, action:{ |slider|
    ~bassamp = slider.value;
});
EZSlider(w, 50@(w.bounds.height*0.9), "guitar", \unipolar, layout:\vert, action:{ |slider|
    ~guitaramp = slider.value;
});
EZSlider(w, 50@(w.bounds.height*0.9), "drums", \unipolar, layout:\vert, action:{ |slider|
    ~drumsamp = slider.value;
});


Tdef(\drums).play(t, quant:Quant(4));
Tdef(\drums).stop
~kickpat    = [1, 0, 0, 0,      0, 0, 1, 1,     0, 0, 1, 0,     0, 0, 0, 0];
~snarepat   = [0, 0, 0, 1,      0, 0, 0, 0,     0, 0, 0, 0,     1, 0, 0, 0];
~hatspat    = [0, 0, 1, 0,      0, 1, 0, 0,     0, 1, 0, 0,     0, 0, 1, 0];
// ~hatspat    = [0, 1, 1, 0,      0, 1, 1, 0,     0, 1, 1, 0,     0, 1, 1, 0];
// ~hatspat    = [1, 0, 1, 0,      1, 0, 1, 0,     1, 0, 1, 0,     1, 0, 1, 0];

(
Tdef(\drums, {
    var mix, room, damp, amp;
    
    mix = 0.9;
    room = 0.8;
    damp = 0.4;
    amp = 0.8;
    
    inf.do { |i|
        var index = i%16;
        var mult = 1;
        if(~kickpat.wrapAt(i) == 1) {
            Synth(\BStorePiece3_Sampler, [\buf, ~kick, \mix, mix, \room, room, \damp, damp, \pan, ~pan, \amp, ~drumsamp * amp]);
        };
        if(~snarepat.wrapAt(i) == 1) {
            Synth(\BStorePiece3_Sampler, [\buf, ~snare, \mix, mix, \room, room, \damp, damp, \pan, ~pan, \amp, ~drumsamp * amp]);
        } {
            if(index == 13 && (0.25.coin)) {
                Synth(\BStorePiece3_Sampler, [\buf, ~snare, \mix, mix, \room, room, \damp, damp, \pan, ~pan, \amp, ~drumsamp * amp]);
                
            };
        };
        if(~hatspat.wrapAt(i) == 1) {
            Synth(\BStorePiece3_Sampler, [\buf, ~hats, \mix, mix, \room, room, \damp, damp, \pan, ~pan, \amp, ~drumsamp * amp]);
        } {
            if(index == 1 && 0.25.coin) {
                ~double.({Synth(\BStorePiece3_Sampler, [\buf, ~hats, \mix, mix, \room, room, \damp, damp, \pan, ~pan, \amp, ~drumsamp * amp])}, 2, 2);
                
            };
        };
        0.5.wait;
    };
});
)

~double = {|func, mult=2, div=2|
    {
        mult.do { |i|
            func.();
            (0.5 / div).wait;
        };
    }.fork(t)
};

// Capture melodic patterns
// Guitar activity control
// Guitar effects
// Larger scale decisions - play / don't play for x time
// Large pads every now and then
// Changing from sets of drum patterns
// Write possible structures for piece
// Root note changes.

// Structure
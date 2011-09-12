s.boot;

SynthDef(\BSP1_Pad) {|out=0, rootnote = 45, mix=0.5, room=0.8, damp=0.1, min=0.05, attack=1.5, decay=0.2, sustain=1, release=1, peak=0.1, gate=0, ffreq=250, pan=0, lag=1.6|
    var rootcps = Lag.kr(rootnote.midicps, lag);
    // var fifthcps = Lag.kr((rootnote + 7).midicps, lag);
    var root = Formant.ar(rootcps, rootcps*2, rootcps*4, 0.5);
    // var fifth = Formant.ar(fifthcps, fifthcps*2, fifthcps*4, 0.5);
    var octave = Formant.ar(rootcps*2, rootcps*4, rootcps*8, 0.5);
    
    // var combine = Mix.ar([root, fifth, octave]);
    var combine = Mix.ar([root, octave]);
    var verb = FreeVerb.ar(combine, mix, room, damp);
    
    var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release, peak-min), gate) + min;
    
    var drywet = Mix.ar([combine, verb]);
    
    var filt = HPF.ar(drywet, ffreq);
    
    Out.ar(out,
        Pan2.ar(env * filt, pan)
    );
    
}.add;


~p1_synths = Array.newClear(4);
~p1_synths.do { |item, i|
    // item.free
    item.set(\sustain, 0.5);
};

~p1_synths[0] = Synth(\BSP1_Pad, [\rootnote, 45]);
~p1_synths[1] = Synth(\BSP1_Pad, [\rootnote, 47]);
~p1_synths[2] = Synth(\BSP1_Pad, [\rootnote, 54]);
~p1_synths[3] = Synth(\BSP1_Pad, [\rootnote, 61]);

r = Routine {
    var lastIndex;
    inf.do {
        if(~p1_chords.size > 1) {
            ~p1_nextChordIndex = (0..(~p1_chords.size-1));
            lastIndex = ~p1_nextChordIndex.removeAt(~p1_chords.indexOf(~p1_chord));
            if(0.8.coin) {
                if(0.9.coin) {
                    "hi".postln;
                    ~p1_chord = ~p1_chords.wrapAt(lastIndex);
                };
            };
            ~p1_chord = ~p1_chords[~p1_nextChordIndex.choose];
        } {
            ~p1_chord = ~p1_chords.choose;
        };
        
        ~p1_synths.do { |item, i|
            item.set(\rootnote, ~p1_chord[i]);
        };
        10.wait;
    };
};
r.stop
r.play
~p1_chords = List[];
~p1_chords.add([45, 47, 54, 61]);
~p1_chords.add([45, 48, 53, 60]);
~p1_chords.add([45, 47, 54, 61]+1);
~p1_chords.add([45, 49, 54, 62]);
~p1_chords.add([45, 50, 54, 64]);
~p1_chords.add([45, 49, 57, 64]);
~p1_chords.add([46, 49, 56, 65]);
~p1_chords.add([46, 50, 55, 60]);
~p1_chord = ~p1_chords.choose;

~p1_chords = List[]; ~p1_chords.add([46, 50, 55, 60]);

~p1_synths.do { |item, i|
    item.set(\min, 0.01);
    item.set(\lag, 1);
};



ArrayedCollection
x.(2)

~p1_chord = ~p1_chords.choose;
~p1_synths.do { |item, i|
    item.set(\rootnote, ~p1_chord[i]);
};

MultiTouchPad.start
MultiTouchPad.setAction = {|curID, xys| 
    var x, y;
    var x1, x2, x3, x4, y1, y2, y3, y4;
    var b1, b2, b3, b4;
    var gates;
    
    
    gates = nil!4;
    
    x = xys[0];
    y = xys[1].linlin(0, 1, 1, 0);

    
    if(x < 0.5 && (y > 0.5)) {
        x1 = x.linlin(0, 0.5, 0, 1);
        y1 = y.linlin(0.5, 1, 0, 1);
    
        ~p1_synths[0].set(\pan, x1);
    
        if(y1 > 0.5) {
            gates[0] = 1;
        } {
            gates[0] = 0;
        };
        ~p1_synths[0].set(\gate, gates[0]);
    };
    
    if(x > 0.5 && (y > 0.5)) {
        x2 = x.linlin(0.5, 1, 0, 1);
        y2 = y.linlin(0.5, 1, 0, 1);
    
        ~p1_synths[1].set(\pan, x2);
        if(y2 > 0.5) {
            gates[1] = 1;
        } {
            gates[1] = 0;
        };
        ~p1_synths[1].set(\gate, gates[1]);
    
    };
    
    if(x < 0.5 && (y < 0.5)) {
        x3 = x.linlin(0, 0.5, 0, 1);
        y3 = y.linlin(0, 0.5, 0, 1);
    
        ~p1_synths[2].set(\pan, x3);
        if(y3 > 0.5) {
            gates[2] = 1;
        } {
            gates[2] = 0;
        };
        ~p1_synths[2].set(\gate, gates[2]);        
    };
    
    if(x > 0.5 && (y < 0.5)) {
        x4 = x.linlin(0.5, 1, 0, 1);
        y4 = y.linlin(0, 0.5, 0, 1);
    
        ~p1_synths[3].set(\pan, x4);
        if(y4 > 0.5) {
            gates[3] = 1;
        } {
            gates[3] = 0;
        };
        ~p1_synths[3].set(\gate, gates[3]);    
    };
    
};

MultiTouchPad.stop; //don't forget to stop



MIDIIn.connect(0, 2)
~notes = Dictionary.new;
~on = NoteOnResponder({ |src, chan, num, vel| [src, chan, num, vel].postln })
~on.function_({|src, chan, num, vel|
    ~notes.add(num.asSymbol -> Synth(\BStoreOne_Pad, [\rootnote, num, \sustain, vel.linlin(0, 127, 0, 1)]));
})
~off = NoteOffResponder({|src, chan, num, vel| [src, chan, num, vel].postln });
~off.function_({|src, chan, num, vel|
    ~notes[num.asSymbol].set(\gate, 0);
    ~notes.removeAt(num.asSymbol);
})

~responder = NoteOnResponder({ |src, chan, num, vel| [src, chan, num, vel].postln })
~responder.function_({|src, chan, num, vel|
    Ndef(\pad).set(\rootnote, num);
})



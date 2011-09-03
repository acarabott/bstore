s.boot;
Ndef(\pad).play;

(
    Ndef(\pad, {|rootnote = 45, mix=0.5, room=0.8, damp=0.1|
        var root = Formant.ar(rootnote.midicps, 220, 440, 0.5);
        var fifth = Formant.ar((rootnote+7).midicps, 220, 440, 0.5);
        var octave = Formant.ar((rootnote+12).midicps, 220, 440, 0.5);
        
        var combine = Mix.ar([root, fifth, octave]);
        var verb = FreeVerb.ar(combine, mix, room, damp);
        Mix.ar([combine, verb])
        
        
    })
)

Tdef(\notes).play;
Tdef(\notes).stop;
Tdef(\notes, {
    var notes = 45 + Scale.minor.degrees;
    var choice, prev;
    inf.do { |i|
        while({choice == prev}, {
            choice = notes.choose;
        });
        Ndef(\pad).set(\rootnote, notes.choose);
        prev = choice;
        2.wait;
    };
})


~responder = NoteOnResponder({ |src, chan, num, vel| [src, chan, num, vel].postln })
~responder.function_({|src, chan, num, vel|
    Ndef(\pad).set(\rootnote, num);
})


SynthDef(\BStoreOne_Pad) {|out=0, rootnote = 45, mix=0.5, room=0.8, damp=0.1, attack=1.5, decay=0.2, sustain=1, release=1, gate=1|
    var rootcps = rootnote.midicps;
    var fifthcps = (rootnote + 7).midicps;
    var root = Formant.ar(rootcps, rootcps*2, rootcps*4, 0.5);
    var fifth = Formant.ar(fifthcps, fifthcps*2, fifthcps*4, 0.5);
    var octave = Formant.ar(rootcps*2, rootcps*4, rootcps*8, 0.5);
    
    var combine = Mix.ar([root, fifth, octave]);
    var verb = FreeVerb.ar(combine, mix, room, damp);
    var env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);
    
    Out.ar(out,
        env * Mix.ar([combine, verb]);
    );
    
}.add;

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


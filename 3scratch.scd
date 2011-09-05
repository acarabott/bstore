s.options.memSize = 2**18;
s.boot;


Tdef(\bassline).play(t, quant:Quant(4));
Tdef(\bassline).stop;

~rowdyguitar = false;
~rowdyguitar = true;
~guitarfifth = false;
~guitarfifth = true;

~guitarRetrig = 0;
(
    ~root = 50;
    ~next = true;
    ~guitar = true;
    Tdef(\bassline, {
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

            note = ~root;
            if(~bassMove) {
                if(~y <= 0.5 && next) {
                    note = [~root-5, ~root+7].wchoose([0.25, 0.25]);
                    if(0.9.coin) {
                        next = false;
                    };

                } {
                    if(0.1.coin) {
                        next = true;
                    };
                };
            };

            Synth(\BStorePiece3_Bass, [\freq, note.midicps, \amp, amp*~bassamp]);        
            Synth(\BStorePiece3_Bass, [\freq, (note-12).midicps, \amp, amp*~bassamp]);

        
        if(~trig && ~guitar) {
            if(~rowdyguitar) {
                rand = [1, 2].choose;
                ~double.(f, rand*4, rand);
            } {
                if(0.2.coin) {
                    ~double.(f, 2)
                } {
                    f.();
                };
                
            };
            
            ~guitar = false;
        } {
            if(~guitarRetrig.coin) {
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
        rate = [1, 2, 4].choose;
        // rate = (~x.linlin(0, 1.0, 0, 3).ceil)
        // rate = [0.5, 1.5, 2, 3].wchoose([4,1,4,4].normalizeSum);
    };
    if(~guitarfifth) {
        rate = rate * 1.5;
    };
    
    Synth.before(~reverb, \BStorePiece3_Sampler, [\out, ~verbBus, \buf, ~last, \pan, ~pan, \amp, ~guitaramp, \rate, rate]);
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
            Synth.before(~reverb, \BStorePiece3_Sampler, [\buf, ~kick, \pan, 0, \amp, ~drumsamp * amp, \out, ~verbBus]);
        };
        if(~snarepat.wrapAt(i) == 1) {
            Synth.before(~reverb, \BStorePiece3_Sampler, [\buf, ~snare, \pan, 0, \amp, ~drumsamp * amp, \out, ~verbBus]);
        } {
            if(index == 13 && (0.25.coin)) {
                Synth.before(~reverb, \BStorePiece3_Sampler, [\buf, ~snare, \pan, 0, \amp, ~drumsamp * amp, \out, ~verbBus]);
                
            };
        };
        if(~hatspat.wrapAt(i) == 1) {
            Synth.before(~reverb, \BStorePiece3_Sampler, [\buf, ~hats, \pan, ~pan, \amp, ~drumsamp * amp, \out, ~verbBus]);
        } {
            if(index == 1 && 0.25.coin) {
                ~double.({Synth.before(~reverb, \BStorePiece3_Sampler, [\buf, ~hats, \pan, ~pan, \amp, ~drumsamp * amp, \out, ~verbBus])}, 2, 2);
                
            };
        };
        0.5.wait;
    };
});
)

Ndef(\BStorePiece3_Swoop, {|freq=440|
    var noise = WhiteNoise.ar(0.5);
    var hpf = HPF.ar(noise, 80);
    var lpf = LPF.ar(hpf, 5000);
    var filt = Formlet.ar(lpf, Demand.kr(Impulse.kr(0.25), 0, Dxrand((50 + Scale.minor.degrees).midicps, inf)), 0.5, 3, SinOsc.kr(1, 0, 0.05, 0.05));
    
    filt;
}).play;
Demand.kr(Impulse.kr(0.5, 0,Dxrand([50 + Scale.minor.degrees].midicps, inf)))
Tdef(\swoop, {
  inf.do{
    Ndef(\BStorePiece3_Swoop).set(\freq, (50 + Scale.minor.degrees).choose.midicps);
    2.wait;
  }
}).play;

s.internal.boot;
(
{ 
}.play )


Ndef(\klank, {
    DynKlank.ar(
        `[
            [100, 200, 300, 400, 500, 600, 700, 800]*2, 
            [0.05, 0.2, 0.04, 0.06, 0.11, 0.01, 0.15, 0.03, 0.15, 0.2]
        ], 
        LFSaw.ar(MouseX.kr(110, 880), 0, 0.1),
        // PinkNoise.ar(0.05), 
        1
    )
}).play;

(
Ndef(\swoop, {
	var sig = VarSaw.ar(
		110,
		0,									//iphase
        2,
		0.1									//mul
	);
	sig = Resonz.ar(sig, MouseX.kr(50, 1000), MouseY.kr(0.001, 8));
    Out.ar(0,
        sig.dup    
    );
}
).play;
)




SynthDef(\BSP3_Bass) { |out=0, freq=110, amp=1, xpos=0, ypos=0|
    var saw = LFSaw.ar(freq, 0, amp/6);
    var sin = SinOsc.ar(freq, 0, amp);
    var env = Env.perc(0.01, 0.5, 1);
    var envgen = EnvGen.ar(env, doneAction: 2);
    var sig = Mix.ar([saw, sin]);
    Out.ar(out,
        Pan4.ar(sig*envgen, xpos, ypos);
    );

}.add;

SynthDef(\BSP3_Sampler) { |out=0, buf=0, amp=0.5, pan=0, rate=1, dur=8, tail=1, xpos=0, ypos=0|
    var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf)*rate, doneAction: 2)*amp;
    var env = EnvGen.ar(Env.new([1,1,0], [dur, tail]), doneAction: 2);
    
    Out.ar(out,
        Pan4.ar(sig*env, xpos, ypos)
    );
}.add;

SynthDef(\BSP3_Reverb) { |in=0, out=0, mix=0.5, room=0.8, damp=0.4|
    var sig = In.ar(in, 4);
    var verbFront   = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
    var verbBack    = FreeVerb2.ar(sig[2], sig[3], mix, room, damp);
    var verbLeft    = FreeVerb2.ar(sig[0], sig[2], mix, room, damp);
    var verbRight   = FreeVerb2.ar(sig[1], sig[3], mix, room, damp);


    Out.ar(out,
        [
            Mix.ar([sig[0], verbFront[0]/2, verbLeft[0]/2]), 
            Mix.ar([sig[1], verbFront[1]/2, verbRight[0]/2]), 
            Mix.ar([sig[2], verbBack[0]/2, verbLeft[1]/2]),
            Mix.ar([sig[3], verbBack[1]/2, verbRight[1]/2])
        ]
    );
}.add;    

SynthDef(\BSP3_VarSaw) { |out=0, freq=440, amp=0.25, pan=0, att=0.2, sus=0.75, rel=1, rate=0.5, fgain=2, xpos=0, ypos=0, madgain=0|
    var sig = Mix.new(VarSaw.ar(freq * [0.5,1,2], 0, LFNoise1.kr(0.3,0.1,0.1), 0.1));
    var line = Line.kr(8000, 1000, 1);
    var lpf = LPF.ar(sig, line);
    var moog = MoogFF.ar(lpf, SinOsc.kr(rate).range(400,10000), fgain);
    var env = EnvGen.ar(Env.linen(att, sus, rel, amp, 'sine'), doneAction: 2);
    var madmoog = MoogFF.ar(lpf, line, madgain).range(-0.1, 0.1);
    var final = Mix.ar([moog, madmoog]);
    
    Out.ar(out,
        Pan4.ar(final * env, xpos, ypos)
    );
}.add;

"SynthDefs loaded".postln;

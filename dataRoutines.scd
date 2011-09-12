c = Condition(false);
r = Routine {
    var dirs = true!4;
    inf.do {
        c.wait;
        ~data.do { |item, i|
            if(dirs[i]) {
                if(item < 1) {
                    ~data[i] = item + 0.01;
                } {
                    dirs[i] = false;
                };
            } {
                if(item > 0) {
                    ~data[i] = item - 0.01;
                } {
                    dirs[i] = true
                };
            };
        };
        
        ~data.linlin(0, 1, 0, 200).do { |item, i|
            var itemBounds = ~wv[i].bounds;
            var top;
            
            if(i <= 1) {
                top = 200;
            } {
                top = 0
            };
            ~wv[i].bounds = Rect(itemBounds.left, top + 200 - item, 200, item);
        };
        
        ~rate.wait;
    }
};
~data = [1,0,1,0];
w = Window("activity levels", Rect(100, 100, 400, 400)).front;
~wv = [[0,0], [200, 0], [0, 200], [200, 200]].collect({ |item, i| 
    CompositeView.new(w, Rect(item[0], item[1], 200, 0)).background_(Color.rand)
})
r.play(AppClock);
r.stop
~rate = 0.001.max(0.000001);
c.test = false; c.signal;
c.test = true; c.signal;
]


~p3_bassline.play(~p3_clock, Quant(4));
~p3_bassline.stop
~p3_bassHigh = 1
~p3_bassThresh = 0.5
~p3_bassMove = true;

Synth.before(~p3_bassVerb, \BSP3_Bass, [\out, ~p3_bassVerbBus, \freq, (45).midicps, \amp, 0.4*~p3_amps[\bass], \xpos, -1, \ypos, 0]);


~testBus = Bus.audio(s, 4);

~testVerb = Synth(\BSP3_Reverb, [\in, ~testBus, \damp, 1, \mix, 0.1, \room, 0.2]);
~testVerb.free
~testVerb.set(\damp, 0.1);
~testVerb.set(\room, 0.8);
~testVerb.set(\mix, 0.5);

Synth.before(~testVerb, \BSP3_Bass, [\out, ~testBus, \freq, (74).midicps, \amp, 0.5, \xpos, (((~data[0]+~data[2])/2).neg + ((~data[1] + ~data[3])/2)), \ypos, ~data.mean.linlin(0, 1, 0, [1, -1].choose)]);

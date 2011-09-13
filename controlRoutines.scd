~p3_section1Control = Routine {
    var start, end, index, div, inc;

    ~p3_bassMove = false;
    ~p3_bassEnd = true;
    ~p3_bassHigh = 0;
    ~p3_bassThresh = 1;


    index = 0;
    start = ~p3_sectionDuration/10;
    end = ~p3_sectionDuration/5;
    div = 100;
    inc = 1/div;

    ~p3_bassline.play(~p3_clock, Quant(4));
    start.wait;
    ~p3_bassMove = true;
    "moving".postln;
    while({index < 1}, {
        index = index + inc;
        ~p3_bassHigh = ~p3_bassHigh + inc;
        ~p3_bassThresh = ~p3_bassThresh - inc;

        if(index > 0.8) {
            ~p3_bassEnd = true;
        };

        ((~p3_sectionDuration-start-end) / div).wait;
    });
    "at end".postln;
    end.wait;
    ~p3_bassMove = false;
    ~p3_bassHigh = 0;
    ~p3_bassThresh = 1;
};


"Control Routines loaded".postln;
~p3_responder = OSCresponderNode(s.addr, '/activity', {|t, r, msg| }).add;
~p3_responder.action_({|t, r, msg|
    var data = msg[1..4];
    var scaled = data.collect({ |item, i| 
        (item * ~p3_dataScale[i] * ~p3_dataScale[4]).min(1);
    });
    
    ~p3_data[\left] = (scaled[0] + scaled[2]) / 2;
    ~p3_data[\right] = (scaled[1] + scaled[3]) / 2;
    ~p3_data[\top] = scaled[0..1].mean;
    ~p3_data[\bottom] = scaled[2..3].mean;
    ~p3_data[\total] = scaled.sum;
    ~p3_data[\mean] = scaled.mean;
    
    {
        data.linlin(0, 1, 0, 200).do { |item, i|
            var inBounds = ~p3_activityIn[i].bounds;
            var outBounds = ~p3_activityOut[i].bounds;
            var top;
            var out;
        
            if(i > 1) {
                top = 200;
            } {
                top = 0
            };
            
            out = scaled[i].linlin(0, 1, 0, 200);

            ~p3_activityIn[i].bounds = Rect(inBounds.left, top + 200 - item, 200, item);
            ~p3_activityOut[i].bounds = Rect(outBounds.left, top + 200 - out, 200, out);
        };
    }.fork(AppClock);
    
    // if(~p3_drumReverbChanging) {
    //     ~p3_drumReverbFunc.(data);
    // };
    // 
    // if(~p3_drumActivityChanging) {
    //     ~p3_drumActivityFunc.(data);
    // };
    // 
    
});

"Responders added".postln;
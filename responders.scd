~p3_netAddr = NetAddr("127.0.0.1", 57120);
~p3_responder = OSCresponderNode(~p3_netAddr, '/activity', {|t, r, msg| }).add;
~p3_responder.action_({|t, r, msg|
    var data = msg[1..4];
    var scaled = data.collect({ |item, i| 
        (item * ~p3_dataScale[(i+1).asSymbol] * ~p3_dataScale[\master]).min(1);
    });
    
    ~p3_data[\1] = scaled[0];
    ~p3_data[\2] = scaled[1];
    ~p3_data[\3] = scaled[2];
    ~p3_data[\4] = scaled[3];
    ~p3_data[\left] = (scaled[0] + scaled[2]) / 2;
    ~p3_data[\right] = (scaled[1] + scaled[3]) / 2;
    ~p3_data[\top] = scaled[0..1].mean;
    ~p3_data[\bottom] = scaled[2..3].mean;
    ~p3_data[\total] = scaled.sum;
    ~p3_data[\lrdiff] = ~p3_data[\left].neg + ~p3_data[\right];
    ~p3_data[\tbdiff] = ~p3_data[\top].neg + ~p3_data[\bottom];
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
    
    if(~p3_drumReverbChanging) {
        ~p3_drumReverbFunc.(data);
    };
    
    if(~p3_drumActivityChanging) {
        ~p3_drumActivityFunc.(data);
    };
    
    
});

"Responders added".postln;
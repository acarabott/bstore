~p3_data = Dictionary.new;
~p3_data.add(\left -> 0);
~p3_data.add(\right -> 0);
~p3_data.add(\top -> 0);
~p3_data.add(\bottom -> 0);
~p3_data.add(\1 -> 0);
~p3_data.add(\2 -> 0);
~p3_data.add(\3 -> 0);
~p3_data.add(\4 -> 0);
~p3_data.add(\total -> 0);
~p3_data.add(\mean -> 0);

n = NetAddr("127.0.0.1", 57120);
o = OSCresponderNode(n, '/activity', {|t, r, msg| }).add;
o.action_({|t, r, msg|
    var data = msg[1..4];
    var scaled = data.collect({ |item, i| 
        (item * ~dataScale[i] * ~dataScale[4]).min(1);
    });
    
    ~p3_data[\left] = (scaled[0] + scaled[2]) / 2;
    ~p3_data[\right] = (scaled[1] + scaled[3]) / 2;
    ~p3_data[\top] = scaled[0..1].mean;
    ~p3_data[\bottom] = scaled[2..3].mean;
    ~p3_data[\total] = scaled.sum;
    ~p3_data[\mean] = scaled.mean;
    
    {
        data.linlin(0, 1, 0, 200).do { |item, i|
            var inBounds = ~activityIn[i].bounds;
            var outBounds = ~activityOut[i].bounds;
            var top;
            var out;
        
            if(i > 1) {
                top = 200;
            } {
                top = 0
            };
            
            out = scaled[i].linlin(0, 1, 0, 200);

            ~activityIn[i].bounds = Rect(inBounds.left, top + 200 - item, 200, item);
            ~activityOut[i].bounds = Rect(outBounds.left, top + 200 - out, 200, out);
        };
    }.fork(AppClock);
    
    // if(~drumReverbChanging) {
    //     ~drumReverbFunc.(data);
    // };
    // 
    // if(~drumActivityChanging) {
    //     ~drumActivityFunc.(data);
    // };
    // 
    
});

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
                
        n.sendMsg("/activity", ~data[0], ~data[1], ~data[2], ~data[3]);
        (1/24).wait;
    }
};


r.play;
r.stop
c.test = false; c.signal;
c.test = true; c.signal;

~p3_viewsUp = false;
~p3_data = [0,0,0,0];
~p3_dataScale = 1!5;
~p3_activityWin = Window("Activity Levels", Rect(100, 100, 1000, 400)).front;
~p3_changeColours = {|in=true, out=true|
    
    ~p3_activityColors = Array.fill(4, {Color.rand(0.0, 0.6)});
    if(~p3_viewsUp) {
        ~p3_activityColors.do { |item, i|
            ~p3_activityIn[i].background_(item);
            ~p3_activityOut[i].background_(item);
        };
    };
};
~p3_changeColours.();
~p3_activityIn = [[0,0], [200, 0], [0, 200], [200, 200]].collect({ |item, i| 
    CompositeView.new(~p3_activityWin, Rect(item[0], item[1], 200, 100)).background_(~p3_activityColors[i])
});

~p3_activityScaleComp = CompositeView(~p3_activityWin, Rect(400, 0, 200, 400));
~p3_activityScaleComp.addFlowLayout;
["1", "2", "3", "4", "mast"].do { |item, i|
    var slider = EZSlider(
        ~p3_activityScaleComp, 
        35@350, 
        item, 
        ControlSpec(1, 4, \lin, 0.01, 1, "mult"),
        {|ez| ~p3_dataScale[i] = ez.value},
        1,
        layout:\vert
    );
    
    slider.labelView.align_(\center);
};
~p3_activityScaleLabel = StaticText(~p3_activityScaleComp, 200@35)
    .string_("Scaling")
    .align_(\center)
    .font_(Font("Helvetica", 22));
~p3_activityOut = [[600,0], [800, 0], [600, 200], [800, 200]].collect({ |item, i| 
    CompositeView.new(~p3_activityWin, Rect(item[0], item[1], 200, 100)).background_(~p3_activityColors[i])
});
~p3_viewsUp = true;
~p3_activityOut.do { |item, i|
    item.bounds = item.bounds.height_(100)
};


~p3_drumActivityChanging = true;
~p3_drumReverbChanging = false;
~p3_drumReverbFunc = {|data|
    var max = data.maxItem;
    ~p3_drumVerb.set(\room, max.linlin(0, 0.8, 0, 0.9));
    ~p3_amps[\drums] = max.linlin(0, 1, 0.4, 1);
        
};

~p3_drumActivityFunc = {|data|
    var min, val;
    
    min = ~p3_data[\left].min(~p3_data[\right]);
    if(min < 0.5) {
        val = ~p3_data[\left].max(~p3_data[\right]).linlin(0, 1, 10, 1).floor;
    } {
        val = (~p3_data[\left] + ~p3_data[\right]).linlin(0, 2, 10, 1).floor;
    };
    
    ~p3_snarePat = ~p3_snarePats[\active].collect({ |item, i| 
        if(item == 1) {
            item
        } {
            item + val;
        };
    });
    ~p3_hatsPat = ~p3_hatsPats[\main].collect({ |item, i| 
        if(item == 1) {
            item
        } {
            item + val;
        };
    });
    // ~p3_snarePat    = ~p3_snarePats[\active] + val;
};

~p3_section2Control = Routine {
    var start, end, index, div, inc;
    index = 0;
    start = ~p3_sectionDuration/10;
    end = ~p3_sectionDuration/5;
    div = 100;
    inc = 1/div;

    start.wait;
    ~p3_kickOn = false;
    ~p3_snareOn = false;
    ~p3_hatsOn = true;
    
    ~drumReverbChanging = false;
    ~drumActivityChanging = false;
    ~p3_snarePat    = ~p3_snarePats[\main];
    ~p3_hatsPat     = ~p3_hatsPats[\offbeat];
    ~p3_kickPat    = ~p3_kickPats[\main];

    ~p3_drumRoutine.play(~p3_clock, Quant(4));
    
    5.wait;
    ~p3_kickOn = true;
    
    5.wait;
    ~p3_hatsPat = ~p3_hatsPats[\main];
    ~p3_snareOn = true;
    
    ~drumReverbChanging = true;
    ~p3_drumPanMoving = true;
    5.wait;
    
    ~drumActivityChanging = true;
    ~p3_snarePat = ~p3_snarePats[\active];
    ~p3_snarePats[\active];
    // Slowly drift panning backwards and forwards?
};



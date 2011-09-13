n = NetAddr("127.0.0.1", 57120);
o = OSCresponderNode(n, '/activity', {|t, r, msg| }).add;
o.action_({|t, r, msg|
    var data = msg[1..4];
    var scaled = data.collect({ |item, i| 
        (item * ~dataScale[i] * ~dataScale[4]).min(1);
    });
    
    ~p3_left = (scaled[0] + scaled[2]) / 2;
    ~p3_right = (scaled[1] + scaled[3]) / 2;
    ~p3_top = scaled[0..1].mean;
    ~p3_bottom = scaled[2..3].mean;
    
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

~viewsUp = false;
~data = [0,0,0,0];
~dataScale = 1!5;
~activityWin = Window("Activity Levels", Rect(100, 100, 1000, 400)).front;
~changeColours = {|in=true, out=true|
    
    ~activityColors = Array.fill(4, {Color.rand(0.0, 0.6)});
    if(~viewsUp) {
        ~activityColors.do { |item, i|
            ~activityIn[i].background_(item);
            ~activityOut[i].background_(item);
        };
    };
};
~changeColours.();
~activityIn = [[0,0], [200, 0], [0, 200], [200, 200]].collect({ |item, i| 
    CompositeView.new(~activityWin, Rect(item[0], item[1], 200, 100)).background_(~activityColors[i])
});

~activityScaleComp = CompositeView(~activityWin, Rect(400, 0, 200, 400));
~activityScaleComp.addFlowLayout;
["1", "2", "3", "4", "mast"].do { |item, i|
    var slider = EZSlider(
        ~activityScaleComp, 
        35@350, 
        item, 
        ControlSpec(1, 4, \lin, 0.01, 1, "mult"),
        {|ez| ~dataScale[i] = ez.value},
        1,
        layout:\vert
    );
    
    slider.labelView.align_(\center);
};
~activityScaleLabel = StaticText(~activityScaleComp, 200@35)
    .string_("Scaling")
    .align_(\center)
    .font_(Font("Helvetica", 22));
~activityOut = [[600,0], [800, 0], [600, 200], [800, 200]].collect({ |item, i| 
    CompositeView.new(~activityWin, Rect(item[0], item[1], 200, 100)).background_(~activityColors[i])
});
~viewsUp = true;
~activityOut.do { |item, i|
    item.bounds = item.bounds.height_(100)
};


~drumActivityChanging = true;
~drumReverbChanging = false;
~drumReverbFunc = {|data|
    var max = data.maxItem;
    ~p3_drumVerb.set(\room, max.linlin(0, 0.8, 0, 0.9));
    ~p3_amps[\drums] = max.linlin(0, 1, 0.4, 1);
        
};

~drumActivityFunc = {|data|
    var min, val;
    
    min = ~p3_left.min(~p3_right);
    if(min < 0.5) {
        val = ~p3_left.max(~p3_right).linlin(0, 1, 10, 1).floor;
    } {
        val = (~p3_left + ~p3_right).linlin(0, 2, 10, 1).floor;
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



n = NetAddr("127.0.0.1", 57120);
o = OSCresponderNode(n, '/activity', {|t, r, msg| }).add;
o.action_({|t, r, msg|
    var data = msg[1..4];
    ~p3_left = (data[0] + data[2]) / 2;
    ~p3_right = (data[1] + data[3]) / 2;
    ~p3_top = data[0..1].mean;
    ~p3_bottom = data[2..3].mean;
    
    if(~drumReverbChanging) {
        ~drumReverbFunc.(data);
    };
    
    if(~drumActivityChanging) {
        ~drumActivityFunc.(data);
    };
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
        
        n.sendMsg("/activity", ~data[0], ~data[1], ~data[2], ~data[3]);
        ~rate.wait;
    }
};

~data = [0,1,0,1];
w = Window("activity levels", Rect(100, 100, 400, 400)).front;
~wv = [[0,0], [200, 0], [0, 200], [200, 200]].collect({ |item, i| 
    CompositeView.new(w, Rect(item[0], item[1], 200, 0)).background_(Color.rand)
});
r.play(AppClock);
r.stop
~rate = 0.001.max(0.000001);
c.test = false; c.signal;
c.test = true; c.signal;
]

~data = [1,0.9,1,0.9];
~data = [0,0,0,0]; n.sendMsg("/activity", ~data[0], ~data[1], ~data[2], ~data[3]);

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



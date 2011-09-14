c = Condition(false);
r = Routine {
    var dirs = true!4;
    var inc = 0.01;
    inf.do {
        c.wait;
        if(~p3_testMove) {
            ~p3_testData.do { |item, i|
                if(dirs[i]) {
                    if(item < ~rmax) {
                        ~p3_testData[i] = item + inc;
                    } {
                        dirs[i] = false;
                    };
                } {
                    if(item > 0) {
                        ~p3_testData[i] = item - inc;
                    } {
                        dirs[i] = true;
                    };
                };
            
            };
        } {
            ~p3_testData = [0,0,0,0];
        };
        
        ~p3_netAddr.sendMsg("/activity", ~p3_testData[0], ~p3_testData[1], ~p3_testData[2], ~p3_testData[3]);
        (1/24).wait;
    }
};

~random = Routine {
    inf.do {
        if(~p3_testMove) {
            ~p3_testData.do { |item, i|
                if(0.25.coin) {
                    ~p3_testData[i] = 1.0.rand;
                };
            };
        };
        ~p3_netAddr.sendMsg("/activity", ~p3_testData[0], ~p3_testData[1], ~p3_testData[2], ~p3_testData[3]);
        ~rate.wait;
    };
}

~random.play
~rate = 1/24;
~rmax = 1;
~p3_testData = [0,0,0,0];
~p3_testMove = true;
r.play;
r.stop
c.test = false; c.signal;
c.test = true; c.signal;


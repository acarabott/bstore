c = Condition(false);
r = Routine {
    var dirs = true!4;
    var keys = [\1, \2, \3, \4];
    var inc = 0.01;
    inf.do {
        c.wait;
        if(~p3_testMove) {
            ~p3_testData.do { |item, i|
                if(dirs[i]) {
                    if(item < 1) {
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


r.play;
r.stop
c.test = false; c.signal;
c.test = true; c.signal;
~p3_testMove = false;
~p3_testData = [1,0,1,0];
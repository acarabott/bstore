r = Routine {
    var dirs = true!4;
    inf.do {
        
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
        
        0.01.wait;
    }
};
~data = [0,0,0,0];
w = Window("activity levels", Rect(100, 100, 400, 400)).front;
~wv = [[0,0], [200, 0], [0, 200], [200, 200]].collect({ |item, i| 
    CompositeView.new(w, Rect(item[0], item[1], 200, 0)).background_(Color.rand)
})
r.play(AppClock);
r.stop

asdf
// Mixer
~p3_mixer = Window("BStorePiece3 Mixer", Rect(100, 100, 270, 600)).front;
~p3_mixer.view.addFlowLayout;
~p3_mixerCompBounds = (~p3_mixer.bounds.width - (~p3_mixer.view.decorator.gap.x * 2))@((~p3_mixer.bounds.height/2) - (~p3_mixer.view.decorator.gap.y*2));
~p3_mixerTop = CompositeView(~p3_mixer, ~p3_mixerCompBounds);
~p3_mixerTop.addFlowLayout;
~p3_mixerBot = CompositeView(~p3_mixer, ~p3_mixerCompBounds);
~p3_mixerBot.addFlowLayout;
~p3_sliders = Dictionary[];
~p3_amps.asSortedArray.do { |item|
    var split = item[0].asString.split($_);
    var view, width;

    width = 60;
    if(split[0].contains("drum")) {
        view = ~p3_mixerBot;
        if(split[0].contains("s").not) {
            width = 31;
        };
    } {
        view = ~p3_mixerTop;        
    };
    ~p3_sliders.add(item[0] -> EZSlider(
        view, 
        width@(~p3_mixer.bounds.height*0.45), 
        item[0].asString.split($_).last, 
        ControlSpec.new(0, 1.5, \lin, 0.01, 1, "amp"), 
        {|slider|
            ~p3_amps[item[0]] = slider.value;
        },
        item[1],
        layout:\vert
        )
    );
    ~p3_sliders[item[0]].labelView.align_(\center);
};    

// Activity Window
~p3_viewsUp = false;
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

~p3_activityMulComp = CompositeView(~p3_activityWin, Rect(400, 0, 200, 400));

~p3_activityMulComp.addFlowLayout;
[\1, \2, \3, \4, \master].do { |item, i|
    var slider = EZSlider(
        ~p3_activityMulComp, 
        35@175, 
        item.asString, 
        ControlSpec(0.1, 4, \lin, 0.01, 1, "mult"),
        {|ez| ~p3_dataMul[item] = ez.value},
        1,
        layout:\vert
    );
    
    slider.labelView.align_(\center);
};
~p3_activityMulLabel = StaticText(~p3_activityMulComp, 200@20)
    .string_("Mul")
    .align_(\center)
    .font_(Font("Helvetica", 16));
~p3_activityAddComp = CompositeView(~p3_activityWin, Rect(400, 200, 200, 400));
~p3_activityAddComp.addFlowLayout;
[\1, \2, \3, \4, \master].do { |item, i|
    var slider = EZSlider(
        ~p3_activityAddComp, 
        35@175, 
        item.asString, 
        ControlSpec(0, 1, \lin, 0.01, 0, "add"),
        {|ez| ~p3_dataAdd[item] = ez.value},
        0,
        layout:\vert
    );
    
    slider.labelView.align_(\center);
};
~p3_activityAddLabel = StaticText(~p3_activityAddComp, 200@20)
    .string_("Add")
    .align_(\center)
    .font_(Font("Helvetica", 16));

~p3_activityOut = [[600,0], [800, 0], [600, 200], [800, 200]].collect({ |item, i| 
    CompositeView.new(~p3_activityWin, Rect(item[0], item[1], 200, 100)).background_(~p3_activityColors[i])
});
~p3_viewsUp = true;
~p3_activityOut.do { |item, i|
    item.bounds = item.bounds.height_(100)
};

// Server Meter
if(~p3_meterUp.not) {
    s.meter;
};


"Mixer created".postln;
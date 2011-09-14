~p3_netAddr = NetAddr("127.0.0.1", 57120);
~p3_responder = OSCresponderNode(~p3_netAddr, '/activity', {|t, r, msg| }).add;
~p3_responder.action_({|t, r, msg|
    var data = msg[1..4];
    var mulAdd = data.collect({ |item, i| 
        var symbol = (i+1).asSymbol;
        ((item + ~p3_dataAdd[symbol] + ~p3_dataAdd[\master]) * ~p3_dataMul[symbol] * ~p3_dataMul[\master]).min(1);
    });
    
    ~p3_updateData.(mulAdd);
    
    ~p3_updateGUI.(data, mulAdd);
        
});

"Responders added".postln;
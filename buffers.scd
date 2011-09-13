~p3_buffers = Dictionary.new;
~p3_buffers.add(\guitar -> (~p3_path ++ "audio/guitarD/*.aif").pathMatch.collect {|file| Buffer.read(s, file)});
~p3_buffers.add(\kick   -> Buffer.read(s, ~p3_path ++ "audio/drums/kick.aif"));
~p3_buffers.add(\snare  -> Buffer.read(s, ~p3_path ++ "audio/drums/snare.aif"));
~p3_buffers.add(\hats   -> (~p3_path ++ "audio/drums/hhc*.aif").pathMatch.collect {|file| Buffer.read(s, file)});


"Buffers loaded".postln;

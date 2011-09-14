~p3_clock = TempoClock(160/60);
~p3_controlCondition = Condition.new(false);
~p3_sectionDuration = 300;

~p3_amps = Dictionary.new;
~p3_amps.add(\bass -> 1);
~p3_amps.add(\bassHigh -> 1);
~p3_amps.add(\guitar -> 1);
~p3_amps.add(\varsaw -> 1);
~p3_amps.add(\drums -> 1);
~p3_amps.add(\drum_kick -> 1);
~p3_amps.add(\drum_snare -> 1);
~p3_amps.add(\drum_hats -> 1);

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
~p3_data.add(\lrdiff -> 0);
~p3_data.add(\tbdiff -> 0);

~p3_data.add(\mean -> 0);
~p3_data.add(\lowMax -> 0);

~p3_dataMul = Dictionary.new;
~p3_dataMul.add(\1 -> 1);
~p3_dataMul.add(\2 -> 1);
~p3_dataMul.add(\3 -> 1);
~p3_dataMul.add(\4 -> 1);
~p3_dataMul.add(\master -> 1);

~p3_dataAdd = Dictionary.new;
~p3_dataAdd.add(\1 -> 0);
~p3_dataAdd.add(\2 -> 0);
~p3_dataAdd.add(\3 -> 0);
~p3_dataAdd.add(\4 -> 0);
~p3_dataAdd.add(\master -> 0);

~p3_root = 50;
~p3_bassNote = ~p3_root;

~p3_bassMove = false;
~p3_bassEnd = false;
~p3_bassHigh = 0;
~p3_bassThresh = 0.5;


~p3_kickOn      = false;
~p3_snareOn     = false;
~p3_hatsOn      = false;
~p3_snarePats   = Dictionary.new;
~p3_hatsPats    = Dictionary.new;
~p3_kickPats    = Dictionary.new;
~p3_kickPats.add(\main -> [1, 0, 0, 0,      0, 0, 1, 1,     0, 0, 1, 0,     0, 0, 0, 0]);
~p3_kickPats.add(\active -> [1, 2, 0, 0,      0, 0, 1, 1,     0, 0, 1, 2,     0, 2, 2, 0]);
~p3_snarePats.add(\main ->      [0, 0, 0, 1,      0, 0, 0, 0,     0, 0, 0, 0,     1, 10, 10, 10]);
~p3_snarePats.add(\active ->    [0, 0, 0, 1,      0, 0, 1, 2,     1, 0, 2, 0,     1, 5, 5, 5]);
~p3_hatsPats.add(\offbeat ->    [0, 0, 1, 0]);
~p3_hatsPats.add(\main ->       [0, 10, 1, 0,      0, 1, 0, 0,     0, 1, 0, 10,     0, 0, 1, 0]);
~p3_hatsPats.add(\quavers ->    [1, 0]);

~p3_snarePat    = ~p3_snarePats[\main];
~p3_hatsPat     = ~p3_hatsPats[\main];
~p3_kickPat    = ~p3_kickPats[\main];

~p3_drumRoomInit = 0.2;
~p3_guitarRoomInit = 0.8;
~p3_guitarMixInit = 0.6;
~p3_guitarDampInit = 0.3;
~p3_varsawRoomInit = 1;
~p3_bassRoomInit = 0.5;
~p3_bassMixInit = 0.5;

~p3_varsawMad = 0;

~p3_drumPanMoving = false;
~p3_drumActivityChanging = false;
~p3_drumDoubleMax = 0.05;

~p3_guitarRetrig = 0.3;
~p3_guitarResolved = false;
~p3_guitarStartMult = 1;
~p3_guitarStartTwo = false;

~p3_lastGuitar = nil;
~p3_lastStarter = nil;
~p3_guitarNoteCount = 4;
~p3_guitarPhrasesCount = 4;
~p3_guitarResolvers = [0, 1, 2, 4, 5, 7];
~p3_phraseResolvers = [0, 7];

~p3_guitarMelodies = Dictionary.new;
~p3_guitarMelodies.add(\one ->      [[4, 4], [3, 4], [5, 4], [1, 4],    [4, 4], [3, 4], [1, 1.5],           [0, 1.5], [2, 1.5], [nil, 3.5]] );
~p3_guitarMelodies.add(\two ->      [[5, 4], [6, 4], [7, 4], [4, 4],    [5, 4], [6, 4], [4, 8]]);
~p3_guitarMelodies.add(\three ->    [[2, 2], [1, 2], [2, 1], [3, 2],    [2, 2], [1, 2], [2, 1], [0, 2],     [2, 2], [1, 2], [2, 1], [3, 2], [4, 4], [nil, 3]]);
~p3_guitarMelodies.add(\four -> [[7, 1.5], [4, 1.5], [5, 1.5], [2, 1.5], [nil, 4], [4, 1.5], [2, 1.5], [3, 1.5], [0, 1.5], [nil, 4]]);
~p3_guitarMelodies.add(\five -> [[7, 4], [4, 4], [5, 4], [2, 4], [nil, 8], [4, 4], [2, 4], [4, 4], [0, 4], [nil, 4]]);
~p3_guitarMelodies.add(\six -> [[0, 4], [1, 4], [2, 8],    [2, 4], [3, 4], [4, 8]]);
~p3_guitarMelodies.add(\seven -> [[4, 4], [3, 6], [0, 2], [2, 2]]);
~p3_guitarMelodies.add(\eight -> [[0, 2], [0, 2], [1, 2], [1, 2], [2, 2], [2, 2], [5, 2], [4, 2], [4, 8]]);
~p3_guitarMelodies.add(\nine -> [[0, 2], [0, 2], [1, 2], [1, 2], [2, 2], [2, 2], [5, 2], [4, 2], [4, 4], [3, 2], [5, 1], [2, 4], [nil, 5]]);


~p3_thickGuitarHarmony = false;
~p3_guitarMelodyOctave = 1;
~p3_guitarStartActivityLevel = 0.1;
~p3_guitarMelodyActivityThresh = 0.8;
~p3_guitarMelodyCount = 0;
~p3_guitarInteractiveActivityLevel = 0.3;

~p3_drumWildKickPats = List[];
~p3_drumWildKickPats.add([1, 0, 0, 0, 0, 0, 0, 0]);
~p3_drumWildKickPats.add([1, 0, 0,  1, 0, 0,    1, 1, 0,    1, 1, 0,    1, 0, 0, 0]);
~p3_drumWildKickPats.add([1, 0, 0, 0]);
~p3_drumWildKickPats.add([0]);


~p3_drumWildSnarePats = List[];
~p3_drumWildSnarePats.add([0, 0, 0, 0, 1, 0, 0, 0]);
~p3_drumWildSnarePats.add([0, 0, 5, 0,      1, 0, 0, 0,     0, 0, 5, 0,     1, 0, 0, 0]);
~p3_drumWildSnarePats.add([0, 0, 5, 0,      1, 0, 0, 0,     10, 10, 5, 10,     1, 10, 10, 10]);
~p3_drumWildSnarePats.add([0]);

~p3_drumWildHatsPats = List[];
~p3_drumWildHatsPats.add([0]);
~p3_drumWildHatsPats.add([0, 0, 1, 0]);
~p3_drumWildHatsPats.add([1, 0]);
~p3_drumWildHatsPats.add([1, 0, 0]);

~p3_drumWildPats = Dictionary();
~p3_drumWildPats.add(\kick  -> ~p3_drumWildKickPats[0]);
~p3_drumWildPats.add(\snare -> ~p3_drumWildSnarePats[0]); 
~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[0]);    
~p3_drumWildPats.add(\all -> false);


~p3_drumWildPlayNext = 0.15;
~p3_drumWildPlayNoteMin = 0.4;
~p3_drumWildMultMin = 0.2;
~p3_drumWildMultMax = 0.8;
~p3_drumWildRateMoves = false;

"Variables initialised".postln;

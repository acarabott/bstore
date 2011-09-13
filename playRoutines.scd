// Bass
~p3_bassline = Routine {
    var next = true;
    var firstNotes = [~p3_bassNote, ~p3_bassNote-5, ~p3_bassNote+7, ~p3_bassNote-12, ~p3_bassNote+12];
    var firstWeights = [3, 3, 1, 2, 1].normalizeSum;
    var endNotes = [~p3_bassNote, ~p3_bassNote-5, ~p3_bassNote+7, ~p3_bassNote-12, ~p3_bassNote+12, ~p3_bassNote+8, ~p3_bassNote+20, ~p3_bassNote+19, ~p3_bassNote-4, ~p3_bassNote+2, ~p3_bassNote-10];
    var endWeights = [3, 3, 1, 2, 1, 4, 4, 4, 4, 4, 4].normalizeSum;
    
    inf.do{ |i|
        var amp;
        var note;
        var rand;
        var xpos;
        
        if(i%4 == 0) {
            amp = 0.2;
        } {
            amp = 0.1;
        };
    
        note = ~p3_bassNote;
        if(~p3_bassMove) {
            if(~p3_data[\left] >= ~p3_bassThresh || (~p3_data[\right] >= ~p3_bassThresh)) {  
                if(~p3_bassEnd.not) {
                    note = firstNotes.wchoose(firstWeights);
                } {
                    note = endNotes.wchoose(endWeights);
                };
                
                if(~p3_bassHigh.coin) {
                    if(~p3_data[\left] >= ~p3_data[\right]) {
                        xpos = ~p3_data[\left].neg;
                    } {
                        xpos = ~p3_data[\right];
                    };
                    
                    Synth.before(~p3_bassVerb, \BSP3_Bass, [\out, ~p3_bassVerbBus, \freq, (note+12).midicps, \amp, amp*~p3_amps[\bassHigh], \xpos, ~p3_data[\lrdiff], \ypos, ~p3_data[\mean].linlin(0, 1, 0, [1, -1].choose)]);
                };
            };
        };
    
        Synth(\BSP3_Bass, [\freq, note.midicps, \amp, amp*~p3_amps[\bass]]);
        Synth(\BSP3_Bass, [\freq, (note-12).midicps, \amp, amp*~p3_amps[\bass]]);
    
        0.5.wait;
    }
};

// Drums
~p3_drumBuild = Routine {
    //  Start routine
    ~p3_hatsOn = true;
    // 20.wait;
    2.wait;
    "Kick start".postln;
    ~p3_kickOn = true;
    // 10.wait;
    2.wait;
    "Snare start, hats change.".postln;
    ~p3_hatsPat = ~p3_hatsPats[\main];
    ~p3_snareOn = true;
    // 20.wait;
    2.wait;
    "Drum reverb interactive".postln;
    ~p3_drumVerbRoutine.play;

};

~p3_drumRoutine = Routine {
    inf.do {|i|
        var index = i%16;
        var mult = 1;
        var kickWrap, snareWrap, hatsWrap;
        var xpos;

        kickWrap = ~p3_kickPat.wrapAt(i);
        snareWrap = ~p3_snarePat.wrapAt(i);
        hatsWrap = ~p3_hatsPat.wrapAt(i);

        if(~p3_drumPanMoving) {
            xpos = ~p3_data[\lrdiff];
        } {
            xpos = 0;
        };

        if(~p3_kickOn) {
            if(kickWrap == 1) {
                Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_buffers[\kick], \pan, 0, \amp, ~p3_amps[\drums] * ~p3_amps[\drum_kick], \out, ~p3_drumVerbBus, \xpos, xpos]);
            };
        };
        if(~p3_snareOn) {
            if(snareWrap == 1) {
                Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_buffers[\snare], \pan, 0, \amp, ~p3_amps[\drums] * ~p3_amps[\drum_snare], \out, ~p3_drumVerbBus, \xpos, xpos, \rate, 1]);
            } {
                if(snareWrap > 1 && (1 / snareWrap).coin) {
                    Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_buffers[\snare], \pan, 0, \amp, ~p3_amps[\drums] * ~p3_amps[\drum_snare], \out, ~p3_drumVerbBus, \xpos, xpos, \rate, (0.8,0.91..1.2).choose]);

                };
            };
        };
        if(~p3_hatsOn) {
            if(hatsWrap == 1) {
                Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_buffers[\hats].choose, \amp, ~p3_amps[\drums] * ~p3_amps[\drum_hats], \out, ~p3_drumVerbBus, \xpos, xpos]);
            } {
                if(hatsWrap > 1 && (1 / hatsWrap).coin) {
                    Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_buffers[\hats].choose, \amp, ~p3_amps[\drums] * ~p3_amps[\drum_hats], \out, ~p3_drumVerbBus, \xpos, xpos]);
                };

                if(~p3_hatsPat === ~p3_hatsPats[\main] && (hatsWrap == 2)) {
                    ~p3_double.({|i| Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_buffers[\hats].choose, \amp, ~p3_amps[\drums] * ~p3_amps[\drum_hats], \out, ~p3_drumVerbBus, \xpos, xpos])}, 2, 2);
                };
            };
        };
        0.5.wait;
    };
};

~p3_drumWildRoutine = Routine {
    // TODO Reactive panning on this
    // TODO Divide up activity levels based on quarters. One for rate other for madness
    var rateSig = Env.new([1, 2, 1, 0.05], [1,0.5, 1]).asSignal(100);
    var drumBufs = [~p3_buffers[\kick], ~p3_buffers[\snare], ~p3_buffers[\hats].choose];
    var multArray = [2, 3, 4, 6, 8, 12, 16];
    var playNext = true;
    var doubleWait = 0.5;
    var subMultArray;
    
    ~p3_bassNote = 57;
    
    inf.do {|i|

        // Switch bassnote from b6 to 5 every 32 beats
        if(i%32 == 0) {
            if(~p3_bassNote == 57) {
                ~p3_bassNote = 58;
            } {
                ~p3_bassNote = 57;
            };
        };

        ~p3_drumWildPats.keysValuesDo { |key, value|
            var item, rate, rateFunc, mult, div;
            rate = rateSig[~p3_y.linlin(0, 1, 0, rateSig.size-1).floor.asInteger];
            // If not '\all' then it's an actual drum pattern
            if(key != \all) {
                if(~p3_drumWildPats[\all]) {
                    rate = 1;
                };

                item = value.wrapAt(i);

                // Probabalistic playing of specified drum hit
                if(item > 0 && (1/item).coin) {
                    Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_buffers[key], \pan, 0, \amp, ~p3_amps[\drums] * ~p3_amps[(\drum_ ++ key).asSymbol], \rate, rate, \out, ~p3_drumVerbBus, \dur, 0.25, \tail, 0.25]);
                };
            } {
                //If all samples should be used, at any point
                if(value) {
                    "hi".postln;
                    // If the previous beat was to take up twice it's normal duration
                    if(playNext) {
                        "bye".postln;
                        // Whether or not to play a note
                        if(~p3_x.max(~p3_drumWildPlayNoteMin).coin) {
                            item = drumBufs.wchoose([1, 2, 4].normalizeSum);

                            // Whether or not to play more than one note
                            if(~p3_x.linlin(0, 1, ~p3_drumWildMultMin, ~p3_drumWildMultMax).coin) {
                                subMultArray = multArray[0..~p3_x.linlin(0.25, 1, 0, multArray.size).floor.asInteger];
                                mult = subMultArray.wchoose(Array.series(subMultArray.size, 10, -2).normalizeSum);
                                if(0.25.coin) {
                                    div = [2, 4, 8].wchoose([2,2,1].normalizeSum);
                                } {
                                    div = 1;
                                };

                                // TODO this can increase as time goes on
                                if(0.25.coin) {
                                    div = div * mult;
                                };
                            } {
                                mult = 1;
                                div = 1;
                            };

                            // If more than one note, do/don't change rate of each hit
                            if(mult > 1) {
                                if(~p3_drumWildRateMoves && (mult > 1)) {
                                    if(0.5.coin) {
                                        rateFunc = {|ri| (rate - (ri/(1..10).choose))};
                                    } {
                                        rateFunc = {|ri| (rate + (ri/(1..10).choose))};
                                    };
                                } {
                                    rateFunc = {|ri| rate};
                                };

                                // Possibly have a double length 'note'
                                // This can be for longer cuts, or to get a cut + pause
                                if(~p3_drumWildPlayNext.coin) {
                                    playNext = false;
                                    doubleWait = 1;
                                };

                            } {
                                rateFunc = {|ri| rate};
                            };

                            if(~debug) {
                                // "item: ".post; (item).postln;
                                // "mult: ".post; (mult).postln;
                                // "div: ".post; (div).postln;
                                // "doubleWait: ".post; (doubleWait).postln;
                                // "rate: ".post; (rate).postln;
                                // "rateFunc: ".post; (rateFunc.()).postln;
                                // " ".postln;
                            };

                            // Play notes using the double function.
                            ~p3_double.(
                                {|di|
                                    Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, item, \pan, [~p3_x, ~p3_y].choose, \amp, ~p3_amps[\drums] * ~p3_amps[(\drum_ ++ ~p3_buffers.findKeyForValue(item)).asSymbol], \rate, rateFunc.(di), \out, ~p3_drumVerbBus, \dur, 0.25, \tail, 0.25])
                                },
                                mult,
                                div,
                                doubleWait;
                            );
                        };
                    } {
                        playNext = true;
                    };
                } 
            };
        };
        0.5.wait;
    }
};


// Guitar
~p3_guitarStart = Routine {
    inf.do {|i|
        if(~p3_guitarResolved.not && (~p3_guitarStartActivityLevel).coin) {
            ~p3_guitarNote.();
        } {
            if(0.5.coin) {
                ~p3_guitarResolved = false;
            };
        };
        0.5.wait;
    };
};

~p3_guitarMelody = Routine {
    inf.do {|i|
        var melody;
        i.postln;
        // TODO Make this cumulative activity level
        if(~p3_guitarMelodyActivityLevel.coin) {
            "play!".postln;
            melody = ~p3_guitarMelodies.choose;
            melody.do { |melody, j|
                var wait = 0;
                var synths = List[];
            
                if(melody[0].notNil) {
                    // TODO Make these pan positions 4 way!
                    Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, ~p3_buffers[\guitar][melody[0]], \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_amps[\guitar], \rate, 1*~p3_guitarMelodyOctave]);
                    Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, ~p3_buffers[\guitar][melody[0]], \pan, ~p3_x.linlin(0, 1, 1, -1), \amp, ~p3_amps[\guitar], \rate, 0.5*~p3_guitarMelodyOctave]);
            
                    if(~p3_guitarMelodyCount >= 3) {
                        synths.add([~p3_root  + Scale.minor.degrees.wrapAt(melody[0]), ~p3_x.linlin(0, 1, -1, 1)]);
                    };
                    if(~p3_guitarMelodyCount >= 7) {
                        synths.add([~p3_root  + 12 + Scale.minor.degrees.wrapAt(melody[0]), ~p3_x.linlin(0, 1, 1, -1)]);
                    };
                    if(~p3_thickGuitarHarmony) {
                        synths.add([~p3_root + Scale.minor.degrees.wrapAt(melody[0]-2), ~p3_x.linlin(0, 1, -1, 1)]);
                        synths.add([~p3_root + 12 + Scale.minor.degrees.wrapAt(melody[0]-2), ~p3_x.linlin(0, 1, 1, -1)]);
                        synths.add([~p3_root + 24 + Scale.minor.degrees.wrapAt(melody[0]+2), ~p3_x.linlin(0, 1, -1, 1)]);
                    };
                
                    synths.do { |synth|
                        Synth(\BSP3_VarSaw, [\amp, ~p3_amps[\varsaw]/synths.size, \freq, synth[0].midicps, \out, ~p3_varsawVerbBus, \pan, synth[1]]);
                    };
                    wait = wait + (melody[1]/8);

                    (melody[1]/8).wait;
                    Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, ~p3_buffers[\guitar][melody[0]], \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_amps[\guitar]/2, \rate, 2*~p3_guitarMelodyOctave]);
                    wait = wait + (melody[1]/8);
                    (melody[1]/8).wait;
                    Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, ~p3_buffers[\guitar][melody[0]], \pan, ~p3_x.linlin(0, 1, -1, 1), \amp, ~p3_amps[\guitar]/2, \rate, 4*~p3_guitarMelodyOctave]);
        
                };
                (melody[1] - wait).wait;
            };
            ~p3_guitarMelodyCount = ~p3_guitarMelodyCount + 1;
        } {
            "no play".postln;
            8.wait;
        };
    
    }
};

~p3_interactiveGuitar = Routine {
    var startTime = SystemClock.beats;
    var rates = [1, 1.5, 2, 3, 4];
    var diaRates = [1, 2, 4];
    var currentRate = rates[0];
    var lastRateTime = startTime;
    var rateIndex = 0;
    var phraseLength = [8, 16].choose;
    var synthOn = false;
    var sectionWait;
    var diaRateWeights;
    var synthStartTime;

    // Create weights for crazy section. Mostly in the middle octave.
    diaRateWeights = diaRates.collect({ |item, i|
        if(i < (x.size/4).floor) {
            2;
        } {
            if(i > (x.size*0.5).floor) {
                1;
            } {
                3;
            };        
        };

    }).normalizeSum;

    if(~debug) {
        sectionWait = 10;
    } {
        sectionWait = 60;
    };
    inf.do {|i|
        var timeNow, runningTime, timeSinceRate, mult, wait, phraseIndex, rate, amp, scale, synthNoteIndex, synthNotes, synthPan;
        timeNow = SystemClock.beats;
        runningTime = timeNow - startTime;
        timeSinceRate = timeNow - lastRateTime;
        phraseIndex = i % phraseLength;

        // This uses the running time to index into the rate (octave control) array sequentially
        // Once it reaches the last index, switch to using diatonic rates
        if(runningTime < (rates.size * sectionWait)) {
            if(~debug) {
                // "runningTime: ".post; (runningTime).postln;
                // "lastRateTime: ".post; (lastRateTime).postln;
                // "timeSinceRate: ".post; (timeSinceRate).postln;
            };
            // Move to next section (rate/octave)
            if(timeSinceRate >= sectionWait) {
                lastRateTime = SystemClock.beats;
                rateIndex = (runningTime/sectionWait).floor.asInteger.min(rates.size - 1);
                currentRate = rates[rateIndex];
            };
        } {
            // Start of each phrase (choice of octave), decide how long the next phrase should be
            if( phraseIndex == 0) {
                currentRate = diaRates.wchoose(diaRateWeights);
                phraseLength = [8, 16].choose;
            };
        };

        if(~debug) {
            // "currentRate: ".post; (currentRate).postln;
            // "rateIndex: ".post; (rateIndex).postln;
            // "phraseIndex: ".post; (phraseIndex).postln;
        };

        // This switch will occur when final (crazy) section is reached.
        // Varsaw is turned on 
        if(rateIndex < (rates.size-1)) {
            wait = 0.5;
        } {
            wait = 0.25;
            if(synthOn.not) {
                synthOn = true;
                synthStartTime = timeNow;
            };
        };

        // Play a guitar note according to activity level scaled by progression through sections (gets more active)
        if(((~p3_guitarInteractiveActivityLevel*2) * rateIndex.linlin(0, rates.size-1, 0.3, 0.8)).coin) {

            if((~p3_guitarInteractiveActivityLevel/2).coin) {
                mult = 2;
            } {
                mult = 1;
            };

            rate = [currentRate, currentRate/2, currentRate*2].wchoose([0.8, 0.1, 1]);
            amp = rate.linlin(rates.first, rates.last, 1, 0.4);

            if(~debug) {
                // "mult: ".post; (mult).postln;
                // "rate: ".post; (rate).postln;
                // "amp: ".post; (amp).postln;
            };
            ~p3_double.({|i| ~p3_guitarNote.(rate, amp)}, mult, mult, wait);

        };

        // Play a synth note every 32 semiquavers
        if((i % 32) == 0 && synthOn) {
            synthNotes = List[];

            // MinPentatonic for rate of 3 as non diatonic
            // This probably never reaches 3 as using diatonic....
            if(rate == 3) {
                scale = Scale.minorPentatonic.degrees;
            } {
                scale = Scale.minor.degrees;
            };
            // TODO this pan interactive
            synthPan = (-1,-0.9..1).choose;
            synthNoteIndex = (scale.size-1).rand;
            synthNotes.add(scale[synthNoteIndex]);

            // Varsaw starts playing in thirds after 2 minutes 
            if(timeNow - synthStartTime > (2 * sectionWait)) {
                synthNotes.add(scale.wrapAt(synthNoteIndex + [2, -2].choose));
            };

            synthNotes.do { |synthNote, synthNotesIndex|
                var synthAmp, synthFreq;
                synthAmp = ~p3_amps[\varsaw] / synthNotes.size;
                synthFreq = (~p3_root + synthNote).midicps;
                
                if(synthNotesIndex.odd) {
                    synthPan = synthPan.neg;
                };

                Synth(\BSP3_VarSaw, [\amp, synthAmp, \freq, synthFreq, \out, ~p3_varsawVerbBus, \pan, synthPan, \sus, 1, \rel, 2]);                
                Synth(\BSP3_VarSaw, [\amp, synthAmp, \freq, synthFreq*2, \out, ~p3_varsawVerbBus, \pan, synthPan, \sus, 1, \rel, 2]);                  
            };            
        };


        if(~debug) {
            // "wait: ".post; (wait).postln;
        };
        wait.wait;
    }
};

~p3_drumWildControl = Routine {
    // 0:00 - Drums start, just kick and snare
    if(~debug) {
        10.wait;
    } {
        60.wait;        
    };
    
    // 0:30 - Hats enter on off beat
    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[1]);
    if(~debug) {
        5.wait;
    } {
        30.wait;        
    };

    // 1:00 -  Kick more active
    ~p3_drumWildPats.add(\kick  -> ~p3_drumWildKickPats[1]);

    if(~debug) {
        5.wait;
    } {
        30.wait;        
    };
    
    // 1:30 - Snare more active
    ~p3_drumWildPats.add(\snare -> ~p3_drumWildSnarePats[1]); 
    if(~debug) {
        5.wait;
    } {
        30.wait;        
    };
    
    // 2:00 - Snare more active hats on beat. 
    //      - Hats switch between crotchets and dotted crotchets for 2 mins
    ~p3_drumWildPats.add(\snare -> ~p3_drumWildSnarePats[2]); 
    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[2]);
    4.do { |i|
        if(~debug) {
            5.wait;
        } {
            15.wait;        
        };
        ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[3]);
        if(~debug) {
            5.wait;
        } {
            15.wait;        
        };
        ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[2]);
    };
    // 4:00 - All drum patterns drop out. 
    //      - More interactive drums start
    ~p3_drumWildPats.add(\snare -> ~p3_drumWildSnarePats[3]);     
    ~p3_drumWildPats.add(\kick  -> ~p3_drumWildKickPats[2]);
    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[0]);
    ~p3_drumWildPats.add(\all -> true);

    if(~debug) {
        5.wait;
    } {
        60.wait;        
    };
    // 5:00 - Hats enter with interactive drums

    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[1]);

    if(~debug) {
        5.wait;
    } {
        30.wait;        
    };
    // 5:30 - Hats on beat
    //      - Drums become a lot more active
    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[2]);
    ~p3_drumWildPlayNext = 0;
    ~p3_drumWildPlayNoteMin = 0.7;
    
    if(~debug) {
        5.wait;
    } {
        30.wait;        
    };
    
    // 6:00 - Hats switch between Crotchet/dotted crotchet for 0:40 - 2:00
    4.do { |i|
        if(~debug) {
            5.wait;
        } {
            [5,15].choose.wait;        
        };
        ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[3]);
        if(~debug) {
            5.wait;
        } {
            [5,15].choose.wait;        
        };
        ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[2]);
    };
    // 6:40-8:00 - Drums very active
    //           - Pitch shift rolls start
    ~p3_drumWildPlayNoteMin = 1;
    ~p3_drumWildRateMoves = true;
    ~p3_drumWildMultMin = 0.5;

    if(~debug) {
        5.wait;
    } {
        30.wait;        
    };
    // 7:10-8:30 - Kick and snare back in
    ~p3_drumWildPats.add(\kick  -> ~p3_drumWildKickPats[0]);
    ~p3_drumWildPats.add(\snare -> ~p3_drumWildSnarePats[0]); 

    if(~debug) {
        5.wait;
    } {
        30.wait;        
    };
    // 7:40-9:00 - Drums very cutty/rolly
    ~p3_drumWildMultMin = 1;
    ~p3_drumWildMultMax = 1;
    ~p3_drumWildPlayNext = 1;
    
    if(~debug) {
        5.wait;
    } {
        (60).wait;        
    };
    // 8:40-10:00 - Drums go back to a basic beat
    ~p3_drumWildPats.add(\all -> false);
    ~p3_drumWildPats.add(\kick  -> ~p3_drumWildKickPats[0]);
    ~p3_drumWildPats.add(\snare -> ~p3_drumWildSnarePats[0]); 
    ~p3_drumWildPats.add(\hats  -> ~p3_drumWildHatsPats[0]);
    
    ~p3_controlCondition.test = true;
    ~p3_controlCondition.signal;
    
};


"Play routines loaded".postln;
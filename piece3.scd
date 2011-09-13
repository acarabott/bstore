~debug = true;
~debug = false;

~p3_server.();
~p3_loadsynthdefs.();
~p3_variables.();
~p3_busses.();
~p3_responders.();
~p3_functions.();
~p3_buffers.();
~p3_synths.();
~p3_createMixer.();
~p3_playRoutines1.();
~p3_playRoutines2.();
~p3_playRoutines3.();
~p3_playRoutines4.();
~p3_controlRoutines1.();

~p3_control.play
~p3_stop.();
~p3_reset.();

(
~p3_stop = {
    ~p3_mouseResponder.remove;
    [~p3_control, ~p3_drumBuild, ~p3_bassline, ~p3_drumRoutine, ~p3_guitarStart, ~p3_guitarMelody, ~p3_interactiveGuitar, ~p3_drumVerbRoutine, ~p3_guitarVerbRoutine, ~p3_varsawVerbRoutine].do { |item, i|
        item.stop;
    };
};

~p3_reset = {
    ~p3_variables.();
    ~p3_responders.();
    ~p3_synths.();
    ~p3_playRoutines1.();
    ~p3_playRoutines2.();
    ~p3_playRoutines3.();    
    ~p3_playRoutines4.();
    ~p3_controlRoutines1.();    
};
)

(
    ~p3_section1Control = Routine {
        var start, end, index, div, inc;

        ~p3_bassMove = false;
        ~p3_bassEnd = true;
        ~p3_bassHigh = 0;
        ~p3_bassThresh = 1;


        index = 0;
        start = ~p3_sectionDuration/10;
        end = ~p3_sectionDuration/5;
        div = 100;
        inc = 1/div;

        ~p3_bassline.play(~p3_clock, Quant(4));
        start.wait;
        ~p3_bassMove = true;
        "moving".postln;
        while({index < 1}, {
            index = index + inc;
            ~p3_bassHigh = ~p3_bassHigh + inc;
            ~p3_bassThresh = ~p3_bassThresh - inc;

            if(index > 0.8) {
                ~p3_bassEnd = true;
            };

            ((~p3_sectionDuration-start-end) / div).wait;
        });
        "at end".postln;
        end.wait;
        ~p3_bassMove = false;
        ~p3_bassHigh = 0;
        ~p3_bassThresh = 1;
    };
    
~p3_control = Routine {
    "Bass start".postln;
    ~p3_bassline.play(~p3_clock, Quant(4));
    if(~debug) {
        1.wait;
    } {
        10.wait;
    };
    "Bass Moving".postln;
    ~p3_bassMove = true;
    if(~debug) {
        5.wait;
    } {
        60.wait;
    };
    "Drums start".postln;
    ~p3_drumRoutine.play(~p3_clock, Quant(4));
    ~p3_drumBuild.play;
    
    "Guitar starts".postln;
    ~p3_guitarStart.play(~p3_clock, Quant(4));
    // TODO have this accumlate activity, once it hits threshold move onto next section
    // (4 * 60).wait;
    if(~debug) {
        10.wait;
    } {
        (4 * 60).wait;
    };
    // When an activity level reaches 0.75 or so do
    ~p3_hatsPat = ~p3_hatsPats[\quavers];
    // (2 * 60).wait;
    if(~debug) {
        10.wait;
    } {
        (2*60).wait;
    };
    ~p3_guitarStart.stop;
    
    // Guitar melodies start
    ~p3_guitarMelodyActivityLevel = 0.2;
    ~p3_guitarMelody.play(~p3_clock, Quant(4));
    // as this acumulates and hits 0.75 then do 
    ~p3_guitarMelodyActivityLevel = 0.75;
    ~p3_snarePat = ~p3_snarePats[\active];
    if(~debug) {
        10.wait;
    } {
        (3*60).wait;
    };
    // Drums stop, guitar harmony thickens, bass changes to Lydian root
    ~p3_drumRoutine.stop;
    ~p3_guitarMelodyActivityLevel = 1;
    ~p3_bassNote = ~p3_root - 4;
    // TODO BASS COMES UP
    ~p3_thickGuitarHarmony = true;
    // TODO Make this interactive
    ~p3_guitarMelodyOctave = 2**(~p3_y*2).floor;
    
    // TODO fade ~p3_amps[\guitar] down to 0
    // TODO fade ~p3_amps[\varsaw] up to 0.8
    if(~debug) {
        10.wait;
    } {
        (3*60).wait;
    };

    ~p3_drumBuild.reset;
    ~p3_drumRoutine.reset;
    if(~debug) {
        10.wait;
    } {
        (3*60).wait;
    };

    ~p3_drumReset.();
    ~p3_drumRoutine.play(~p3_clock, Quant(4));
    ~p3_drumBuild.play;
    // TODO varsaw fade out
    ~p3_guitarMelody.stop;
    ~p3_bassNote = ~p3_root;
    
    {
        ~p3_drumRoutine.stop;
        ~p3_drumWildRoutine.play(~p3_clock, quant:Quant(4));
        ~p3_drumWildControl.play;
    }.fork(~p3_clock, quant:Quant(4));
    
    ~p3_controlCondition.wait;
    // Drum section?
    // TODO Change bass note back when stopping
    // ~p3_bassNote = 50;
    // TODO don't stop drums, just move to low grade
    // Guitar interactive
    ~p3_interactiveGuitar.play(~p3_clock, Quant(4));

    // TODO guitar volume down to 0 (better if guitar notes just stop)
    // TODO VARsaw continues, drums become more hectic
    // TODO Automate varsaw and guitar levels here. should this change GUI values? no
    // TODO varsaw can change to % 16
    // TODO Drums fade out and stop, bass fades out, guitar comes up to about 0.15-0.2
    // TODO varsaw fades out
    
};
);
(
~p3_playRoutines1 = {
  
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
    
    
        // ~p3_guitarVerbRoutine.play;
        // ~p3_varsawVerbRoutine.play;
    };

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
                        
                        Synth.before(~testVerb, \BSP3_Bass, [\out, ~testBus, \freq, (note+12).midicps, \amp, amp*~p3_amps[\bass], \xpos, ~p3_data[\left].neg + ~p3_data[\right], \ypos, ~p3_data[\mean].linlin(0, 1, 0, [1, -1].choose)]);
                    };
                };
            };
        
            Synth(\BSP3_Bass, [\freq, note.midicps, \amp, amp*~p3_amps[\bass]]);
            Synth(\BSP3_Bass, [\freq, (note-12).midicps, \amp, amp*~p3_amps[\bass]]);
        
            0.5.wait;
        }
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
                xpos = ~p3_data[\left].neg + ~p3_data[\right];
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
                    Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_buffers[\hats], \amp, ~p3_amps[\drums] * ~p3_amps[\drum_hats], \out, ~p3_drumVerbBus, \xpos, xpos]);
                } {
                    if(hatsWrap > 1 && (1 / hatsWrap).coin) {
                        Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_buffers[\hats], \amp, ~p3_amps[\drums] * ~p3_amps[\drum_hats], \out, ~p3_drumVerbBus, \xpos, xpos]);
                    };

                    if(~p3_hatsPat === ~p3_hatsPats[\main] && (hatsWrap == 2)) {
                        ~p3_double.({|i| Synth.before(~p3_drumVerb, \BSP3_Sampler, [\buf, ~p3_buffers[\hats], \amp, ~p3_amps[\drums] * ~p3_amps[\drum_hats], \out, ~p3_drumVerbBus, \xpos, xpos])}, 2, 2);
                    };
                };
            };
            0.5.wait;
        };
    };
};
);
(
~p3_playRoutines2 = {
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
};
);
(
~p3_playRoutines3 = {
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

};
);
(
~p3_playRoutines4 = {
    ~p3_drumWildRoutine = Routine {
        // TODO Reactive panning on this
        // TODO Divide up activity levels based on quarters. One for rate other for madness
        var rateSig = Env.new([1, 2, 1, 0.05], [1,0.5, 1]).asSignal(100);
        var drumBufs = [~p3_buffers[\kick], ~p3_buffers[\snare], ~p3_buffers[\hats]];
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
};
);
(
~p3_controlRoutines1 = {
    ~p3_drumVerbRoutine = Routine {
        inf.do {|i|
            ~p3_drumVerb.set(\room, ~p3_y);   // TODO  This should be overall activity level, all quarters
            0.1.wait;
        };
    };

    ~p3_guitarVerbRoutine = Routine {
        inf.do {|i|
            ~p3_guitarVerb.set(\room, ~p3_y.linlin(0, 1, 0.6, 1));   // TODO  This should be overall activity level, all quarters
            0.1.wait;
        };
    };

    ~p3_varsawVerbRoutine = Routine {
        inf.do {|i|
            ~p3_varsawVerb.set(\room, ~p3_y.linlin(0, 1, 0.6, 1));   // TODO  This should be overall activity level, all quarters
            0.1.wait;
        };
    };
};
);
(
~p3_controlRoutines2 = {
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
};
);

(
~p3_server = {
    s.options.memSize = 2**18;
    s.waitForBoot {
        "Server Booted".postln;        
    };
};

~p3_variables = {
    ~p3_clock = TempoClock(160/60);
    ~p3_controlCondition = Condition.new(false);
    ~p3_sectionDuration = 300;
    ~p3_amps = Dictionary.new;
    ~p3_amps.add(\bass -> 1);
    ~p3_amps.add(\guitar -> 1);
    ~p3_amps.add(\varsaw -> 0.4);
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
    ~p3_data.add(\mean -> 0);
    
    ~p3_root = 50;
    ~p3_bassNote = ~p3_root;
    
    ~p3_bassMove = false;
    ~p3_bassEnd = false;
    ~p3_bassHigh = 0;
    ~p3_bassThresh = 0.5;
    
    ~p3_drumPanMoving = false;
    ~p3_kickOn      = false;
    ~p3_snareOn     = false;
    ~p3_hatsOn      = false;
    ~p3_snarePats   = Dictionary.new;
    ~p3_hatsPats    = Dictionary.new;
    ~p3_kickPats    = Dictionary.new;
    ~p3_kickPats.add(\main -> [1, 0, 0, 0,      0, 0, 1, 1,     0, 0, 1, 0,     0, 0, 0, 0]);
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
    ~p3_varsawRoomInit = 1;
    ~p3_bassRoomInit = 0.8;
    
    ~p3_guitarRetrig = 0.3;
    ~p3_guitarResolved = false;
    
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
    ~p3_guitarStartActivityLevel = 1/16;
    ~p3_guitarMelodyActivityLevel = 0;
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
};

~p3_loadsynthdefs = {
    SynthDef(\BSP3_Bass) { |out=0, freq=110, amp=1, xpos=0, ypos=0|
        var saw = LFSaw.ar(freq, 0, amp/6);
        var sin = SinOsc.ar(freq, 0, amp);
        var env = Env.perc(0.01, 0.5, 1);
        var envgen = EnvGen.ar(env, doneAction: 2);
        var sig = Mix.ar([saw, sin]);
        Out.ar(out,
            Pan4.ar(sig*envgen, xpos, ypos);
        );

    }.add;

    SynthDef(\BSP3_Sampler) { |out=0, buf=0, amp=0.5, pan=0, rate=1, dur=8, tail=1, xpos=0, ypos=0|
        var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf)*rate, doneAction: 2)*amp;
        var env = EnvGen.ar(Env.new([1,1,0], [dur, tail]), doneAction: 2);
        
        Out.ar(out,
            Pan4.ar(sig*env, xpos, ypos)
        );
    }.add;

    SynthDef(\BSP3_Mouse) { |out=0, rate=10|
        var imp = Impulse.kr(rate);
        var x = MouseX.kr(0, 1, 0, 0);
        var y = MouseY.kr(1, 0, 0, 0);
    
        SendReply.kr(imp, \xy, [x, y]);
    }.add;

    SynthDef(\BSP3_Reverb) { |in=0, out=0, mix=0.5, room=0.8, damp=0.4|
        var sig = In.ar(in, 4);
        var verbFront   = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
        var verbBack    = FreeVerb2.ar(sig[2], sig[3], mix, room, damp);
        var verbLeft    = FreeVerb2.ar(sig[0], sig[2], mix, room, damp);
        var verbRight   = FreeVerb2.ar(sig[1], sig[3], mix, room, damp);


        Out.ar(out,
            [
                Mix.ar([sig[0], verbFront[0]/2, verbLeft[0]/2]), 
                Mix.ar([sig[1], verbFront[1]/2, verbRight[0]/2]), 
                Mix.ar([sig[2], verbBack[0]/2, verbLeft[1]/2]),
                Mix.ar([sig[3], verbBack[1]/2, verbRight[1]/2])
            ]
        );
    }.add;    
    
    // TODO Make rate and fgain interactive
    // TODO replace mousey with interactive
    SynthDef(\BSP3_VarSaw) { |out=0, freq=440, amp=0.25, pan=0, att=0.2, sus=0.75, rel=1, rate=0.5, fgain=2, xpos=0, ypos=0|
        var sig = Mix.new(VarSaw.ar(freq * [0.5,1,2], 0, LFNoise1.kr(0.3,0.1,0.1), 0.1));
        var line = Line.kr(8000, 1000, 1);
        var lpf = LPF.ar(sig, line);
        var moog = MoogFF.ar(lpf, SinOsc.kr(rate).range(400,10000), fgain);
        var env = EnvGen.ar(Env.linen(att, sus, rel, amp, 'sine'), doneAction: 2);
        var madmoog = MoogFF.ar(lpf, line, MouseY.kr(4, 0)).range(-0.1, 0.1);
        var final = Mix.ar([moog, madmoog]);
        
        Out.ar(out,
            Pan4.ar(final * env, xpos, ypos)
        );
    }.add;
    
    "SynthDefs loaded".postln;
};

~p3_busses = {
    // TODO Will need to have 4 channel busses and two reverbs per bus
    ~p3_drumVerbBus = Bus.audio(s, 4);
    ~p3_guitarVerbBus = Bus.audio(s, 4);
    ~p3_varsawVerbBus = Bus.audio(s, 4);
    ~p3_bassVerbBus = Bus.audio(s, 4);
    "Busses initialised".postln;
};

~p3_responders = {
    ~p3_mouseResponder = OSCresponderNode(s.addr, \xy, {|t, r, msg| }).add;

    ~p3_mouseResponder.action_({|t, r, msg|
        ~p3_x = msg[3];
        ~p3_y = msg[4];
        // TODO Move updating routines to here?...
        
        // TODO Remove this
        ~p3_guitarInteractiveActivityLevel = ~p3_y;
        ~p3_guitarStartActivityLevel = ~p3_y;
    });
    
    "Responders loaded".postln;
};
);
(
~p3_functions = {
    // GUI
    ~p3_createMixer = {
        ~p3_mixer = Window("BStorePiece3 Mixer", Rect(100, 100, 400, 600)).front;
        ~p3_mixer.view.addFlowLayout;
        ~p3_mixerCompBounds = (~p3_mixer.bounds.width - (~p3_mixer.view.decorator.gap.x * 2))@((~p3_mixer.bounds.height/2) - (~p3_mixer.view.decorator.gap.y*2));
        ~p3_mixerTop = CompositeView(~p3_mixer, ~p3_mixerCompBounds);
        ~p3_mixerTop.addFlowLayout;
        ~p3_mixerBot = CompositeView(~p3_mixer, ~p3_mixerCompBounds);
        ~p3_mixerBot.addFlowLayout;
        ~p3_sliders = List[];
        ~p3_amps.asSortedArray.do { |item|
            var split = item[0].asString.split($_);
            var view, width;

            width = 50;
            if(split[0].contains("drum")) {
                view = ~p3_mixerBot;
                if(split[0].contains("s").not) {
                    width = 31;
                };
            } {
                view = ~p3_mixerTop;        
            };
            ~p3_sliders.add(EZSlider(
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
            ~p3_sliders.last.labelView.align_(\center);
        };    
        "Mixer created".postln;
    };
    
    ~p3_drumReset = {
        //  Initialise
        ~p3_hatsOn     = false;
        ~p3_kickOn     = false;
        ~p3_snareOn    = false;
        ~p3_hatsPat    = ~p3_hatsPats[\offbeat];
        ~p3_snarePat    = ~p3_snarePats[\main];
        
        // ~p3_drumVerbRoutine.stop;
        // 0.5.wait;
        // ~p3_drumVerbRoutine.reset;
        // ~p3_drumVerbRoutine.play;
        ~p3_drumVerb.set(\room, ~p3_drumRoomInit);    
        
        "Drums reset".postln;
    };
    
    ~p3_double = {|func, mult=2, div=2, wait=0.5|
        {
            mult.do { |i|
                func.(i);
                (wait / (div)).wait;
            };
        }.fork(~p3_clock)
    };
    
    ~p3_getNeighbours = {|index, max, step=1|
        var ret = List[];
        if(index - step >= 0) {
            ret.add(index-step);
        };
        if((index + step) <= max) {
            ret.add(index+step);
        };
        
        ret;
    };
    ~p3_setNeighbours = {|collection, neighbours, value|
        neighbours.do { |item, i|
            collection[item] = value;
        };
        
        collection;
    };
    
    ~p3_guitarNote = {|rate=1, amp=1|
        var buffer, weights, nearest, sResolvers, neighbours;
        ~p3_guitarResolved = false;
        switch (~p3_guitarNoteCount)
            {1}  {
                ~p3_guitarResolved = true;
                // "resolved!".postln;
                weights = 0!8;
                if(~p3_guitarPhrasesCount == 1) {
                    nearest = ~p3_lastGuitar.nearestInList(~p3_phraseResolvers);
                    // "phrases resolved!".postln;
                    ~p3_guitarPhrasesCount = 5;
                } {
                    nearest = ~p3_lastGuitar.nearestInList(~p3_guitarResolvers);                    
                    sResolvers = ~p3_guitarResolvers.shallowCopy;
                    sResolvers.remove(nearest);
                    weights[~p3_lastGuitar.nearestInList(sResolvers)] = 1;
                };
                weights[nearest] = 1;
                ~p3_guitarNoteCount = 5;    // 5 as 1 will be subtracted            
                ~p3_guitarPhrasesCount = ~p3_guitarPhrasesCount - 1;
            }
            {4}  {
                // "start".postln;
                if(~p3_lastStarter.notNil && 0.5.coin) {
                    weights = ~p3_setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastStarter, ~p3_buffers[\guitar].size-1), 1);
                    
                } {
                    weights = [2,1,2,1,2,1,2,2];
                    
                };
            }
            {~p3_guitarNoteCount}    {
                if(0.75.coin) {
                    // "step".postln;
                    weights = ~p3_setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastGuitar, ~p3_buffers[\guitar].size-1), 1);
                } {
                    // "thirds".postln;
                    weights = ~p3_setNeighbours.(0!8, ~p3_getNeighbours.(~p3_lastGuitar, ~p3_buffers[\guitar].size-1, 2), 1);                    
                };
            };
        
        // weights.postln;
        ~p3_guitarNoteCount = ~p3_guitarNoteCount - 1;
        
        buffer = ~p3_buffers[\guitar].wchoose(weights.normalizeSum);
        ~p3_lastGuitar = ~p3_buffers[\guitar].indexOf(buffer);
        if(~p3_guitarNoteCount == 4) {
            ~p3_lastStarter = ~p3_lastGuitar;
        };
        Synth.before(~p3_guitarVerb, \BSP3_Sampler, [\out, ~p3_guitarVerbBus, \buf, buffer, \pan, ~p3_y.linlin(0, 1, -1, 1), \amp, ~p3_amps[\guitar] * amp, \rate, 1*rate]);
    };  
    
    "Functions loaded".postln;
};

~p3_buffers = {
    ~p3_buffers = Dictionary.new;
    ~p3_buffers.add(\guitar -> "/Users/arthurc/Documents/programming/computerMusic/bstore/audio/guitarD/*.aif".pathMatch.collect {|file| Buffer.read(s, file)});
    ~p3_buffers.add(\kick   -> Buffer.read(s, "sounds/kick.aif"));
    ~p3_buffers.add(\snare  -> Buffer.read(s, "sounds/snare.aif"));
    ~p3_buffers.add(\hats   -> Buffer.read(s, "sounds/hhc4.aif"));
    
    "Buffers loaded".postln;
};

~p3_synths = {
    ~p3_mouseSynth = Synth(\BSP3_Mouse);
    ~p3_drumVerb = Synth(\BSP3_Reverb, [\in, ~p3_drumVerbBus, \damp, 0.4, \mix, 0.8, \room, ~p3_drumRoomInit]);
    ~p3_guitarVerb = Synth(\BSP3_Reverb, [\in, ~p3_guitarVerbBus, \damp, 0.4, \mix, 0.8, \room, ~p3_guitarRoomInit]);
    ~p3_varsawVerb = Synth(\BSP3_Reverb, [\in, ~p3_varsawVerbBus, \damp, 0.1, \mix, 1, \room, ~p3_varsawRoomInit]);
    ~p3_bassVerb = Synth(\BSP3_Reverb, [\in, ~p3_bassVerbBus, \damp, 0.1, \mix, 0.8, \room, ~p3_bassRoomInit]);

    "Synths started".postln;
};
)


 
// TODO Capture melodic patterns
// TODO Guitar activity control
// TODO Guitar effects
// TODO Larger scale decisions - play / don't play for x time
// TODO Large pads every now and then
// TODO Changing from sets of drum patterns
// TODO Write possible structures for piece
// TODO Root note changes.
// TODO Guitar phrases of different no.
// TODO Mixing 
// TODO Have scale controls for activity levels.
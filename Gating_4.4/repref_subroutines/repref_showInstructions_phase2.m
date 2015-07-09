function [] = repref_showInstructions_phase2(window,imageLocs,colors,keys,cbhand,fMRI,stims,outputFile)
  
  %% parameters
  
  % number of practice trials
  PRAC_TRIALS = 6;
  PRAC_BLOCKS = 3;
  
  % timeing variables 
  T_TARGETab = 3;
  T_DELAYa = 6;
  T_PROBEa = 1.064;
  T_RESPONSEa = 0.936;
  T_DELAYb = T_DELAYa;
  T_PROBEb = T_PROBEa;
  T_RESPONSEb = T_RESPONSEa;
  T_RSVP_PROBE = 0.216;
  T_RSVP_GAP = 0.05;
  T_ITI = 2;
  
  % timing stuff
  flipTime = Screen('GetFlipInterval',window);
  dblFlipTime = 2*flipTime;
  
  % Keyboard for training (add conditions for scanner)
  if fMRI == 0
    resp_keys = {'6';'7'};
  else
      switch cbhand
          case 1; resp_hand = {'RIGHT';'LEFT'};
          case 2; resp_hand = {'LEFT';'RIGHT'};
      end
    resp_keys = {'INDEX finger';'MIDDLE finger'};
  end
  
  %% behavioral or canner
  switch fMRI
      case 0
          %% welcome
          msg = sprintf([...
            'These are the instructions for the SECOND activitiy you will do in the scanner!\n\n' ...
            'Press any key to start.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'On each trial of this activity, you will first see two pictures:\n\n'...
            'A FACE and a SCENE. \n\n'...
            'These pictures are the "target" pictures.\n\n'...
            'Press any key to see an example.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          %% example of target presentation
          repref_drawTargets(window, stims.targets(1,1,:), imageLocs);
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip', window);
          WaitSecs(2);

          msg = sprintf([...
            'The FACE or SCENE can appear on the top or bottom of the screen.\n\n'...
            'The location of the FACE or SCENE does not matter.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'On each trial your memory will be tested for one of these pictures.\n\n'...
            'Usually it will be the FACE, but sometimes it will be the SCENE.\n\n'...
            'You will not which one will be tested right away,\n\n'...
            'so you will need to try to remember both pictures.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'To prepare for the test, you should form a mental image of the two target pictures.\n\n'...
            'You need to hold on to this mental image after the pictures disappear from the screen.\n\n'...
            'Your mental image should contain details of both the FACE target and the SCENE target.\n\n'...
            'However, it is important to maintain separate detail for each picture,\n\n'...
            'DO NOT imagine the FACE target and SCENE target interacting in any way.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'You will have four seconds to study the FACE and SCENE targets before they disappear.\n\n'...
            'You will then see a plus sign (+) for eight seconds. When you see the plus sign you\n\n'...
            'should focus your mental energy on thinking about the FACE target only. It is especially\n\n'...
            'important to concentrate on and continue to try to keep in mind the FACE target, because\n\n'...
            'we will be measuring your brain signals during this time and the more you concentrate\n\n'...
            'on the FACE target, the better we will be able to measure your brain signals.\n\n'...
            'Press any key to see an example.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          %% example of target presentation & delay
          repref_drawTargets(window, stims.targets(1,1,:), imageLocs);
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip', window);
          WaitSecs(T_TARGETab);

          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip', window);
          WaitSecs(T_DELAYa);

          msg = sprintf([...
            'You will then have a memory test for the FACE target. When the plus sign\n\n'...
            'disappears, you will see a set of four pictures appear quickly, one at a time.\n\n\n'...
            'Press any key to see an example.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          %% example of probe

          % find stay trial
          t_stay = find(stims.switches(1,:)==0);
          t_stay_pos = t_stay(1);

          % probe
          probes = stims.probes1{1,t_stay_pos};
          t_prev_probe_end = GetSecs;
          for p = 1:length(probes)
            repref_drawImage(window,char(probes(p)),imageLocs);
            Screen('Flip',window);   
            WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE);
            Screen('Flip',window);
            WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE + T_RSVP_GAP);
            t_prev_probe_end = GetSecs;
          end
          Screen('Flip',window);
          WaitSecs(.5);

          msg = sprintf([...
            'Pay close attention to the pictures in this set because your job will be to\n\n'...
            'decide whether the FACE from the initial two images appeared in this set.\n\n'...
            'At the end of the set of pictures, you will see a white dot.\n\n\n'...
            'When the white dot appears:\n\n'...
            'Press the %s key with your INDEX finger if you SAW the initial FACE target in the set.\n\n'...
            'Press the %s key with your MIDDLE finger if you DID NOT see the initial FACE target in the set.'],resp_keys{1},resp_keys{2});
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);  


          %% example of stay trial

          % target
          repref_drawTargets(window, stims.targets(1,t_stay_pos,:), imageLocs);
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip', window);
          WaitSecs(T_TARGETab);

          % delay
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip', window);
          WaitSecs(T_DELAYa);

          % probe 
          registeredKeyPress = false;
          fbColor = colors.white;

          probes = stims.probes1{1,t_stay_pos};
          t_prev_probe_end = GetSecs;
          for p = 1:length(probes)
            repref_drawImage(window,char(probes(p)),imageLocs);
            Screen('Flip',window);      
            WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE);
            Screen('Flip',window);
            WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE + T_RSVP_GAP);
            t_prev_probe_end = GetSecs;
          end

          % response window
          repref_drawCircle(window,fbColor);
          Screen('Flip',window);

          while (GetSecs < t_prev_probe_end+1.5) 

            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);

            % interpret relevant keypresses
            if keyIsDown && ~registeredKeyPress
              registeredKeyPress = true;

              if strcmp(KbName(keyCode), keys.first)
                % user indicated picture was identical
                 responses = 1;
                 fbColor = repref_getFeedback(colors,responses==stims.answers(1,t_stay_pos));

              elseif strcmp(KbName(keyCode), keys.second)
                 % user indicated picture was not identical
                 responses = -1;
                 fbColor = repref_getFeedback(colors,responses==stims.answers(1,t_stay_pos));

              else
                 registeredKeyPress = false;
              end

              % show feedback
              if registeredKeyPress
                repref_drawCircle(window,fbColor);
                Screen('Flip',window);
              end

            end % keyIsDown

          end % while waiting for response


          msg = sprintf([...
            'The white dot will turn GREEN if you are correct or RED if you are incorrect.\n\n'...
            'If you do not respond within one second, the white dot will disappear.\n\n'...
            'Sometimes this task can be frustrating, but just try to do your best.\n\n'...
            'Try to respondrespond as quickly and accurately as possible.\n\n'...
            'This may be difficult at first, but you will have time to practice.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);


          msg = sprintf([...
            'On most trials you will have a memory test for the\n\n'...
            'initial FACE target, but some trials will be different.\n\n'...
            'On some trials, the plus sign (+) will turn into an (x).\n\n']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);  

          %% exmaple of fixation to X switch

          % first delay cue
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip', window);
          WaitSecs(1);

          % second delay cue
          repref_drawFocusCharacter(window,'x',colors.white);
          Screen('Flip', window);
          WaitSecs(1);

          msg = sprintf([...
            'When you see the (x) you should try to forget the FACE target and\n\n'...
            'remember the SCENE target from the start of the trial instead. You\n\n'...
            'will have eight more seconds to do your best to try and forget the\n\n'...
            'FACE target and try to bring the SCENE target back into your mind.\n\n\n'...
            'Once you have the SCENE target in mind, do your best to concentrate on,\n\n'...
            'and hold the SCENE target in mind while we continue to measure your brain signals.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'You will then have a memory test for the SCENE target. Once the (x) disappears\n\n'...
            'a set of pictures will appear very quickly, just like the sequence we just described.\n\n'...
            'This time, it is important that you indicate whether the initial SCENE target\n\n'...
            'appeared in the set of images. Similar to before, when the white dot appears:\n\n\n'...
            'Press the %s key with your INDEX finger if you SAW the initial SCENE target in the set.\n\n'...
            'Press the %s key with your MIDDLE finger if you DID NOT see the initial SCENE target in the set.'],resp_keys{1},resp_keys{2});
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          %% example of switch trial

          % find switch trial
          t_switch = find(stims.switches(1,:)==1);
          t_switch_pos = t_switch(1);

          % target
          repref_drawTargets(window, stims.targets(1,t_switch_pos,:), imageLocs);
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip', window);
          WaitSecs(T_TARGETab);

          % delay a
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip', window);
          WaitSecs(T_DELAYa);

          %delay b
          repref_drawFocusCharacter(window,'x',colors.white);
          Screen('Flip', window);
          WaitSecs(T_DELAYb);

          % probe 
          registeredKeyPress = false;
          fbColor = colors.white;

          probes = stims.probes2{1,t_switch_pos};
          t_prev_probe_end = GetSecs;
          for p = 1:length(probes)
            repref_drawImage(window,char(probes(p)),imageLocs);
            Screen('Flip',window);     
            WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE);
            Screen('Flip',window);
            WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE + T_RSVP_GAP);
            t_prev_probe_end = GetSecs;
          end

          % response window
          repref_drawCircle(window,fbColor);
          Screen('Flip',window);

          while (GetSecs < t_prev_probe_end+1.5) 

            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);

            % interpret relevant keypresses
            if keyIsDown && ~registeredKeyPress
              registeredKeyPress = true;

              if strcmp(KbName(keyCode), keys.first)
                % user indicated picture was identical
                 responses = 1;
                 fbColor = repref_getFeedback(colors,responses==stims.answers(1,t_switch_pos));

              elseif strcmp(KbName(keyCode), keys.second)
                 % user indicated picture was not identical
                 responses = -1;
                 fbColor = repref_getFeedback(colors,responses==stims.answers(1,t_switch_pos));

              else
                 registeredKeyPress = false;
              end

              % show feedback
              if registeredKeyPress
                repref_drawCircle(window,fbColor);
                Screen('Flip',window);
              end

            end % keyIsDown

          end % while waiting for response


          msg = sprintf([...
            'This can be difficult, so we will do some practice so you can get comfortable \n\n'...
            'with the activity. Remember, it is important to form a mental image of both the\n\n'...
            'FACE target and the SCENE target at the beginning of each trial, and keep both\n\n'...
            'in mind until you see a plus sign (+). When the plus sign appears (+) keep the\n\n'...
            'FACE target in mind. On most trials, after the (+) disappears, you will have a \n\n'...
            'memory test for the FACE target. You will see four pictures and you will decide\n\n'...
            'if the FACE target appeared in the set of pictures.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'Sometimes you will not get a memory test for the FACE target after the\n\n'...
            'plus sign disappears. Instead, the plus sign (+) will turn into an (x).\n\n'...
            'When that happens, please try your best to forget the FACE target,\n\n'...
            'and bring the mental image of the SCENE target back into your mind.\n\n' ...
            'When the (x) disappears, you will have a memory test for the SCENE target.\n\n' ...
            'You will see four pictures and you will decide if the SCENE target\n\n'...
            'appeared in the set of pictures. You will not know in advance whether the\n\n' ...
            '(+) will turn into an (x), so always start each trial by trying to form a\n\n'...
            'mental image of both the FACE target and SCENE target.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'When you are ready, you can begin the practice trials. Remember to\n\n'...
            'Press %s with your INDEX finger if the FACE target appears in the set\n\n'...
            'after the plus sign (+), or the SCENE target appears in the set after an (x).\n\n'...
            'Press %s with your MIDDLE finger if the FACE or SCENE target does not appear in the set.\n\n'...
            'Please try to respond as quickly and accurately as you can!\n\n'...
            'Please ask the experimenter now if you have any questions.\n\n\n\n'...
            'Press any key to start the practice trials.'],resp_keys{1},resp_keys{2});
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          % clear key press buffer (requires WaitSecs)
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);

          %% practice trial block

          % set up to rerun unless accuracy and in time responses meet thresholds
          rerun = true;
          p_count = 1;

          while (rerun == true)

          for k = 1:PRAC_BLOCKS

            % Set up array for responses and accuracy
            responses = zeros(PRAC_TRIALS,1);
            acc = zeros(PRAC_TRIALS,1);

            % practice block
            for i = 1:PRAC_TRIALS
              t_trial_start = GetSecs;

              %------------------------------%
              % TARGETab PRESENTATION

              repref_drawTargets(window, stims.targets(k,i,:), imageLocs);
              repref_drawFocusCharacter(window,'+',colors.white);
              Screen('Flip', window);
              WaitSecs(T_TARGETab-dblFlipTime);

              %------------------------------%
              % DELAYa

              % display a focus cross during post-cueA delay period
              repref_drawFocusCharacter(window,'+',colors.white);
              Screen('Flip', window);
              lag = GetSecs - (t_trial_start + T_TARGETab);
              lag = lag + dblFlipTime;
              t_adjusted_delay = T_DELAYa - lag;
              WaitSecs(t_adjusted_delay);

              if ~stims.switches(k,i)
                % ** stay trial **

                %------------------------------%
                % PROBEa

                % display the RSVP probes.
                t_probe_start = GetSecs;
                registeredKeyPress = false;
                fbColor = colors.white;

                probes = stims.probes1{k,i}; 
                t_prev_probe_end = GetSecs;
                for p = 1:length(probes)
                  repref_drawImage(window,char(probes(p)),imageLocs);
                  Screen('Flip',window); 
                  WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE);
                  Screen('Flip',window);
                  WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE + T_RSVP_GAP);
                  t_prev_probe_end = GetSecs;
                end

                % response window
                repref_drawCircle(window,fbColor);
                Screen('Flip',window);

                while (GetSecs < t_probe_start+T_PROBEa+T_RESPONSEa)

                  [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);

                  % interpret relevant keypresses
                  if keyIsDown && ~registeredKeyPress
                    registeredKeyPress = true;

                    if strcmp(KbName(keyCode), keys.first)
                      % user indicated picture was identical
                      responses(i) = 1;
                      fbColor = repref_getFeedback(colors,responses(i)==stims.answers(k,i));

                    elseif strcmp(KbName(keyCode), keys.second)
                      % user indicated picture was not identical
                      responses(i) = -1;
                      fbColor = repref_getFeedback(colors,responses(i)==stims.answers(k,i));

                    else
                      registeredKeyPress = false;
                    end

                    % show feedback
                    if registeredKeyPress
                      repref_drawCircle(window,fbColor);
                      Screen('Flip',window);
                    end

                  end % keyIsDown

                end % while waiting for response

              else
                % ** switch trial **

                %------------------------------%
                % DELAYb

                % display a red focus 'X' during second delay period
                repref_drawFocusCharacter(window,'x',colors.white);
                Screen('Flip', window);
                lag = GetSecs - (t_trial_start + T_TARGETab + T_DELAYa);
                lag = lag + flipTime;
                t_adjusted_delay = T_DELAYb - lag;
                WaitSecs(t_adjusted_delay);

                %------------------------------%
                % PROBEb

                % display the RSVP probes.
                t_probe_start = GetSecs;
                registeredKeyPress = false;
                fbColor = colors.white;

                probes = stims.probes2{k,i}; 
                t_prev_probe_end = GetSecs;
                for p = 1:length(probes)
                  repref_drawImage(window,char(probes(p)),imageLocs);
                  Screen('Flip',window);
                  WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE);
                  Screen('Flip',window);
                  WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE + T_RSVP_GAP);
                  t_prev_probe_end = GetSecs;
                end

                % response window
                repref_drawCircle(window,fbColor);
                Screen('Flip',window);

                while (GetSecs < t_probe_start+T_PROBEb+T_RESPONSEb)

                  [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);

                  % interpret relevant keypresses
                  if keyIsDown && ~registeredKeyPress
                    registeredKeyPress = true;

                    if strcmp(KbName(keyCode), keys.first)
                      % user indicated picture was identical
                      responses(i) = 1;
                      fbColor = repref_getFeedback(colors,responses(i)==stims.answers(k,i));

                    elseif strcmp(KbName(keyCode), keys.second)
                      % user indicated picture was not identical
                      responses(i) = -1;
                      fbColor = repref_getFeedback(colors,responses(i)==stims.answers(k,i));

                    else
                      registeredKeyPress = false;
                    end

                    % show feedback
                    if registeredKeyPress
                      repref_drawCircle(window,fbColor);
                      Screen('Flip',window);
                    end

                  end % keyIsDown

                end % while waiting for response

              end % trial type

              if ~registeredKeyPress
                responses(i) = NaN;
              end

              % Display a fixation screen between trials (ITI)
              repref_drawFocusCharacter(window,'+',colors.blue);
              Screen('Flip', window);
              WaitSecs(T_ITI);
              Screen('Close');
              
              % accuracy
              if isnan(responses(i)) == 1
                acc(i) = NaN;
              else
                acc(i) = stims.answers(k,i)==responses(i);
              end

            end % block 

            %% feedback variables
            % calculate block accuracy
            accuracy = 100*(nanmean(acc));

            % count "in time" respnoses
            in_time = sum(~isnan(responses));

            % print to Matlab window & output file
            dataFile = fopen([outputFile '.txt'], 'a');
            performance = sprintf('practice round: %d\t accuracy: %.1f percent\t in time responses: %d\n',p_count,accuracy,in_time);
            fprintf(dataFile,performance);
            fprintf(performance);
            fclose(dataFile);


            %% feedback
            msg = sprintf([
              'You responded to %d of %d trials.\n\n'...
              '** accuracy on this practice block was: %.1f %% **\n\n'],in_time,PRAC_TRIALS,accuracy);
            repref_drawMessage(window,msg);
            Screen('Flip',window);
            FlushEvents('keyDown');
            WaitSecs(1);
            KbWait(-1);

            % set thresholds and update rerun
            if accuracy > 80 && in_time >= 5
              rerun = false;
              break;
            else
              rerun = true;
              p_count = p_count +1;

              msg = sprintf([
                'This activity can be tough, so we will practice again.\n\n'...
                'If you have any questions, please ask the experimenter now.\n\n'...
                'Remember, please try to be as quick and accurate as you can.\n\n\n\n'...
                'Please press any key to start the next set of practice.']);
              repref_drawMessage(window,msg);
              Screen('Flip',window);
              FlushEvents('keyDown');
              WaitSecs(1);
              KbWait(-1);
            end

          end
          end % while rerun == true

          %% final instructions
          msg = sprintf([
            'When you get in the scanner you will review these instructions again\n\n'...
            'prior to performing the second activity. If you have any questions\n\n'...
            'about the instructions for either the first or second activity please\n\n'...
            'discuss them with youre experimenter now. There are no stupid questions,\n\n'...
            'we want you to go into the scanner feeling sure about these instructions.\n'...
            'These tasks are difficult, so we expect that you will make some mistakes,\n'...
            'just remember to try your best. Contact your experimenter now to continue.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          WaitSecs(1);
          
      % -------------------------------------------- %
      % SCANNER
      case 1
          %% welcome
      msg = sprintf([...
        'Welcome to the second activity!\n\n' ...
        'You will use your %s hand to complete the first half of this activity.\n\n' ...
        'Half way through your experimenter will switch over to your %s hand.\n\n' ...
        'Please make sure you are using your %s hand at this time.\n\n' ...
        'Participant, press any button to continue.'],resp_hand{1},resp_hand{2},resp_hand{1});
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);
      
      msg = sprintf([...
          'We will start by reviewing the instructions.\n\n' ...
          'Press any button to continue.']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

          msg = sprintf([...
            'On each trial of this activity, you will first see two pictures:\n\n'...
            'A FACE and a SCENE. \n\n'...
            'These pictures are the "target" pictures.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'The FACE or SCENE can appear on the top or bottom of the screen.\n\n'...
            'The location of the FACE or SCENE does not matter.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'On each trial your memory will be tested for one of these pictures.\n\n'...
            'Usually it will be the FACE, but sometimes it will be the SCENE.\n\n'...
            'You will not which one will be tested right away,\n\n'...
            'so you will need to try to remember both pictures.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'To prepare for the test, you should form a mental image of the two target pictures.\n\n'...
            'You need to hold on to this mental image after the pictures disappear from the screen.\n\n'...
            'Your mental image should contain details of both the FACE target and the SCENE target.\n\n'...
            'However, it is important to maintain separate detail for each picture,\n\n'...
            'DO NOT imagine the FACE target and SCENE target interacting in any way.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'You will have four seconds to study the FACE and SCENE targets before they disappear.\n\n'...
            'You will then see a plus sign (+) for eight seconds. When you see the plus sign you\n\n'...
            'should focus your mental energy on thinking about the FACE target only. It is especially\n\n'...
            'important to concentrate on and continue to try to keep in mind the FACE target, because\n\n'...
            'we will be measuring your brain signals during this time and the more you concentrate\n\n'...
            'on the FACE target, the better we will be able to measure your brain signals.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'You will then have a memory test for the FACE target. When the plus sign\n\n'...
            'disappears, you will see a set of four pictures appear quickly, one at a time.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'Pay close attention to the pictures in this set because your job will be to\n\n'...
            'decide whether the FACE from the initial two images appeared in this set.\n\n'...
            'At the end of the set of pictures, you will see a white dot.\n\n\n'...
            'When the white dot appears:\n\n'...
            'Press the %s button if you SAW the initial FACE target in the set.\n\n'...
            'Press the %s button if you DID NOT see the initial FACE target in the set.\n\n'...
            'Press any button to see a reminder of a trial.'],resp_keys{1},resp_keys{2});
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);  


          %% example of stay trial

          % find stay trial
          t_stay = find(stims.switches(1,:)==0);
          t_stay_pos = t_stay(1);
          
          % target
          repref_drawTargets(window, stims.targets(1,t_stay_pos,:), imageLocs);
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip', window);
          WaitSecs(T_TARGETab);

          % delay
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip', window);
          WaitSecs(T_DELAYa);

          % probe 
          registeredKeyPress = false;
          fbColor = colors.white;

          probes = stims.probes1{1,t_stay_pos};
          t_prev_probe_end = GetSecs;
          for p = 1:length(probes)
            repref_drawImage(window,char(probes(p)),imageLocs);
            Screen('Flip',window);      
            WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE);
            Screen('Flip',window);
            WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE + T_RSVP_GAP);
            t_prev_probe_end = GetSecs;
          end

          % response window
          repref_drawCircle(window,fbColor);
          Screen('Flip',window);

          while (GetSecs < t_prev_probe_end+1.5) 

            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);

            % interpret relevant keypresses
            if keyIsDown && ~registeredKeyPress
              registeredKeyPress = true;

              if strcmp(KbName(keyCode), keys.first)
                % user indicated picture was identical
                 responses = 1;
                 fbColor = repref_getFeedback(colors,responses==stims.answers(1,t_stay_pos));

              elseif strcmp(KbName(keyCode), keys.second)
                 % user indicated picture was not identical
                 responses = -1;
                 fbColor = repref_getFeedback(colors,responses==stims.answers(1,t_stay_pos));

              else
                 registeredKeyPress = false;
              end

              % show feedback
              if registeredKeyPress
                repref_drawCircle(window,fbColor);
                Screen('Flip',window);
              end

            end % keyIsDown

          end % while waiting for response

          msg = sprintf([...
            'On most trials you will have a memory test for the\n\n'...
            'initial FACE target, but some trials will be different.\n\n'...
            'On some trials, the plus sign (+) will turn into an (x).']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);  

          %% exmaple of fixation to X switch

          % first delay cue
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip', window);
          WaitSecs(1);

          % second delay cue
          repref_drawFocusCharacter(window,'x',colors.white);
          Screen('Flip', window);
          WaitSecs(1);

          msg = sprintf([...
            'When you see the (x) you should try to forget the FACE target and\n\n'...
            'remember the SCENE target from the start of the trial instead. You\n\n'...
            'will have eight more seconds to do your best to try and forget the\n\n'...
            'FACE target and try to bring the SCENE target back into your mind.\n\n\n'...
            'Once you have the SCENE target in mind, do your best to concentrate on,\n\n'...
            'and hold the SCENE target in mind while we continue to measure your brain signals.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf([...
            'You will then have a memory test for the SCENE target. Once the (x) disappears\n\n'...
            'a set of pictures will appear very quickly, just like the sequence we just described.\n\n'...
            'This time, it is important that you indicate whether the initial SCENE target\n\n'...
            'appeared in the set of images. Similar to before, when the white dot appears:\n\n\n'...
            'Press the %s button if you SAW the initial SCENE target in the set.\n\n'...
            'Press the %s button if you DID NOT see the initial SCENE target in the set.\n\n'...
            'Press ay button to see a reminder of this trial.'],resp_keys{1},resp_keys{2});
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          %% example of switch trial

          % find switch trial
          t_switch = find(stims.switches(1,:)==1);
          t_switch_pos = t_switch(1);

          % target
          repref_drawTargets(window, stims.targets(1,t_switch_pos,:), imageLocs);
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip', window);
          WaitSecs(T_TARGETab);

          % delay a
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip', window);
          WaitSecs(T_DELAYa);

          %delay b
          repref_drawFocusCharacter(window,'x',colors.white);
          Screen('Flip', window);
          WaitSecs(T_DELAYb);

          % probe 
          registeredKeyPress = false;
          fbColor = colors.white;

          probes = stims.probes2{1,t_switch_pos};
          t_prev_probe_end = GetSecs;
          for p = 1:length(probes)
            repref_drawImage(window,char(probes(p)),imageLocs);
            Screen('Flip',window);     
            WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE);
            Screen('Flip',window);
            WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE + T_RSVP_GAP);
            t_prev_probe_end = GetSecs;
          end

          % response window
          repref_drawCircle(window,fbColor);
          Screen('Flip',window);

          while (GetSecs < t_prev_probe_end+1.5) 

            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);

            % interpret relevant keypresses
            if keyIsDown && ~registeredKeyPress
              registeredKeyPress = true;

              if strcmp(KbName(keyCode), keys.first)
                % user indicated picture was identical
                 responses = 1;
                 fbColor = repref_getFeedback(colors,responses==stims.answers(1,t_switch_pos));

              elseif strcmp(KbName(keyCode), keys.second)
                 % user indicated picture was not identical
                 responses = -1;
                 fbColor = repref_getFeedback(colors,responses==stims.answers(1,t_switch_pos));

              else
                 registeredKeyPress = false;
              end

              % show feedback
              if registeredKeyPress
                repref_drawCircle(window,fbColor);
                Screen('Flip',window);
              end

            end % keyIsDown

          end % while waiting for response

          msg = sprintf([...
            'Before starting the real trials, you will do some more practice. Remember:\n\n'...
            'Press the %s button if the FACE target appears in the set\n\n'...
            'after the plus sign (+), or the SCENE target appears in the set after an (x).\n\n'...
            'Press the %s button if the FACE or SCENE target does not appear in the set.\n\n'...
            'Please try to respond as quickly and accurately as you can!\n\n'...
            'Please ask the experimenter now if you have any questions.\n\n\n\n'...
            'Press any button to start the practice trials.'],resp_keys{1},resp_keys{2});
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          % clear key press buffer (requires WaitSecs)
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);

          %% practice trial block

          % set up to rerun unless accuracy and in time responses meet thresholds
          rerun = true;
          p_count = 1;

          while (rerun == true)

          for k = 1:PRAC_BLOCKS

            % Set up array for responses and accuracy
            responses = zeros(PRAC_TRIALS,1);
            acc = zeros(PRAC_TRIALS,1);

            % practice block
            for i = 1:PRAC_TRIALS
              t_trial_start = GetSecs;

              %------------------------------%
              % TARGETab PRESENTATION

              repref_drawTargets(window, stims.targets(k,i,:), imageLocs);
              repref_drawFocusCharacter(window,'+',colors.white);
              Screen('Flip', window);
              WaitSecs(T_TARGETab-dblFlipTime);

              %------------------------------%
              % DELAYa

              % display a focus cross during post-cueA delay period
              repref_drawFocusCharacter(window,'+',colors.white);
              Screen('Flip', window);
              lag = GetSecs - (t_trial_start + T_TARGETab);
              lag = lag + dblFlipTime;
              t_adjusted_delay = T_DELAYa - lag;
              WaitSecs(t_adjusted_delay);

              if ~stims.switches(k,i)
                % ** stay trial **

                %------------------------------%
                % PROBEa

                % display the RSVP probes.
                t_probe_start = GetSecs;
                registeredKeyPress = false;
                fbColor = colors.white;

                probes = stims.probes1{k,i}; 
                t_prev_probe_end = GetSecs;
                for p = 1:length(probes)
                  repref_drawImage(window,char(probes(p)),imageLocs);
                  Screen('Flip',window); 
                  WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE);
                  Screen('Flip',window);
                  WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE + T_RSVP_GAP);
                  t_prev_probe_end = GetSecs;
                end

                % response window
                repref_drawCircle(window,fbColor);
                Screen('Flip',window);

                while (GetSecs < t_probe_start+T_PROBEa+T_RESPONSEa)

                  [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);

                  % interpret relevant keypresses
                  if keyIsDown && ~registeredKeyPress
                    registeredKeyPress = true;

                    if strcmp(KbName(keyCode), keys.first)
                      % user indicated picture was identical
                      responses(i) = 1;
                      fbColor = repref_getFeedback(colors,responses(i)==stims.answers(k,i));

                    elseif strcmp(KbName(keyCode), keys.second)
                      % user indicated picture was not identical
                      responses(i) = -1;
                      fbColor = repref_getFeedback(colors,responses(i)==stims.answers(k,i));

                    else
                      registeredKeyPress = false;
                    end

                    % show feedback
                    if registeredKeyPress
                      repref_drawCircle(window,fbColor);
                      Screen('Flip',window);
                    end

                  end % keyIsDown

                end % while waiting for response

              else
                % ** switch trial **

                %------------------------------%
                % DELAYb

                % display a red focus 'X' during second delay period
                repref_drawFocusCharacter(window,'x',colors.white);
                Screen('Flip', window);
                lag = GetSecs - (t_trial_start + T_TARGETab + T_DELAYa);
                lag = lag + flipTime;
                t_adjusted_delay = T_DELAYb - lag;
                WaitSecs(t_adjusted_delay);

                %------------------------------%
                % PROBEb

                % display the RSVP probes.
                t_probe_start = GetSecs;
                registeredKeyPress = false;
                fbColor = colors.white;

                probes = stims.probes2{k,i}; 
                t_prev_probe_end = GetSecs;
                for p = 1:length(probes)
                  repref_drawImage(window,char(probes(p)),imageLocs);
                  Screen('Flip',window);
                  WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE);
                  Screen('Flip',window);
                  WaitSecs('UntilTime',t_prev_probe_end + T_RSVP_PROBE + T_RSVP_GAP);
                  t_prev_probe_end = GetSecs;
                end

                % response window
                repref_drawCircle(window,fbColor);
                Screen('Flip',window);

                while (GetSecs < t_probe_start+T_PROBEb+T_RESPONSEb)

                  [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);

                  % interpret relevant keypresses
                  if keyIsDown && ~registeredKeyPress
                    registeredKeyPress = true;

                    if strcmp(KbName(keyCode), keys.first)
                      % user indicated picture was identical
                      responses(i) = 1;
                      fbColor = repref_getFeedback(colors,responses(i)==stims.answers(k,i));

                    elseif strcmp(KbName(keyCode), keys.second)
                      % user indicated picture was not identical
                      responses(i) = -1;
                      fbColor = repref_getFeedback(colors,responses(i)==stims.answers(k,i));

                    else
                      registeredKeyPress = false;
                    end

                    % show feedback
                    if registeredKeyPress
                      repref_drawCircle(window,fbColor);
                      Screen('Flip',window);
                    end

                  end % keyIsDown

                end % while waiting for response

              end % trial type

              if ~registeredKeyPress
                responses(i) = NaN;
              end

              % Display a blank screen between trials
              repref_drawFocusCharacter(window,'+',colors.blue);
              Screen('Flip', window);
              WaitSecs(T_ITI);
              Screen('Close');

              % accuracy
              if isnan(responses(i)) == 1
                acc(i) = NaN;
              else
                acc(i) = stims.answers(k,i)==responses(i);
              end

            end % block 

            %% feedback variables
            % calculate block accuracy
            accuracy = 100*(nanmean(acc));

            % count "in time" respnoses
            in_time = sum(~isnan(responses));

            % print to Matlab window & output file
            dataFile = fopen([outputFile '.txt'], 'a');
            performance = sprintf('practice round: %d\t accuracy: %.1f percent\t in time responses: %d\n',p_count,accuracy,in_time);
            fprintf(dataFile,performance);
            fprintf(performance);
            fclose(dataFile);


            %% feedback
            msg = sprintf([
              'You responded to %d of %d trials.\n\n'...
              '** accuracy on this practice block was: %.1f %% **\n\n'],in_time,PRAC_TRIALS,accuracy);
            repref_drawMessage(window,msg);
            Screen('Flip',window);
            FlushEvents('keyDown');
            WaitSecs(1);
            KbWait(-1);

            % set thresholds and update rerun
            if accuracy > 80 && in_time >= 5
              rerun = false;
              break;
            else
              rerun = true;
              p_count = p_count +1;

              msg = sprintf([
                'This activity can be tough, so we will practice again.\n\n'...
                'If you have any questions, please ask the experimenter now.\n\n'...
                'Remember, please try to be as quick and accurate as you can.\n\n\n\n'...
                'Please press any button to start the next set of practice.']);
              repref_drawMessage(window,msg);
              Screen('Flip',window);
              FlushEvents('keyDown');
              WaitSecs(1);
              KbWait(-1);
            end

          end
          end % while rerun == true

          %% final instructions
          msg = sprintf([
            'Great!  You are ready to start the real activity now.\n\n'...
            'If you have any questions, please ask the experimenter.\n\n'...
            'You will complete several blocks of trials just like in the practice.\n\n'...
            'There will be a short break in between the blocks.\n\n'...
            'Remember to try your best to be quick and accurate.\n'...
            'Please remain as still as possible throughout the task.\n\n\n\n'...
            'Press any button to start the real trials.']);
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(1);
          KbWait(-1);

          msg = sprintf('...we will begin soon...');
          repref_drawMessage(window,msg);
          Screen('Flip',window);
          FlushEvents('keyDown');
          WaitSecs(4);
          
          
  end % switch
  
  
end % main function



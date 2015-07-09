function [] = repref_showInstructions_phase1(window,imageLocs,colors,keys,cbhand,fMRI,stims,outputFile)
  
  %% parameters
  
  % number of practice trials
  PRAC_BLOCKS = 2;
  PRAC_TRIALS_BLOCK = 5;
  
  % timeing variables 
  T_TARGET = 1;
  T_DELAY = 7;
  T_TRIAL_DURATION = T_TARGET+T_DELAY;
  
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
  
  %% behavioral or scanner
  switch fMRI
    case 0
      %% welcome
      msg = sprintf([...
        'These are the instructions for the FIRST activitiy you will do in the scanner!\n\n' ...
        'Press any key to start.']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      msg = sprintf([...
        'In this activity you will see many pictures, one at a time. Your job is to try to\n\n'...
        'form a mental image of each picture you see on the screen. You will have about\n\n'...
        'one second to do so. You should then try to hold that mental image  in your mind\n\n'...
        'while a plus sign (+) appears on the screen for seven seconds. It is very important to\n\n'...
        'focus on the mental image of the picture while the plus sign is on the screen because\n\n'...
        'we will be measuring your brain signals during this time. The more you focus on the\n\n'...
        'mental image of the picture, the better we will be able to measure your brain signals.\n\n\n'...
        'Press any key to see an example.']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);


      %% example of target presentation
      targets = char(stims.targets(1,1));
      repref_drawImage(window, targets, imageLocs);
      Screen('Flip', window);
      WaitSecs(T_TARGET);

      repref_drawFocusCharacter(window,'+',colors.white);
      Screen('Flip', window);
      WaitSecs(T_DELAY);

      msg = sprintf([...
        'After the plus sign (+) disappears, another picture will appear.\n\n'...
        'You should do your best to indicate whether the new picture matches\n\n'...
        'the one you saw just before it (the one you formed a mental image of).\n\n\n'...
        'Press the %s key if it DOES match the picture just before it.\n\n'...
        'or press the %s key if it DOES NOT match the picture just before it.\n\n\n'...
        'Press any key to see an example.'],resp_keys{1},resp_keys{2});
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      KbWait(-1);


      %% example of trial
      targets = char(stims.targets(1,2));
      repref_drawImage(window, targets, imageLocs);
      Screen('Flip', window);
      WaitSecs(T_TARGET);

      repref_drawFocusCharacter(window,'+',colors.white);
      Screen('Flip', window);
      WaitSecs(T_DELAY);

      t_target2_start = GetSecs;
      targets = char(stims.targets(2,1));
      repref_drawImage(window, targets, imageLocs);
      Screen('Flip', window);

      registeredKeyPress = false;
      while (GetSecs < t_target2_start+T_TARGET)

        % poll for a response
        [keyIsDown,secs,keyCode,deltaSecs] = KbCheck(-1);

        % interpret relevant keypresses
        if keyIsDown && ~registeredKeyPress
          registeredKeyPress = true;

          if strcmp(KbName(keyCode), keys.first)
            % user indicated picture was identical
            demo_responses = 1;

          elseif strcmp(KbName(keyCode), keys.second)
            % user indicated picture was not identical
            demo_responses = 0; % he used -1 previously

          else
            registeredKeyPress = false;
          end

        end % keyIsDown
      end % while waiting for response

      % print participant reponse to experimenter window
      if ~registeredKeyPress
          demo_responses = NaN;
      end
      demo_answer = sprintf('demo response = %d\n',demo_responses);
      fprintf(demo_answer);

      msg = sprintf([...
        'You will not get any feedback about whether you were correct or incorrect.\n\n'...
        'After indicating whether the picture matches your mental image, you should try your best\n\n' ...
        'to then form a mental image of the the new picture, the one on the screen, and hold that\n\n'...
        'mental image in mind during the next plus sign (+) so you can evaluate the next picture.\n\n\n\n'...
        'To summarize, you will see many pictures - one after the other - with a plus sign (+) in between.\n\n'...
        'Try to form a mental image of each picture and hold that image in your mind while the plus sign\n\n'...
        'is on the screen. When the next picture appears, decide whether the new picture matches the last one.\n\n'...
        'Then, form a mental image of the new picture to get ready for the next picture.\n\n']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      msg = sprintf([...
        'This can be difficult at first, but you will have a chance to do some practice now.\n\n'...
        'Please try your best to respond as quickly and accurately as you can.\n\n'...
        'If you have any questions, please ask your experimenter. Otherwise...\n\n'....
        '(Press any key to START THE PRACTICE TRIALS)']);
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

      % Set up array for responses and accuracy
      responses = zeros(PRAC_BLOCKS,PRAC_TRIALS_BLOCK);
      acc = zeros(PRAC_BLOCKS,PRAC_TRIALS_BLOCK);

      % practice block
      for i = 1:PRAC_BLOCKS

        for j = 1:PRAC_TRIALS_BLOCK
          t_trial_start = GetSecs;

          registeredKeyPress = false;

          % display the target stimulus & allow response.
          targets = char(stims.targets(i,j));
          repref_drawImage(window, targets, imageLocs);
          Screen('Flip',window);

          while (GetSecs < t_trial_start+T_TARGET)

            % poll for a response
            [keyIsDown,secs,keyCode,deltaSecs] = KbCheck(-1);

            % interpret relevant keypresses
            if keyIsDown && ~registeredKeyPress
              registeredKeyPress = true;

              if strcmp(KbName(keyCode), keys.first)
                % user indicated picture was identical
                responses(i,j) = 1;

              elseif strcmp(KbName(keyCode), keys.second)
                % user indicated picture was not identical
                responses(i,j) = 0; % he used -1 previously

              else
                registeredKeyPress = false;
              end
            end % keyIsDown
          end % while waiting for response


          % display a focus cross.
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip',window);

          while (GetSecs < t_trial_start+T_TARGET+T_DELAY)

            % poll for a response
            [keyIsDown,secs,keyCode,deltaSecs] = KbCheck(-1);

            % interpret relevant keypresses
            if keyIsDown && ~registeredKeyPress
              registeredKeyPress = true;

              if strcmp(KbName(keyCode), keys.first)
                % user indicated picture was identical
                responses(i,j) = 1;

              elseif strcmp(KbName(keyCode), keys.second)
                % user indicated picture was not identical
                responses(i,j) = 0; % he used -1 previously

              else
                registeredKeyPress = false;
              end
            end % keyIsDown
          end % while waiting for response

          if ~registeredKeyPress
            responses(i,j) = NaN;
          end

          % accuracy (don't count non-response)
          if isnan(responses(i,j)) == 1
            acc(i,j) = NaN;
          else
            acc(i,j) = stims.answers(i,j) == responses(i,j);
          end

          % wait till next trial
          t_trial_stop = t_trial_start+T_TRIAL_DURATION;
          WaitSecs('UntilTime',t_trial_stop);

        end  % trials per block
      end % block
      %% feedback variables
      % calculate block accuracy
      accuracy = 100*(nanmean(nanmean(acc)));

      % count "in time" respnoses
      in_time = sum(sum(~isnan(responses)));

      % print to Matlab window & output file
      dataFile = fopen([outputFile '.txt'], 'a');
      performance = sprintf('practice round: %d\t accuracy: %.1f percent\t in time responses: %d\n',p_count,accuracy,in_time);
      fprintf(dataFile,performance);
      fprintf(performance);
      fclose(dataFile);


      %% feedback
      msg = sprintf([
        'You responded to %d of %d trials.\n\n'...
        '** accuracy on this practice block was: %.1f %% **\n\n'...
        'Always try to respond quickly and accurately.\n\n'...
        'If you have any questions about this task\n'...
        'let the experimenter know, otherwise\n\n'...
        'press any key to continue'],in_time,PRAC_BLOCKS*PRAC_TRIALS_BLOCK,accuracy);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      % set thresholds and update rerun
      if accuracy > 80 && in_time >= 8
        rerun = false;
      else
        rerun = true;
        p_count = p_count +1;

        msg = sprintf([
        'Now we will practice some more.\n\n'...
        'Try to respond quicker and more accurately.\n\n'...
        'Press any key to practice again.']);
        repref_drawMessage(window,msg);
        Screen('Flip',window);
        FlushEvents('keyDown');
        WaitSecs(1);
        KbWait(-1);
        
        % clear key press buffer (requires WaitSecs)
        Screen('Flip',window);
        FlushEvents('keyDown');
        WaitSecs(1);
      end

      end % while rerun == true

      %% final instructions
      msg = sprintf([
        'When you get in the scanner you will review these instructions again\n\n'...
        'prior to performing the first activity. Right now, your experimenter\n\n'...
        'will review the instructions for the second activity you will perform\n\n'...
        'in the scanner, so you can get familiar with that activity as well.\n\n'...
        'Please contact your experimenter to continue.']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      advanceKey = false;       
      
      while ~advanceKey
          
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
          
        % interpret relevant keypresses
        if keyIsDown
          if strcmp(KbName(keyCode), '9(')
            advanceKey = true;
          else
            advanceKey = false;
          end
        end % keyIsDown
          
      end % while waiting for response    
      
      repref_finishExperiment();
      
    case 1
      %% welcome
      msg = sprintf([...
        'Welcome to the first activity!\n\n' ...
        'You will use your %s hand to complete the first half of this activity.\n\n' ...
        'Half way through your experimenter will switch over to your %s hand.\n\n' ...
        'Please make sure you are using your %s hand at this time.\n\n' ...
        'Press any key to continue.'],resp_hand{1},resp_hand{2},resp_hand{1});
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);
      
      msg = sprintf([...
          'We will start by reviewing the instructions.\n\n' ...
          'Press any key to continue.']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      msg = sprintf([...
        'In this activity you will see many pictures, one at a time. Your job is to try to\n\n'...
        'form a mental image of each picture you see on the screen. You will have about\n\n'...
        'one second to do so. You should then try to hold that mental image  in your mind\n\n'...
        'while a plus sign (+) appears on the screen for seven seconds. It is very important to\n\n'...
        'focus on the mental image of the picture while the plus sign is on the screen\n\n\n'...
        'Press any button to continue.']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      msg = sprintf([...
        'After the plus sign (+) disappears, another picture will appear.\n\n'...
        'You should do your best to indicate whether the new picture matches\n\n'...
        'the one you saw just before it (the one you formed a mental image of).\n\n\n'...
        'Press your %s button if it DOES match the picture just before it.\n\n'...
        'or press your %s button if it DOES NOT match the picture just before it.\n\n\n'...
        'Press any button to see an example.'],resp_keys{1},resp_keys{2});
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);


      %% example of trial
      targets = char(stims.targets(1,2));
      repref_drawImage(window, targets, imageLocs);
      Screen('Flip', window);
      WaitSecs(T_TARGET);

      repref_drawFocusCharacter(window,'+',colors.white);
      Screen('Flip', window);
      WaitSecs(T_DELAY);

      t_target2_start = GetSecs;
      targets = char(stims.targets(2,1));
      repref_drawImage(window, targets, imageLocs);
      Screen('Flip', window);

      registeredKeyPress = false;
      while (GetSecs < t_target2_start+T_TARGET)

        % poll for a response
        [keyIsDown,secs,keyCode,deltaSecs] = KbCheck(-1);

        % interpret relevant keypresses
        if keyIsDown && ~registeredKeyPress
          registeredKeyPress = true;

          if strcmp(KbName(keyCode), keys.first)
            % user indicated picture was identical
            demo_responses = 1;

          elseif strcmp(KbName(keyCode), keys.second)
            % user indicated picture was not identical
            demo_responses = 0; % he used -1 previously

          else
            registeredKeyPress = false;
          end

        end % keyIsDown
      end % while waiting for response

      % print participant reponse to experimenter window
      if ~registeredKeyPress
          demo_responses = NaN;
      end
      demo_answer = sprintf('demo response = %d\n',demo_responses);
      fprintf(demo_answer);

      msg = sprintf([...
        'To review, you will see many pictures - one after the other - with a plus sign (+) in between.\n\n'...
        'Try to form a mental image of each picture and hold that image in your mind while the plus sign\n\n'...
        'is on the screen. When the next picture appears, decide whether the new picture matches the last one.\n\n'...
        'Then, form a mental image of the new picture to get ready for the next picture.\n\n']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      msg = sprintf([...
        'Before starting the real trials, you will do some more practice.\n\n'...
        'Please try your best to respond as quickly and accurately as you can.\n\n'...
        'If you have any questions, please ask your experimenter. Otherwise...\n\n'....
        '(Press any button to START THE PRACTICE TRIALS)']);
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

      % Set up array for responses and accuracy
      responses = zeros(PRAC_BLOCKS,PRAC_TRIALS_BLOCK);
      acc = zeros(PRAC_BLOCKS,PRAC_TRIALS_BLOCK);

      % practice block
      for i = 1:PRAC_BLOCKS

        for j = 1:PRAC_TRIALS_BLOCK
          t_trial_start = GetSecs;

          registeredKeyPress = false;

          % display the target stimulus & allow response.
          targets = char(stims.targets(i,j));
          repref_drawImage(window, targets, imageLocs);
          Screen('Flip',window);

          while (GetSecs < t_trial_start+T_TARGET)

            % poll for a response
            [keyIsDown,secs,keyCode,deltaSecs] = KbCheck(-1);

            % interpret relevant keypresses
            if keyIsDown && ~registeredKeyPress
              registeredKeyPress = true;

              if strcmp(KbName(keyCode), keys.first)
                % user indicated picture was identical
                responses(i,j) = 1;

              elseif strcmp(KbName(keyCode), keys.second)
                % user indicated picture was not identical
                responses(i,j) = 0; % he used -1 previously

              else
                registeredKeyPress = false;
              end
            end % keyIsDown
          end % while waiting for response


          % display a focus cross.
          repref_drawFocusCharacter(window,'+',colors.white);
          Screen('Flip',window);

          while (GetSecs < t_trial_start+T_TARGET+T_DELAY)

            % poll for a response
            [keyIsDown,secs,keyCode,deltaSecs] = KbCheck(-1);

            % interpret relevant keypresses
            if keyIsDown && ~registeredKeyPress
              registeredKeyPress = true;

              if strcmp(KbName(keyCode), keys.first)
                % user indicated picture was identical
                responses(i,j) = 1;

              elseif strcmp(KbName(keyCode), keys.second)
                % user indicated picture was not identical
                responses(i,j) = 0; % he used -1 previously

              else
                registeredKeyPress = false;
              end
            end % keyIsDown
          end % while waiting for response

          if ~registeredKeyPress
            responses(i,j) = NaN;
          end

          % accuracy (don't count non-response)
          if isnan(responses(i,j)) == 1
            acc(i,j) = NaN;
          else
            acc(i,j) = stims.answers(i,j) == responses(i,j);
          end

          % wait till next trial
          t_trial_stop = t_trial_start+T_TRIAL_DURATION;
          WaitSecs('UntilTime',t_trial_stop);

        end  % trials per block
      end % block
      %% feedback variables
      % calculate block accuracy
      accuracy = 100*(nanmean(nanmean(acc)));

      % count "in time" respnoses
      in_time = sum(sum(~isnan(responses)));

      % print to Matlab window & output file
      dataFile = fopen([outputFile '.txt'], 'a');
      performance = sprintf('practice round: %d\t accuracy: %.1f percent\t in time responses: %d\n',p_count,accuracy,in_time);
      fprintf(dataFile,performance);
      fprintf(performance);
      fclose(dataFile);


      %% feedback
      msg = sprintf([
        'You responded to %d of %d trials.\n\n'...
        '** accuracy on this practice block was: %.1f %% **\n\n'...
        'Always try to respond quickly and accurately.\n\n'...
        'If you have any questions about this task\n'...
        'let the experimenter know, otherwise\n\n'...
        'press any button to start'],in_time,PRAC_BLOCKS*PRAC_TRIALS_BLOCK,accuracy);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      % set thresholds and update rerun
      if accuracy > 80 && in_time >= 8
        rerun = false;
      else
        rerun = true;
        p_count = p_count +1;

        msg = sprintf([
        'Now we will practice some more.\n\n'...
        'Try to respond quicker and more accurately.\n\n'...
        'Press any button to practice again.']);
        repref_drawMessage(window,msg);
        Screen('Flip',window);
        FlushEvents('keyDown');
        WaitSecs(1);
        KbWait(-1);
        
        % clear key press buffer (requires WaitSecs)
        Screen('Flip',window);
        FlushEvents('keyDown');
        WaitSecs(1);
      end

      end % while rerun == true

      %% final instructions
      msg = sprintf([
        'In a moment, you will proceed to the activity.\n\n'...
        'You will complete many trials like the ones you just practiced.\n\n'...
        'The pictures you will see will be different than the ones you saw in practice.\n\n'...
        'Please remember to try your best,\n'...
        'respond quickly and accurately,\n'...
        'and remain as still as possible.\n\n'...
        'Press any button to start']);
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
        
  end  % switch
 
  
end % main function



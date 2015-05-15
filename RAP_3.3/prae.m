function [results] = prae(subjectNumber,subjectName,startBlock,skipPrac)
  %-----------------------------------------------------------------------%
  % [results] = prae( ... )
  %
  % SUBJNUM    : unique # based on date string (e.g., '1001')
  % SUBJNAME   : unique subject name (e.g., 'prae')
  % STARTBLOCK : 1|2|...|6 experiment block from which to start
  % skipPrac   : true if you want to skip practice (defaults to false)
    
        % SCANNERID  : 1|2 - 0=None, 1=CNI
        % FMRI       : 0|1 - 0=behavioral, 1=fMRI run
        % DEBUG      : 0
        % SCREEN     : 0|1 - 0=primary, 1=secondary
  %
  % e.g.,
  % >> results = prae_phase3('101220','jlp',1)
  %-----------------------------------------------------------------------%
  
  %% check input and determine whether to skip practice
  
  if (nargin < 3) || (nargin > 4)
      error('Error: Too few or too many inputs');
      return;
  elseif nargin < 4 || isempty(skipPrac)
      skip = false;
  elseif nargin == 4
      skip = skipPrac;
  end
  
  %% script version
  
  version = '2015APR21(3.2)';
  
  if ~nargin
    script_backup(mfilename,'./',version);
    results = sprintf('script version: %s\n',version);
    return;
  end 
  
  %% EXPERIMENTAL PARAMETERS
  
  % Hard code arguments for scanner
  scannerID = 1;
  fMRI = 1;
  debug = 0;
  screen = 1;
  
  % Trial-related time variables (seconds)
  T_CUE = 2;
  T_PIC = 2;
  T_DELAY = 4;
  T_RATE = 2;
  T_MRI_WAIT = 10;
  
  if ~fMRI
    T_MRI_WAIT = 2;
  end
  
  % add subroutines
  assert(logical(exist('./prae_subroutines','dir')),...
    sprintf('(*) "prae_subroutines" directory does not exisit in: %s',pwd));
  addpath prae_subroutines/
  
  % sanity checks
  assert(ischar(subjectNumber),'(*) subjectNumber must be a ''string''');
  assert(ischar(subjectName),'(*) subjectName must be a ''string''');
  
  %------------------------------%
%% PRELIMINARY SETUP
  
  [window imageLocs colors] = prae_setupExperiment(debug,screen);
  [keys] = prae_setKeys(scannerID);
  prae_loadFunctions();
    
  %% STIMULI SETUP
  
  allstims = prae_getstimuli(subjectNumber,subjectName);
  stims = allstims.task;
  prac = allstims.practice;
  
  %% SETUP RESULTS FILE
  
  % open and set-up files
  outputFile = ['./results/' mfilename() '_' subjectNumber '_' subjectName];
  dataFile = fopen([outputFile '.txt'], 'a');
  
  % print out analysis information
  header = sprintf([...
    '*********************************************\n' ...
    '* PRAE Experiment\n' ...
    '* Script: %s\n'...
    '* Version: %s\n'...
    '* Date/Time: %s\n' ...
    '* Subject Number: %s\n' ...
    '* Subject Name: %s\n' ...
    '* Start Block: %d\n' ...
    '* fMRI: %d\n' ...
    '* Screen: %d\n' ...
    '* Stims File: %s\n' ...
    '* Results File: %s\n' ...
    '*********************************************\n\n'], ...
    mfilename, version, datestr(now,0), subjectNumber, subjectName, ...
    startBlock, fMRI, screen, allstims.filename, [outputFile '.txt']);
  
  fprintf(dataFile,'%s',header);
  fprintf('%s',header);
  
  %% INSTRUCTIONS
  
  if startBlock == 1
      if skip == false
        % run instructions & training
        prae_showInstructions(window,imageLocs,colors,keys,scannerID,prac);
      end
  end
  
  %% WAITING FOR EXPERIMENT TO BEGIN
  
  msg = sprintf('We are ready to begin the activity.\n\n');
  if fMRI
    msg = [msg 'The screen will go blank for 10 sec before the first trial starts.'];
  else
    msg = [msg 'Press any button to start'];
  end
  prae_drawMessage(window,msg);
  Screen('Flip',window);
  WaitSecs(2);
  
  if ~fMRI
    % wait for any input from user to start the block
    while 1
      
      pressed = KbCheck(-1);
      if pressed; break; end
    
    end
    
    Screen('Flip',window);
  end
  
  %% STIMULUS PRESENTATION
  
  % Set up arrays to collect/report behavioral data.
  rate = zeros(stims.blocks, stims.trials_perblock);
  
  % Set up arrays for timing variables
  block_durations = zeros(1,stims.blocks);
  trial_durations = zeros(stims.blocks,stims.trials_perblock);
  trial_onsets = zeros(stims.blocks,stims.trials_perblock);
  cue_onsets = zeros(stims.blocks,stims.trials_perblock);
  delay1_onsets = zeros(stims.blocks,stims.trials_perblock);
  image_onsets = zeros(stims.blocks,stims.trials_perblock); 
  delay2_onsets = zeros(stims.blocks,stims.trials_perblock); 
  rate_onsets = zeros(stims.blocks,stims.trials_perblock); 
  iti_onsets = zeros(stims.blocks,stims.trials_perblock);
  
  % set up array for stimulus short name
  stim_name = repmat({'-'},stims.blocks,stims.trials_perblock);
  
  % print header to Matlab window and output file
  dataFile = fopen([outputFile '.txt'], 'a');
  trial_header = sprintf(...
    'id\tblock\ttrial\tonset\tonset_delay\tduration\tcue\tdelay1\timage\tdelay2\trate\titi\tcondition\tvalence\timage\trating\n');
  fprintf(dataFile,trial_header);
  fprintf(trial_header);
  fclose(dataFile);
  
  %% start experiment
  %---------------------------------%
  % BLOCK
  for i = startBlock:stims.blocks
    
    % inter-block break - behavioral
    if i > 1 && ~fMRI
      msg = sprintf('Please take a break.');
      prae_drawMessage(window,msg);
      Screen('Flip',window);
      WaitSecs(10);
      
      msg = sprintf('Press any key when you are ready to continue.');
      prae_drawMessage(window,msg);
      Screen('Flip',window);
      KbWait(-1);
      WaitSecs(1);
      
      msg = sprintf('Get Ready.');
      prae_drawMessage(window,msg);
      Screen('Flip',window);
      WaitSecs(2);
      
    elseif i == 1 && ~fMRI
      msg = sprintf('Get Ready.');
      prae_drawMessage(window,msg);
      Screen('Flip',window);
      WaitSecs(2);
    end
    
    % EXPERIMENTER TRIGGER START OF TASK
    if fMRI
        
        % hold screen for trigger
        msg = sprintf('Get Ready.');
        prae_drawMessage(window,msg);
        Screen('Flip',window);
        triggerKey = false;
        
        while ~triggerKey
            
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
            
            % interpret relevant keypresses
            if keyIsDown
                if strcmp(KbName(keyCode), keys.trigger)
                    triggerKey = true;
                    [status, startTime] = StartScan;
                    fprintf('Status = %d\n',status);
                    if status == 0
                    else
                        msg = sprintf('Error. Scanner not initiated.');
                        prae_drawMessage(window,msg);
                        Screen('Flip',window);
                        WaitSecs(2);
                        if ~debug
                            prae_finishExperiment();
                        end
                    end
                else
                    triggerKey = false;
                end
            end % keyIsDown
            
        end % triggerKey wait
    end % if fMRI
    
    % start the  block
    switch fMRI
        case 0
            t_block_start = GetSecs;
        case 1
            t_block_start = startTime;
    end    
    % wait for magnetic field to stabilize
    if T_MRI_WAIT
      while (GetSecs - t_block_start < T_MRI_WAIT); 
          prae_drawFocusCharacter(window, colors.white, imageLocs);
          Screen('Flip',window);
      end
    end   
    
    %--------------------------------%
    % TRIAL
    for j = 1:stims.trials_perblock
      
      % (re-)open text file for output
      dataFile = fopen([outputFile '.txt'], 'a');
      
      % start trial time
      t_trial_start = GetSecs;
      if (debug); prae_dbTimeStamp('TRIAL:START(global)',t_trial_start);end
      
      %------------------------------%
      % PRESENT STIMULI
      
      % SET TRIAL DURATION
      switch stims.condition(i,j) % 1 = anticipate; 2 = retrospect; 3 = full; 4 = full+rate
          case 1; T_DUR = T_CUE+T_DELAY+stims.iti(i,j);
          case 2; T_DUR = T_PIC+T_DELAY+stims.iti(i,j);
          case 3; T_DUR = T_CUE+T_DELAY+T_PIC+T_DELAY+stims.iti(i,j);
          case 4; T_DUR = T_CUE+T_DELAY+T_PIC+T_DELAY+T_RATE+stims.iti(i,j);
      end
      
      % START PRESENTING STIMULI
      if stims.condition(i,j) ~= 2 % not on retrospective catch trials
          % CUE -------------------------------------%
          t_cue_start = GetSecs;
          prae_drawCue(window, stims.valence(i,j), colors);
          Screen('Flip',window);
          if (debug); prae_dbTimeStamp('cue onset:',t_trial_start);end
          while (GetSecs < t_trial_start + T_CUE);end

          % DELAY -------------------------------------%
          t_delay1_start = GetSecs;
          prae_drawFocusCharacter(window, colors.white, imageLocs);
          Screen('Flip', window);
          if (debug); prae_dbTimeStamp('delay 1 onset:',t_trial_start);end
          while (GetSecs < t_trial_start + T_CUE + T_DELAY);end
      end % 
      
      if stims.condition(i,j) ~= 1 % not on anticipation catch trials
          % IMAGE -------------------------------------%
          t_image_start = GetSecs;
          prae_drawTarget(window, stims.targets(i,j), imageLocs);
          Screen('Flip', window);
          if (debug); prae_dbTimeStamp('image onset:',t_trial_start);end
          if stims.condition(i,j) == 2
              while (GetSecs < t_trial_start + T_PIC);end
          else
              while (GetSecs < t_trial_start + T_CUE + T_DELAY + T_PIC);end
          end
          % DELAY -------------------------------------%
          t_delay2_start = GetSecs;
          prae_drawFocusCharacter(window, colors.white, imageLocs);
          Screen('Flip', window);
          if (debug); prae_dbTimeStamp('delay 2 onset:',t_trial_start);end
          if stims.condition(i,j) == 2
              while (GetSecs < t_trial_start + T_PIC + T_DELAY);end
          else
              while (GetSecs < t_trial_start + T_CUE + T_DELAY + T_PIC + T_DELAY);end
          end
      end %
      
      if stims.condition(i,j) == 4 % only on full+rating trials
          % RATING -------------------------------------%
          t_rate_start = GetSecs;

          prae_drawRate(window,colors.white,colors.white,colors.white,colors.white,imageLocs);
          Screen('Flip', window);
          if (debug); prae_dbTimeStamp('rating onset:',t_trial_start);end
          FlushEvents('keyDown');

          newcol.left = colors.white;
          newcol.middle = colors.white;
          newcol.right = colors.white;

          registeredKeyPress = false;

          while (GetSecs < t_trial_start+T_CUE+T_DELAY+T_PIC+T_DELAY+T_RATE)

              [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);

              % interpret relevant keypresses
              if keyIsDown && ~registeredKeyPress

                  registeredKeyPress = true;

                  switch KbName(keyCode)

                      case keys.first

                          % rated as unpleasant
                          rate(i,j) = -1;
                          newcol.left = colors.blue;

                      case keys.second

                          % rated as neutral
                          rate(i,j) = 0;
                          newcol.middle = colors.blue;

                      case keys.third

                          % rated as pleasant
                          rate(i,j) = 1;
                          newcol.right = colors.blue;

                      otherwise

                          % incorrect key press. Reset.
                          registeredKeyPress = false;

                          newcol.left = colors.white;
                          newcol.middle = colors.white;
                          newcol.right = colors.white;

                  end % switch

                  if registeredKeyPress

                      % show feedback
                      prae_drawRate(window,colors.white,newcol.left,newcol.middle,newcol.right,imageLocs);
                      Screen('Flip', window);

                  end

              end % keyIsDown
          end % wait

          if ~registeredKeyPress
              rate(i,j) = -99;
          end
          
      else
          rate(i,j) = NaN;
      end % ratings
      
      % ITI -------------------------------------%
      
      t_iti_start = GetSecs;
      prae_drawREST(window,'REST',colors.grey);
      Screen('Flip', window);
      if (debug); prae_dbTimeStamp('iti onset:',t_trial_start);end
      while (GetSecs < t_trial_start+T_DUR-1); end
      if (debug); prae_dbTimeStamp('iti offset:',t_trial_start);end
      
      % Display a blank screen between trials
      Screen('Flip', window);
      while (GetSecs < t_trial_start+T_DUR); end
      t_trial_stop = GetSecs;
      Screen('Close');
      
      %% TRIAL SPECIFIC DATA FOR LOGGING (NEED TO UPDATE)
      
      % condition
      switch stims.condition(i,j)
          case 1; cond = 'anticipate';
          case 2; cond = 'retrospect';
          case 3; cond = 'full';
          case 4; cond = 'full+rate';    
      end
      
      % valence
      switch stims.valence(i,j)
          case 1; valence = 'neutral';
          case 2; valence = 'negative';
          case 3; valence = 'positive';
      end
      
      % stimulus onsets
      trial_onsets(i,j) = t_trial_start - t_block_start;
      
      if stims.condition(i,j) ~= 2; 
          cue_onsets(i,j) = t_cue_start - t_block_start; 
          delay1_onsets(i,j) = t_delay1_start - t_block_start;
      else
          cue_onsets(i,j) = NaN;
          delay1_onsets(i,j) = NaN;
      end
      
      if stims.condition(i,j) ~= 1
          image_onsets(i,j) = t_image_start - t_block_start;
          delay2_onsets(i,j) = t_delay2_start - t_block_start;
      else
          image_onsets(i,j) = NaN;
          delay2_onsets(i,j) = NaN;
      end
      
      if stims.condition(i,j) == 4
          rate_onsets(i,j) = t_rate_start - t_block_start;
      else
          rate_onsets(i,j) = NaN;
      end
      
      iti_onsets(i,j) = t_iti_start - t_block_start;
      
      
      % record duration of trial
      trial_durations(i,j) = t_trial_stop - t_trial_start;
      
      % calculate trial onset delay
      if j == 1
        onset_delay = t_trial_start - (t_block_start + T_MRI_WAIT);
      else
        onset_delay = trial_onsets(i,j) - (trial_onsets(i,j-1)+trial_durations(i,j-1));
      end
      if abs(onset_delay) < 0.1; onset_delay = 0; end
      
      % get trial-specific stimuli
      split.target = regexp(stims.targets{i,j},'/','split');
      this.target = split.target{4};
      stim_name{i,j} = this.target;
      
      % print trial results
      trial_info = sprintf('%s\t%d\t%d\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%s\t%s\t%s\t%d\n',...
        subjectNumber,i,j,trial_onsets(i,j),onset_delay,trial_durations(i,j),...
        cue_onsets(i,j),delay1_onsets(i,j),image_onsets(i,j),delay2_onsets(i,j),rate_onsets(i,j),iti_onsets(i,j),...
        cond,valence,this.target,rate(i,j));
      
      fprintf(dataFile,trial_info);
      fprintf(trial_info);
      
      % flush text file to disk
      fclose(dataFile);
      
      % pre-release by 'T_PRE_RELEASE' to allow for TTL wait on next trial
      WaitSecs('UntilTime',t_trial_start+T_DUR);
      % % if (debug); prae_dbTimeStamp('trial:end',t_trial_start);end
      
    end  % trial
    
    % record duration of block
    block_durations(i) = GetSecs - t_block_start;
    
    %% show end of block text
    msg = sprintf(['%d of %d blocks completed\n\n'...
      '...Please remain as still as possible...\n\n' ...
      '...Your experimenter will be with you shortly....'],i,stims.blocks);
    prae_drawMessage(window, msg);
    Screen('Flip',window);
    advanceKey = false;
    
    while ~advanceKey
        
        % % [keyIsDown,secs,keyCode,deltaSecs,devName] = prae_PniKbCheckMulti(keys);
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
        
        % interpret relevant keypresses
        if keyIsDown
            if strcmp(KbName(keyCode), keys.advance)
                advanceKey = true;
                break;
            else
                advanceKey = false;
            end
        end % keyIsDown
        
    end % while waiting for response
    
  end  % block
  
  %% fill results structure for return
  results.script = mfilename();
  results.date = datestr(now);
  results.data_file = [outputFile '.txt'];
  results.subj_num = subjectNumber;
  results.subj_name = subjectName;
  results.block_durations = block_durations;
  results.trial_avg = mean(mean(trial_durations));
  results.trial_durations = trial_durations;
  results.trial_onsets = trial_onsets;
  results.trial_onset_delay = onset_delay;
  results.cue_onsets = cue_onsets;
  results.delay1_onsets = delay1_onsets;
  results.image_onsets = image_onsets;
  results.delay2_onsets = delay2_onsets;
  results.rate_onsets = rate_onsets;
  results.iti_onsets = iti_onsets;
  results.stims = stim_name;
  results.valence_ratings = rate;
  
  % save results structure
  save([outputFile '_results.mat'],'results');
  
  
  %% all done!
  prae_drawMessage(window, 'Task complete. Thank you!\n\nPlease remain as still as possible.\n\nYour experienter will we with you shortly.');
  Screen('Flip',window);
  advanceKey = false;       
      
  while ~advanceKey
      
      % % [keyIsDown,secs,keyCode,deltaSecs,devName] = prae_PniKbCheckMulti(keys);
      [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
      
      % interpret relevant keypresses
      if keyIsDown
          if strcmp(KbName(keyCode), keys.advance)
              advanceKey = true;
          else
              advanceKey = false;
          end
      end % keyIsDown
      
  end % while waiting for response
    
  prae_finishExperiment();
  
end % prae function


function [results] = repref_phase1_short(subjectNumber, subjectName, startBlock, screen, cbfaces, cbscenes)
  %-----------------------------------------------------------------------%
  % [results] = repref_phase1(...
  %
  % SUBJNUM    : unique # based on date string (e.g., '101220')
  % SUBJNAME   : unique subject name (e.g., 'jlp')
  % STARTBLOCK : 1|2 - should always be 1 for _short version
  % SCREEN     : 0|1
  % cbfaces  : unique counterbalance order (1-6) (e.g., 1)
  % cbscenes : unique counterbalance order (1-5) (e.g., 1)
  %
  % e.g.,
  % >> results = repref_phase1('101220','jlp',1,0,1,1)
  %-----------------------------------------------------------------------%
  
  %% script version
  
  version = '2015Jan23'; 
  
  if ~nargin
    jalewpea_script_backup(mfilename,'./',version);
    results = sprintf('script version: %s\n',version);
    return;
  end
  
  %% EXPERIMENTAL PARAMETERS
  
  % Lock variables that used to be function arguments
  % this is the fMRI version of the task ONLY.
  scannerID = 1;
  fMRI = 1;
  debug = 0;
  phase = 1;
  cbhand = 1;
  
  % Trial-related time variables (seconds)
  T_TARGET = 1;
  T_DELAY = 1;
  T_TRIAL_DURATION = T_TARGET+T_DELAY;

  T_MRI_WAIT = 10; % MRI stabilization interval
  
  if ~fMRI 
    T_MRI_WAIT = 0;
  end
  
  
  % add subroutines
  assert(logical(exist('./repref_subroutines','dir')),...
    sprintf('(*) "repref_subroutines" directory does not exisit in: %s',pwd));
  addpath repref_subroutines/
  
  % sanity checks
  assert(ischar(subjectNumber),'(*) subjectNumber must be a ''string''');
  assert(ischar(subjectName),'(*) subjectName must be a ''string''');
  
  %-------------------------------------------------------------------------%
  %
  % RUN THE EXPERIMENT!!!
  %
  %-------------------------------------------------------------------------%
  
  %------------------------------%
  %% PRELIMINARY SETUP
  
  [window imageLocs colors] = repref_setupExperiment(debug,screen);
  [keys] = repref_setKeys(scannerID,phase,cbhand,startBlock);
  repref_loadFunctions();
  
  flipTime = Screen('GetFlipInterval',window);
  dblFlipTime = 2*flipTime;
  
  %------------------------------%
  %% STIMULI SETUP
  
  allstims = repref_getstimuli(subjectNumber,subjectName,cbfaces,cbscenes);
  stims = allstims.phase1;
  prac_stims = allstims.phase1_practice;
  
  %------------------------------%
  %% SETUP RESULTS FILE
  
  % open and set-up files
  outputFile = ['./results/' mfilename() '_' subjectNumber '_' subjectName];
  dataFile = fopen([outputFile '.txt'], 'a');
  
  % print out analysis information
  header = sprintf([...
    '*********************************************\n' ...
    '* RepRef Experiment\n' ...
    '* Phase: 1 (1-back MVPA localizer)\n' ... 
    '* Script: %s\n'...
    '* Version: %s\n'...
    '* Date/Time: %s\n' ...
    '* Subject Number: %s\n' ...
    '* Subject Name: %s\n' ...
    '* Run: %d\n' ...
    '* fMRI: %d\n' ...
    '* Debug: %d\n' ...
    '* Screen: %d\n' ...
    '* Stims File: %s\n' ...
    '* Results File: %s\n' ...
    '*********************************************\n\n'], ...
    mfilename, version, datestr(now,0), subjectNumber, subjectName, ...
    startBlock, fMRI, debug, screen, allstims.filename, [outputFile '.txt']);
  
  fprintf(dataFile,'%s',header);
  fprintf('%s',header);
  
  %% INSTRUCTIONS
  
  if startBlock == 1
    % run instructions & training
    repref_showInstructions_phase1(window,imageLocs,colors,keys,cbhand,fMRI,prac_stims,outputFile);
    % clean up output file
    dataFile = fopen([outputFile '.txt'], 'a');
    line_gap = sprintf('\n');
    fprintf(dataFile,line_gap);
    fprintf(line_gap);
    fclose(dataFile);
  end
  
  
  %% WAITING FOR EXPERIMENT TO BEGIN!
  
  msg = sprintf('We are ready to begin the first task.\n\n');
  if fMRI
    msg = [msg 'The screen will go blank for 10 seconds before the first trial starts.'];
  else
    msg = [msg '(press any button to start!)'];
  end
  repref_drawMessage(window,msg);
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
  
  %------------------------------%
  %% STIMULUS PRESENTATION
  
  % Set up arrays to collect/report behavioral data.
  responses = zeros(stims.blocks, stims.trials_perblock);
  responseRTs = zeros(stims.blocks, stims.trials_perblock);
  acc = zeros(stims.blocks, stims.trials_perblock);
  
  trial_durations = zeros(stims.blocks,stims.trials_perblock);
  trial_onsets = zeros(stims.blocks,stims.trials_perblock);
  delay_onsets = zeros(stims.blocks,stims.trials_perblock);
  
  % print header to Matlab window and output file
  dataFile = fopen([outputFile '.txt'], 'a');
  trial_header = ...
    sprintf('id\tblock\ttrial\ttrial_onset\tlag\tlength\tdelay_onset\tcond\tcond_num\tanswer\tresp\tacc\trt\ttarget\n');
  fprintf(dataFile,trial_header);
  fprintf(trial_header);
  fclose(dataFile);
  
  % EXPERIMENTER TRIGGER START OF TASK
  msg = sprintf('Get Ready.\n\n');
  repref_drawMessage(window,msg);
  Screen('Flip',window);
  triggerKey = false;
  
  while ~triggerKey
      
      % % [keyIsDown,secs,keyCode,deltaSecs,devName] = repref_PniKbCheckMulti(keys);
      [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
      
      % interpret relevant keypresses
      if keyIsDown
          if strcmp(KbName(keyCode), keys.trigger)
              triggerKey = true;
             [status, startTime] = StartScan;
             fprintf('Status = %d\n',status);
              if status == 0
                  triggerKey = true;
              else
                msg = sprintf('Error. Scanner not initiated.');
                repref_drawMessage(window,msg);
                Screen('Flip',window);
                WaitSecs(2);
                repref_finishExperiment();
              end
          else
              triggerKey = false;
          end
      end % keyIsDown
      
  end % triggerKey wait
  
  % start task  
  t_task_start = startTime;
  Screen('Flip',window);
    
  % wait for magnetic field to stabilize 
  if T_MRI_WAIT
    while (GetSecs - t_task_start < T_MRI_WAIT); end
  end   
    
  % BLOCK
  for i = startBlock:stims.blocks
       
    % TRIAL
    for j = 1:stims.trials_perblock
      
      % (re-)open text file for output
      dataFile = fopen([outputFile '.txt'], 'a');
      
      % trial start time
      t_trial_start = GetSecs;
      registeredKeyPress = false;
      if (debug); repref_dbTimeStamp('TRIAL:START(global)',t_experiment_start);end
      
      % start RT timer @ beginning of trail
      t_response_start = t_trial_start;
      if (debug); repref_dbTimeStamp('response',t_trial_start);end
      
      
      %% display the target stimulus & allow response.
      target = char(stims.targets(i,j));
      repref_drawImage(window, target, imageLocs);
      Screen('Flip',window);
      % % WaitSecs(T_TARGET-dblFlipTime)
      
      while (GetSecs < t_trial_start+T_TARGET)
        
        % poll for a response
        [keyIsDown,secs,keyCode,deltaSecs] = KbCheck(-1);
        
        % interpret relevant keypresses
        if keyIsDown && ~registeredKeyPress
          registeredKeyPress = true;
          
          if strcmp(KbName(keyCode), keys.first)
            % user indicated picture was identical
            responses(i,j) = 1;
            responseRTs(i,j) = secs - t_response_start;
            
          elseif strcmp(KbName(keyCode), keys.second)
            % user indicated picture was not identical
            responses(i,j) = 0; % he used -1 previously
            responseRTs(i,j) = secs - t_response_start;
            
          else
            registeredKeyPress = false;
          end
        end % keyIsDown
      end % while waiting for response

      
      %% display a focus cross.
      t_delay_start = GetSecs;
      repref_drawFocusCharacter(window,'+',colors.white);
      Screen('Flip',window);
      
      if (debug); repref_dbTimeStamp('dp',t_trial_start);end
      lag = GetSecs - (t_trial_start + T_TARGET);
      lag = lag + dblFlipTime;
      t_adjusted_delay = T_DELAY - lag;
      if (debug)
        repref_dbTimeStamp(sprintf('... adjusted_delay=%.1f',...
          t_adjusted_delay*1000),t_trial_start);
      end
      % % WaitSecs(t_adjusted_delay);
      
      while (GetSecs < t_trial_start+T_TARGET+T_DELAY)
        
        % poll for a response
        [keyIsDown,secs,keyCode,deltaSecs] = KbCheck(-1);
        
        % interpret relevant keypresses
        if keyIsDown && ~registeredKeyPress
          registeredKeyPress = true;
          
          if strcmp(KbName(keyCode), keys.first)
            % user indicated picture was identical
            responses(i,j) = 1;
            responseRTs(i,j) = secs - t_response_start;
            
          elseif strcmp(KbName(keyCode), keys.second)
            % user indicated picture was not identical
            responses(i,j) = 0; % he used -1 previously
            responseRTs(i,j) = secs - t_response_start;
            
          else
            registeredKeyPress = false;
          end
        end % keyIsDown
      end % while waiting for response
      
      if ~registeredKeyPress
        responses(i,j) = NaN;
        responseRTs(i,j) = NaN;
      end
      
      %% Calculate times, export, and wait for next trial
      % record onset times & duration of trial
      t_trial_stop = t_trial_start+T_TRIAL_DURATION;
      trial_onsets(i,j) = t_trial_start - t_task_start;
      trial_durations(i,j) = t_trial_stop - t_trial_start;
      delay_onsets(i,j) = t_delay_start - t_task_start;
      
      % calculate trial onset delay
      if j == 1
        onset_delay = t_trial_start - (t_task_start + T_MRI_WAIT);
      else
        onset_delay = trial_onsets(i,j) - (trial_onsets(i,j-1)+trial_durations(i,j-1));
      end
      if abs(onset_delay) < 0.1; onset_delay = 0; end
      
      % get trial-specific information
      split.target = regexp(target,'/','split');
      this.category = split.target{3};
      this.target = split.target{4};
      
      % accuracy (don't count non-response)
      if isnan(responses(i,j)) == 1
        acc(i,j) = NaN;
      else
        acc(i,j) = stims.answers(i,j) == responses(i,j);
      end
      
      trial_info = sprintf(...
        '%s\t%d\t%d\t%.1f\t%.1f\t%.1f\t%.1f\t%s\t%d\t%d\t%d\t%d\t%.3f\t%s\n',...
        subjectNumber,i,j,trial_onsets(i,j),onset_delay,trial_durations(i,j),...
        delay_onsets(i,j),this.category,stims.condition(i),...
        stims.answers(i,j),responses(i,j),acc(i,j),...
        responseRTs(i,j),this.target);
      
      fprintf(dataFile,trial_info);
      fprintf(trial_info);
      
      % flush text file to disk
      fclose(dataFile);
      
      % wait till next trial
      WaitSecs('UntilTime',t_trial_stop);
      if (debug); repref_dbTimeStamp('trial:end',t_trial_start);end
      
    end  % trial
    
  end  % block
  
  %% fill results structure for return
  results.script = mfilename();
  results.date = datestr(now);
  results.data_file = [outputFile '.txt'];
  results.subj_num = subjectNumber;
  results.subj_name = subjectName;
  results.run = startBlock;
  results.hand = keys.hand;
  results.stims = stims;
  results.trial_durations = trial_durations;
  results.trial_onsets = trial_onsets;
  results.delay_onsets = delay_onsets;
  results.responses = responses;
  results.corrects = stims.answers;
  results.accuracies = (acc);
  results.accuracy_avg = nanmean(nanmean(results.accuracies)); % don't count non-response
  results.rts = responseRTs;
  results.rt_avg = nanmean(nanmean(responseRTs)); % don't count non-response
  
  % save results structure
  save([outputFile '_results.mat'],'results');
  
  % all done!
  repref_drawMessage(window, 'Please remain as still as possible.\n\nYour experimenter will be with you shortly.');
  Screen('Flip',window);
  advanceKey = false;       
      
    while ~advanceKey
          
      % % [keyIsDown,secs,keyCode,deltaSecs,devName] = repref_PniKbCheckMulti(keys);
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
  repref_finishExperiment();
  
end % function                 
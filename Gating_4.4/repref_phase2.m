function [results] = repref_phase2(subjectNumber,subjectName,startBlock,screen,cbhand,cbfaces,cbscenes,skipPrac)
  %-----------------------------------------------------------------------%
  % [results] = repref_phase2( ... )
  %
  % SUBJNUM    : unique # based on date string (e.g., '101220')
  % SUBJNAME   : unique subject name (e.g., 'jlp')
  % STARTBLOCK : 1|2|...|8 experiment block from which to start
  % SCREEN     : 0|1
  % cbhand     : unique counterbalnace order (1 right start,2 left start) (e.g., 1)
  % cbfaces  : unique counterbalance order (1-6) (e.g., 1)
  % cbscenes : unique counterbalance order (1-5) (e.g., 1)
  % skipPrac   : true if you want to skip practice (defaults to false)
  %
  % e.g.,
  % >> results = repref_phase2('101220','jlp',1,0,1,1,1)
  %-----------------------------------------------------------------------%
  
  %% check input and determine whether to skip practice
  
  if (nargin < 7) || (nargin > 8)
      error('Error: Too few or too many inputs');
      return;
  elseif nargin < 8 || isempty(skipPrac)
      skip = false;
  elseif nargin == 8
      skip = skipPrac;
  end
  
  %% script version
  
  version = '2015July03';
  
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
  phase = 2;
  
  % Trial-related time variables (seconds)
  T_TARGETab = 4;
  T_DELAYa = 8;
  T_PROBEa = 1.064; 
  T_RESPONSEa = 0.936; 
  T_DELAYb = T_DELAYa;
  T_PROBEb = T_PROBEa;
  T_RESPONSEb = T_RESPONSEa;
  T_ITI = 6;
    
  T_RSVP_PROBE = 0.216; % duration of each RSVP stimulus
  T_RSVP_GAP = 0.05;
  T_MRI_WAIT = 10; % MRI stabilization interval
    
  if ~fMRI
    T_MRI_WAIT = 0;
    T_ITI = T_ITI-4;
  end
  
  % add subroutines
  assert(logical(exist('./repref_subroutines','dir')),...
    sprintf('(*) "repref_subroutines" directory does not exisit in: %s',pwd));
  addpath repref_subroutines/
  
  % sanity checks
  assert(ischar(subjectNumber),'(*) subjectNumber must be a ''string''');
  assert(ischar(subjectName),'(*) subjectName must be a ''string''');
  
  %-------------------------------------------------------------------------%
  %-------------------------------------------------------------------------%
  
  %% PRELIMINARY SETUP
  
  [window imageLocs colors] = repref_setupExperiment(debug,screen);
  [keys] = repref_setKeys(scannerID,phase,cbhand,startBlock);
  repref_loadFunctions();
  
  % timing stuff
  flipTime = Screen('GetFlipInterval',window);
  dblFlipTime = 2*flipTime;
  T_STAY_TRIAL_DURATION = T_TARGETab+T_DELAYa+T_PROBEa+T_RESPONSEa+T_ITI;
  T_SWITCH_TRIAL_DURATION = T_TARGETab+T_DELAYa+T_DELAYb+T_PROBEb+T_RESPONSEb+T_ITI;
  
  %% STIMULI SETUP
  
  allstims = repref_getstimuli(subjectNumber,subjectName,cbfaces,cbscenes);
  stims = allstims.phase2;
  prac_stims = allstims.phase2_practice;
  
  %% SETUP RESULTS FILE
  
  % open and set-up files
  outputFile = ['./results/' mfilename() '_' subjectNumber '_' subjectName '_' int2str(startBlock)];
  dataFile = fopen([outputFile '.txt'], 'a');
  
  % print out analysis information
  header = sprintf([...
    '*********************************************\n' ...
    '* RepRef Experiment\n' ...
    '* Phase: 2 (Stay & Switch Trials)\n' ...
    '* Script: %s\n'...
    '* Version: %s\n'...
    '* Date/Time: %s\n' ...
    '* Subject Number: %s\n' ...
    '* Subject Name: %s\n' ...
    '* Start Block: %d\n' ...
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
  
  if startBlock == 1 % change back to 1
      if skip == false
          % run instructions & training
          repref_showInstructions_phase2(window,imageLocs,colors,keys,cbhand,scannerID,prac_stims,outputFile);
          % clean up output file
          dataFile = fopen([outputFile '.txt'], 'a');
          line_gap = sprintf('\n');
          fprintf(dataFile,line_gap);
          fprintf(line_gap);
          fclose(dataFile);
      end
  end
  
  %% WAITING FOR EXPERIMENT TO BEGIN
  
  msg = sprintf('We are ready to begin the second task.\n\n');
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
      
      pressed = KbCheck(-1); % this is a work around to clear the key board buffer, otherwise the response from KbWait(-1) stays there
      if pressed; break; end
    
    end
    
    Screen('Flip',window);
  end
  
  
  %% STIMULUS PRESENTATION 
  
  % Set up arrays to collect/report behavioral data.
  responses = zeros(stims.blocks, stims.trials_perblock);
  responseRTs = zeros(stims.blocks, stims.trials_perblock);
  realRTs = zeros(stims.blocks, stims.trials_perblock);
  acc = zeros(stims.blocks, stims.trials_perblock);
  
  block_durations = zeros(1,stims.blocks);
  trial_durations = zeros(stims.blocks,stims.trials_perblock);
  trial_onsets = zeros(stims.blocks,stims.trials_perblock);
  delayA_onsets = zeros(stims.blocks,stims.trials_perblock);
  delayB_onsets = zeros(stims.blocks,stims.trials_perblock);
  probe_onsets = zeros(stims.blocks,stims.trials_perblock);
  response_onsets = zeros(stims.blocks,stims.trials_perblock);
  rsvptarget_onsets = zeros(stims.blocks,stims.trials_perblock);
  
  hand = {};
  
  % print header to Matlab window and output file
  dataFile = fopen([outputFile '.txt'], 'a');
  trial_header = sprintf(...
    'id\tblock\ttrial\ttrial_onset\tlag\ttrial_length\tdelayA_onset\tdelayB_onset\tprobe_onset\tresponse_onset\ttype\tcat\tcond\tcue\tans\tresp\tacc\trt\trealrt\trsvp\ttop\tbottom\n');
  fprintf(dataFile,trial_header);
  fprintf(trial_header);
  fclose(dataFile);
  
  % BLOCK
  for i = startBlock:stims.blocks
    
    % re-assign buttons for handedness
    [keys] = repref_setKeys(scannerID,phase,cbhand,i);
    hand = {hand;keys.hand};
    
    % EXPERIMENTER TRIGGER START OF TASK
    msg = sprintf('Get Ready.');
    repref_drawMessage(window,msg);
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

    % start the  block
    t_block_start = startTime;
    Screen('Flip',window);
    
    % wait for magnetic field to stabilize
    if T_MRI_WAIT
      while(GetSecs - t_block_start < T_MRI_WAIT); end
    end   
    
    % TRIAL
    for j = 1:stims.trials_perblock
      
      % (re-)open text file for output
      dataFile = fopen([outputFile '.txt'], 'a');
      
      t_trial_start = GetSecs;
      if (debug); repref_dbTimeStamp('TRIAL:START(global)',t_experiment_start);end
      
      %------------------------------%
      % TARGETab PRESENTATION
      
      repref_drawTargets(window, stims.targets(i,j,:), imageLocs);
      repref_drawFocusCharacter(window,'+',colors.white);
      Screen('Flip', window);
      if (debug); repref_dbTimeStamp('targetAB',t_trial_start);end
      while (GetSecs < t_trial_start+T_TARGETab); end
      
      %------------------------------%
      % DELAYa
      
      % display a focus cross during post-cueA delay period
      t_delayA_start = GetSecs;
      repref_drawFocusCharacter(window,'+',colors.white);
      Screen('Flip', window);
      if (debug); repref_dbTimeStamp('dpA',t_trial_start); end
      while (GetSecs < t_trial_start+T_TARGETab+T_DELAYa); end
      
      if ~stims.switches(i,j)
          
        % ** stay trial **
        t_trial_stop = t_trial_start+T_STAY_TRIAL_DURATION;
        
        %------------------------------%
        % PROBEa
       
        % set up
        t_probe_start = GetSecs;
        registeredKeyPress = false;
        fbColor = colors.white;
        t_response_start = t_probe_start;
       
        % display the RSVP probes.
        probes = stims.probes1{i,j};
        t_prev_probe_end = GetSecs;
        
        for p = 1:length(probes)
            
            repref_drawImage(window,char(probes(p)),imageLocs);
            Screen('Flip',window);
            
            if p == stims.rsvptarget(i,j)
                rsvptarget_onsets(i,j) = GetSecs - t_probe_start;
            else
                rsvptarget_onsets(i,j) = NaN;
                if p == length(probes)
                    t_last_probe = GetSecs - t_probe_start;
                end
            end
            
            while (GetSecs < t_prev_probe_end+T_RSVP_PROBE)
                
                % accept key press
                [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
                
                % interpret relevant keypresses
                if keyIsDown && ~registeredKeyPress
                    registeredKeyPress = true;
                    
                    if strcmp(KbName(keyCode), keys.first)
                        % user indicated picture was identical
                        responses(i,j) = 1;
                        responseRTs(i,j) = secs - t_response_start;
                        fbColor = repref_getFeedback(colors,responses(i,j)==stims.answers(i,j));
                        
                    elseif strcmp(KbName(keyCode), keys.second)
                        % user indicated picture was not identical
                        responses(i,j) = -1;
                        responseRTs(i,j) = secs - t_response_start;
                        fbColor = repref_getFeedback(colors,responses(i,j)==stims.answers(i,j));
                        
                    else
                        registeredKeyPress = false;
                    end
                end % if key press
                
            end % while
            
            % blank screen gap
            Screen('Flip',window);

            while (GetSecs < t_prev_probe_end+T_RSVP_PROBE+T_RSVP_GAP)
                
                % accept key press
                [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
                
                % interpret relevant keypresses
                if keyIsDown && ~registeredKeyPress
                    registeredKeyPress = true;
                    
                    if strcmp(KbName(keyCode), keys.first)
                        % user indicated picture was identical
                        responses(i,j) = 1;
                        responseRTs(i,j) = secs - t_response_start;
                        fbColor = repref_getFeedback(colors,responses(i,j)==stims.answers(i,j));
                        
                    elseif strcmp(KbName(keyCode), keys.second)
                        % user indicated picture was not identical
                        responses(i,j) = -1;
                        responseRTs(i,j) = secs - t_response_start;
                        fbColor = repref_getFeedback(colors,responses(i,j)==stims.answers(i,j));
                        
                    else
                        registeredKeyPress = false;
                    end
                end % if key press
                
            end % while

            if (debug); repref_dbTimeStamp(sprintf('probe%d(rel)',p),t_prev_probe_end);end
            t_prev_probe_end = GetSecs;
            
        end
        
        % total probe time
        t_probe = GetSecs - t_last_probe;
        
        % response screen
        repref_drawCircle(window,fbColor);
        Screen('Flip',window);
        if (debug); repref_dbTimeStamp('responseA',t_trial_start);end
        
        % open response window
        while (GetSecs < t_probe_start+T_PROBEa+T_RESPONSEa)
            
            % accept button press
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
          
            % interpret relevant keypresses
            if keyIsDown && ~registeredKeyPress
                registeredKeyPress = true;
                
                if strcmp(KbName(keyCode), keys.first)
                    % user indicated picture was identical
                    responses(i,j) = 1;
                    responseRTs(i,j) = secs - t_response_start;
                    fbColor = repref_getFeedback(colors,responses(i,j)==stims.answers(i,j));
                    
                elseif strcmp(KbName(keyCode), keys.second)
                    % user indicated picture was not identical
                    responses(i,j) = -1;
                    responseRTs(i,j) = secs - t_response_start;
                    fbColor = repref_getFeedback(colors,responses(i,j)==stims.answers(i,j));
                    
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
        
        % place holder for results
        t_delayB_start = NaN;
        
      else
          
        % ** switch trial **
        t_trial_stop = t_trial_start+T_SWITCH_TRIAL_DURATION;
                
        %------------------------------%
        % DELAYb
        
        % display a red focus 'X' during second delay period
        t_delayB_start = GetSecs;
        repref_drawFocusCharacter(window,'x',colors.white);
        Screen('Flip', window);
        if (debug); repref_dbTimeStamp('dpB',t_trial_start);end
        while (GetSecs < t_trial_start + T_TARGETab + T_DELAYa + T_DELAYb); end
        
        %------------------------------%
        % PROBEb
        
        % set up
        t_probe_start = GetSecs;
        registeredKeyPress = false;
        fbColor = colors.white;
        t_response_start = t_probe_start;
        
        % display the RSVP probes.
        probes = stims.probes2{i,j};
        t_prev_probe_end = GetSecs;
        
        for p = 1:length(probes)
            
            % draw probes
            repref_drawImage(window,char(probes(p)),imageLocs);
            Screen('Flip',window);
            
            if p == stims.rsvptarget(i,j)
                rsvptarget_onsets(i,j) = GetSecs - t_probe_start;
            else
                rsvptarget_onsets(i,j) = NaN;
                if p == length(probes)
                    t_last_probe = GetSecs - t_probe_start;
                end
            end
            
            while (GetSecs < t_prev_probe_end+T_RSVP_PROBE)
                % accept button press
                [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);

                % interpret relevant keypresses
                if keyIsDown && ~registeredKeyPress
                    registeredKeyPress = true;

                    if strcmp(KbName(keyCode), keys.first)
                        % user indicated picture was identical
                        responses(i,j) = 1;
                        responseRTs(i,j) = secs - t_response_start;
                        fbColor = repref_getFeedback(colors,responses(i,j)==stims.answers(i,j));
                        
                    elseif strcmp(KbName(keyCode), keys.second)
                        % user indicated picture was not identical
                        responses(i,j) = -1;
                        responseRTs(i,j) = secs - t_response_start;
                        fbColor = repref_getFeedback(colors,responses(i,j)==stims.answers(i,j));

                    else
                        registeredKeyPress = false;
                    end
                end % if button press
            end % while
            
            % blank screen gap
            Screen('Flip',window);
            
            while (GetSecs < t_prev_probe_end+T_RSVP_PROBE+T_RSVP_GAP)
                % accept button press
                [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);

                % interpret relevant keypresses
                if keyIsDown && ~registeredKeyPress
                    registeredKeyPress = true;

                    if strcmp(KbName(keyCode), keys.first)
                        % user indicated picture was identical
                        responses(i,j) = 1;
                        responseRTs(i,j) = secs - t_response_start;
                        fbColor = repref_getFeedback(colors,responses(i,j)==stims.answers(i,j));
                        
                    elseif strcmp(KbName(keyCode), keys.second)
                        % user indicated picture was not identical
                        responses(i,j) = -1;
                        responseRTs(i,j) = secs - t_response_start;
                        fbColor = repref_getFeedback(colors,responses(i,j)==stims.answers(i,j));

                    else
                        registeredKeyPress = false;
                    end
                end % if button press
            end % while
            
            if (debug); repref_dbTimeStamp(sprintf('probe%d(rel)',p),t_prev_probe_end);end
            t_prev_probe_end = GetSecs;
            
        end
        
        % total probe time
        t_probe = GetSecs - t_last_probe;
        
        % response screen
        repref_drawCircle(window,fbColor);
        Screen('Flip',window);
        if (debug); repref_dbTimeStamp('responseB',t_trial_start);end
        
        % open response window
        while (GetSecs < t_probe_start+T_PROBEb+T_RESPONSEb)
          
          [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
          
          % interpret relevant keypresses
          if keyIsDown && ~registeredKeyPress
            registeredKeyPress = true;
            
            if strcmp(KbName(keyCode), keys.first)
              % user indicated picture was identical
              responses(i,j) = 1;
              responseRTs(i,j) = secs - t_response_start;
              fbColor = repref_getFeedback(colors,responses(i,j)==stims.answers(i,j));
              
            elseif strcmp(KbName(keyCode), keys.second)
              % user indicated picture was not identical
              responses(i,j) = -1;
              responseRTs(i,j) = secs - t_response_start;
              fbColor = repref_getFeedback(colors,responses(i,j)==stims.answers(i,j));
              
            end
            
            % show feedback
            if registeredKeyPress
                repref_drawCircle(window,fbColor);
                Screen('Flip',window);
            end
            
          end % keyIsDown
          
        end % while waiting for response
        
      end % trial type
      
      
      %% ITI
      
      % Display a blank screen between trials
      repref_drawFocusCharacter(window,'+',colors.blue);
      Screen('Flip', window);
      if (debug); repref_dbTimeStamp('iti',t_trial_start);end
      Screen('Close');
      
      % leave response window open for half the ITI
      while (GetSecs < t_probe_start+T_PROBEb+T_RESPONSEb+(.5*T_ITI))
          
          [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
          
          % interpret relevant keypresses
          if keyIsDown && ~registeredKeyPress
              registeredKeyPress = true;
              
              if strcmp(KbName(keyCode), keys.first)
                  % user indicated picture was identical
                  responses(i,j) = 1;
                  responseRTs(i,j) = secs - t_response_start;
                  
              elseif strcmp(KbName(keyCode), keys.second)
                  % user indicated picture was not identical
                  responses(i,j) = -1;
                  responseRTs(i,j) = secs - t_response_start;
                  
              else
                  registeredKeyPress = false;
              end
          end % key press
      end % while wating
      
      % non-response if no button press
      if ~registeredKeyPress 
        responses(i,j) = NaN;
        responseRTs(i,j) = NaN;
      end
      
      % adjusted RTs
      if isnan(rsvptarget_onsets(i,j)) && ~isnan(responseRTs(i,j));
          realRTs(i,j) = responseRTs(i,j) - t_probe;
      elseif ~isnan(rsvptarget_onsets(i,j)) && ~isnan(responseRTs(i,j));
          realRTs(i,j) =  responseRTs(i,j) - rsvptarget_onsets(i,j);
      elseif isnan(responseRTs(i,j));
          realRTs(i,j) = NaN;
      end
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % collect trial-specific information for logging
      
      % type
      switch stims.switches(i,j)
        case 0
          type = 'stay';
        otherwise
          type = 'switch';
      end
      
      % cue
      switch stims.cues(i,j)
        case 0
          cue = '-';
        case 1
          cue = 'bottom';
        case 2
          cue = 'top';
      end
      
      % category
      switch stims.cuedcats(i,j)
        case 1
          cat = 'face';
        case 2
          cat = 'scene';
      end
      
      % condition
      switch stims.cuecond(i,j)
        case 1
          cond = 'sad';
        case 2
          cond = 'neutral';
      end
      
      % record onsets & duration of trial
      trial_onsets(i,j) = t_trial_start - t_block_start;
      delayA_onsets(i,j) = t_delayA_start - t_block_start;
      switch stims.switches(i,j)
        case 0
          delayB_onsets(i,j) = NaN;
        otherwise
          delayB_onsets(i,j) = t_delayB_start - t_block_start;
      end
      probe_onsets(i,j) = t_probe_start - t_block_start;
      response_onsets(i,j) = t_response_start - t_block_start;
      trial_durations(i,j) = t_trial_stop - t_trial_start;
      
      % calculate trial onset delay
      if j == 1
        onset_delay = t_trial_start - (t_block_start + T_MRI_WAIT);
      else
        onset_delay = trial_onsets(i,j) - (trial_onsets(i,j-1)+trial_durations(i,j-1));
      end
      if abs(onset_delay) < 0.1; onset_delay = 0; end
      
      % trial accuracy (don't count non-response)
      if isnan(responses(i,j)) == 1
        acc(i,j) = NaN;
      else
        acc(i,j) = stims.answers(i,j) == responses(i,j);
      end
      
      % get trial-specific stimuli
      split.target1 = regexp(stims.targets{i,j,1},'/','split');
      this.target1 = split.target1{4};
      split.target2 = regexp(stims.targets{i,j,2},'/','split');
      this.target2 = split.target2{4};
      
      % print trial results
      trial_info = sprintf('%s\t%d\t%d\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%.3f\t%.3f\t%d\t%s\t%s\n',...
        subjectNumber,i,j,trial_onsets(i,j),onset_delay,trial_durations(i,j),...
        delayA_onsets(i,j),delayB_onsets(i,j),probe_onsets(i,j),response_onsets(i,j),...
        type,cat,cond,cue,stims.answers(i,j),responses(i,j),...
        acc(i,j),responseRTs(i,j),realRTs(i,j),stims.rsvptarget(i,j),this.target1,this.target2);
      
      fprintf(dataFile,trial_info);
      fprintf(trial_info);
      
      % flush text file to disk
      fclose(dataFile);
      
      % pre-release by 'T_PRE_RELEASE' to allow for TTL wait on next trial
      WaitSecs('UntilTime',t_trial_stop);
      if (debug); repref_dbTimeStamp('trial:end',t_trial_start);end
      
    end  % trial
    
    % record duration of block
    block_durations(i) = GetSecs - t_block_start;
    
    % determine accuracy for cued trials
    block.answers = stims.answers(i,:);
    block.responses = responses(i,:);
    block.cued_trials = find(block.answers~=0);
    block.corrects = sum(block.answers(block.cued_trials)==block.responses(block.cued_trials));
    block.accuracy = 100*block.corrects/length(block.cued_trials);
    
    %% show block results
    msg = sprintf(['%d of %d blocks completed\n\n'...
      '** accuracy on this block was: %.1f %% **\n\n'...
      '...Please remain as still as possible...\n\n' ...
      '...Your experimenter will be with you shortly...'],i,stims.blocks,block.accuracy);
    repref_drawMessage(window, msg);
    Screen('Flip',window);
    advanceKey = false;
    
    while ~advanceKey
        
        % % [keyIsDown,secs,keyCode,deltaSecs,devName] = repref_PniKbCheckMulti(keys);
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
        
        % interpret relevant keypresses
        if keyIsDown
            if strcmp(KbName(keyCode), keys.advance)
                advanceKey = true;
                if i == 4
                    repref_finishExperiment();
                    break;
                end
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
  results.trial_avg = mean(mean(trial_durations));
  results.trial_durations = trial_durations;
  results.trial_onsets = trial_onsets;
  results.delayA_onsets = delayA_onsets;
  results.delayB_onsets = delayB_onsets;
  results.probe_onsets = probe_onsets;
  results.response_onsets = response_onsets;
  results.stims = stims;
  results.responses = responses;
  results.corrects = stims.answers;
  results.accuracies = (acc);
  results.accuracy_avg = nanmean(nanmean(results.accuracies)); % don't count non-response
  results.rts = responseRTs;
  results.realrts = realRTs;
  results.rt_avg = nanmean(nanmean(responseRTs)); % don't count non-response
  results.hand = hand;
  
  % save results structure
  save([outputFile '_results.mat'],'results');
  
  
  %% all done!
  repref_drawMessage(window, 'Task complete. Thank you!\n\nPlease remain as still as possible.\n\nYour experienter will we with you shortly.');
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
  
end % main function

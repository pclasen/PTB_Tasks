function [ ] = prae_prescan(subjectNumber, subjectName)
  %-----------------------------------------------------------------------%
  % [results] = prae_prescan( ... )
  %
  % SUBJNUM    : unique # based on date string (e.g., '1001')
  % SUBJNAME   : unique subject name (e.g., 'prae')
  %
  % e.g.,
  % >> results = prae_prescreen('101220','jlp')
  %-----------------------------------------------------------------------%
 %% script version
  
  version = '2015MAY22(3.4)';
  
  if ~nargin
    script_backup(mfilename,'./',version);
    return;
  end 
  
  % add subroutines
  assert(logical(exist('./prae_subroutines','dir')),...
    sprintf('(*) "prae_subroutines" directory does not exisit in: %s',pwd));
  addpath prae_subroutines/
  
  % sanity checks
  assert(ischar(subjectNumber),'(*) subjectNumber must be a ''string''');
  assert(ischar(subjectName),'(*) subjectName must be a ''string''');
  
  %% EXPERIMENTAL PARAMETERS
  
  % Hard code arguments for scanner
  scannerID = 0;
  debug = 0;
  screen = 0;
  
%% PRELIMINARY SETUP
  
  [window imageLocs colors] = prae_setupExperiment(debug,screen);
  [keys] = prae_setKeys(scannerID);
  prae_loadFunctions();
    
  %% STIMULI SETUP
  
  allstims = prae_getstimuli(subjectNumber,subjectName);
  prac = allstims.practice;
  
  
  %% INSTRUCTIONS
  
  if startBlock == 1
      if skip == false
        % run instructions & training
        prae_showInstructions(window,imageLocs,colors,keys,scannerID,prac);
      end
  end
  
  % press "a" to exit after termination
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
  
  
end % function


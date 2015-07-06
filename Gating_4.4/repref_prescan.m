function [ ] = repref_prescan(subjectNumber,subjectName,phase,screen,cbfaces,cbscenes)
  %-----------------------------------------------------------------------%
  % [ ] = repref_prescan(...)
  %
  % SUBJNUM    : unique # based on date string (e.g., '101220')
  % SUBJNAME   : unique subject name (e.g., 'jlp')
  % phase      : 1|2 - corresponds to phase you want instructions for (e.g., 1)
  % SCREEN     : 0|1 - 0 is primary screen
  % cbfaces    : unique counterbalance order (1-6) (e.g., 1)
  % cbscenes   : unique counterbalance order (1-5) (e.g., 1)
  %
  % e.g.,
  % >> results = repref_phase1('101220','jlp',1,0,1,1)
  %-----------------------------------------------------------------------%

  %% script version
  
  version = '2015Jan20'; 
  
  if ~nargin
    jalewpea_script_backup(mfilename,'./',version);
    results = sprintf('script version: %s\n',version);
    return;
  end
  
  % add subroutines
  assert(logical(exist('./repref_subroutines','dir')),...
    sprintf('(*) "repref_subroutines" directory does not exisit in: %s',pwd));
  addpath repref_subroutines/
  
  % sanity checks
  assert(ischar(subjectNumber),'(*) subjectNumber must be a ''string''');
  assert(ischar(subjectName),'(*) subjectName must be a ''string''');
  
    %% EXPERIMENTAL PARAMETERS
  
  % Lock variables that used to be function arguments
  % this is the fMRI version of the task ONLY.
  scannerID = 0;
  startBlock = 0;
  fMRI = 0;
  debug = 0;
  cbhand = 1;
  
  %% PRELIMINARY SETUP
  
  [window imageLocs colors] = repref_setupExperiment(debug,screen);
  [keys] = repref_setKeys(scannerID,phase,cbhand,startBlock);
  repref_loadFunctions();
  
  %------------------------------%
  %% STIMULI SETUP
  
  allstims = repref_getstimuli(subjectNumber,subjectName,cbfaces,cbscenes);
  prac_stims1 = allstims.phase1_prescan;
  prac_stims2 = allstims.phase2_prescan;
  
  %------------------------------%

  %% SETUP RESULTS FILE
  
  % open and set-up files
  outputFile = ['./results/' mfilename() '_' subjectNumber '_' subjectName];
  dataFile = fopen([outputFile '.txt'], 'a');
  
  % print out analysis information
  header = sprintf([...
    '*********************************************\n' ...
    '* RepRef Instructions\n' ...
    '* Phase: %s\n' ... 
    '* Script: %s\n'...
    '* Version: %s\n'...
    '* Date/Time: %s\n' ...
    '* Subject Number: %s\n' ...
    '* Subject Name: %s\n' ...
    '* Screen: %d\n' ...
    '* Stims File: %s\n' ...
    '* Results File: %s\n' ...
    '*********************************************\n\n'], ...
    phase, mfilename, version, datestr(now,0), subjectNumber, subjectName, ...
    screen, allstims.filename, [outputFile '.txt']);
  
  fprintf(dataFile,'%s',header);
  fprintf('%s',header);
  
  %% phase 1 instructions
  switch phase
    case 1
      repref_showInstructions_phase1(window,imageLocs,colors,keys,cbhand,fMRI,prac_stims1,outputFile);
      % clean up output file
      dataFile = fopen([outputFile '.txt'], 'a');
      line_gap = sprintf('\n');
      fprintf(dataFile,line_gap);
      fprintf(line_gap);
      fclose(dataFile);
    case 2
      % run instructions & training
      repref_showInstructions_phase2(window,imageLocs,colors,keys,cbhand,fMRI,prac_stims2,outputFile);
      % clean up output file
      dataFile = fopen([outputFile '.txt'], 'a');
      line_gap = sprintf('\n');
      fprintf(dataFile,line_gap);
      fprintf(line_gap);
      fclose(dataFile);
  end % switch

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

end % main function


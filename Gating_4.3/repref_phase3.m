function [results] = repref_phase3(subjectNumber,subjectName,startBlock,screen,scannerID,fMRI,cbfaces,cbscenes,skipPrac)
  %-----------------------------------------------------------------------%
  % [results] = repref_phase3( ... )
  %
  % SUBJNUM    : unique # based on date string (e.g., '101220')
  % SUBJNAME   : unique subject name (e.g., 'jlp')
  % STARTBLOCK : 1|2|...|8 experiment block from which to start
  % SCREEN     : 0|1
  % cbfaces  : unique counterbalance order (1-6) (e.g., 1)
  % cbscenes : unique counterbalance order (1-5) (e.g., 1)
  % skipPrac   : true if you want to skip practice (defaults to false)
  %
  % e.g.,
  % >> results = repref_phase3('101220','jlp',1,0,1,1)
  %-----------------------------------------------------------------------%
 
  %% check input and determine whether to skip practice
  
  if (nargin < 8) || (nargin > 9)
      error('Error: Too few or too many inputs');
      return;
  elseif nargin < 9 || isempty(skipPrac)
      skip = false;
  elseif nargin == 9
      skip = skipPrac;
  end
  
  %% script version
  
  version = '2015Jan13';
  
  if ~nargin
    jalewpea_script_backup(mfilename,'./',version);
    results = sprintf('script version: %s\n',version);
    return;
  end
  
  %% EXPERIMENTAL PARAMETERS
  
  % Lock variables that used to be function arguments
  % this is the fMRI version of the task ONLY.
  debug = 0;
  phase = 3;
  
  % Trial-related time variables (seconds)
  T_PROBE = 4;
  T_FEEDBACK = 0.75;
  T_ITI = 0.5;
  
  % Keyboard for training (add conditions for scanner)
  if fMRI == 0
    resp_keys = {'6';'7';'8'};
  else 
    resp_keys = {'INDEX finger';'MIDDLE finger';'RING finger'};
  end
  
  % add subroutines
  assert(logical(exist('./repref_subroutines','dir')),...
    sprintf('(*) "repref_subroutines" directory does not exisit in: %s',pwd));
  addpath repref_subroutines/
  
  % sanity checks
  assert(ischar(subjectNumber),'(*) subjectNumber must be a ''string''');
  assert(ischar(subjectName),'(*) subjectName must be a ''string''');
  
  %------------------------------%
  %% PRELIMINARY SETUP
  
  [window imageLocs colors] = repref_setupExperiment(debug,screen);
  [keys] = repref_setKeys(scannerID,phase,startBlock);
  repref_loadFunctions();
  
  %------------------------------%
  %% STIMULI SETUP
  
  allstims = repref_getstimuli(subjectNumber,subjectName,cbfaces,cbscenes);
  stims = allstims.phase3;
  prac_stims = allstims.phase3_practice;
  
  %------------------------------%
  %% SETUP RESULTS FILE
  
  % open and set-up files
  outputFile = ['./results/' mfilename() '_' subjectNumber '_' subjectName];
  dataFile = fopen([outputFile '.txt'], 'a');
  
  % print out analysis information
  header = sprintf([...
    '*********************************************\n' ...
    '* RepRef Experiment\n' ...
    '* Phase: 3 Old/New Recognition\n' ...
    '* Script: %s\n'...
    '* Version: %s\n'...
    '* Date/Time: %s\n' ...
    '* Subject Number: %s\n' ...
    '* Subject Name: %s\n' ...
    '* Start Block: %s\n' ...
    '* Stims File: %s\n' ...
    '* Results File: %s\n' ...
    '*********************************************\n\n'], ...
    mfilename,version, datestr(now,0), subjectNumber, subjectName, ...
    num2str(startBlock), allstims.filename, [outputFile '.txt']);
  
  fprintf(dataFile,'%s',header);
  fprintf('%s',header);
  
  %------------------------------%
  %% SETUP RESPONSE COLLECTION
  
  % Set up arrays to collect/report behavioral data.
  responses = zeros(stims.trials_perblock, 1);
  responseRTs = zeros(stims.trials_perblock, 1);
  confidence = zeros(stims.trials_perblock, 1);
  confidenceRTs = zeros(stims.trials_perblock, 1);

  trial_header = sprintf('id\ttrial\ttype\tcat\tp2block\tp2trial\tp2ans\tp3ans\tansType\tcond\tresp\tresponse\tacc\trespRT\tconf\tconfidence\tconfRT\tstim\n');
  fprintf(dataFile,trial_header);
  fprintf(trial_header);
  
  %------------------------------%
  %% Instructions
  if skip == false
      
      msg = sprintf(['Welcome to the third and final activity!\n\n\n' ...
        'Press any button to continue.']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      msg = sprintf(['Before reviewing the instructions for this activity please be aware\n\n' ...
        'that we will be taking very high resolution pictures of your brain\n\n' ...
        'while you complete this activity. These are not pictures of how your\n\n' ...
        'brain is functioning, rather pictures of the structures of your brain.\n\n' ...
        'The scanner will make different kinds of noises while it takes these pictures,\n\n' ...
        'that is compeletly normal. Just remember to try and remain as still possible\n\n' ...
        'while you complete the third and final activity.\n\n' ...
        'Press any button to review the instructions.']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      msg = sprintf([
        'In this activity you will see many faces, one at a time.\n\n'...
        'For each of these faces, your job is to decide whether or not\n\n'...
        'you saw the face in the previous activity. Specifically, you\n\n'...
        'should decide whether each face presented here matches one of\n\n'...
        'the FACE targets that you saw at the beginning of each trial\n\n'...
        'of the previous activity, which you then held in mind until you\n\n'...
        'saw the set of 4 rapid pictures. These are the faces that you \n\n'...
        'saw along with a picture of a scene. Press any button to see\n\n'...
        'a reminder of how the FACE targets appeared in the last activity.\n\n']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      %% example of paring

      repref_drawTargets(window, prac_stims.pair(:,1), imageLocs);
      repref_drawFocusCharacter(window,'+',colors.white);
      Screen('Flip', window);
      FlushEvents('keyDown');
      WaitSecs(2);

      msg = sprintf([
        'In this activity, you will only be tested for your memory of the \n\n'...
        'FACE targets from the previous activity, not for any "non-target" faces\n\n'...
        'that appeared during the 4 rapid pictures or any of the SCENE targets.']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      msg = sprintf([
        'We will not try to trick you! In this activity we will only show you\n\n'...
        'faces that were FACE targets that you tried to remember at the beginning \n\n'...
        'of each trial from the previous activity, OR brand new faces that you\n\n'...
        'have not seen today during any of the activities.']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      msg = sprintf(['For each face you see in this activity it is really important\n\n' ...
        'that you pay attention to it and search you memory to determine:\n\n' ...
        'Whether you think you remember seeing it as a FACE target in the\n\n'...
        'previous activity, in which case you would call it "OLD" (remember,\n\n'...
        'you will only be shown FACE targets) OR whether you think the face\n\n'...
        'was not a FACE target, in which case you would call it "NEW".\n\n\n'...
        'Press the %s button if you think you recognize the face as "OLD".\n\n'...
        'Press the %s button if you think the face is "NEW".\n\n\n'...
        'You will have two seconds to decide wither you think the face is OLD or NEW.\n\n'...
        'Please try your best to respond to each of the faces.'],resp_keys{1},resp_keys{3});
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      msg = sprintf(['After rating whether the face was OLD or NEW, we would also like\n\n' ...
        'to know how sure you were in making your OLD or NEW rating:\n\n\n'...
        'Press the %s button for I AM NOT SURE.\n\n'...
        'Press the %s button for I AM SOMEWHAT SURE.\n\n'...
        'Press the %s button for I AM VERY SURE.\n\n'...
        'You will have two seconds to indicate how sure you are about your rating.\n\n'],resp_keys{1},resp_keys{2},resp_keys{3});
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);

      msg = sprintf(['You will have a chance to practice what it will feel like\n\n' ...
        'to complete this task in a moment. During the practice you will not see\n\n'...
        'any FACE targets from the previous task. You will only see faces you have\n\n'...
        'not seen in any of the activities today. This practice will give you a\n\n'...
        'chance to see how much time you have to respond to each question AND\n\n'...
        'what buttons you should press. Remember, you will only have a couple\n\n'...
        'seconds to make a decision; this can be difficult at first, but you should\n\n'...
        'try your best. Try to be as accurate as possible.\n\n'...
        '(press any button to start practicing)']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');
      WaitSecs(1);
      KbWait(-1);
      WaitSecs(1);

      %% Practice trial block

      repref_phase3_practice(window,imageLocs,colors,keys,prac_stims);

      msg = sprintf(['Now you have a sense for what this task will be like and\n\n'...
        'how long you have to respond to each picture. If you have\n\n'...
        'any questions about completing this activity, please contact\n\n' ...
        'your experimenter now. Otherwise, you can begin the memory test.\n\n'...
        '(press any button to start!)']);
      repref_drawMessage(window,msg);
      Screen('Flip',window);
      FlushEvents('keyDown');

      %% Start subsequent memory test
      switch fMRI
          case 0
              while 1
                  pressed = KbCheck(-1);
                  if pressed; break; end
              end
              Screen('Flip',window);
              FlushEvents('keyDown');
              WaitSecs(2);
          case 1
              % EXPERIMENTER TRIGGER START OF TASK
              msg = sprintf('Get Ready.');
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
                      else
                          triggerKey = false;
                      end
                  end % keyIsDown

              end % triggerKey wait

              Screen('Flip',window);
              WaitSecs(2);
      end % switch
  end % skip 
  %------------------------------%
  %% START THE EXPERIMENT!
  
  % each trial
  for i = 1:stims.trials_perblock
    
    %------------------------------%
    % PROBE PRESENTATION & OLD/NEW RATING
    
    t_probe_start = GetSecs;

    probe = char(stims.targets(i));
    repref_drawImage(window,probe,imageLocs);
    repref_drawRecognition2way(window,colors.white,colors.white,colors.white,imageLocs); 
    Screen('Flip', window);
    FlushEvents('keyDown');
    
    newcol.left = colors.white;
    newcol.right = colors.white;
    
    registeredKeyPress = false;
    
    % response window
    while (GetSecs < t_probe_start+T_PROBE)

      % % [keyIsDown,secs,keyCode,deltaSecs,devName] = repref_PniKbCheckMulti(keys);
      [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
      
      % interpret relevant keypresses
      if keyIsDown && ~registeredKeyPress
        
        registeredKeyPress = true;
        responseRTs(i) = secs - t_probe_start;
        
        switch KbName(keyCode)
          
            case keys.first
   
              % user indicated picture was "OLD"
              responses(i) = -1;
              newcol.left = colors.blue;
                        
            case keys.third
          
              % user indicated picture was "NEW"
              responses(i) = 1;
              newcol.right = colors.blue;
            
            otherwise

              % incorrect key pressed. Reset everything.
              registeredKeyPress = false;
              responseRTs(i) = NaN;
            
              newcol.left = colors.white;
              newcol.right = colors.white;
          
        end
        
        if registeredKeyPress
          
          % show feedback
          repref_drawImage(window,probe,imageLocs);
          repref_drawRecognition2way(window,colors.white,newcol.left,newcol.right,imageLocs);
          Screen('Flip', window);
          WaitSecs(T_FEEDBACK); break;
          
        end
          
      end % keyIsDown
      
      if ~registeredKeyPress
        responses(i) = -99;
        responseRTs(i) = NaN;
      end
      
    end % reponse window
    
    %------------------------------%
    % CONFIDENCE RATING
    
    if responses(i) ~= -99 % response to old/new, get confidence rating
        
      t_rate_start = GetSecs;

      repref_drawRecognition3way(window,colors.white,colors.white,colors.white,colors.white,imageLocs);
      Screen('Flip', window);
      FlushEvents('keyDown');
    
      newcol.left = colors.white;
      newcol.middle = colors.white;
      newcol.right = colors.white;
    
      registeredKeyPress = false;
      
      % response window
      while (GetSecs < t_rate_start+T_PROBE)
 
        % % [keyIsDown,secs,keyCode,deltaSecs,devName] = repref_PniKbCheckMulti(keys);
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
      
        % interpret relevant keypresses
        if keyIsDown && ~registeredKeyPress
        
          registeredKeyPress = true;
          confidenceRTs(i) = secs - t_rate_start;
        
          switch KbName(keyCode)
          
              case keys.first
   
                % user indicated picture was "LOW"
                confidence(i) = 1;
                newcol.left = colors.blue;
                        
              case keys.second
          
                % user indicated picture was "MOD"
                confidence(i) = 2;
                newcol.middle = colors.blue;
            
              case keys.third
            
                % user indicated picture was "HIGH"
                confidence(i) = 3;
                newcol.right = colors.blue;
            
              otherwise

                % incorrect key pressed. Reset everything.
                registeredKeyPress = false;
                confidenceRTs(i) = NaN;
            
                newcol.left = colors.white;
                newcol.middle = colors.white;
                newcol.right = colors.white;
          
          end
        
          if registeredKeyPress
          
            % show feedback
            repref_drawRecognition3way(window,colors.white,newcol.left,newcol.middle,newcol.right,imageLocs);
            Screen('Flip', window);
            WaitSecs(T_FEEDBACK); break;
          
          end
        
        end % keyIsDown
        
        if ~registeredKeyPress
          confidence(i) = -99;
          confidenceRTs(i) = NaN;
        end
        
      end % reponse window
    
    else % no response to old/new
      confidence(i) = -99;
      confidenceRTs(i) = NaN;
    end % if loop
    
    
    %------------------------------%
    %% ITI
    
    % % repref_drawRecognition3way(window,colors.white,colors.white,colors.white,colors.white,imageLocs);
    Screen('Flip', window);
    Screen('Close');
    WaitSecs(T_ITI);
    
    % collect trial-specific info
    source = stims.source(i);
    p2ans = stims.p2answers(i);
    source_idx = find(stims.source_ids==source);
    type = char(stims.source_names(source_idx));
    cond = char(stims.condition_names(stims.condition(i)));
    answer = stims.answers(i);
    response = responses(i);
    accuracy = (answer == response);
    respRT = responseRTs(i);
    conf = confidence(i);
    confRT = confidenceRTs(i);
    cat = char(stims.category_names(stims.category(i)));
    block = stims.p2block(i);
    trial = stims.p2trial(i);
    split.probe = regexp(probe,'/','split');
    probe_name = split.probe{4};
    
    switch response
      case -1; responseType = 'OLD';
      case 1; responseType = 'NEW';
      otherwise; responseType = 'NaN';
    end
    
    switch answer
      case -1; ansType = 'OLD';
      case 1; ansType = 'NEW';
      otherwise; ansType = '???';
    end
    
    switch conf
      case 1; confType = 'Low';
      case 2; confType = 'Moderate';
      case 3; confType = 'High';
      otherwise; confType = 'NaN';
    end
    
    % print trial results
    trial_info = sprintf('%s\t%d\t%s\t%s\t%d\t%d\t%d\t%d\t%s\t%s\t%d\t%s\t%d\t%.2f\t%d\t%s\t%.2f\t%s\n',...
      subjectNumber,i,type,cat,block,trial,p2ans,answer,ansType,cond,response,responseType,accuracy,respRT,conf,confType,confRT,probe_name);
    
    fprintf(dataFile,trial_info);
    fprintf(trial_info);
    
  end  % trial
  
  %% fill results structure for return
  results.script = mfilename();
  results.date = datestr(now);
  results.data_file = [outputFile '.txt'];
  results.subj_num = subjectNumber;
  results.subj_name = subjectName;
  results.categories = stims.source_names;
  results.condition = stims.condition_names;
  results.responses = responses;
  results.responseRTs = responseRTs;
  results.answers = stims.answers;
  results.corrects = (responses == stims.answers);
  results.confidence = confidence;
  results.confidenceRTs = confidenceRTs;
  results.sources = stims.source;
  
  % save results structure
  save([outputFile '_results.mat'],'results');
  
  % all done!
  repref_drawMessage(window, 'Task complete. Thank you!\n\nPlease remain as still as possible while the scan finishes.\n\nYour experimenter will be with you shortly.');
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

function [ ] = repref_phase3_practice(window, imageLocs, colors, keys, stims)
%
%   

  %% EXPERIMENTAL PARAMETERS
  
  % Trial-related time variables (seconds)
  T_PROBE = 4;
  T_FEEDBACK = 0.75;
  T_ITI = 0.5;
  
  trials_perblock = 5;
  
  %% RESPONSE COLLECTION
responses = zeros(trials_perblock,1);
confidence = zeros(trials_perblock,1);
  

 %% START THE EXPERIMENT!
  
  % each trial
  for i = 1:trials_perblock
    
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
        % % responseRTs(i) = secs - t_probe_start;
        
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
              % % responseRTs(i) = NaN;
            
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
        % % responseRTs(i) = NaN;
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
          % % confidenceRTs(i) = secs - t_rate_start;
        
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
                % % confidenceRTs(i) = NaN;
            
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
          % % confidenceRTs(i) = NaN;
        end
        
      end % reponse window
    
    else % no response to old/new
      confidence(i) = -99;
      % % confidenceRTs(i) = NaN;
    end % if loop
    
    
    %------------------------------%
    %% ITI
    
    % % repref_drawRecognition3way(window,colors.white,colors.white,colors.white,colors.white,imageLocs);
    Screen('Flip', window);
    Screen('Close');
    WaitSecs(T_ITI);
  
  end % trials
  
end %% main function


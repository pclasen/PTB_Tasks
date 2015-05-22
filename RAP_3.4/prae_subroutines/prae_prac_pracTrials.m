function [] = prae_prac_pracTrials(window,imageLocs,colors,keys,pracTrials)
% Practice trials procedure

% stimuli, valence, condition, iti
stimuli = pracTrials.stimuli;
valence = pracTrials.valence;
condition = pracTrials.condition;
iti = pracTrials.iti;

% local variables
T_CUE = 2;
T_PIC = 2;
T_DELAY = 4;
T_RATE = 2;

%% PROCEDURE

% pre-trial wait
prae_drawFocusCharacter(window, colors.white, imageLocs);
Screen('Flip',window);
WaitSecs(2);

% start trials
for i = 1:length(stimuli)
    
    % start the clock for each trial
    t_trial_start = GetSecs;
    
    % determine duration for each trial
    switch condition(i) % 1 = anticipate; 2 = retrospect; 3 = full; 4 = full+rate
        case 1; T_DUR = T_CUE+T_DELAY+iti(i);
        case 2; T_DUR = T_PIC+T_DELAY+iti(i);
        case 3; T_DUR = T_CUE+T_DELAY+T_PIC+T_DELAY+iti(i);
        case 4; T_DUR = T_CUE+T_DELAY+T_PIC+T_DELAY+T_RATE+iti(i);
    end
      
    % present the trial
    if condition(i) ~= 2 % not on retrospective catch trials
        
        % CUE -------------------------------------%
        prae_drawCue(window, valence(i), colors);
        Screen('Flip',window);
        while (GetSecs < t_trial_start + T_CUE);end
        
        % DELAY -------------------------------------%
        prae_drawFocusCharacter(window, colors.white, imageLocs);
        Screen('Flip', window);
        while (GetSecs < t_trial_start + T_CUE + T_DELAY);end
        
    end 
    
    if condition(i) ~= 1 % not on anticipation catch trials
        
        % IMAGE -------------------------------------%
        prae_drawTarget(window, stimuli(i), imageLocs);
        Screen('Flip', window);
        if condition(i) == 2
            while (GetSecs < t_trial_start + T_PIC);end
        else
            while (GetSecs < t_trial_start + T_CUE + T_DELAY + T_PIC);end
        end
        
        % DELAY -------------------------------------%
        prae_drawFocusCharacter(window, colors.white, imageLocs);
        Screen('Flip', window);
        if condition(i) == 2
            while (GetSecs < t_trial_start + T_PIC + T_DELAY);end
        else
            while (GetSecs < t_trial_start + T_CUE + T_DELAY + T_PIC + T_DELAY);end
        end
    end %
    
    if condition(i) == 4 % only on full+rating trials
        
        % RATING -------------------------------------%        
        prae_drawRate(window,colors.white,colors.white,colors.white,colors.white,imageLocs);
        Screen('Flip', window);
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
                        newcol.left = colors.blue;
                        
                    case keys.second
                        
                        % rated as neutral
                        newcol.middle = colors.blue;
                        
                    case keys.third
                        
                        % rated as pleasant
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
            
        end
    end % ratings
    
    % ITI -------------------------------------%
    prae_drawREST(window,'REST',colors.white);
    Screen('Flip', window);
    while (GetSecs < t_trial_start+T_DUR-1); end
    
    % Display a blank screen between trials
    Screen('Flip', window);
    while (GetSecs < t_trial_start+T_DUR); end
    Screen('Close');
    
end % trials

WaitSecs(1);

end % main function


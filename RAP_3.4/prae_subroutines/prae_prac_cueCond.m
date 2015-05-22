function [] = prae_prac_cueCond(window,imageLocs,colors,cueCond)
% Cue conditioning procedure

% stimuli and valence
stimuli = cueCond.stimuli;
valence = cueCond.valence;

for i = 1:length(stimuli)
    
    prae_drawCue(window, valence(i), colors);
    Screen('Flip',window);
    WaitSecs(2);
    
    prae_drawFocusCharacter(window, colors.white, imageLocs);
    Screen('Flip',window);
    WaitSecs(4);
    
    prae_drawTarget(window, stimuli(i), imageLocs);
    Screen('Flip',window);
    WaitSecs(2);
    
    Screen('Flip',window);
    Screen('Close');
    
    prae_drawFocusCharacter(window, colors.white, imageLocs);
    Screen('Flip',window);
    WaitSecs(4);
    
    prae_drawREST(window,'REST',colors.white);
    Screen('Flip',window);
    WaitSecs(2);
    
end % for loop

WaitSecs(1);

end % function


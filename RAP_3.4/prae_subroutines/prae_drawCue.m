function prae_drawCue(window, cue, colors)
% Draw cue in proper location
Screen('TextFont', window, 'Helvetica');
Screen('TextSize', window, 288);
Screen('TextStyle', window, 0); % bold = 1
% % Screen('TextColor', window, colors);

switch cue
    case 3 % positive 
        Screen('TextColor', window, colors.green);
        DrawFormattedText(window, '+', 'center', 'center');
    case 1 % neutral
        Screen('TextColor', window, colors.white);
        DrawFormattedText(window, 'o', 'center', 'center');
    case 2 % negative
        Screen('TextColor', window, colors.red);
        DrawFormattedText(window, '-', 'center', 'center');
end


end % function


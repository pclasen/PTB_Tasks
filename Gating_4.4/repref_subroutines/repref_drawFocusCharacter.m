function repref_drawFocusCharacter(window,character,color)
% draw a single character in the center of the screen
  Screen('TextFont', window, 'Helvetica');
  Screen('TextSize', window, 48);
  Screen('TextStyle', window, 0);
  Screen('TextColor', window, color);
  DrawFormattedText(window, character, 'center', 'center');
end

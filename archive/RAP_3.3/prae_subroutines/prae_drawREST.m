function prae_drawREST(window, text, color)
% draw line of text at center of screen
  Screen('TextFont', window, 'Helvetica');
  Screen('TextSize', window, 144);
  Screen('TextStyle', window, 0);
  if (nargin < 3)
    color = WhiteIndex(window);
  end  
  Screen('TextColor', window, color);
  Screen('Preference', 'TextAlphaBlending', 0);
  DrawFormattedText(window, text, 'center', 'center');
end


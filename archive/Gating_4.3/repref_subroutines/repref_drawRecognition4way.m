function repref_drawRecognition4way(window, color_text, color_farleft, color_midleft, color_midright, color_farright, imageLocs)
  
  %% draw 4 circles on top of image
  Screen('FillOval', window, color_farleft, imageLocs.circle_farleft);
  Screen('FillOval', window, color_midleft, imageLocs.circle_midleft);
  Screen('FillOval', window, color_midright, imageLocs.circle_midright);
  Screen('FillOval', window, color_farright, imageLocs.circle_farright);
  
  %% draw text labels
  
  Screen('TextFont', window, 'Helvetica');
  Screen('TextSize', window, 28);
  Screen('TextStyle', window, 1);
  
  DrawFormattedText(window, '(sure old)', imageLocs.circle_farleft(1)-50, imageLocs.circle_farleft(2)-50, color_text);
  DrawFormattedText(window, '(sure new)', imageLocs.circle_farright(1)-50, imageLocs.circle_farright(2)-50, color_text);
  
  DrawFormattedText(window, '(unsure old)', imageLocs.circle_midleft(1)-80, imageLocs.circle_midleft(2)-50, color_text);
  DrawFormattedText(window, '(unsure new)', imageLocs.circle_midright(1)-80, imageLocs.circle_midright(2)-50, color_text);
  
end

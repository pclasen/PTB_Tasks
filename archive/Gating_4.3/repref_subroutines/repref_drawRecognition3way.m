function repref_drawRecognition3way(window, color_text, color_left, color_middle, color_right, imageLocs)
  
  %% draw 3 circles shifted up
  Screen('FillOval', window, color_left, imageLocs.circle_dfarleft);
  Screen('FillOval', window, color_middle, imageLocs.circle_down);
  Screen('FillOval', window, color_right, imageLocs.circle_dfarright);
  
  %% draw text labels
  Screen('TextFont', window, 'Helvetica');
  Screen('TextSize', window, 28);
  Screen('TextStyle', window, 1);
  
  DrawFormattedText(window,'How sure are you about your rating?','center', 'center', color_text);
  DrawFormattedText(window, 'Not sure', imageLocs.circle_dfarleft(1)-50, imageLocs.circle_dfarleft(2)-50, color_text);
  DrawFormattedText(window, 'Somewhat sure', 'center', imageLocs.circle_down(2)-50, color_text);
  DrawFormattedText(window, 'Very sure', imageLocs.circle_dfarright(1)-50, imageLocs.circle_dfarright(2)-50, color_text);
  
  DrawFormattedText(window, '(index)', imageLocs.circle_dfarleft(1)-50, imageLocs.circle_dfarleft(2)+30, color_text);
  DrawFormattedText(window, '(middle)', 'center', imageLocs.circle_down(2)+30, color_text);
  DrawFormattedText(window, '(ring)', imageLocs.circle_dfarright(1)-30, imageLocs.circle_dfarright(2)+30, color_text);
  
end

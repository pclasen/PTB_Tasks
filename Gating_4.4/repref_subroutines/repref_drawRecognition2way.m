function repref_drawRecognition2way(window, color_text, color_left, color_right, imageLocs)
  
  %% draw 2 circles above image
  Screen('FillOval', window, color_left, imageLocs.circle_dfarleft);
  Screen('FillOval', window, color_right, imageLocs.circle_dfarright);
  
  %% draw text labels
  Screen('TextFont', window, 'Helvetica');
  Screen('TextSize', window, 28);
  Screen('TextStyle', window, 1);
  
  DrawFormattedText(window, 'OLD',imageLocs.circle_dfarleft(1)-20, imageLocs.circle_dfarleft(2)-50, color_text);
  DrawFormattedText(window, 'NEW',imageLocs.circle_dfarright(1)-20, imageLocs.circle_dfarright(2)-50, color_text);
  
  DrawFormattedText(window, '(index)',imageLocs.circle_dfarleft(1)-50, imageLocs.circle_dfarleft(2)+30, color_text);
  DrawFormattedText(window, '(ring)',imageLocs.circle_dfarright(1)-30, imageLocs.circle_dfarright(2)+30, color_text);
end

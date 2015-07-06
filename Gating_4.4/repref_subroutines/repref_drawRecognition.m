function repref_drawRecognition(window, color_left, color_right, imageLocs)
  
  % draw 2 circles ... 1 of left, 1 on right
  Screen('FillOval', window, color_left, imageLocs.circle_left);
  Screen('FillOval', window, color_right, imageLocs.circle_right);
  
  % draw text labels
  Screen('TextFont', window, 'Helvetica');
  Screen('TextSize', window, 28);
  Screen('TextStyle', window, 1);
  DrawFormattedText(window, 'old', imageLocs.circle_left(1)-15, imageLocs.circle_left(2)-50, color_left);
  DrawFormattedText(window, 'new', imageLocs.circle_right(1)-20, imageLocs.circle_right(2)-50, color_right);
  
end

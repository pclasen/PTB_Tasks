function prae_drawRate(window, color_text, color_left, color_middle, color_right, imageLocs)
  
  %% draw 3 circles shifted up
  Screen('FillOval', window, color_left, imageLocs.circle_farleft);
  Screen('FillOval', window, color_middle, imageLocs.circle_middle);
  Screen('FillOval', window, color_right, imageLocs.circle_farright);
  
  %% draw text labels
  Screen('TextFont', window, 'Helvetica');
  Screen('TextSize', window, 28);
  Screen('TextStyle', window, 1);
  
  %DrawFormattedText(window, 'Please rate that image?','center', 'center', color_text);
  DrawFormattedText(window, 'Unpleasant', imageLocs.circle_farleft(1)-60, imageLocs.circle_farleft(2)-50, color_text);
  DrawFormattedText(window, 'Neutral', 'center', imageLocs.circle_middle(2)-50, color_text);
  DrawFormattedText(window, 'Pleasant', imageLocs.circle_farright(1)-50, imageLocs.circle_farright(2)-50, color_text);
  
  DrawFormattedText(window, '(index)', imageLocs.circle_farleft(1)-50, imageLocs.circle_farleft(2)+30, color_text);
  DrawFormattedText(window, '(middle)', 'center', imageLocs.circle_middle(2)+30, color_text);
  DrawFormattedText(window, '(ring)', imageLocs.circle_farright(1)-30, imageLocs.circle_farright(2)+30, color_text);
  
end

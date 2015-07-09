function repref_drawRefreshSemanticCue(window, category, colors, imageLocs)
  % draw focus '+' colored according to category of the cue
  
  assert(category == 1 || category ==2);
  switch category
    case 1 % face
      color = colors.orange;
      text = 'face';
    case 2 % scene
      color = colors.blue;
      text = 'scene';
  end
  
  % draw cue word in appropriate color
  Screen('TextSize', window, 48);
  Screen('TextColor', window, color);
  DrawFormattedText(window, text, 'center', 'center');
  
end
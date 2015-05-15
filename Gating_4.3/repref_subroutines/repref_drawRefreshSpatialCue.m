function repref_drawRefreshSpatialCue(window, cue, colors, imageLocs)
  % draw white circle centered on top or below center of screen
  
  assert(cue == 1 || cue ==2);
  switch cue
    case 1
      loc = imageLocs.top;
    case 2
      loc = imageLocs.bottom;
  end
  
  % draw circle
  h = loc(1) + (loc(3)-loc(1))/2;
  v = loc(2) + (loc(4)-loc(2))/2;
  size = 6;
  rect = [h-size v-size h+size v+size];
  Screen('FillOval', window, colors.white, rect);
  repref_drawFocusCharacter(window,'+',colors.white);
  
end
function repref_drawRefreshCue(window, cue, colors, imageLocs)
  % draw a colored square at the appropriate location
  
  assert(cue == 1 || cue ==2);
  switch cue
    case 1
      %       loc = imageLocs.cue_top;
      loc = imageLocs.top;
    case 2
      %       loc = imageLocs.cue_bottom;
      loc = imageLocs.bottom;
  end
  
  % dilate the rectangle so that we have a slightly bigger green one, with
  % a slightly smaller black one overlayed.
  big_square_loc = loc;
  small_square_loc = loc +  [10 10 -10 -10];
  
  Screen('FillRect', window, colors.green, big_square_loc);
  Screen('FillRect', window, colors.black, small_square_loc);  

end
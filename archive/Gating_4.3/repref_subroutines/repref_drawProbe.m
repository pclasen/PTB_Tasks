function repref_drawProbe(window, fileName, cue, imageLocs)
  % draw a single stimulus @ rect specified 
  
  imageData = imread(fileName);
  texture = Screen('MakeTexture', window, imageData);
  
  assert(cue == 1 || cue ==2);
  switch(cue)
    case 1
      loc = imageLocs.top;
    case 2
      loc = imageLocs.bottom;
  end
  
  Screen('DrawTexture', window, texture, [], loc, 0, 1);
end

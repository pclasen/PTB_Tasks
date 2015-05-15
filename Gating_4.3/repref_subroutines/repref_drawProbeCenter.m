function repref_drawProbeCenter(window, fileName, imageLocs)
  % draw a single stimulus @ screen center
  
  imageData = imread(fileName);
  texture = Screen('MakeTexture', window, imageData);
  
  loc = imageLocs.center;
  
  Screen('DrawTexture', window, texture, [], loc, 0, 1);
end

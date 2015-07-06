function repref_drawImage(window, fileName, imageLocs)
  % draw a single stimulus @ rect specified by 'imageLocs.center'
  imageData = imread(fileName);
  texture = Screen('MakeTexture', window, imageData);
  Screen('DrawTexture', window, texture, [], imageLocs.center, 0, 1);
end

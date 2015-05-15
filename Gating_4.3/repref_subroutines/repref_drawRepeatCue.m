function repref_drawRepeatCue(window, cue, targets, imageLocs)
  % draw 2 images, horizontally centered, 1 on top, 1 below, separated by
  % a small gap (see repref_setupExperiment.m)
  
  % currentImages is a cell array of strings representing image paths
  assert(cue == 1 || cue ==2);
  switch cue
    case 1
      loc = imageLocs.top;
    case 2
      loc = imageLocs.bottom;
  end
  
  drawImageInLocation(window, char(targets(cue)), loc);

end

%-------------------------------------------------------------------------%
function drawImageInLocation(window, fileName, location)
  imageData = imread(fileName);
  texture = Screen('MakeTexture', window, imageData);
  Screen('DrawTexture', window, texture, [], location);
end

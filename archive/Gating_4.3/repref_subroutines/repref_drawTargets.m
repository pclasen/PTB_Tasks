function repref_drawTargets(window, targets, imageLocs)
% draw 2 images, horizontally centered, 1 on top, 1 below, separated by
% a small gap (see repref_setupExperiment.m)
 
% currentImages is a cell array of strings representing image paths
drawImageInLocation(window, char(targets(1)), imageLocs.top);
drawImageInLocation(window, char(targets(2)), imageLocs.bottom);

end

%-------------------------------------------------------------------------%

function drawImageInLocation(window, fileName, location)
  imageData = imread(fileName);
  texture = Screen('MakeTexture', window, imageData);
  Screen('DrawTexture', window, texture, [], location);
end

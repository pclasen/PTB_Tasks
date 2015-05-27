function prae_drawTarget(window, target, imageLocs)
% draw image in center of screen
% (see prae_setupExperiment.m)
 
% currentImages is a cell array of strings representing image paths
drawImageInLocation(window, char(target), imageLocs.center);

end

%-------------------------------------------------------------------------%

function drawImageInLocation(window, fileName, location)
  imageData = imread(fileName);
  texture = Screen('MakeTexture', window, imageData);
  Screen('DrawTexture', window, texture, [], location);
end

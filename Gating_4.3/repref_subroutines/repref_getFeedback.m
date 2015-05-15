function [color] = repref_getFeedback(colors, correct)
  % return green color if correct, red if incorrect
  
  if correct
    color = colors.green;
  else
    color = colors.red;
  end
  
end

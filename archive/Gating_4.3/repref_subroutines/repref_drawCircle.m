function repref_drawCircle(window, color)
  dims = Screen('Rect',window);
  h = dims(3)/2;
  v = dims(4)/2;
  size = 6;
  rect = [h-size v-size h+size v+size];
  Screen('FillOval', window, color, rect);
end



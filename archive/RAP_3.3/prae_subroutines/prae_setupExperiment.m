function [window imageLocs colors] = prae_setupExperiment(debug,screen)
  % setup 'prae' experiment
  
  % Clear all variables.
  clc;
  
  % create the main window & calculate image locations
  % screen: main window=0, secondary=1
  % % Screen('Preference', 'SkipSyncTests', 1)
  window = Screen(screen, 'OpenWindow', BlackIndex(screen));
  
  % get colors
  
  colors.black = [0, 0, 0];
  colors.white = [255, 255, 255];
  colors.grey = [150 150 150];
  colors.red = [255, 0, 0];
  colors.green = [0, 255, 0];
  colors.blue = [0, 0, 255];
  colors.orange = [255 127 0];
  
  % get dimensions of screen
  rect = Screen('Rect', window);
  screenCenterX = (rect(3)-rect(1))/2;
  screenCenterY = (rect(4)-rect(2))/2;
  height = screenCenterY * 2;
  dx = 0.3*height;
  dy = dx;
  buffer = 0.2*dx;
  
  % set locations for images
  %
  % rect: origin @ upper-left of screen
  % [left top right bottom]
  %
  screen_center = [screenCenterX screenCenterY screenCenterX screenCenterY];
  center_it = [-dx -dy dx dy]; 
  imageLocs.center = screen_center + center_it;
  
  % setup dimensions of rating circles
  size = 6;
  rect = screen_center + [-size -size size size];
  
  h_shift = screenCenterX/8;
  shift_left = [-h_shift 0 -h_shift 0];
  shift_right = [h_shift 0 h_shift 0];
  
  v_shift = screenCenterY/4;
  shift_up = [0 -v_shift 0 -v_shift];
  shift_down = [0 +v_shift 0 +v_shift];
  
  imageLocs.circle_middle = rect;
  imageLocs.circle_left = rect + shift_left;
  imageLocs.circle_right = rect + shift_right;
  
  imageLocs.circle_farleft = rect + 3*shift_left;
  imageLocs.circle_midleft = rect + shift_left + shift_up;
  imageLocs.circle_midright = rect + shift_right + shift_up;
  imageLocs.circle_farright = rect + 3*shift_right;
  
  imageLocs.circle_dfarleft = rect + 3*shift_left + shift_down;
  imageLocs.circle_dmidleft = rect + shift_left + shift_down;
  imageLocs.circle_dmidright = rect + shift_right + shift_down;
  imageLocs.circle_dfarright = rect + 3*shift_right + shift_down;
  
  imageLocs.header = rect;
  
  % Reseed the random-number generator for each expt.
  rand('state', sum(100*clock));
  
  % Make sure keyboard mapping is the same on all supported operating
  % systems (Apple Mac OS X, MS Windows and GNU/Linux)
  KbName('UnifyKeyNames');
  
  if ~debug
    % Hide the mouse cursor:
    HideCursor();
    
    % Ignore keyboard input while running experiment.
    ListenChar(2);
  end
  
  % Set priority for script execution to realtime priority:
  priorityLevel = MaxPriority(window);
  Priority(priorityLevel);
end

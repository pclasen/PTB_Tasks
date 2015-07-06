function [window imageLocs colors] = repref_setupExperiment(debug,screen)
  % setup 'repref' experiment
  
  % Clear all variables.
  clc;
  
  % create the main window & calculate image locations
  % screen: main window=0, secondary=1
  % Screen('Preference', 'SkipSyncTests', 1)
  window = Screen(screen, 'OpenWindow', BlackIndex(screen));
  
  % get colors
  
  colors.black = [0, 0, 0];
  colors.white = [255, 255, 255];
  colors.red = [255, 0, 0];
  colors.green = [0, 255, 0];
  colors.blue = [0, 0, 255];
  colors.orange = [255 127 0];
  
  % get dimensions of screen
  rect = Screen('Rect', window);
  screenCenterX = (rect(3)-rect(1))/2;
  screenCenterY = (rect(4)-rect(2))/2;
  height = screenCenterY * 2;
  dx = 0.10*height;
  dy = dx;
  buffer = 0.2*dx;
  
  % set locations for images
  %
  % rect: origin @ upper-left of screen
  % [left top right bottom]
  %
  screen_center = [screenCenterX screenCenterY screenCenterX screenCenterY];
  
  center_it = [-dx -dy dx dy];
  shift_up = [-dx -2*dy-buffer dx -buffer];
  shift_down = [-dx buffer dx 2*dy+buffer];
  
  imageLocs.center = screen_center + center_it;
  imageLocs.top = screen_center + shift_up;
  imageLocs.bottom = screen_center + shift_down;
  
  shift_cue = [dx/2 dy/2 -dx/2 -dy/2];
  
  imageLocs.cue_top = imageLocs.top + shift_cue;
  imageLocs.cue_bottom = imageLocs.bottom + shift_cue;
  
  % setup dimensions of circle
  size = 6;
  rect = screen_center + [-size -size size size];
  
  h_shift = screenCenterX/8;
  shift_left = [-h_shift 0 -h_shift 0];
  shift_right = [h_shift 0 h_shift 0];
  
  v_shift = screenCenterY/3;
  shift_up = [0 -v_shift 0 -v_shift];
  shift_down = [0 +v_shift 0 +v_shift];
  
  imageLocs.circle_left = rect + shift_left;
  imageLocs.circle_right = rect + shift_right;
  imageLocs.circle_up = rect + shift_up;
  imageLocs.circle_down = rect + shift_down;
  
  imageLocs.circle_farleft = rect + 3*shift_left + shift_up;
  imageLocs.circle_midleft = rect + shift_left + shift_up;
  imageLocs.circle_midright = rect + shift_right + shift_up;
  imageLocs.circle_farright = rect + 3*shift_right + shift_up;
  
  imageLocs.circle_dfarleft = rect + 3*shift_left + shift_down;
  imageLocs.circle_dmidleft = rect + shift_left + shift_down;
  imageLocs.circle_dmidright = rect + shift_right + shift_down;
  imageLocs.circle_dfarright = rect + 3*shift_right + shift_down;
  
  imageLocs.header = rect + shift_up;
  
  
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

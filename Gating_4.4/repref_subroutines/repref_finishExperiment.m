function repref_finishExperiment()
  % Cloase all screen objects
  sca
  
  % Restore normal priority.
  Priority(0);
  
  % Resume receiving keyboard input.
  ListenChar(0);
  
  % Show mouse cursor.
  ShowCursor();
  
  % Close all open files.
  fclose('all');

end

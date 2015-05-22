function prae_waitTTL(fMRI, startTime)
  % if in fMRI mode, wait for TTL pulse from scanner
  if ~fMRI
    while 1
      % wait for start of next 2s interval since 'startTime'
      if (mod(GetSecs-startTime,2) < 0.001)
        %         fprintf('  [fake TTL: %.3f]\n',GetSecs-startTime);
        return;
      end
    end
  else
    % wait for TTL pulse from scanner
    TTLpulse = 'LeftShift';
    while 1
      [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
      keyName = KbName(keyCode);
      
      if keyIsDown && ~isempty(strmatch(TTLpulse,keyName))
        % TTL pulse received!
        return;
      end % keyIsDown
    end % while waiting for response
  end % fmri
  
end
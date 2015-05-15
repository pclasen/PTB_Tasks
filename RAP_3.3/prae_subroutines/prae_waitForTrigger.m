function [waitSecs] = prae_waitForTrigger(keys,fMRI,startTime)
  
  beginWaiting=GetSecs;
  
  if ~fMRI
    
    while 1
      % wait for start of next 2s interval since 'startTime'
      if (mod(GetSecs-startTime,2) < 0.001)
        waitSecs = GetSecs - beginWaiting;
        return;
      end
    end
    
  else
    % wait for trigger from scanner
    
    while 1
               
        [pressed,pressTime,keyCodes,deltaSecs] = KbCheck(keys.triggerDeviceNumber);

        if pressed
            
            keyName = KbName(keyCodes);
            
            %         if multiple keys were pressed simultaneously, grab only 1
            %         if (iscellstr(keyName)); keyName = keyName{1}; end
            
            %         if pressed && ~isempty(strmatch(keys.trigger,keyName))
            
            if strcmp(keyName,keys.trigger)
                %             if keyCodes(34)
                
                % trigger received!
                %                 fprintf('Button pressed!: time=%0.2f, key=%s, deltasecs=%0.4f\n',...
                %                     pressTime-beginWaiting,keyName,deltaSecs);
                
                waitSecs = pressTime - beginWaiting;
                return;
            end
            
        end
        
        WaitSecs(0.0005); % relax for 0.5 ms
        
    end % waiting for trigger
    
  end % if fMRI
  
end
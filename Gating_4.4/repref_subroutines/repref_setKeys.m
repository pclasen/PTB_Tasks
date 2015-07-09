function [keys] = repref_setKeys(scannerID,phase,cbhand,startBlock)
% Map keyboards to responses

% scannerID  0|1     : behavioral or CNI scanner button box
% phase      1|2|3   : phase of experiment
% startBlcok 1|2...8 : block 
  
  switch scannerID
    
    case 0 % none
      keys.scanner = 'None';
      keys.triggerTech = 'None';
      keys.first = '6^';
      keys.second = '7&';
      keys.third = '8*';
      keys.fourth = '9(';
      keys.trigger = '=+';
      keys.triggerDevice = 'Apple Keyboard';
      keys.hand = 'Right';
      
    case 1 % Stanford CNI
      keyBoardID = repref_getKeyboardNumber();
      switch phase
        case 1 % phase 1
            switch cbhand
                case 1 % right hand start
                    switch startBlock
                        case 1 % first run
                            keys.scanner = 'CNI';
                            keys.hand = 'Right';
                            keys.first = '9(';
                            keys.second = '8*';
                            keys.third = '7&';
                            keys.fourth = '6^';
                            keys.advance = 'a';
                            keys.trigger = '=+';
                            keys.triggerDevice = keyBoardID;
                        case 2 % second run 
                            keys.scanner = 'CNI';
                            keys.hand = 'Left';
                            keys.first = '4$';
                            keys.second = '3#';
                            keys.third = '2@';
                            keys.fourth = '1!';
                            keys.advance = 'a';
                            keys.trigger = '=+';
                            keys.triggerDevice = keyBoardID;
                    end % startBlock
                case 2 % left hand start
                    switch startBlock
                        case 1 % first run
                            keys.scanner = 'CNI';
                            keys.hand = 'Left';
                            keys.first = '4$';
                            keys.second = '3#';
                            keys.third = '2@';
                            keys.fourth = '1!';
                            keys.advance = 'a';
                            keys.trigger = '=+';
                            keys.triggerDevice = keyBoardID;
                        case 2 % second run 
                            keys.scanner = 'CNI';
                            keys.hand = 'Right';
                            keys.first = '9(';
                            keys.second = '8*';
                            keys.third = '7&';
                            keys.fourth = '6^';
                            keys.advance = 'a';
                            keys.trigger = '=+';
                            keys.triggerDevice = keyBoardID;
                    end % startBlock
            end % cbhand
                    
        case 2 % phase 2
            switch cbhand
                case 1 % right hand start
                    if startBlock <= 4
                        keys.scanner = 'CNI';
                        keys.hand = 'Right';
                        keys.first = '9(';
                        keys.second = '8*';
                        keys.third = '7&';
                        keys.fourth = '6^';
                        keys.advance = 'a';
                        keys.trigger = '=+';
                        keys.triggerDevice = keyBoardID;
                    elseif startBlock > 4
                        keys.scanner = 'CNI';
                        keys.hand = 'Left';
                        keys.first = '4$';
                        keys.second = '3#';
                        keys.third = '2@';
                        keys.fourth = '1!';
                        keys.advance = 'a';
                        keys.trigger = '=+';
                        keys.triggerDevice = keyBoardID;
                    end
                case 2 % left hand start
                    if startBlock <= 4
                        keys.scanner = 'CNI';
                        keys.hand = 'Left';
                        keys.first = '4$';
                        keys.second = '3#';
                        keys.third = '2@';
                        keys.fourth = '1!';
                        keys.advance = 'a';
                        keys.trigger = '=+';
                        keys.triggerDevice = keyBoardID;
                    elseif startBlock > 4
                        keys.scanner = 'CNI';
                        keys.hand = 'Right';
                        keys.first = '9(';
                        keys.second = '8*';
                        keys.third = '7&';
                        keys.fourth = '6^';
                        keys.advance = 'a';
                        keys.trigger = '=+';
                        keys.triggerDevice = keyBoardID;
                    end
            end % cbhand
          
        case 3 % phase 3
            keys.scanner = 'CNI';
            keys.hand = 'Right';
            keys.first = '9(';
            keys.second = '8*';
            keys.third = '7&';
            keys.fourth = '6^';
            keys.advance = 'a';
            keys.trigger = '=+';
            keys.triggerDevice = keyBoardID;
      end % phase
              
    otherwise
      error('Unrecognized scanner!');
  end % scannerID
  
  keys.triggerDeviceNumber = GetKeyboardIndices(keys.triggerDevice);

end % function


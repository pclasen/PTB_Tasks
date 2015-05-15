function [keys] = prae_setKeys(scannerID)
% Map keyboards to responses

% scannerID  0|1 : behavioral or CNI scanner button box
  
  switch scannerID
    
    case 0 % none
      keys.scanner = 'None';
      keys.triggerTech = 'None';
      keys.first = '6^';
      keys.second = '7&';
      keys.third = '8*';
      keys.fourth = '9(';
      keys.advance = 'a';
      keys.trigger = '=+';
      keys.triggerDevice = 'Apple Keyboard';
      keys.hand = 'Right';
      
    case 1 % Stanford CNI
      keyBoardID = repref_getKeyboardNumber();
      
      keys.scanner = 'CNI';
      keys.hand = 'Right';
      keys.first = '9(';
      keys.second = '8*';
      keys.third = '7&';
      keys.fourth = '6^';
      keys.advance = 'a';
      keys.trigger = '=+';
      keys.triggerDevice = keyBoardID;
              
    otherwise
      error('Unrecognized scanner!');
  end % scannerID
  
  keys.triggerDeviceNumber = GetKeyboardIndices(keys.triggerDevice);

end % function


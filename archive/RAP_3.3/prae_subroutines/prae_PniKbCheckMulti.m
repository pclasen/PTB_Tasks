function [keyIsDown,secs,keyCodes,deltaSecs,devName] = prae_PniKbCheckMulti(keys)
%[keyIsDown,secs,keyCodes,deltaSecs,devName] = PniKbCheckMulti
%
% Meant to replace KbCheck(-1) in environments where a device needs to
% be excluded from the list of devices lest triggers/buttons/keys are
% missed. Add any problematic device names (as revealed by 
% GetKeyboardIndices) to the 'badDevices' list, below, and they will
% be skipped.
%
% The IOGear switch can be bypassed physically or in software; here is
% the software solution.
%
% The 'devName' output, which the regular KbCheck does not return,
% is the name of the device which produced the keypress, if any.
% (be careful that the skyra trigger, or the '5%' key, was not
%  produced accidentally by the experimenter typing 5 on the keyboard!
%  You can avoid this by checking the the devName, and comparing
%  it to the skyra trigger box name, '932')
%
% Note that the first time this is run there is overhead time for
% initialization, which could miss an event-- run for the first time
% early on in your stimulus script, before you need it for real)
%
% History
%
% 2011.Mar.30    bdsinger    
% 2011.Apr.12       "        Wrote it based on KbQueueCheck, but it failed
% 2011.Apr.13       "        Simplified and based on KbCheck
% 2011.Apr.14       "        Updated the help text above

persistent deviceNums deviceNames numDevices

if isempty(deviceNums)
    %% Add any badDevices here %%%%%%%%%%%
    badDevices = {};
    
    switch keys.triggerTech
      case 'CurrentDesign'
        badDevices={'Xkeys'};
      case 'PST'
        badDevices={'932'};
    end
    
    [deviceNums,deviceNames] = GetKeyboardIndices;
    [~,badIndices,~]=intersect(deviceNames,badDevices);
    deviceNums(badIndices)=[];
    deviceNames(badIndices)=[];
    numDevices = length(deviceNums);

    eval('deviceNames');
end


devName='none';
for device=1:numDevices
    [keyIsDown,secs,keyCodes,deltaSecs]=KbCheck(deviceNums(device));
    if keyIsDown
        devName=deviceNames{device};
        return
    end
end

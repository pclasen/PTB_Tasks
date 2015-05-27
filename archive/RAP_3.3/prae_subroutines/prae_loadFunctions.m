function prae_loadFunctions()
% Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure
% they are loaded and ready when we need them - without delays
% in the wrong moment:
  KbCheck;
  WaitSecs(0.1);
  GetSecs;
end

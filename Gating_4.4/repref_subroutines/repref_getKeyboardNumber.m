function [kb] = repref_getKeyboardNumber()
% Determine USB device number of the keyboard

d = PsychHID('Devices');
kb = 0;

for n = 1:length(d)
    if strcmp(d(n).usageName,'Keyboard') % % &&(d(n).productID == 566) % add specific product id
        k = n;
        break
    end
end
if kb == 0
    fprintf(['Button box NOT FOUND.\n']);
end

end


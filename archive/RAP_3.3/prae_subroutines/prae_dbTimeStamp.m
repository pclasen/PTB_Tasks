function prae_dbTimeStamp(label, time)
% print out simple timestamp for debugging experiment timing
fprintf('**** %s: %.1f\n', label, 1000*(GetSecs - time));
end

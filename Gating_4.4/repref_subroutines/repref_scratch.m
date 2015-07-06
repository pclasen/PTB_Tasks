p2 = stimuli.phase2;

for i = 1:size(stims_uncued_p2,1)
  stim = char(stims_uncued_p2(i));
  
  member = find(ismember(p2_stimuli,stim));
  [block trial slot] = ind2sub(size(p2_stimuli),member);
  
  cued_stim = char(p2.cuestims(block,trial));
  both = p2_stimuli(block,trial,:);
  uncued_stim = char(stims_uncued_p2(i));
  
  fprintf('i = %d\n',i);
  fprintf('both: %s\t%s\n',char(both(1)),char(both(2)));
  fprintf('cued: %s\n',cued_stim);
  fprintf('uncued: %s\n\n',uncued_stim);
  
end
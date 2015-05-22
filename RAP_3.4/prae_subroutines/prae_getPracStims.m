function [stimuli] = prae_getPracStims(images,P_stimuli,P_valence)
  
  %% conditioning stimuli
  % these are 12 stimlui for cue conditioning
  stimuli.cueCond.stimuli = P_stimuli;
  stimuli.cueCond.valence = P_valence;


  %% practice trials stimuli

  % Define 
  N_CATS = 3;
  N_TRIALS_cat_block = 4;
  
  % ITI
  T_ITI = [4 6];
  N_ITI = [4 8];
  
  % create stim, valence, condition lists
  % set up B_stims & B_val
  B_stims = [];
  B_val = [];
  
  % populate with stimuli and valence per block
  for k = 1:N_CATS
      % stimuli
      stim_set = images(1:N_TRIALS_cat_block,k);
      B_stims = [B_stims;stim_set];
      
      % valence (1 = neut; 2 = neg; 3 = pos)
      B_val = [B_val;repmat(k,N_TRIALS_cat_block,1)];
  end
  
  % condition (ant = 1; retro = 2; full = 3; full+rate = 4)
  B_cond = repmat([3,4,1,2]',3,1);
  
  % variable iti
  t_iti = [repmat(T_ITI(1),N_ITI(1),1);repmat(T_ITI(2),N_ITI(2),1)];
  t_iti = randsample(t_iti,length(t_iti));
  B_iti = t_iti;
  
  % pseudo-randomize (no more than 3 of the same valence, condition in a row and no more that 1 catch trial in a row)
  order = randperm(size(B_stims,1));
  
  % sequence checker (evaluate & update order to ensure constraints)
  seq_check = false;
  valCheck = B_val(order)';
  condCheck = B_cond(order)';
  % % itiCheck = B_iti(order)';
  while seq_check == false
      if sum(strfind(valCheck, [1 1 1])) > 0 | sum(strfind(valCheck, [2 2 2])) > 0 | sum(strfind(valCheck, [3 3 3])) > 0 | ...
              sum(strfind(condCheck, [1 1])) > 0 | sum(strfind(condCheck, [2 2])) > 0 | sum(strfind(condCheck, [3 3])) > 0 | sum(strfind(condCheck, [4 4])) > 0
          
          seq_check = false;
          order = randperm(size(B_stims,1));
          valCheck = B_val(order)';
          condCheck = B_cond(order)';
      else
          seq_check = true;
      end
  end
  
  T_stimuli = B_stims(order);
  T_valence = B_val(order);
  T_condition = B_cond(order);
  T_iti = B_iti(order);
  
  % stimuli to object
  stimuli.pracTrials.stimuli = T_stimuli;
  stimuli.pracTrials.valence = T_valence;
  stimuli.pracTrials.condition = T_condition;
  stimuli.pracTrials.iti = T_iti;


end % main function


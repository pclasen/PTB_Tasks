function [practice] = repref_getstimuliPhase2Practice(stims,n_blocks,n_trials)
  
  %-------------------------------------------------------------------------%
  % [practice] = repref_getstimuliPhase2Practice(...)
  %
  % * all arguments must be specificed in repref_getstimuli
  %
  %------------------------------------------------------------------------%
  
  %% create answers, switches, slots, and stims 
  
  T_switches = [];
  T_answers = [];
  T_slots = [];
  T_targets = [];
  T_condition = [];
  
  id_sad_start = 1;
  id_sad_end = (n_trials/2);
  id_neut_start = 1;
  id_neut_end = (n_trials/2);
  id_scenes_start = 1;
  id_scenes_end = n_trials;
  
  for i = 1:n_blocks
      
    % answers (half valid, half invalid) 
    answers = ones(n_trials,1);
    answers(2:2:end) = -1;
    
    % switches (one third of trials are switch trials) 
    switches = zeros(n_trials,1);
    switches(3:3:end) = 1;
    
    % slots 
    trial_div = n_trials/3; 
    slots = repmat([1;2],n_trials/trial_div,1);
    % Balance cue top/bottom across blocks            
    if mod(i,2) == 0
        slots = (3 - slots);
    end
     
    % stimuli
    sad_targets = stims.targets.sad(id_sad_start:id_sad_end);
    neut_targets = stims.targets.neut(id_neut_start:id_neut_end);
    face_targets = [sad_targets;neut_targets];
    scene_targets = stims.targets.scenes(id_scenes_start:id_scenes_end);
    targets = [face_targets scene_targets];
    target_id = [repmat([1],length(sad_targets),1); repmat([2],length(neut_targets),1)]; %PC - % sad == 1, neutral == 2
  
    % randomize
    order = randperm(size(answers,1));
    T_switches = [T_switches; switches(order)];
    T_answers = [T_answers; answers(order)];
    T_slots = [T_slots; slots(order)];
    T_targets = [T_targets; targets(order,[1 2])];
    T_condition = [T_condition; target_id(order)];
       
    id_sad_start = id_sad_end + 1;
    id_sad_end = id_sad_end + (n_trials/2);
    id_neut_start = id_neut_end + 1;
    id_neut_end = id_neut_end + (n_trials/2);
    id_scenes_start = id_scenes_end + 1;
    id_scenes_end = id_scenes_end + n_trials;
    
  end

  % provide slot index for second column
  T_slots = [T_slots (3-T_slots)];
  
  % map the stimuli to the slots_p2 matrix
  %     For Scenes: (slot(i) = 2) is always 'cued' for first delay period
  %     For Faces: (slot(i) = 1) is always 'cued' for first dalay period
  % for each row, rearrange the column in which the categories appear
  for i=1:size(T_targets,1)
    col_order = T_slots(i,:);
    T_targets(i,:) = T_targets(i,col_order);
  end

  
  %% setup probe stimuli
  probes1 = repmat({'-'},(n_trials*n_blocks),1);
  probes2 = repmat({'-'},(n_trials*n_blocks),1);
  rsvp_target_pos = 0*answers;
  
  % setup probe list indices
  id_sad = [1;2];
  id_neut = [1;2];
  
  % prac foils
  prac_foils = stims.foils;
  
  for i = 1:(n_blocks*n_trials)
    
    this.cue = find(T_slots(i,:)==1); %1 for face, 2 for scene
    this.switch = T_switches(i);
    this.answer = T_answers(i);
    this.firstcuecond = T_condition(i);
    this.firstcuedstim = T_targets(i,this.cue);
    this.firstuncuedstim = T_targets(i,3-this.cue);
    
    if this.switch == 0
      % 'stay' trial
      this.secondcuedstim = '-';
      this.seconduncuedstim = '-';    
    else
      % 'switch' trial
      this.secondcuedstim = this.firstuncuedstim;
      this.seconduncuedstim = this.firstcuedstim;
    end
    
    % get probes
    rsvp_foils = [];
    if this.firstcuecond == 1
      for k = [this.firstcuecond this.firstcuecond+2] %face probes valence match cue valence, accomodate 2 scene columns
        foils = prac_foils(:,k);
        id_rsvp_start = id_sad(1);
        id_rsvp_end = id_sad(2);
        rsvp_foils = [rsvp_foils; foils(id_rsvp_start:id_rsvp_end)];
      end
      id_sad = id_sad + 2;
    elseif this.firstcuecond == 2
      for k = [this.firstcuecond this.firstcuecond+2] %face probes valence match cue valence, accomodate 2 scene columns
        foils = prac_foils(:,k);
        id_rsvp_start = id_neut(1);
        id_rsvp_end = id_neut(2);
        rsvp_foils = [rsvp_foils; foils(id_rsvp_start:id_rsvp_end)];
      end
      id_neut = id_neut + 2;
    end

    % segment probes
    foils_end = rsvp_foils(2:4);
    foils_firstposition = rsvp_foils(1);      

    if this.answer == -1
      % invalid probe (all probe stims are foils)
      rsvp_target_pos(i) = -1;
      
    else
      % 1 valid probe, N-1 foils
      
      % if this trial has a valid probe, need to replace one of the
      % foils in position 2,3,4 with the target stimulus
            
      if this.switch == 0
        % 'stay' trial
        
        valid_target = this.firstcuedstim;
        foils_end(1) = valid_target;
                
      else
        % 'switch' trial
        
        valid_target = this.secondcuedstim;
        foils_end(end) = valid_target;
        
      end   
    end
    
    % bring together, randomize positions (with constraint for valid
    % trials), and create target position idicator
    foils_rsvp = [foils_firstposition; foils_end];
    foils_rsvp = randsample(foils_rsvp,4);
    if this.answer == 1
      foil_idx = find(ismember(foils_rsvp,valid_target));
      while foil_idx == 1
        foils_rsvp = randsample(foils_rsvp,4);
        foil_idx = find(ismember(foils_rsvp,valid_target));
      end
      rsvp_target_pos(i) = foil_idx;
    else
      rsvp_target_pos(i) = -1;
    end
    
    % assign to structure cell
    if this.switch == 0
      % 'stay' trial
      probes1(i) = {foils_rsvp};
    else
      % 'switch' trial
      probes2(i) = {foils_rsvp};
    end
    
  end

  % separate the stim list into a separate list for each block
  B_targets = {};
  B_probes1 = {};
  B_probes2 = {};
  B_answers = [];
  B_slots = [];
  B_switches = [];
  B_rsvptarget = [];
  B_cuecond = [];
  
  for i = 1:n_blocks
    id_start = 1 + (i-1)*n_trials;
    id_end = id_start + n_trials - 1;
    id_range = id_start:id_end;
    
    B_targets(i,:,:) = T_targets(id_range,:);
    B_probes1(i,:) = probes1(id_range);
    B_probes2(i,:) = probes2(id_range);
    B_answers(i,:) = T_answers(id_range);
    B_slots(i,:,:) = T_slots(id_range,:);
    B_switches(i,:) = T_switches(id_range);
    B_rsvptarget(i,:) = rsvp_target_pos(id_range);
    B_cuecond(i,:) = T_condition(id_range);
  end
  
  % cue & cuecats
  cues = B_slots(:,:,2); %PC - this references cue location (1 = face bottom; 2 = face top; flips for scenes)
  cuedcats = 1 + 0*cues; %PC -  1 = face, 2 = scene (i.e., 1 + ; 2 +)
  
  %% save results
  practice.blocks = n_blocks;
  practice.trials = n_trials;
  practice.stay_trials = 4;
  practice.switch_trials = 2;
  practice.targets = B_targets;
  practice.slots = B_slots;
  practice.cues = cues;
  practice.cuedcats = cuedcats;
  practice.cuecond = B_cuecond; %PC - notation for type of face (1 = sad, 2 = neut)
  practice.probes1 = B_probes1;
  practice.probes2 = B_probes2;
  practice.answers = B_answers;
  practice.rsvptarget = B_rsvptarget;
  practice.switches = B_switches;
  practice.switches_name.stay = 0;
  practice.switches_name.switch = 1;
  
end


function [stimuli] = repref_getstimuli(subjectNumber, subjectName, cbfaces, cbscenes)
  
  %-------------------------------------------------------------------------%
  % [stimuli] = repref_getstimuli(...)
  %
  % * all arguments are strings
  %
  % SUBJNUM  : unique # based on date string (e.g., '101220')
  % SUBJNAME : unique subject name (e.g., 'jlp')
  % cbfaces  : unique counterbalance order (1-6) (e.g., 1)
  % cbscenes : unique counterbalance order (1-5) (e.g., 1)
  %
  % e.g.,
  % >> repref_getstimuli('101110','jlp',1,1)
  %------------------------------------------------------------------------%
  
 %% script version

 version = '2015Jan13'; 
 
 if ~nargin
   jalewpea_script_backup(mfilename,'./',version);
   stimuli = sprintf('script version: %s\n',version);
   return;
 end
  
  %% EXPERIMENTAL PARAMETERS
  
  DEBUG_ME = false;
  
  % Resource paths
  S_SAD_FACE_DIR = './stimuli_bw/sad_faces';
  S_NEUT_FACE_DIR = './stimuli_bw/neut_faces';
  S_SCENE_DIR = './stimuli_bw/scenes';
  S_P1_PRAC_DIR = './stimuli_bw/phase1_practice';
  S_P3_PRAC_DIR = './stimuli_bw/phase3_practice';
  
  % Resource lists
  S_P1_PRAC_LIST = './stimuli_bw/practice_lists/p1_prac_list.txt';
  S_P1_SAD_LIST = './stimuli_bw/phase1_lists/p1_sad.txt';
  S_P1_NEUT_LIST = './stimuli_bw/phase1_lists/p1_neut.txt';
  S_P1_SCENE_LIST = './stimuli_bw/phase1_lists/p1_scenes.txt';
  
  S_P23_SAD_LIST = ['./stimuli_bw/phase2_lists/p2_sad_' num2str(cbfaces) '.txt'];
  S_P23_NEUT_LIST = ['./stimuli_bw/phase2_lists/p2_neut_' num2str(cbfaces) '.txt'];
  S_P23_SCENE_LIST = ['./stimuli_bw/phase2_lists/p2_scene_' num2str(cbscenes) '.txt'];
  
  S_P3_PRAC_LIST = './stimuli_bw/practice_lists/p3_prac_list.txt'; % (face;scene;face;face;face;face;face)
  
  % Stimulus categories
  N_CATS = 3; 
  CAT_NAMES = {'sad' 'neutral' 'scene'}; 
  
  % RSVP probes
  N_RSVP_FOILS_total = 192; % 48 per face category, 96 scenes 
  N_RSVP_FOILS_total_cat = N_RSVP_FOILS_total/(N_CATS+1); % adujust for two columns of scenes
  N_RSVP_FOILS_probe = 4; 
  N_RSVP_FOILS_probe_cat = N_RSVP_FOILS_probe/(N_CATS-1); % adjust for odd number of categories
  
  % Phase 1 blocks & trials (1-back MVPA Localizer)
  N_BLOCKS_p1 = 15;
  N_TRIALS_block_p1 = 5;
  
  % Phase 1 practice
  n_prac_trials_p1 = 10; % must be divisible by N_TRIALS_block_p1
  
  % Phase 2 blocks & trials (Stay-Switch Task)
  N_BLOCKS_p2 = 8; 
  N_STAY_block_p2 = 12; 
  N_SWITCH_block_p2 = 6; 
  N_TRIALS_block_p2 = N_STAY_block_p2 + N_SWITCH_block_p2;
  
  % Phase 2 practice stims
  n_prac_blocks_p2 = 3;
  n_prac_trials_p2 = 6;
  n_prac_trials_block_p2 = n_prac_blocks_p2*n_prac_trials_p2;
  n_prac_targets_p2 = 2*n_prac_trials_p2;
  
  % Phase 3 blocks & trials
  N_BLOCKS_p3 = 1; 
  N_STIMS_from_p2 = 2*N_SWITCH_block_p2*N_BLOCKS_p2;
  N_TRIALS_block_p3 = (1.5)*N_STIMS_from_p2; %PC - 2:1, old:new
  
  
  %-------------------------------------------------------------------------%
  %-------------------------------------------------------------------------%
  
  %------------------------------%
  %% santity checks
  assert(logical(exist('./stimuli_bw/','dir')),...
    sprintf('(*) "stimuli_bw" directory does not exisit in: %s',pwd));
  
  % sanity checks
  assert(ischar(subjectNumber),'(*) subjectNumber must be a ''string''');
  assert(ischar(subjectName),'(*) subjectName must be a ''string''');
  
  stim_filename = ['./stimuli_bw/subject_sets/repref_stimuli_' ...
    subjectNumber '_' subjectName '.mat'];
  
  if exist(stim_filename,'file') == 2
    % If stimulus set already exists for this subect, read it in.
    disp(['stim file: ' stim_filename ' exists! reading it in ...']);
    load(stim_filename); % 'stimuli' variable
    return;
  end
  
  % ---------------------------------------------------------- %
  %% Read in and organize stimuli for all phases of experiment
  
  % save ID info
  stimuli.filename = stim_filename;
  stimuli.created = datestr(now,0);
  stimuli.categories = CAT_NAMES;
  
  % Open lists of image stimuli (faces, scenes and objects).
  % phase 1 practice
  fileID = fopen(S_P1_PRAC_LIST);
  list = textscan(fileID, '%s');
  p1_prac_list = strcat(S_P1_PRAC_DIR,'/',list{1});
  fclose(fileID);
  % phase 1 sad faces
  fileID = fopen(S_P1_SAD_LIST); 
  list = textscan(fileID, '%s');
  p1_sad_list = strcat(S_SAD_FACE_DIR,'/',list{1});
  fclose(fileID);
  % phase 1 neutral faces
  fileID = fopen(S_P1_NEUT_LIST); 
  list = textscan(fileID, '%s');
  p1_neut_list = strcat(S_NEUT_FACE_DIR,'/',list{1}); 
  fclose(fileID);
  % phase 1 scenes
  fileID = fopen(S_P1_SCENE_LIST);
  list = textscan(fileID, '%s');
  p1_scenes_list = strcat(S_SCENE_DIR,'/',list{1});
  fclose(fileID);

  % phase 2 & 3 sad faces
  fileID = fopen(S_P23_SAD_LIST); 
  list = textscan(fileID, '%s');
  p23_sad_list = strcat(S_SAD_FACE_DIR,'/',list{1});
  fclose(fileID);
  % phase 2 & 3 neutral faces
  fileID = fopen(S_P23_NEUT_LIST); 
  list = textscan(fileID, '%s');
  p23_neut_list = strcat(S_NEUT_FACE_DIR,'/',list{1}); 
  fclose(fileID);
  % phase 2 & 3 scenes
  fileID = fopen(S_P23_SCENE_LIST);
  list = textscan(fileID, '%s');
  p23_scenes_list = strcat(S_SCENE_DIR,'/',list{1});
  fclose(fileID);
  %phase 3 practice
  fileID = fopen(S_P3_PRAC_LIST);
  list = textscan(fileID, '%s');
  p3_prac_list = strcat(S_P3_PRAC_DIR,'/',list{1});
  fclose(fileID);
  
  
  %-------------------------------------------------------------------------%
  %% How many total stimuli do we need for all 3 phases?
  % (assertions confirm that stimuli per category are whole integers)
  
  % Phase 1 - 1 target per trial
  n_stims_p1 = N_BLOCKS_p1 * N_TRIALS_block_p1; %PC - 5*15 = 75 (25 per condition)
  n_stims_cat_p1 = n_stims_p1 / N_CATS;
  assert(~mod(n_stims_cat_p1,1));
  
  % Phase 2 - 2 targets per trial + RSVP foils
  n_targets_p2 = 2*(N_BLOCKS_p2 * N_TRIALS_block_p2); %PC - 2*(8*18) = 288 (144 scenes, 72 sad, 72 neutral)
    % % n_stims_p2 = N_RSVP_FOILS_total + n_targets_p2; %PC - 126 (42 per condition) + 288 = 468
  n_targets_sad_p2 = (n_targets_p2 / (N_CATS + 1));
  n_targets_neut_p2 = (n_targets_p2 / (N_CATS + 1));
  n_targets_scenes_p2 = (n_targets_p2 / (N_CATS - 1));
  n_stims_sad_p2 =  n_targets_sad_p2 + (N_RSVP_FOILS_total / (N_CATS+1)); 
  n_stims_neut_p2 = n_targets_neut_p2 + (N_RSVP_FOILS_total / (N_CATS+1));
  n_stims_scenes_p2 = n_targets_scenes_p2 + (N_RSVP_FOILS_total / (N_CATS-1));
  assert(~mod(n_stims_sad_p2,1));
  assert(~mod(n_stims_neut_p2,1));
  assert(~mod(n_stims_scenes_p2,1));
  
  % Phase 3 - 1/2 of stimuli come directly from phase 2 (1 from each
  % trial); other 1/2 are new, so we need 'N' new stimuli for phase 3
  n_stims_p3 = (.5)*N_STIMS_from_p2; %PC - 48 new, 2:1 (old, new)
  n_stims_sad_p3 = n_stims_p3 / (N_CATS - 1); %PC - 24 sad
  n_stims_neut_p3 = n_stims_p3 / (N_CATS - 1); %PC - 24 neut
  assert(~mod(n_stims_sad_p3,1));
  assert(~mod(n_stims_neut_p3,1));

  
  %-------------------------------------------------------------------------%
  %% Grab stimuli
  
  % PHASE 1
  % practice defined as: p1_prac_stim 
  stims_p1 = [randsample(p1_sad_list,n_stims_cat_p1) randsample(p1_neut_list,n_stims_cat_p1) randsample(p1_scenes_list,n_stims_cat_p1)];
  
  % PHASES 2 & 3
  % number of stims per subcategory across phases 2 and 3
  s_p2_sad = 1:n_stims_sad_p2;
  s_p2_neut = 1:n_stims_neut_p2;
  s_p2_scenes = 1:n_stims_scenes_p2;
  s_p3_sad = (n_stims_sad_p2+1):(n_stims_sad_p2+n_stims_sad_p3);
  s_p3_neut = (n_stims_neut_p2+1):(n_stims_neut_p2+n_stims_neut_p3);
  
  % separate stims into lists for each phase & randomize
  stims_p2.sad = p23_sad_list(s_p2_sad);
  stims_p2.neut = p23_neut_list(s_p2_neut);
  stims_p2.scenes = p23_scenes_list(s_p2_scenes);
  stims_p3t.sad = p23_sad_list(s_p3_sad);
  stims_p3t.neut = p23_neut_list(s_p3_neut);
  stims_p2.sad = randsample(stims_p2.sad,n_stims_sad_p2);
  stims_p2.neut = randsample(stims_p2.neut,n_stims_neut_p2);
  stims_p2.scenes = randsample(stims_p2.scenes,n_stims_scenes_p2);  
  stims_p3t.sad = randsample(stims_p3t.sad,n_stims_sad_p3);
  stims_p3t.neut = randsample(stims_p3t.neut,n_stims_neut_p3);
  stims_p3 = [stims_p3t.sad stims_p3t.neut];
  
  %-------------------------------------------------------------------------%
  %% Arrange stimuli for Phase 1
  
  % practice stimuli
  stimuli.phase1_prescan = repref_getstimuliPhase1Practice(p1_prac_list,n_prac_trials_p1,N_TRIALS_block_p1);
  stimuli.phase1_practice = repref_getstimuliPhase1Practice(p1_prac_list,n_prac_trials_p1,N_TRIALS_block_p1);
  
  % use naming convention
  p1_stimuli = stims_p1;
  
  % define blocks per category
  p1_blocks_cat = N_BLOCKS_p1 / N_CATS;
  
  % define 1-back id matrix
  p1_1back_mat = [1;zeros(N_TRIALS_block_p1 - 1,1)]; % 1-back
  p1_1back_mat(:,2)= p1_1back_mat*0; % not 1-back
  p1_1back_mat = p1_1back_mat';
  
  % preset block level matrices
  blocks.targets = [];
  blocks.condition = [];
  blocks.answers = [];
  
  % create blocks per condition
  for k = 1:N_CATS
    % start row indices  
    idx_start = 1;
    idx_end = N_TRIALS_block_p1;
    
    for i = 1:p1_blocks_cat
      p1_stimuli_b{i} = p1_stimuli(idx_start:idx_end,k);
      p1_cond_b{i} = k; % 1=sad, 2=neut, 3=scene
     
      % half of blocks are 1-back, half not
      switch mod(i,2)
        case 0 % 1-back on evens  
          p1_1back_b(i,:) = p1_1back_mat(1,:);  
        case 1 % no back on odds
          p1_1back_b(i,:) = p1_1back_mat(2,:);
      end
        
      % transpose stimuli
      p1_stimuli_b{i} = p1_stimuli_b{i}';
        
      % randomize order or trials in block
      order = randperm(N_TRIALS_block_p1);
      p1_stimuli_b{i} = p1_stimuli_b{i}(order);
      p1_1back_b(i,:) = p1_1back_b(i,order);
      
      % modify 1-back block stims & generate answer indices
      p1_answers_b(i,:) = p1_1back_mat(2,:);
      switch mod(i,2)
        case 0 % 1-back
          % find 1-back id position
          pos_1back = find(p1_1back_b(i,:) == 1);
          % create 1-back and update answers (adjusting for id at end of stim set)
          if pos_1back < N_TRIALS_block_p1
            p1_stimuli_b{i}(pos_1back + 1) = p1_stimuli_b{i}(pos_1back);
            p1_answers_b(i,pos_1back + 1) = 1;
          elseif pos_1back == N_TRIALS_block_p1;
            p1_stimuli_b{i}(pos_1back - 1) = p1_stimuli_b{i}(pos_1back);
            p1_answers_b(i,pos_1back) = 1;
          end
        case 1
      end
        
      % increment row indices
      idx_start = idx_end + 1;
      idx_end = idx_end + N_TRIALS_block_p1;
    end
      
    % combine stims form all blocks into 1 matrix
    for i = 1:p1_blocks_cat
      blocks.targets = [blocks.targets; p1_stimuli_b{i}];
      blocks.condition = [blocks.condition; p1_cond_b{i}];
      blocks.answers = [blocks.answers; p1_answers_b(i,:)];
    end
  end
 
  % randomize blocks for presentation
  p1_order_b = randperm(N_BLOCKS_p1);
  blocks.targets = blocks.targets(p1_order_b,:);
  blocks.condition = blocks.condition(p1_order_b,1);
  blocks.answers = blocks.answers(p1_order_b,:);
  
  % add data reference objects 
  stimuli.phase1.blocks = N_BLOCKS_p1;
  stimuli.phase1.trials_perblock = N_TRIALS_block_p1;
  stimuli.phase1.targets = blocks.targets;
  stimuli.phase1.condition = blocks.condition;
  stimuli.phase1.answers = blocks.answers;
  
    
  %-------------------------------------------------------------------------%
  %% Arrange stimuli for Phase 2
  % separate target stimuli from foils
  targets_p2.sad = stims_p2.sad(1:n_targets_sad_p2);
  foils_p2t.sad = stims_p2.sad(n_targets_sad_p2+1:n_stims_sad_p2);
  targets_p2.neut = stims_p2.neut(1:n_targets_neut_p2);
  foils_p2t.neut = stims_p2.neut(n_targets_neut_p2+1:n_stims_neut_p2);
  targets_p2.scenes = stims_p2.scenes(1:n_targets_scenes_p2);
  foils_p2t.scenes = stims_p2.scenes(n_targets_scenes_p2+1:n_stims_scenes_p2);
  % set up two columns of scenes
  split_scene_foils = [foils_p2t.scenes(1:N_RSVP_FOILS_total_cat) foils_p2t.scenes((N_RSVP_FOILS_total_cat+1):(N_RSVP_FOILS_total_cat*2))]; 
  
  % practice stims
  prac_p2.total = [foils_p2t.sad foils_p2t.neut split_scene_foils];
  prac_p2.targets.sad = prac_p2.total(1:n_prac_trials_block_p2,1);
  prac_p2.targets.neut = prac_p2.total(1:n_prac_trials_block_p2,2);
  scene1t = prac_p2.total(1:n_prac_trials_block_p2,3);
  scene2t = prac_p2.total(1:n_prac_trials_block_p2,4);
  prac_p2.targets.scenes = [scene1t;scene2t];
  prac_p2.foils = prac_p2.total(n_prac_trials_block_p2+1:(n_prac_trials_block_p2*2),:);
  
  % organize foils
  foils_p2 = [];
  for i = 1:3
    order = randperm(N_RSVP_FOILS_total_cat);
    foil_org = [foils_p2t.sad(order) foils_p2t.neut(order) split_scene_foils(order,:)];
    foils_p2 = [foils_p2; foil_org];
  end
  
  % generate practice trials
  stimuli.phase2_prescan = repref_getstimuliPhase2Practice(prac_p2,n_prac_blocks_p2,n_prac_trials_p2); 
  stimuli.phase2_practice = repref_getstimuliPhase2Practice(prac_p2,n_prac_blocks_p2,n_prac_trials_p2); 
  
  % define answers, switches and slots (and stimuli)
  switches_p2 = [];
  answers_p2 = [];
  slots_p2 = [];
  stimuli_p2 = [];
  cue_cond_p2 = [];
  
  % set indices for stimulus selection
  p2_block_id_start_sad = 1;
  p2_block_id_start_neut = 1;
  p2_block_id_start_scenes = 1;
  p2_block_id_end_sad = N_TRIALS_block_p2/2;
  p2_block_id_end_neut = N_TRIALS_block_p2/2;
  p2_block_id_end_scenes = N_TRIALS_block_p2;
  
  % create answers, switches, slots, and stims per block
  for i = 1:N_BLOCKS_p2
  
    % answers (half valid, half invalid) 
    answers = ones(N_TRIALS_block_p2,1);
    answers(2:2:end) = -1;
    
    % switches (one third of trials are switch trials) 
    switches = zeros(N_TRIALS_block_p2,1);
    switches(3:3:end) = 1;
    
    % slots 
    p2_trial_div = N_TRIALS_block_p2/3; 
    slots = repmat([1;1;1;2;2;2],N_TRIALS_block_p2/p2_trial_div,1);
    % Balance cue top/bottom across blocks            
    if mod(i,2) == 0
        slots = (3 - slots);
    end
     
    % stimuli
    p2_sad_target = targets_p2.sad(p2_block_id_start_sad:p2_block_id_end_sad);
    p2_neut_target = targets_p2.neut(p2_block_id_start_neut:p2_block_id_end_neut);
    p2_scenes_target = targets_p2.scenes(p2_block_id_start_scenes:p2_block_id_end_scenes);
    p2_face_target = [p2_sad_target;p2_neut_target];
    p2_stims = [p2_face_target p2_scenes_target];
    p2_stim_id = [repmat([1],length(p2_sad_target),1); repmat([2],length(p2_neut_target),1)]; %PC - % sad == 1, neutral == 2

    % pseudo-randomize (no more than 3 stay or switch trials in a row)
    order = randperm(size(answers,1));
      % stay/switch sequence checker (evaluate & update order to ensure constraints) 
      seq_check = false;
      switchCheck = switches(order)';
      condCheck = p2_stim_id(order)';
      while seq_check == false
        if sum(strfind(switchCheck, [0 0 0 0])) > 0 | sum(strfind(switchCheck, [1 1 1 1])) > 0 | sum(strfind(condCheck, [1 1 1 1])) > 0 | sum(strfind(condCheck, [2 2 2 2])) > 0
          seq_check = false;
          order = randperm(size(answers,1));
          switchCheck = switches(order)';
          condCheck = p2_stim_id(order)';
        else
          seq_check = true;
        end
      end
    
    switches_p2 = [switches_p2; switches(order)];
    answers_p2 = [answers_p2; answers(order)];
    slots_p2 = [slots_p2; slots(order)];
    stimuli_p2 = [stimuli_p2; p2_stims(order,[1 2])];
    cue_cond_p2 = [cue_cond_p2; p2_stim_id(order)];
        
    % increment & update indices
    p2_block_id_start_sad = p2_block_id_end_sad + 1;
    p2_block_id_start_neut = p2_block_id_end_neut + 1;
    p2_block_id_start_scenes = p2_block_id_end_scenes + 1;
    p2_block_id_end_sad = p2_block_id_end_sad + (N_TRIALS_block_p2/2);
    p2_block_id_end_neut = p2_block_id_end_neut + (N_TRIALS_block_p2/2);
    p2_block_id_end_scenes = p2_block_id_end_scenes + N_TRIALS_block_p2;
    
  end
  
  % provide slot index for second column
  slots_p2 = [slots_p2 (3-slots_p2)];
  
  % map the stimuli to the slots_p2 matrix
  %     For Scenes: (slot(i) = 2) is always 'cued' for first delay period
  %     For Faces: (slot(i) = 1) is always 'cued' for first dalay period
  % for each row, rearrange the column in which the categories appear
  for i=1:size(stimuli_p2,1)
    col_order = slots_p2(i,:);
    stimuli_p2(i,:) = stimuli_p2(i,col_order);
  end

  % setup probe stimuli
  probes1_p2 = repmat({'-'},(N_BLOCKS_p2*N_TRIALS_block_p2),1);
  probes2_p2 = repmat({'-'},(N_BLOCKS_p2*N_TRIALS_block_p2),1);
  p2_rsvp_target_pos = 0*answers_p2;
  
  % setup probe list indices
  id_sad = [1;2];
  id_neut = [1;2];
  
  for i = 1:(N_BLOCKS_p2*N_TRIALS_block_p2)
    
    this.cue = find(slots_p2(i,:)==1); %1 for face, 2 for scene
    this.switch = switches_p2(i);
    this.answer = answers_p2(i);
    this.firstcuecond = cue_cond_p2(i);
    this.firstcuedstim = stimuli_p2(i,this.cue);
    this.firstuncuedstim = stimuli_p2(i,3-this.cue);
    
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
        foils = foils_p2(:,k);
        id_rsvp_start = id_sad(1);
        id_rsvp_end = id_sad(2);
        rsvp_foils = [rsvp_foils; foils(id_rsvp_start:id_rsvp_end)];
      end
      id_sad = id_sad + 2;
    elseif this.firstcuecond == 2
      for k = [this.firstcuecond this.firstcuecond+2] %face probes valence match cue valence, accomodate 2 scene columns
        foils = foils_p2(:,k);
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
      p2_rsvp_target_pos(i) = -1;
      
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
    foils_rsvp = randsample(foils_rsvp,N_RSVP_FOILS_probe);
    if this.answer == 1
      foil_idx = find(ismember(foils_rsvp,valid_target));
      while foil_idx == 1
        foils_rsvp = randsample(foils_rsvp,N_RSVP_FOILS_probe);
        foil_idx = find(ismember(foils_rsvp,valid_target));
      end
      p2_rsvp_target_pos(i) = foil_idx;
    else
      p2_rsvp_target_pos(i) = -1;
    end
    
    % assign to structure cell
    if this.switch == 0
      % 'stay' trial
      probes1_p2(i) = {foils_rsvp};
    else
      % 'switch' trial
      probes2_p2(i) = {foils_rsvp};
    end
    
  end

  % separate the stim list into a separate list for each block
  p2_stimuli = {};
  p2_probes1 = {};
  p2_probes2 = {};
  p2_answers = [];
  p2_slots = [];
  p2_switches = [];
  p2_rsvptarget = [];
  p2_cuecond = [];
  for i = 1:N_BLOCKS_p2
    id_start = 1 + (i-1)*N_TRIALS_block_p2;
    id_end = id_start + N_TRIALS_block_p2 - 1;
    id_range = id_start:id_end;
    
    p2_stimuli(i,:,:) = stimuli_p2(id_range,:);
    p2_probes1(i,:) = probes1_p2(id_range);
    p2_probes2(i,:) = probes2_p2(id_range);
    p2_answers(i,:) = answers_p2(id_range);
    p2_slots(i,:,:) = slots_p2(id_range,:);
    p2_switches(i,:) = switches_p2(id_range);
    p2_rsvptarget(i,:) = p2_rsvp_target_pos(id_range);
    p2_cuecond(i,:) = cue_cond_p2(id_range);
  end
  
  p2_cues = p2_slots(:,:,2); %PC - this references cue location (1 = face bottom; 2 = face top; flips for scenes)
  p2_cuedcats = 1 + 0*p2_cues; %PC -  1 = face, 2 = scene (i.e., 1 + ; 2 +)
  
  % save results
  stimuli.phase2.blocks = N_BLOCKS_p2;
  stimuli.phase2.trials_perblock = N_TRIALS_block_p2;
  stimuli.phase2.stay_perblock = N_STAY_block_p2;
  stimuli.phase2.switch_perblock = N_SWITCH_block_p2;
  stimuli.phase2.targets = p2_stimuli;
  stimuli.phase2.slots = p2_slots;
  stimuli.phase2.cues = p2_cues;
  stimuli.phase2.cuedcats = p2_cuedcats;
  stimuli.phase2.cuecond = p2_cuecond; %PC - notation for type of face (1 = sad, 2 = neut)
  stimuli.phase2.probes1 = p2_probes1;
  stimuli.phase2.probes2 = p2_probes2;
  stimuli.phase2.answers = p2_answers;
  stimuli.phase2.rsvptarget = p2_rsvptarget;
  stimuli.phase2.switches = p2_switches;
  stimuli.phase2.switches_name.stay = 0;
  stimuli.phase2.switches_name.switch = 1;
  stimuli.phase2.id_sad = id_sad;
  stimuli.phase2.id_neut =id_neut;
   
  
  %-------------------------------------------------------------------------%
  %% Arrange stimuli for Phase 3
  
  % grab all un-cued target stimuli from phase 2
  
  % practice stimuli 
  p3_prac_pair = p3_prac_list(1:2);
  p3_prac_targets = p3_prac_list(3:7);
  stimuli.phase3_practice.pair = p3_prac_pair;
  stimuli.phase3_practice.targets = p3_prac_targets;
  
  % get indicies for the cued stimuli in all 'switch trials'
  cued_switch_idx_1 = find((p2_slots(:,:,1)==1) .* (p2_switches==1)); %PC - p2_slots == 1, face; p2_slots == 2, scene
  cued_switch_idx_2 = find((p2_slots(:,:,2)==1) .* (p2_switches==1)); %PC - p2_slots == 1, face; p2_slots == 2, scene
  assert(length(cued_switch_idx_1)==length(cued_switch_idx_2),...
    '(*) p3 cued switch stims not balanced for cue1 and cue2');
  % %   cued_switch_idx_all = [cued_switch_idx_1; cued_switch_idx_2];
    
  % get indicies corresponding to the cued stimuli in the 'stay trials'
  % NOTE: ** only ** use those stims from 'invalid probe' trials so that
  % the target picture never reappeared
  cued_stay_idx_1 = find((p2_slots(:,:,1)==1) .* (p2_switches==0) .* (p2_answers==-1)); %PC - p2_slots == 1, face; p2_slots == 2, scene
  cued_stay_idx_2 = find((p2_slots(:,:,2)==1) .* (p2_switches==0) .* (p2_answers==-1)); %PC - p2_slots == 1, face; p2_slots == 2, scene
  assert(length(cued_stay_idx_1)==length(cued_stay_idx_2),...
    '(*) p3 cued stay stims not balanced for cue1 and cue2');
  
  % combine stims from all trials
  cued_idx_1 = [cued_stay_idx_1; cued_switch_idx_1];
  cued_idx_2 = [cued_stay_idx_2; cued_switch_idx_2];
  
  % get row & col subscripts for the cued stimuli indicies
  [row_1 col_1] = ind2sub(size(p2_stimuli),cued_idx_1);
  [row_2 col_2] = ind2sub(size(p2_stimuli),cued_idx_2);
  
  % convert subscript from blockXtrial, into index for blockXtrialXstimuli
  page_1 = ones(length(row_1),1);
  idx_1 = sub2ind(size(p2_stimuli),row_1,col_1,page_1);
  idx_1_2d = sub2ind(size(p2_answers),row_1,col_1);
  page_2 = 2*page_1;
  idx_2 = sub2ind(size(p2_stimuli),row_2,col_2,page_2);
  idx_2_2d = sub2ind(size(p2_answers),row_2,col_2);
  
  % get cued stimuli
  stims_cued_p2 = p2_stimuli([idx_1;idx_2]);
  category_cued_p2 = p2_slots([idx_1;idx_2]);
  condition_cued_p2 = p2_cuecond([idx_1_2d;idx_2_2d]);
  answers_cued_p2 = p2_answers([idx_1_2d;idx_2_2d]);
  source_cued_p2 = [-1*ones(length(cued_stay_idx_1),1); -99*ones(length(cued_switch_idx_1),1)];
  source_cued_p2 = repmat(source_cued_p2,2,1); 
  block_cued_p2 = [row_1;row_2];
  trial_cued_p2 = [col_1;col_2];
  
  % arrange new stimuli for phase 3
  % %   newstims_p3 = [stims_p3(:,1); stims_p3(:,2)]; % combine cats
  newstims_p3 = [stims_p3(:,1);stims_p3(:,2)]; % stack
  condition_newstims_p3 = [ones(length(stims_p3),1);2*ones(length(stims_p3),1)]; % 1 = sad, 2 = neutral
  category_newstims_p3 = [1*ones(length(newstims_p3),1)];
  source_newstims_p3 = zeros(size(newstims_p3,1),1);
    
  % combine p2 cued stims with new p3 stims
  stims_p3 = [stims_cued_p2;newstims_p3];
  category_p3 = [category_cued_p2;category_newstims_p3];
  condition_p3 = [condition_cued_p2;condition_newstims_p3];
  p2answers_p3 = [answers_cued_p2;0*category_newstims_p3];
  source_p3 = [source_cued_p2;source_newstims_p3];
  block_p3 = [block_cued_p2;0*block_cued_p2];
  trial_p3 = [trial_cued_p2;0*trial_cued_p2];
  
  % shuffle the stims for presentation
  order = randperm(length(stims_p3));
  p3_stimuli = stims_p3(order);
  p3_category = category_p3(order);
  p3_condition = condition_p3(order);
  p3_p2answers = p2answers_p3(order);
  p3_source = source_p3(order);
  p3_block = block_p3(order);
  p3_trial = trial_p3(order);
  p3_answers = (p3_source==0);
  p3_answers = p3_answers + -1*(1 - p3_answers);
  
  % save results
  stimuli.phase3.blocks = N_BLOCKS_p3;
  stimuli.phase3.trials_perblock = N_TRIALS_block_p3;
  stimuli.phase3.targets = p3_stimuli;
  stimuli.phase3.category = p3_category;
  stimuli.phase3.category_names = {'face','scene'};
  stimuli.phase3.condition = p3_condition;
  stimuli.phase3.condition_ids = [1 2];
  stimuli.phase3.condition_names = {'sad','neutral'};
  stimuli.phase3.source = p3_source;
  stimuli.phase3.p2answers = p3_p2answers;
  stimuli.phase3.p2answers_names = {'-1:foil','0:none','1:valid'};
  stimuli.phase3.p2block = p3_block;
  stimuli.phase3.p2trial = p3_trial;
  stimuli.phase3.source_ids = [0 -1 -99];  
  stimuli.phase3.source_names = {'new','stay','switch'};
  stimuli.phase3.answers = p3_answers;
  
  %-------------------------------------------------------------------------%
  % Save stimuli for this subject
  stimuli.version = version;
  save(stim_filename,'stimuli');
  
end

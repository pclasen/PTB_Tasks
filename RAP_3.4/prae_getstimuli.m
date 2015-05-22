function [stimuli] = prae_getstimuli(subjectNumber, subjectName, varargin)
  
  %-------------------------------------------------------------------------%
  % [stimuli] = repref_getstimuli(...)
  %
  % * all arguments are strings
  %
  % SUBJNUM  : unique # based on date string (e.g., '101220')
  % SUBJNAME : unique subject name (e.g., 'jlp')
  % VARARGIN : skip practice trials (default is 'false', to skip - 'true'
  %
  % e.g.,
  % >> repref_getstimuli('101110','jlp')
  %------------------------------------------------------------------------%
  
 %% script version

 version = '2015MAY12(3.3)'; 
 
 if ~nargin
   script_backup(mfilename,'./',version);
   stimuli = sprintf('script version: %s\n',version);
   return;
 end

 %% optional input for NO practice
 numvarargs = length(varargin);
 if numvarargs > 1
     error('Error: Only one optional input is accepted');
 end
 
 optargs = false;
 optargs = varargin;
 
 [skipPrac] = optargs;
 
 
 
  %% EXPERIMENTAL PARAMETERS
  
  %DEBUG_ME = false;
  
  % Resource paths
  S_TARGET_DIR = './stimuli/targets';
  
  % Resource lists
  S_NEUT_LIST = './stimuli/neutral_list.txt';
  S_NEG_LIST = './stimuli/negative_list.txt';
  S_POS_LIST = './stimuli/positive_list.txt';
  
  % CUE/IMAGE categories
  N_CATS = 3;
  N_PICS_CAT = 40;
  N_PICS_cat_test = 32;
  CAT_NAMES = {'Neutral' 'Negative' 'Positive'};
  
  % ITI
  T_ITI = [4 6 8 10];
  N_ITI = [7 12 3 2];
  
  % Blocks and trials
  N_BLOCKS = 4; 
  N_TRIALS_block = 24;
  N_TRIALS_cat_block = N_TRIALS_block / N_CATS;
  
  
  %-------------------------------------------------------------------------%
  %-------------------------------------------------------------------------%
  
  %------------------------------%
  %% santity checks
  assert(logical(exist('./stimuli/','dir')),...
    sprintf('(*) "stimuli" directory does not exisit in: %s',pwd));
  
  % sanity checks
  assert(ischar(subjectNumber),'(*) subjectNumber must be a ''string''');
  assert(ischar(subjectName),'(*) subjectName must be a ''string''');
  
  stim_filename = ['./stimuli/subject_sets/prae_stimuli_' ...
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
  
  % Open lists of image stimuli
  % neutral
  fileID = fopen(S_NEUT_LIST);
  list = textscan(fileID, '%s');
  neut_list = strcat(S_TARGET_DIR,'/',list{1});
  fclose(fileID);
  % negative
  fileID = fopen(S_NEG_LIST); 
  list = textscan(fileID, '%s');
  neg_list = strcat(S_TARGET_DIR,'/',list{1});
  fclose(fileID);
  % positive
  fileID = fopen(S_POS_LIST);
  list = textscan(fileID, '%s');
  pos_list = strcat(S_TARGET_DIR,'/',list{1});
  fclose(fileID);

  %-------------------------------------------------------------------------%
  %% Grab stimuli
  
  R_neut_list = randsample(neut_list,N_PICS_CAT);
  R_neg_list = randsample(neg_list,N_PICS_CAT);
  R_pos_list = randsample(pos_list,N_PICS_CAT);
  
  images = [R_neut_list(1:N_PICS_cat_test) R_neg_list(1:N_PICS_cat_test) R_pos_list(1:N_PICS_cat_test)];
  prac_images = [R_neut_list((N_PICS_cat_test+1):N_PICS_CAT) R_neg_list((N_PICS_cat_test+1):N_PICS_CAT) R_pos_list((N_PICS_cat_test+1):N_PICS_CAT)];
  
  %-------------------------------------------------------------------------%
  %% Arrange Stimuli
  
  % define stimuli, valence, condition (ant/retro/full/full+rate) 
  T_stimuli = {};
  T_valence = [];
  T_condition = [];
  T_iti= [];
  P_stimuli = {};
  P_valence = [];
  
  % set indices for stimulus selection
  B_start = 1;
  B_end = N_TRIALS_cat_block;
  
  % create stim, valence, condition, type lists
  for i = 1:N_BLOCKS
    
    % set up B_stims & B_val
    B_stims = [];
    B_val = [];
    
    % populate with stimuli and valence per block
    for k = 1:N_CATS
        % stimuli
        stim_set = images(B_start:B_end,k);
        B_stims = [B_stims;stim_set];
        
        % valence (1 = neut; 2 = neg; 3 = pos)
        B_val = [B_val;repmat(k,N_TRIALS_cat_block,1)];
    end 
    
    % increment & update indices
    B_start = B_start + N_TRIALS_cat_block;
    B_end = B_end + N_TRIALS_cat_block;
    
    % condition (ant = 1; retro = 2; full = 3; full+rate = 4)
    B_cond = repmat([3,3,3,3,4,4,1,2]',3,1);
    
    % variable iti
    t_iti = [repmat(T_ITI(1),N_ITI(1),1);repmat(T_ITI(2),N_ITI(2),1);...
        repmat(T_ITI(3),N_ITI(3),1);repmat(T_ITI(4),N_ITI(4),1)];
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
           sum(strfind(condCheck, [1 1 1])) > 0 | sum(strfind(condCheck, [2 2 2])) > 0 | sum(strfind(condCheck, [3 3 3 3])) > 0 | sum(strfind(condCheck, [4 4])) > 0
            seq_check = false;
            order = randperm(size(B_stims,1));
            valCheck = B_val(order)';
            condCheck = B_cond(order)';
        else
            seq_check = true;
        end
    end
    
    % index stims for anticipation catch (unused) to use in practice (12
    % stims, 4 per condition)
    L_AC = find(B_cond(order)==1);
    P_stims = B_stims(order);
    P_stimuli = [P_stimuli; P_stims(L_AC)];
    P_vals = B_val(order);
    P_valence = [P_valence; P_vals(L_AC)];
    
    % add trials to blocks
    T_stimuli(i,:) = B_stims(order);
    T_valence(i,:) = B_val(order);
    T_condition(i,:) = B_cond(order);
    T_iti(i,:) = B_iti(order);
  
  end % blocks
  
  % randomize blocks for presentation
  order = randperm(N_BLOCKS);
  T_stimuli = T_stimuli(order,:);
  T_valence = T_valence(order,:);
  T_condition = T_condition(order,:);
  T_iti = T_iti(order,:);
  
  % practice stimuli
  [practice] = prae_getPracStims(prac_images,P_stimuli,P_valence);
  
  % save results
  stimuli.task.blocks = N_BLOCKS;
  stimuli.task.trials_perblock = N_TRIALS_block;
  stimuli.task.fullTrials_perblock = N_TRIALS_block/2;
  stimuli.task.anticipatecatchTrials_perblock = N_TRIALS_block/4;
  stimuli.task.retrospectcatchTrials_perblock = N_TRIALS_block/4;
  stimuli.task.numberoffulltrialswithrating = 3;
  stimuli.task.targets = T_stimuli;
  stimuli.task.valence = T_valence;
  stimuli.task.val_names = CAT_NAMES;
  stimuli.task.condition = T_condition;
  stimuli.task.cond_names = {'anticipate' 'retrospect' 'full' 'full+rate'};
  stimuli.task.iti = T_iti;
  stimuli.practice = practice;
  
  %-------------------------------------------------------------------------%
  % Save stimuli for this subject
  stimuli.version = version;
  save(stim_filename,'stimuli');
  
end % function

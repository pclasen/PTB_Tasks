function [practice] = repref_getstimuliPhase1Practice(stims,n_trials,n_trials_block)

  %-------------------------------------------------------------------------%
  % [practice] = repref_getstimuliPhase1Practice(...)
  %
  % * all arguments must be specificed in repref_getstimuli
  %
  %------------------------------------------------------------------------%

  % randomize targets
  targets = randsample(stims,n_trials);
  
  % trials per block
  n_blocks = n_trials/n_trials_block;
  
  % define 1-back id matrix
  oneback_mat = [1;zeros(n_trials_block - 1,1)]; % 1-back
  oneback_mat(:,2)= oneback_mat*0; % not 1-back
  oneback_mat = oneback_mat';
  
  % set up recepticles
  blocks.targets = [];
  blocks.answers = [];
  
  % sed start indices
  id_start = 1;
  id_end = n_trials_block;
  
  for i = 1:n_blocks
    targets_b{i} = targets(id_start:id_end);
    
    % for short practice every block has 1 back
    oneback_b(i,:) = oneback_mat(1,:);
    
    % transpose
    targets_b{i} = targets_b{i}';
    
    % randomize order
    order = randperm(n_trials_block);
    targets_b{i} = targets_b{i}(order);
    oneback_b(i,:) = oneback_b(i,order);
    
    % modify 1-back block stims & generate answer indices
    answers_b(i,:) = oneback_mat(2,:);
    % find 1-back id position
    pos_1back = find(oneback_b(i,:) == 1);
    % create 1-back and update answers (adjusting for id at end of stim set)
    if pos_1back < n_trials_block
      targets_b{i}(pos_1back + 1) = targets_b{i}(pos_1back);
      answers_b(i,pos_1back + 1) = 1;
    elseif pos_1back == n_trials_block;
      targets_b{i}(pos_1back - 1) = targets_b{i}(pos_1back);
      answers_b(i,pos_1back) = 1;
    end
        
    % increment row indices
    id_start = id_end + 1;
    id_end = id_end + n_trials_block;
    
    % combine stims form all blocks into 1 matrix
    blocks.targets = [blocks.targets; targets_b{i}];
    blocks.answers = [blocks.answers; answers_b(i,:)];
  end

  practice.targets = blocks.targets;
  practice.answers = blocks.answers;
  
end


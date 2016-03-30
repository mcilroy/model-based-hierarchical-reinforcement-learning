%% HRL - model based
function hrl()
    %% parameter declarations
    close all; clear; gridsize = 11; discount = 0.9; alpha_value = 0.1; alpha_action = 0.01; temp = 10; 
    max_depth=1; search_attempts=1; time_length=50000; trial_total = 1; build_mode = 1;
    %% setup world
    blocks = [1 6; 2 6; 4 6; 5 6; 6 1; 6 3; 6 4; 6 5; 6 6; 7 6; 7 7; 7 8; 7 10; 7 11; 8 6; 9 6; 11 6;];
    for i=1:gridsize;
        for j=1:gridsize;
            for k = 1:size(blocks,1)
                if i==blocks(k,1) && j==blocks(k,2);
                    grid(i,j).terrain = 'block';
                end
            end
        end
    end
    %% setup start and end states
    s.i = 1; s.j = 11;
    grid(s.i,s.j).start = s;
    s.i = 8; s.j = 2;
    grid(s.i,s.j).end = 1;
    
    %% create options
    options = create_options(gridsize);
    moves = zeros(1,trial_total);
    options_taken_array = zeros(1,trial_total);
    for trial=1:trial_total
        s.i = 1; s.j = 11; grid(s.i,s.j).start = s; % start state of agent
        option_idx = 1; % root option
        tot_steps = 1;
        s_init = s;
        cum_reward = 0;
        alpha = exp(-trial/(trial_total*.2));
        move = 0;
        options_taken = 0;
        for t=1:time_length;
            %% select from a list of possible actions given the current option context
            if build_mode == 0;
                a_idx = get_model_based_a(options, option_idx, temp, s, alpha, grid, max_depth, search_attempts); % if option==1 then action = 1:12, if option >=2 then option = 1:4    
            else
                a_idx = get_next_action(options, options(option_idx), temp, s_init, alpha);
            end
            if a_idx >4 % if selected a new option (non-primitive)
                %% reset option
                o_idx = a_idx;
                option_idx = a_idx-3;
                tot_steps = 1;
                s_init = s;
                cum_reward = 0;
                %% take a primitive action from the option's W values
                if build_mode ==0;
                    a_idx = get_model_based_a(options, option_idx, temp, s, alpha, grid, max_depth, search_attempts); % option = not root, so action = 1:4
                else
                    a_idx = get_next_action(options, options(option_idx), temp, s_init, alpha);
                end
            end
            action = create_a(a_idx);
            next_state = transition(grid, s, action);
            if strcmp(options(option_idx).name,'root'); % if root option
                %% reset option values
                cum_reward = 0;
                tot_steps = 1;
                s_init = s;
                %% update the root's option W and V matrixes
                if build_mode == 0;
                    [cum_reward, options] = update_option_values(s,s_init,cum_reward,discount,tot_steps,@reward,action,options,option_idx,next_state,action.idx,alpha_value,alpha_action);
                end
                options_taken = options_taken + 1;
            else
                %% update the current option's W and V matrixes
                [cum_reward, options] = update_option_values(s,s,0,discount,1,@pseudo_reward,action,options,option_idx,next_state,action.idx,alpha_value,alpha_action);
                if is_sub_goal(options(option_idx), next_state) == 1; % if subgoal reached
                    %% update the root option's W and V concerning taking a specific option
                    option_idx = 1;
                    if build_mode == 0;
                        [cum_reward, options] = update_option_values(s,s_init,cum_reward,discount,tot_steps,@reward,action,options,option_idx,next_state,o_idx,alpha_value,alpha_action);  
                    end
                    cum_reward = 0;
                    tot_steps = 0; % set to 0 because you increase it by 1 in the next line
                    s_init = next_state;
                    options_taken = options_taken + 1;
                else
                    cum_reward = cum_reward + discount^(tot_steps-1)*reward(s, action); % keep adding reward up
                end
                tot_steps = tot_steps+1;
            end     
            s = next_state; 
            move = move +1;
            if build_mode==0;
                if end_state(grid,s)
                    break;
                end  
            end
            if build_mode==1;
                if mod(t,5000) == 0;
                    t
                end
            end
        end
        moves(1,trial) = move;
        options_taken_array(1,trial) = options_taken;
    end
    display_grid(grid, options(1).V)
    display_grid(grid, options(2).V)
    [value, ind] = max(options(1).W,[],3);
    display_grid(grid, ind)
    plot(moves);
    plot(options_taken_array);
    if build_mode == 1;
        save('../data/option_building.mat', 'options');
    end
end

function [cum_reward, options] = update_option_values(s, s_init, cum_reward ,discount, tot_steps, reward_function, action, options, option_idx, next_state, a_idx, alpha_value, alpha_action)
    cum_reward = cum_reward + discount^(tot_steps-1)*reward_function(s, action, options(option_idx));
    delta = cum_reward + discount^tot_steps * options(option_idx).V(next_state.i,next_state.j) - options(option_idx).V(s_init.i, s_init.j);
    options(option_idx).V(s_init.i, s_init.j) = options(option_idx).V(s_init.i, s_init.j) + alpha_value*delta;
    options(option_idx).W(s_init.i, s_init.j, a_idx) = options(option_idx).W(s_init.i,s_init.j, a_idx) + alpha_action*delta;
end

%% select the best action after looking ahead and skipping primitive actions inside options
% if option==root then lookahead on all options, but skip primitives steps and stop at end goal
% if option==non-root do only primitives of the current option and stop when subgoal reached
function best_a_idx = get_model_based_a(options, option_idx, temp, s_init, alpha, grid, max_depth, search_attempts)
    %best_a_idx = get_next_action(options, options(option_idx), temp, s_init, alpha);
    %return;
	best_a_idx = get_next_action(options, options(option_idx), temp, s_init, alpha);
	best_V = 0; % assuming no negative rewards
	for i=1:search_attempts
		depth = 1;
		action_ids = zeros(1,max_depth);
		s = s_init;
		while depth <= max_depth
			a_idx = get_next_action(options, options(option_idx), temp, s, alpha); % action= 1:12
			if option_idx == 1 && a_idx > 4; % root and new option selected
				option_idx = a_idx-3; % set current option to selected option
				next_state = options(option_idx).end_states(1); % skip to end state
				option_idx = 1; % set back to root
			else
				action = create_a(a_idx);
				next_state = transition(grid, s, action);
			end
			action_ids(1, depth) = a_idx;
			depth = depth + 1;
			if option_idx == 1; % root
				goal_state_reached = end_state(grid, next_state);
			else
				goal_state_reached = is_sub_goal(options(option_idx), next_state);
			end
			if goal_state_reached==1; % if reached goal, return previous state's value because goal state does not have a V value.
				if options(option_idx).V(s.i,s.j) > best_V;
					best_V = options(option_idx).V(s.i,s.j);
					best_a_idx = action_ids(1,1);
				end
				break;
			else
				if options(option_idx).V(next_state.i, next_state.j) > best_V;
					best_V = options(option_idx).V(next_state.i,next_state.j);
					best_a_idx = action_ids(1,1);
				end
			end
			s = next_state;
		end
	end
end

function a_idx = get_next_action(options, current_option, temp, s, alpha)
    possible_options_indexes = get_possible_options(options, current_option, s);
    [indexes,action_probs] = get_action_probabilities(possible_options_indexes, current_option, temp, s);
    a_idx = select(indexes, action_probs, alpha);
end

function possible_abs_options = get_possible_options(options, current_option, s)
    for i=1:4;
        possible_abs_options(i) = i; % always add primitive actions
    end
    if strcmp(current_option.name,'root'); % don't allow options to add other options
        count = 5;
        for i=2:size(options,2) % skip root option
            bool = 0;
            start_states = options(i).start_states;
            for j=1:size(start_states,2)
                if start_states(j).i == s.i && start_states(j).j == s.j
                    bool = 1;
                end
            end
            if bool ==1;
                possible_abs_options(count) = i+3; % add idx of option
                count = count+1;
            end
        end
    end
end

%% return array of action probabilities for the current option in control
function [indexes, action_probs] = get_action_probabilities(selected_options, current_option, temp, s)
    action_probs = exp(current_option.W(s.i,s.j,selected_options)/temp)/(sum(exp(current_option.W(s.i,s.j,selected_options)/temp)));
    action_probs = reshape(action_probs,[size(selected_options,2),1]);
    indexes = selected_options;
end

function a = select(indexes, action_probs, alpha)
    choice = rand();
    low = 0;
    high = action_probs(1);
    for i=1:size(action_probs,1);
        if choice >= low && choice < high;
            a = indexes(i);
        end
        if i < size(action_probs,1);
            low = low+action_probs(i);
            high = high+action_probs(i+1);
        end
    end
    if rand() < alpha;
        a = indexes(randi(size(indexes,2)));
    end
end

function bool = end_state(grid,s)
    if grid(s.i,s.j).end == 1;
        bool =1;
    else
        bool = 0;
    end
end

function bool = is_sub_goal(current_option, next_state)
    bool =0;
    for i=1:size(current_option.end_states,1)
        if next_state.i == current_option.end_states(i).i && next_state.j == current_option.end_states(i).j
            bool = 1;
        end
    end
end

function s = transition(grid, s, action)
    if strcmp(action.name,'left')
        if allowed(grid,s.i,s.j-1)
            s.j = s.j-1;
        end
    elseif strcmp(action.name,'right')
        if allowed(grid,s.i,s.j+1)
            s.j = s.j+1;
        end
    elseif strcmp(action.name,'up')
        if allowed(grid,s.i-1,s.j)
            s.i = s.i-1;
        end
    elseif strcmp(action.name,'down')
        if allowed(grid,s.i+1,s.j)
            s.i = s.i+1;
        end
    end
end

function bool = allowed(grid, i,j)
    bool = 1;
    if i<1 || i > size(grid,1) || j < 1 || j > size(grid,2);
        bool = 0;
        return;
    end
    if strcmp(grid(i,j).terrain,'block')
        bool = 0;
        return;
    end
end

function r = reward(s, action, current_option)
    if s.i == 7 && s.j == 2 && strcmp(action.name,'down');
        r = 100;
    elseif s.i == 9 && s.j == 2 && strcmp(action.name,'up');
        r = 100;
    elseif s.i == 8 && s.j == 1 && strcmp(action.name,'right');
        r = 100;
    elseif s.i == 8 && s.j == 3 && strcmp(action.name,'left');
        r = 100;
    else
        r = 0;
    end
end

function r = pseudo_reward(s, action, current_option)
    if strcmp(current_option.name,'room_upperleft_door_down') &&  s.i == 5 && s.j == 2 && strcmp(action.name,'down');
        r = 100;
    elseif strcmp(current_option.name,'room_upperleft_door_right') && s.i == 3 && s.j == 5 && strcmp(action.name,'right');
        r = 100;
    elseif strcmp(current_option.name,'room_upperright_door_left') && s.i == 3 && s.j == 7 && strcmp(action.name,'left');
        r = 100;
    elseif strcmp(current_option.name,'room_upperright_door_down') && s.i == 6 && s.j == 9 && strcmp(action.name,'down');
        r = 100;
    elseif strcmp(current_option.name,'room_lowerleft_door_up') && s.i == 7 && s.j == 2 && strcmp(action.name,'up');
        r = 100;
    elseif strcmp(current_option.name,'room_lowerleft_door_right') && s.i == 10 && s.j == 5 && strcmp(action.name,'right');
        r = 100;
    elseif strcmp(current_option.name,'room_lowerright_door_left') && s.i == 10 && s.j == 7 && strcmp(action.name,'left');
        r = 100;
    elseif strcmp(current_option.name,'room_lowerright_door_up') && s.i == 8 && s.j == 9 && strcmp(action.name,'up');
        r = 100;
    else
        r = 0;
    end
end

function display_grid(grid,V)
    dis = zeros(size(grid,1),size(grid,2));
    for i=1:size(grid,1);
        for j=1:size(grid,2);
            if strcmp(grid(i,j).terrain,'block');
                dis(i,j)=-1;
            else
                dis(i,j)=V(i,j);
            end
        end
    end
    dis
end

function u = create_a(idx)
    if idx ==1;
        u.name = 'left';
    elseif idx ==2;
        u.name= 'right';
    elseif idx==3;
        u.name='up';
    elseif idx==4;
        u.name='down';
    elseif idx==5;
        u.name='room_upperleft_door_down';
    elseif idx==6;
        u.name='room_upperleft_door_right';
    elseif idx==7;
        u.name='room_upperright_door_left';
    elseif idx==8;
        u.name='room_upperright_door_down';
    elseif idx==9;
        u.name='room_lowerleft_door_up';
    elseif idx==10;
        u.name='room_lowerleft_door_right';
    elseif idx==11;
        u.name='room_lowerright_door_left';
    elseif idx==12;
        u.name='room_lowerright_door_up';
    end
    u.idx=idx;
end
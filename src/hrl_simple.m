%% HRL - simple
function hrl()
    %% parameter declarations
    close all; clear; gridsize = 5; discount = 0.9; alpha_value = 0.1; alpha_action = 0.01; temp = 10;

    s.i = 1; s.j = 1;
    grid(1,1).start = s;
    s.i = 1; s.j = 5;
    grid(1,5).end = 1;
    
    %% create options
    options = create_options(gridsize);
    
    for trial=1:5000
        if trial == 1000
            blah = 1;
        end
        s.i = 1; s.j = 1; grid(s.i,s.j).start = s; % start state of agent
        %current_option = options(1); % select root option to start
        option_idx = 1;
        tot_steps = 1;
        s_init = s;
        cum_reward = 0;
        for t=1:100;
            possible_options_indexes = get_possible_options(options, options(option_idx), s);
            [indexes,action_probs] = get_action_probabilities(possible_options_indexes, options(option_idx), temp, s);
            a_idx = select(indexes, action_probs);            
            if a_idx >2 % selected a new option (non-primitive)
                o_idx = a_idx;
                %current_option = options(a_idx-1);
                option_idx = a_idx-1;
                tot_steps = 1;
                s_init = s;
                cum_reward = 0;
                %% take an action from the option, get pseudo reward, update option values and move
                possible_options_indexes = get_possible_options(options, options(option_idx), s);
                [indexes,action_probs] = get_action_probabilities(possible_options_indexes, options(option_idx), temp, s);
                a_idx = select(indexes, action_probs); % 1-2 idx
            end
            action = create_a(a_idx);
            next_state = transition(grid, s, action);
            if strcmp(options(option_idx).name,'root');
                cum_reward = 0;
                tot_steps = 1;
                s_init = s;
                cum_reward = cum_reward + discount^(tot_steps-1)*reward(s, action);
                delta = cum_reward + discount^tot_steps * options(option_idx).V(next_state.i,next_state.j) - options(option_idx).V(s_init.i, s_init.j);
                options(option_idx).V(s_init.i, s_init.j) = options(option_idx).V(s_init.i, s_init.j) + alpha_value*delta;
                options(option_idx).W(s_init.i, s_init.j, action.idx) = options(option_idx).W(s_init.i,s_init.j, action.idx) + alpha_action*delta;
            else
                pseudo = discount^(1-1)*pseudo_reward(s, action, options(option_idx));
                delta = pseudo + discount^1 * options(option_idx).V(next_state.i,next_state.j) - options(option_idx).V(s.i, s.j);
                options(option_idx).V(s.i, s.j) = options(option_idx).V(s.i, s.j) + alpha_value*delta;
                options(option_idx).W(s.i, s.j, action.idx) = options(option_idx).W(s.i,s.j, action.idx) + alpha_action*delta;
                if is_sub_goal(options(option_idx), next_state) == 1;
                    %options(option_idx) = options(1); % set root option
                    option_idx = 1;
                    cum_reward = cum_reward + discount^(tot_steps-1)*reward(s, action);
                    delta = cum_reward + discount^tot_steps * options(option_idx).V(next_state.i,next_state.j) - options(option_idx).V(s_init.i, s_init.j);
                    options(option_idx).V(s_init.i, s_init.j) = options(option_idx).V(s_init.i, s_init.j) + alpha_value*delta;
                    options(option_idx).W(s_init.i, s_init.j, o_idx) = options(option_idx).W(s_init.i,s_init.j, o_idx) + alpha_action*delta;  
                    
                    cum_reward = 0;
                    tot_steps = 0;
                    s_init = next_state;
                else
                    cum_reward = cum_reward + discount^(tot_steps-1)*reward(s, action);
                end
                tot_steps = tot_steps+1;
            end

            
            s = next_state; 
            if end_state(grid,s)
                break;
            end    
        end
    end
    display_grid(grid, options(1).V)
    display_grid(grid, options(2).V)
end

function bool = is_sub_goal(current_option, next_state)
    bool =0;
    for i=1:size(current_option.end_states,1)
        if next_state.i == current_option.end_states(i).i && next_state.j == current_option.end_states(i).j
            bool = 1;
        end
    end
end

%% return array of action probabilities for the current option in control
function [indexes, action_probs] = get_action_probabilities(selected_options, current_option, temp, s)
    action_probs = exp(current_option.W(s.i,s.j,selected_options)/temp)/(sum(exp(current_option.W(s.i,s.j,selected_options)/temp)));
    action_probs = reshape(action_probs,[size(selected_options,2),1]);
    indexes = selected_options;
end

function possible_abs_options = get_possible_options(options, current_option, s)
    for i=1:2;
        possible_abs_options(i) = i; % always add primitive actions
    end
    if strcmp(current_option.name,'root'); % don't allow options to add other options
        count = 3;
        for i=2:size(options,2) % skip root option
            bool = 0;
            start_states = options(i).start_states;
            for j=1:size(start_states,2)
                if start_states(j).i == s.i && start_states(j).j == s.j
                    bool = 1;
                end
            end
            if bool ==1;
                possible_abs_options(count) = i+1; % add idx of option
                count = count+1;
            end
        end
    end
end

function bool = end_state(grid,s)
    if grid(s.i,s.j).end == 1;
        bool =1;
    else
        bool = 0;
    end
end

function s = transition(grid, s, action)
    if strcmp(action.name,'left')
        if allowed(grid,s.i,s.j-1,'left')
            s.j = s.j-1;
        end
    elseif strcmp(action.name,'right')
        if allowed(grid,s.i,s.j+1,'right')
            s.j = s.j+1;
        end
    end
end

function bool = allowed(grid, i,j, a)
    bool = 1;
    if i<1 || i > size(grid,1) || j < 1 || j > size(grid,2);
        bool = 0;
        return;
    end
end

function r = reward(s, action)
    if s.i == 1 && s.j == 4 && strcmp(action.name,'right');
        r = 100;
    else
        r = 0;
    end
end

function r = pseudo_reward(s, action, current_option)
    if strcmp(current_option.name,'go_right') &&  s.i == 1 && s.j == 4 && strcmp(action.name,'right');
        r = 100;
    else
        r = 0;
    end
end

function a = select(indexes, action_probs)
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
    if rand() < 0.1;
        a = indexes(randi(size(indexes,2)));
    end
end

function display_grid(grid,V)
    dis = zeros(size(grid,1),size(grid,2));
    for i=1:size(grid,1);
        for j=1:size(grid,2);
            dis(i,j)=V(i,j);
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
        u.name='go_right';
    end
    u.idx=idx;
end

function options = create_options(gridsize)
    % options = root, plus 8 options to move towards different doors.
    for i=1:2;
       options(i).isRoot = 0;
       
        if i==1; 
            options(i).name = 'root'; 
            options(i).isRoot = 1;
            options(i).W = zeros(1,gridsize,3);
            options(i).V = zeros(1,gridsize);
        end
        if i==2; 
            options(i).name = 'go_right'; 
            options(i).W = zeros(1,gridsize,2);
            options(i).V = zeros(1,gridsize);
            count =1;
            for j=1:4;
                s.i = 1;
                s.j = j;
                options(i).start_states(count) = s;
                count=count+1;
            end
            s.i = 1; s.j=1;
            options(i).start_states(count) = s;
            s.i=1; s.j=5;
            options(i).end_states(1) = s;
        end
    end
end
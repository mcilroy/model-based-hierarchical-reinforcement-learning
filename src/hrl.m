%% HRL
function hrl()
    %% parameter declarations
    close all; clear; gridsize = 11; discount = 0.9; alpha_value = 0.2; alpha_action = 0.1; temp = 10;
    
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
    s.i = 1; s.j = 11;
    grid(1,11).start = s;
    s.i = 8; s.j = 2;
    grid(8,2).end = 1;
    
    %% create options
    options = create_options(gridsize);
    
    
    
    for trial=1:1000
        s.i = 1; s.j = 11; grid(s.i,s.j).start = s; % start state of agent
        current_option = options(1); % select root option to start
        tot_steps = 1;
        s_init = s;
        cum_reward = 0;
        for t=1:100;
            possible_options = get_possible_options(options, current_option, s);
            [indexes,action_probs] = get_action_probabilities(possible_options, current_option, temp, s);
            a_idx = select(indexes, action_probs);            
            if a_idx >4 % selected a new option (non-primitive)
                current_option = options(a_idx-3);
                tot_steps = 1;
                s_init = s;
                cum_reward = 0;
                %% take an action from the option, get pseudo reward, update option values and move
                possible_options = get_possible_options(options, current_option, s);
                [indexes,action_probs] = get_action_probabilities(possible_options, current_option, temp, s);
                a_idx = select(indexes, action_probs); % 1-4 idx
%                 action = create_a(a_idx);
%                 next_state = transition(grid, s, action);
%                 cum_reward = cum_reward + discount^(tot_steps-1)*pseudo_reward(s, action);
%                 delta = cum_reward + discount^tot_steps * current_option.V(next_state.i,next_state.j) - current_option.V(s_init.i, s_init.j);
%                 current_option.V(s_init.i, s_init.j) = current_option.V(s_init.i, s_init.j) + alpha_value*delta;
%                 current_option.W(s_init.i, s_init.j, action.idx) = current_option.W(s.i,s.j, action.idx) + alpha_action*delta;
%                 s = next_state; 
%                 if end_state(grid,s)
%                     break;
%                 end
            end
            action = create_a(a_idx);
            next_state = transition(grid, s, action);
            if strcmp(current_option.name,'root');
                cum_reward = 0;
                tot_steps = 1;
                s_init = s;
                cum_reward = cum_reward + discount^(tot_steps-1)*reward(s, action);
                delta = cum_reward + discount^tot_steps * current_option.V(next_state.i,next_state.j) - current_option.V(s_init.i, s_init.j);
                current_option.V(s_init.i, s_init.j) = current_option.V(s_init.i, s_init.j) + alpha_value*delta;
                current_option.W(s_init.i, s_init.j, action.idx) = current_option.W(s_init.i,s_init.j, action.idx) + alpha_action*delta;
            else
                pseudo = discount^(1-1)*pseudo_reward(s, action, current_option);
                delta = pseudo + discount^1 * current_option.V(next_state.i,next_state.j) - current_option.V(s.i, s.j);
                current_option.V(s.i, s.j) = current_option.V(s.i, s.j) + alpha_value*delta;
                current_option.W(s.i, s.j, action.idx) = current_option.W(s.i,s.j, action.idx) + alpha_action*delta;
                if is_sub_goal(current_option, next_state) == 1;
                    current_option = options(1); % set root option
                    cum_reward = cum_reward + discount^(tot_steps-1)*reward(s, action);
                    delta = cum_reward + discount^tot_steps * current_option.V(next_state.i,next_state.j) - current_option.V(s_init.i, s_init.j);
                    current_option.V(s_init.i, s_init.j) = current_option.V(s_init.i, s_init.j) + alpha_value*delta;
                    current_option.W(s_init.i, s_init.j, action.idx) = current_option.W(s_init.i,s_init.j, action.idx) + alpha_action*delta;  
                    
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
    elseif strcmp(action.name,'up')
        if allowed(grid,s.i-1,s.j,'up')
            s.i = s.i-1;
        end
    elseif strcmp(action.name,'down')
        if allowed(grid,s.i+1,s.j,'down')
            s.i = s.i+1;
        end
    end
end

function bool = allowed(grid, i,j, a)
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

function r = reward(s, action)
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

function options = create_options(gridsize)
    % options = root, plus 8 options to move towards different doors.
    for i=1:9;
        options(i).W = zeros(gridsize,gridsize,12);
        options(i).V = zeros(gridsize,gridsize);
       options(i).isRoot = 0;
        if i==1; 
            options(i).name = 'root'; 
            options(i).isRoot = 1;
        end
        if i==2; 
            options(i).name = 'room_upperleft_door_down'; 
            count =1;
            for j=1:5;
                for k=1:5;
                    s.i = j;
                    s.j = k;
                    options(i).start_states(count) = s;
                    count=count+1;
                end
            end
            s.i=3; s.j=6;
            options(i).start_states(end+1) = s;
            s.i=6; s.j=2;
            options(i).end_states(1) = s;
        end
        if i==3; 
            options(i).name = 'room_upperleft_door_right';
            count =1;
            for j=1:5;
                for k=1:5;
                    s.i = j;
                    s.j = k;
                    options(i).start_states(count) = s;
                    count=count+1;
                end
            end
            s.i=6; s.j=2;
            options(i).start_states(end+1) = s;
            s.i=3; s.j=6;
            options(i).end_states(1) = s;
        end
        if i==4; 
            options(i).name = 'room_upperright_door_left';
            count =1;
            for j=1:6;
                for k=7:11;
                    s.i = j;
                    s.j = k;
                    options(i).start_states(count) = s;
                    count=count+1;
                end
            end
            s.i=7; s.j=9;
            options(i).start_states(end+1) = s;
            s.i=3; s.j=6;
            options(i).end_states(1) = s;
        end
        if i==5; 
            options(i).name = 'room_upperright_door_down';
            count =1;
            for j=1:6;
                for k=7:11;
                    s.i = j;
                    s.j = k;
                    options(i).start_states(count) = s;
                    count=count+1;
                end
            end
            s.i=3; s.j=6;
            options(i).start_states(end+1) = s;
            s.i=7; s.j=9;
            options(i).end_states(1) = s;
        end
        if i==6; 
            options(i).name = 'room_lowerleft_door_up';
            count =1;
            for j=7:11;
                for k=1:5;
                    s.i = j;
                    s.j = k;
                    options(i).start_states(count) = s;
                    count=count+1;
                end
            end
            s.i=10; s.j=6;
            options(i).start_states(end+1) = s;
            s.i=6; s.j=2;
            options(i).end_states(1) = s;
        end
        if i==7; 
            options(i).name = 'room_lowerleft_door_right';
            count =1;
            for j=7:11;
                for k=1:5;
                    s.i = j;
                    s.j = k;
                    options(i).start_states(count) = s;
                    count=count+1;
                end
            end
            s.i=6; s.j=2;
            options(i).start_states(end+1) = s;
            s.i=10; s.j=6;
            options(i).end_states(1) = s;
        end
        if i==8; 
            options(i).name = 'room_lowerright_door_left';
            count =1;
            for j=7:11;
                for k=1:5;
                    s.i = j;
                    s.j = k;
                    options(i).start_states(count) = s;
                    count=count+1;
                end
            end
            s.i=7; s.j=9;
            options(i).start_states(end+1) = s;
            s.i=10; s.j=6;
            options(i).end_states(1) = s;
        end
        if i==9; 
            options(i).name = 'room_lowerright_door_up';
            count =1;
            for j=8:11;
                for k=7:11;
                    s.i = j;
                    s.j = k;
                    options(i).start_states(count) = s;
                    count=count+1;
                end
            end
            s.i=10; s.j=6;
            options(i).start_states(end+1) = s;
            s.i=7; s.j=9;
            options(i).end_states(1) = s;
        end
    end
end
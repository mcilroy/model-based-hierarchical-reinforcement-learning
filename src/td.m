%% td
function td()
    close all; clear; gridsize = 11; discount = 0.9; alpha_value = 0.2; alpha_action = 0.1; temp = 10;
    W = zeros(gridsize,gridsize,4);
    V = zeros(gridsize,gridsize);
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
    
    for trial=1:1000
        s.i = 1; s.j = 11;
        grid(i,j).start = s;
        for t=1:100;
            action_probs = exp(W(s.i,s.j,1:4)/temp)/(sum(exp(W(s.i,s.j,1:4)/temp)));
            action_probs = reshape(action_probs,[4,1]);
            a_idx = select(action_probs);
            action = create_a(a_idx);
            next_state = transition(grid, s,action);
            delta = reward(s,action) + discount * V(next_state.i,next_state.j) - V(s.i,s.j);
            V(s.i, s.j) = V(s.i,s.j) + alpha_value*delta;
            W(s.i, s.j, action.idx) = W(s.i,s.j, action.idx) + alpha_action*delta;
            s = next_state;
            if end_state(grid,s)
                break;
            end
        end
    end
    display_grid(grid,V)
end

function bool= end_state(grid,s)
    if grid(s.i,s.j).end == 1;
        bool =1;
    else
        bool = 0;
    end
end
function s = transition(grid, s,action)
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

function u = create_a(idx)
    if idx ==1;
        u.name = 'left';
    elseif idx ==2;
        u.name= 'right';
    elseif idx==3;
        u.name='up';
    elseif idx==4;
        u.name='down';
    end
    u.idx=idx;
end

function a = select(action_probs)
    choice = rand();
    low = 0;
    high = action_probs(1);
    for i=1:size(action_probs,1);
        if choice >= low && choice < high;
            a = i;
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

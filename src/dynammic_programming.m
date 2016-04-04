%dynamic programming example
function dynammic_programming()
    clear; close all;
    
    %% parameter declarations
    gridsize = 11;
    grid = setup_world(gridsize);
    
    %% policy iteration
    Q=zeros(gridsize, gridsize, 4); alpha=0.1; gamma=0.5; %starting state
    pi=ones(gridsize, gridsize);
    for trial=1:30
        %update Q function
        for i=1:gridsize;
            for j=1:gridsize;
                if allowed(grid, i, j)==0; continue; end
                if i==8 && j==2; continue; end
                s.i = i; s.j = j;
                for u=1:size(Q,3);
                    a = create_a(u);
                    next_state = transition(grid, s, a);
                    action_idx = pi(next_state.i, next_state.j);
                    Q(i,j,u) = reward(s, a) + gamma*Q(next_state.i, next_state.j, action_idx);
                end
            end
        end
        %update policy
        for i=1:gridsize;
            for j=1:gridsize;
                if allowed(grid, i,j)==0; continue; end
                if j==8 && j==2; continue; end
                [~,uidx]=max(Q(i,j,1:4)); 
                pi(i,j)=uidx;
            end
        end
    end
    Q
end

function idx = value_action(a)
    if strcmp(a.name,'left')
        idx=1;
    elseif strcmp(a.name,'right')
        idx=2;
    elseif strcmp(a.name,'up')
        idx=3;
    elseif strcmp(a.name,'down')
        idx=4;
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


function i = idx_s(s)
    if s.x == 1 && s.y == 4;
        i = 1;
    elseif s.x == 2 && s.y == 4;
        i =2;
    elseif s.x == 3&& s.y ==4;
        i=3;
    elseif s.x == 4 && s.y ==4
        i=4;
    elseif s.x == 5 && s.y == 4;
        i=5;
    elseif s.x ==3 && s.y ==3;
        i=6;
    elseif s.x ==3 && s.y == 2;
        i=7;
    elseif s.x ==3 && s.y ==1;
        i=8;
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

%% setup world
function grid = setup_world(gridsize)
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
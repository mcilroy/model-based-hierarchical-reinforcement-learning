%% creates a set of options
function options = create_options(gridsize)
    % options = root, plus 8 options to move towards different doors.
    for i=1:9;
        
        options(i).V = zeros(gridsize, gridsize);
        options(i).isRoot = 0;
        options(i).W = zeros(gridsize, gridsize, 4);
        if i==1; 
            options(i).name = 'root'; 
            options(i).isRoot = 1;
            options(i).W = zeros(gridsize, gridsize, 12);
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


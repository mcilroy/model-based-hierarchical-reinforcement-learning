%% modify search and depth amounts to see which values perform best
function hrl_parameter_tuning()
    close all; clear; 
    tic
    max_parameter_search_attempts=6; %10
    max_parameter_depth=6; %10
    max_runs=20; %100
    trial_total = 350; %1000
    time_length = 550; %500
    best_time=4; %4
    gridsize=11;
    learn_options_mode = 0;
    avg_moves = zeros(max_parameter_search_attempts, max_parameter_depth, trial_total);
    avg_options_taken_array = zeros(max_parameter_search_attempts, max_parameter_depth, trial_total);
    for search_attempt=1:max_parameter_search_attempts
        for depth=1:max_parameter_depth
            run_moves = zeros(1,trial_total);
            run_options_taken_array = zeros(1,trial_total);
            run_options = create_options(gridsize);
            for run=1:max_runs
                [options, moves, options_taken_array] = hrl_complex_model_based(depth, search_attempt, time_length, trial_total);
                run_moves(1,:) = run_moves(1,:) + moves(1,:);
                run_options_taken_array(1,:) = run_options_taken_array(1,:) + options_taken_array(1,:);
                for i=1:size(run_options,2)
                    run_options(i).W = run_options(i).W + options(i).W;
                    run_options(i).V = run_options(i).V + options(i).V;
                end
                sprintf('search:%d depth:%d run:%d',search_attempt, depth, run)
            end
            run_moves(1,:) = run_moves(1,:) / max_runs;
            avg_moves(search_attempt, depth, :) = run_moves(1,:);
            run_options_taken_array(1,:) = run_options_taken_array(1,:) / max_runs;
            avg_options_taken_array(search_attempt, depth, :) = run_options_taken_array(1,:);
            for i=1:size(run_options,2)
                run_options(i).W = run_options(i).W / max_runs;
                run_options(i).V = run_options(i).V / max_runs;
            end
            avg_run_options(search_attempt, depth).run_option = run_options;
            sprintf('search:%d depth:%d',search_attempt, depth)
        end
    end
    
    run_moves = zeros(1,trial_total);
    run_options_taken_array = zeros(1,trial_total);
    run_options = create_options(gridsize);
    depth=0;
    search_attempt=0;
    for run=1:max_runs
        [options, moves, options_taken_array] = hrl_complex_model_based(depth, search_attempt, time_length, trial_total);
        run_moves(1,:) = run_moves(1,:) + moves(1,:);
        run_options_taken_array(1,:) = run_options_taken_array(1,:) + options_taken_array(1,:);
        for i=1:size(run_options,2)
            run_options(i).W = run_options(i).W + options(i).W;
            run_options(i).V = run_options(i).V + options(i).V;
        end
        sprintf('run:%d',run)
    end
    run_moves(1,:) = run_moves(1,:) / max_runs;
    modelfree_avg_moves(:) = run_moves(1,:);
    run_options_taken_array(1,:) = run_options_taken_array(1,:) / max_runs;
    modelfree_avg_options_taken_array(:) = run_options_taken_array(1,:);
    for i=1:size(run_options,2)
        run_options(i).W = run_options(i).W / max_runs;
        run_options(i).V = run_options(i).V / max_runs;
    end
    modelfree_avg_run_options(1).run_option = run_options;
    
    save('../data/lookahead_avg_values2.mat', 'avg_moves', 'avg_options_taken_array', 'avg_run_options');
    save('../data/modelfree_avg_values2.mat', 'modelfree_avg_moves', 'modelfree_avg_options_taken_array', 'modelfree_avg_run_options');
    toc
end
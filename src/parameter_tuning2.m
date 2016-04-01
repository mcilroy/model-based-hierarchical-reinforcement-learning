function parameter_tuning()
    max_depth = 5;
    max_search_attempts =5;
    trial_total = 350;
    time_length = 550;
    [options, moves, options_taken_array] = hrl_complex_model_based(max_depth, max_search_attempts, time_length, trial_total)
    
end


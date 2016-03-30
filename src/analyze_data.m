function analyze_data()
    clear; close all;
    load('../data/lookahead_avg_values.mat');
    load('../data/modelfree_avg_values.mat');
    figure; hold on;
    legend_vals = cell(1, size(avg_moves,1)*size(avg_moves,2));
    counter = 1;
    for search=1:size(avg_moves,1);
        for depth=1:size(avg_moves,2);
            plot(reshape(avg_moves(search,depth,:),1,[]));
            legend_vals{1,counter} = sprintf('%d %d', search, depth);
            counter=counter+1;
        end
    end
    legend(legend_vals(1,:));
    
end
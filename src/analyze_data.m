function analyze_data()
    clear; close all;
    load('../data/lookahead_avg_values_working_model.mat');
    load('../data/modelfree_avg_values_working_model.mat');
    %avg_moves = avg_options_taken_array;
    figure; hold on;
    legend_vals = cell(1, size(avg_moves, 1));
    legend_vals2 = cell(1, size(avg_moves, 1));
    counter = 1;
    for search=1:size(avg_moves, 1);
        plot(reshape(avg_moves(search, 1, :), 1, []));
        %legend_vals{1,counter} = sprintf('%d %d', search, 1);
        legend_vals2{1, counter} = int2str(counter);
        counter=counter+1;
    end
    legend(legend_vals2(1,:));
    xlabel('trials') % x-axis label
    ylabel('time') % y-axis label
    title('search amount');
    
    figure; hold on;
    legend_vals = cell(1, size(avg_moves, 2));
    legend_vals2 = cell(1, size(avg_moves, 1));
    counter = 1;
    for depth=1:size(avg_moves, 2);
        plot(reshape(avg_moves(1, depth, :), 1, []));
        legend_vals{1,counter} = sprintf('%d %d', 1, depth);
        legend_vals2{1, counter} = int2str(counter);
        counter=counter+1;
    end
    legend(legend_vals2(1,:));
    xlabel('trials') % x-axis label
    ylabel('time') % y-axis label
    title('depth amount');
    
    
    figure; hold on;
    plot(modelfree_avg_moves(1,:));
    legend('model free');
    xlabel('trials') % x-axis label
    ylabel('time') % y-axis label
    
    bestsearch = 1;
    bestdepth = 1;
    bestindex = size(avg_moves(search,depth,:),3);
    for search=1:size(avg_moves, 1);
        for depth=1:size(avg_moves, 2);
            index = size(avg_moves(search,depth,:),3);
            for i = 1:size(avg_moves(search,depth,:),3);
                if avg_moves(search,depth,i) <= 17;
                    index = i;
                    break;
                end
            end
            if index < bestindex;
                bestindex = index;
                bestsearch=search;
                bestdepth=depth;
            end
        end
    end
    bestsearch
    bestdepth
end
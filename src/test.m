function blah()

    for i=1:10;
    end
    i;
    options(1).dude = 1;
    options= do(options,1,2);
    options(1).dude;

    for i=1:0
    i;
    end
    
    plot([1 2 3]);
    hold on;
    plot([4 5 6]);
    blah = cell(1,2);
    for i=1:2;
        blah{1,i} = sprintf('%d',i);
    end
    legend(blah);
end

function options = do(options,id,val)
options(id).dude = val;
end
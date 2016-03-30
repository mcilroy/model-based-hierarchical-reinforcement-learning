function blah()
options(1).dude = 1;
options= do(options,1,2);
options(1).dude
end

function options = do(options,id,val)
options(id).dude = val;
end
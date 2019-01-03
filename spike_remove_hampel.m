function dataws=spike_remove_hampel(data,step)

% data 1xn structude data (without time vector)

fn=fieldnames(data);
% disp('... SPIKES REMOVE')
for i=1:length(fn)

    raw=data.(char(fn(i)));
    for iste=1:step:length(raw)-step,
        raw(iste:iste+step-1)= hampel(1:step, raw(iste:iste+step-1));%... ,DX,T,'Adaptive',1
    end
    dataws.(char(fn(i)))=raw;                   
end

return

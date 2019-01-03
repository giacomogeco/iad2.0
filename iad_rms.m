function irms=iad_rms(data,station)

    data=rmfield(data,'tt');
        
    srms = structfun(@(x) ( rms(x) ), data, 'UniformOutput', false);
    
    srms =cell2mat(struct2cell(srms));
        
    irms=median(srms(station.sensors==1));
    
    

return
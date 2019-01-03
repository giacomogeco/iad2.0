function data=iad_read_ws_data(ConFileName,working_dir,slh,net,to,tend,f1,f2)

% global working_dir slh
% to=now-5/1440;
% tend=now;
% f1=[.1 .1 .1 .1];
% f2=[10 10 10 10];
% stz='mvt';
    

station=iad_read_ascii2cell([working_dir,slh,'conf_files',slh,net,slh,ConFileName]);

if isempty(f1),
    flag_filt=false;
else
    flag_filt=true;
end
channels=station.wschannels;
network=station.wsnetwork;

[data,w]=get_winston_data(char(station.wsstation),channels,network,to,tend,...
    station.wsserver,...
    station.wsport,...
    station.wslocation);


if isempty(data)
    disp('data is empty from get_winston_data')
    return
end

if length(fieldnames(data))~=length(station.wschannels)+1
    disp('Different or wrong channel names and/or number')
    data=[];
    return
end
% spike remove ............
if station.spikeremove(1)==1
    tmp=data.tt;data=rmfield(data,'tt');
    data=spike_remove_hampel(data,station.smp(1));
    data.tt=tmp;
    disp('spikes removed')
end
%...........................

if isempty(data),
    disp('WARNING isempty(data)')
    return
end

for i=1:length(station.wschannels),
    sconv=(station.advoltage/2^station.adbit)/station.gain(i);
    
    data.(char(station.wschannels(i)))=data.(char(station.wschannels(i)))*sconv;   %... UM
    
    if flag_filt,
        data.(char(station.wschannels(i)))=filtrax_nan(data.(char(station.wschannels(i))),...
            f1(i),f2(i),...
            station.smp(i));
    else
        data.(char(station.wschannels(i)))=data.(char(station.wschannels(i)));
%         -nanmean(data.(char(station.wschannels(i))));
    end
end

return


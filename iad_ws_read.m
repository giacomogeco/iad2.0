
clear all,
close all
clear function
clear global
warning off
%    function iad(net,namestz,ConfFileName)
% net='wyssen';namestz='no1';ConfFileName='conf_no1_2015_priv.txt';
% net='wyssen';namestz='no2';ConfFileName='conf_no2_2015_priv.txt';
% net='wyssen';namestz='gms';ConfFileName='conf_gms1_2015_priv.txt';
% net='wyssen';namestz='gm2';ConfFileName='conf_gms2_2015_priv.txt';
% net='wyssen';namestz='fru';ConfFileName='conf_fru_2015_priv.txt';
net='wyssen';namestz='dvs';ConfFileName='conf_dvs_2015_priv.txt';
% net='wyssen';namestz='prt';ConfFileName='conf_prt_2015_priv.txt';

save('/Users/giacomo/Documents/item/matlab/iad_av_detector/tmp/temp.mat','net','namestz','ConfFileName')
%%%%%%%%%% SET PATHS %%%%%%%%%%%
global working_dir slh
[working_dir,slh]=iad_setpath;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('/Users/giacomo/Documents/item/matlab/iad_av_detector/tmp/temp.mat')

station=iad_read_ascii2cell([working_dir,slh,'conf_files',slh,net,slh,ConfFileName]);

return
%%
t1=datenum(2016,1,1);
t2=datenum(2016,6,15);
th=t1:1/24:t2-1/24;
nh=length(th);


channels=station.wschannels;
network=station.wsnetwork;

ef=[];
smp=50;
nn=smp*3600;

for i=1:nh
    
    [data,w]=get_winston_data(char(station.wsstation),channels,network,th(i),th(i+1),...
    station.wsserver,...
    station.wsport,...
    station.wslocation);

    if isempty(data)
        ef=cat(1,ef,0);
    else
        ii=isnan(data.CH1);ii=sum(ii);

        ef=cat(1,ef,100-100*ii/nn);
    end
%     data=iad_read_ws_data(ConfFileName,working_dir,slh,net,th(i),th(i+1),[],[]);
    
    
end
    return
% function iad_noise_comput

% function iad(net,namestz,ConfFileName)
clear all,
% close all
clear function
clear global
warning off
%    function iad(net,namestz,ConfFileName)
% net='wyssen';namestz='no1';ConfFileName='conf_no1_2015_priv.txt';
% net='wyssen';namestz='no2';ConfFileName='conf_no2_2015_priv.txt';
% net='wyssen';namestz='gms';ConfFileName='conf_gms1_2015_priv.txt';
% net='wyssen';namestz='gm2';ConfFileName='conf_gms2_2015_priv.txt';
net='wyssen';namestz='fru';ConfFileName='conf_fru_2015_priv.txt';
% net='wyssen';namestz='fru';ConfFileName='conf_fru_2014.txt';
% net='wyssen';namestz='dvs';ConfFileName='conf_dvs_2015_priv.txt';
% net='wyssen';namestz='prt';ConfFileName='conf_prt_2015_priv.txt';

save('/Users/giacomo/Documents/item/matlab/iad_av_detector/tmp/temp.mat','net','namestz','ConfFileName')
%%%%%%%%%% SET PATHS %%%%%%%%%%%
global working_dir slh
[working_dir,slh]=iad_setpath;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('/Users/giacomo/Documents/item/matlab/iad_av_detector/tmp/temp.mat')

%% LOOP DI PROCESSING

t1=datenum(2016,4,1);
t2=datenum(2016,4,4);

% t1=datenum(2015,4,18,10,15,0);
% t2=datenum(2015,4,18,11,0,0);


t15=t1:15/1440:t2-15/1440;
n15=length(t15);

station=iad_read_ascii2cell([working_dir,slh,'conf_files',slh,net,slh,ConfFileName]);

avnoise=[];
for i=1:n15 

    to=t15(i);
    tend=to+15/1440;

    disp(['Loading ',upper(namestz),' data From:',datestr(to,0),' To: ',datestr(tend,0)])
    data=iad_read_ws_data(ConfFileName,working_dir,slh,net,to,tend,[],[]);

    
    data=rmfield(data,'tt');
    
    smtrx=sum(cell2mat(struct2cell(data)')');
    data = structfun(@(x) ( x(isfinite(smtrx)) ), data,'UniformOutput', false);
    
    
    
    dataf = structfun(@(x) ( filtrax(x,1,10,50)), data, 'UniformOutput', false);
    
    datan = structfun(@(x) ( mean(abs(x))), dataf, 'UniformOutput', false);
    
    avnoise=cat(2,avnoise,cell2mat(struct2cell(datan)));
    


end % while 1


return
     




% function iadINLtest(net,namestz,ConfFileName)



clear all,close all,clear function,
clear global
net='wyssen';
namestz='no1';
ConfFileName='conf_no1_2018_tst.txt';

offline=1;
warning off

save(['~/',namestz,'_temp.mat'],'net','namestz','ConfFileName','offline')
%%%%%%%%%% SET PATHS %%%%%%%%%%%
global working_dir slh net
[working_dir,slh]=iad_setpath;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(['~/',namestz,'_temp.mat'])
%%%%%%%%% SCEGLI IL TIPO DI FILES %%%%%%%%%%%%
offlinefiletypes={'gcf','mat','mseed',''};
offlinefiletypes=char(offlinefiletypes(4));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if offline
% 	cmdstring=['rm ',working_dir,'/tmp/*.mat'];
% 	system(cmdstring)
% end

%%%%%%%%%% STATIONS & PROCESSING PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
station=iad_read_ascii2cell([working_dir,slh,'conf_files',slh,net,slh,ConfFileName]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clock_offset=station.clockoffset;		%... offset (ore) between pc clock and UTC time 


istz=1;
on_start=1;
k_fault=0; %%%%%%%%%%%%%% inizializzazione del contatore di riprova di lettura del dato
tstart=floor((now-clock_offset/24)*86400/60)/86400*60+1/1440+station.lag/86400;
knodata=0;


% matfilepath='http://85.10.199.200/matfiles/';
%matfilepath='http://148.251.122.130/matfiles/';

%sandro 12122018
nowOld=now();
sendTestRunning=false;


FROM=input('FROM (yyyy-mm-dd_HH:MM:SS)','s');
TO=input('TO (yyyy-mm-dd_HH:MM:SS)','s');
FROM=datenum(FROM,'yyyy-mm-dd_HH:MM:SS');
TO=datenum(TO,'yyyy-mm-dd_HH:MM:SS');
nownames=FROM:900/86400:TO;

iNl=[];
cOh=[];
pRs=[];
nDs=[];
cNs=[];
tT=[];
tTd=[];

global station
%% LOOP DI PROCESSING
   

for i15=1:length(nownames)

    tend=nownames(i15);
    to=tend-15/1440;%-1/100/86400;      
    disp(['Loading ',upper(namestz),' data From:',datestr(to,0),' To: ',datestr(tend,0)])
    
    switch namestz
        case {'lvn','gm2','gms','gtn','rsp','hrm','lpb','rpc'}
            data=iad_readWYACserverdata(station,upper(namestz),to,tend);
        otherwise
            data=iad_read_ws_data(ConfFileName,working_dir,slh,net,to,tend,[],[]);
    end

    disp(['Loading ',upper(namestz),' data From:',datestr(to,0),' To: ',datestr(tend,0)])

    if isempty(data)
        eff=0;
    else
        data = structfun(@(x) ( x' ), data, 'UniformOutput', false);
%               data=iad_rmseed(tfiles,station);
        icut=data.tt>=to & data.tt<tend;
        data = structfun(@(x) ( x(icut) ), data, 'UniformOutput', false);

        for ich=1:length(station.wschannels)+1
            if ich==length(station.wschannels)+1
                tv=data.tt;
            else
                eval(['m',num2str(ich),'=','data.(char(station.wschannels(ich)));']);
%                         MD(ich,:)=data.(char(station.wschannels(ich)));
            end
        end
        eff=100*(sum(isfinite(m2))/(station.smp(1)))/60;
    end


    if eff<50
        disp(['--> data efficience: ',num2str(eff),'%'])
        continue
    end
   
    tt=data.tt;
    data=rmfield(data,'tt');
    M=cell2mat(struct2cell(data));
    
    disp(datestr(tt(end)))   
    tT=cat(1,tT,tt(1));
    disp('--> dts computation')
        % Processo Detection per VALANGHE naturali e controlled     
    Det_Av=iad_mcc_analysis_new(tt,M,station,slh,working_dir,'avalanches');     
    disp('--> INL computation')       
    iinnll=iadINLcomput(tt(end),station,ConfFileName);
    iNl=cat(1,iNl,iinnll);

    if size(Det_Av.data,1)==0
        cOh=cat(1,cOh,NaN);
        pRs=cat(1,pRs,NaN*zeros(1,length(station.smp)));
        nDs=cat(1,nDs,NaN);
        cNs=cat(1,cNs,NaN);
        tTd=cat(2,tTd,tt(1));
        disp('---> isempty Det_Av.data')
        continue
    else
        
        L=station.av_min_dets_length;
        DT=station.av_min_dets_continuity;
        [~,~,dts,Ev_Av,prsD]=iad_detections2events_new(DT,L,...
            Det_Av.data(:,1)',...   % time
            Det_Av.data(:,2),...    % pressure (Pa)
            Det_Av.status1,...
            Det_Av.data(:,7),...    % semblance (0-1)
            Det_Av.data(:,3),...    % backazimuth (???N)
            Det_Av.data(:,5),...    % app. vel. (m/s)
            Det_Av.data(:,9),...    % consistency (s)
            Det_Av.data(:,8),...    % pick frequency (Hz)
            Det_Av.data(:,10),...   % Explosion Index (Sandro 2017)   %%%%%%%%%%%%%Det_Av.data(:,10),...   % Explosion Index (Sandro 2017)
            station.av_shift);       
%             Ev_Av.data=zeros(1,16);
        if Ev_Av.data(1,1)>0    
            nDs=cat(1,nDs,size(Ev_Av.data,1));
            pRs=cat(1,pRs,prsD);
            cOh=cat(1,cOh,Ev_Av.data(:,7));
            cNs=cat(1,cNs,Ev_Av.data(:,9));
            tTd=cat(2,tTd,dts(1,:));
        else
            cOh=cat(1,cOh,NaN);
            pRs=cat(1,pRs,NaN*zeros(1,length(station.smp)));
            nDs=cat(1,nDs,NaN);
            cNs=cat(1,cNs,NaN);
            tTd=cat(2,tTd,tt(1));
            disp('---> isempty Ev_Av.data')
        end
    end
    disp('')

end % while 1
    
    


return


%%
clear all,close all
f1=load('IDAno1Sts20182019_0.mat');
f1.pRs(:,4)=0;f1.pRs(:,5)=0;
f2=load('IDAno1Sts20182019_1.mat');
f3=load('IDAno1Sts20182019_2.mat');

tTd=cat(2,f1.tTd,f2.tTd,f3.tTd);
tT=cat(1,f1.tT,f2.tT,f3.tT);tT=tT(1:end-1);
nDs=cat(1,f1.nDs,f2.nDs,f3.nDs);

iNl=cat(2,f1.iNl',f2.iNl',f3.iNl');
pRs=cat(2,f1.pRs',f2.pRs',f3.pRs');


% load IDA_NO1_Alerts
% T=datenum(T);

figure
ax(1)=subplot(311);plot(tT,iNl,'.-');grid on
hold on
% pp=plot(T,20*log10(pA),'pk');set(pp,'markerfacecolor','y')
ax(2)=subplot(312);plot(tT,nDs,'o');grid on

ax(3)=subplot(313);plot(tTd,pRs,'.');grid on


linkaxes(ax,'x')


%%
clear all,close all

first = datenum(2018,12,01);
last = datenum(2019,4,30);
period=15/1440;
bins = period*(floor(first/period):ceil(last/period));
Te=bins(1:end)';

DT=1.51;L=10;

% no1=load('IDAStatusNO120182019.mat');
no1=load('IDAStatusNO120182019v2.mat');
no1.iNl=no1.iNl';no1.pRs=no1.pRs';
j=find(no1.tT>datenum(2018,11,28));
no1.tT=no1.tT(j);
no1.nDs=no1.nDs(j);
no1.sCk=no1.sCk(j);
no1.iNl=no1.iNl(:,j);
no1.iNls=nanmedian(no1.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,no1.tTd,no1.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(no1.tT', bins); %... loc Nx1
loci(loci==0)=1;
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,NaN);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',no1.iNl(i,:),size(Te),@nansum,NaN);
end
no1.Time=Te;
no1.AcouticEnergy=Ea;
no1.DetectionRate=Ni;
no1.AcouticPressure=Pa;
no1.InfrasonicNoiseLevel=Inl;



rsp=load('IDAStatusRSP20182019v2.mat');
rsp.iNl=rsp.iNl';rsp.pRs=rsp.pRs';
j=find(rsp.tT>datenum(2018,12,6));
rsp.tT=rsp.tT(j);
rsp.nDs=rsp.nDs(j);
rsp.sCk=rsp.sCk(j);
rsp.iNl=rsp.iNl(:,j);
%>>>>> Remove outlayers
XX=1:size(rsp.iNl,2);
[rsp.iNl(1,:),I,Y0,LB,UB] = hampel(XX,rsp.iNl(1,:));
[rsp.iNl(2,:),I,Y0,LB,UB] = hampel(XX,rsp.iNl(2,:));
[rsp.iNl(3,:),I,Y0,LB,UB] = hampel(XX,rsp.iNl(3,:));
[rsp.iNl(4,:),I,Y0,LB,UB] = hampel(XX,rsp.iNl(4,:));
[rsp.iNl(5,:),I,Y0,LB,UB] = hampel(XX,rsp.iNl(5,:));
rsp.iNls=nanmedian(rsp.iNl);

[tMe,pRs,E]=iad_DtsGrouping(DT,L,rsp.tTd,rsp.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(rsp.tT', bins); %... loc Nx1
loci(loci==0)=1;
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,NaN);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',rsp.iNl(i,:),size(Te),@nansum,NaN);
end
rsp.Time=Te;
rsp.AcouticEnergy=Ea;
rsp.DetectionRate=Ni;
rsp.AcouticPressure=Pa;
rsp.InfrasonicNoiseLevel=Inl;





gtn=load('IDAStatusGTN20182019.mat');
gtn.iNl=gtn.iNl';gtn.pRs=gtn.pRs';
%>>>>> Remove outlayers
XX=1:size(gtn.iNl,2);
[gtn.iNl(1,:),I,Y0,LB,UB] = hampel(XX,gtn.iNl(1,:));
[gtn.iNl(2,:),I,Y0,LB,UB] = hampel(XX,gtn.iNl(2,:));
[gtn.iNl(3,:),I,Y0,LB,UB] = hampel(XX,gtn.iNl(3,:));
[gtn.iNl(4,:),I,Y0,LB,UB] = hampel(XX,gtn.iNl(4,:));
gtn.iNls=nanmedian(gtn.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,gtn.tTd,gtn.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(gtn.tT', bins); %... loc Nx1
loci(loci==0)=1;
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,NaN);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',gtn.iNl(i,:),size(Te),@nansum,NaN);
end
gtn.Time=Te;
gtn.AcouticEnergy=Ea;
gtn.DetectionRate=Ni;
gtn.AcouticPressure=Pa;
gtn.InfrasonicNoiseLevel=Inl;





gm2=load('IDAStatusGM220182019.mat');
gm2.iNl=gm2.iNl';gm2.pRs=gm2.pRs';
j=find(gm2.tT>datenum(2018,12,7));
gm2.tT=gm2.tT(j);
gm2.nDs=gm2.nDs(j);
gm2.iNl=gm2.iNl(:,j);
%>>>>> Remove outlayers
XX=1:size(gm2.iNl,2);
[gm2.iNl(1,:),I,Y0,LB,UB] = hampel(XX,gm2.iNl(1,:));
[gm2.iNl(2,:),I,Y0,LB,UB] = hampel(XX,gm2.iNl(2,:));
[gm2.iNl(3,:),I,Y0,LB,UB] = hampel(XX,gm2.iNl(3,:));
[gm2.iNl(4,:),I,Y0,LB,UB] = hampel(XX,gm2.iNl(4,:));
gm2.iNls=nanmedian(gm2.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,gm2.tTd,gm2.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(gm2.tT', bins); %... loc Nx1
loci(loci==0)=1;
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,NaN);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',gm2.iNl(i,:),size(Te),@nansum,NaN);
end
gm2.Time=Te;
gm2.AcouticEnergy=Ea;
gm2.DetectionRate=Ni;
gm2.AcouticPressure=Pa;
gm2.InfrasonicNoiseLevel=Inl;






% no2=load('IDAStatusNO220182019.mat'); % xcorr with sensor5
% no2=load('IDAStatusNO220182019.mat'); % xcorr without sensor5
no2=load('IDAStatusNO220182019v2.mat')
no2.iNl=no2.iNl';no2.pRs=no2.pRs';
% no2.iNl(5,:)=NaN;
no2.iNls=nanmedian(no2.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,no2.tTd,no2.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(no2.tT', bins); %... loc Nx1
loci(loci==0)=1;
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,NaN);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',no2.iNl(i,:),size(Te),@nansum,NaN);
end
no2.Time=Te;
no2.AcouticEnergy=Ea;
no2.DetectionRate=Ni;
no2.AcouticPressure=Pa;
no2.InfrasonicNoiseLevel=Inl;





gms=load('IDAStatusGMS20182019.mat');
gms.iNl=gms.iNl';gms.pRs=gms.pRs';
j=find(gms.tT>datenum(2018,12,7));
gms.tT=gms.tT(j);
gms.nDs=gms.nDs(j);
gms.iNl=gms.iNl(:,j);
gms.iNls=nanmedian(gms.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,gms.tTd,no2.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(gms.tT', bins); %... loc Nx1
loci(loci==0)=1;
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,NaN);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',gms.iNl(i,:),size(Te),@nansum,NaN);
end
gms.Time=Te;
gms.AcouticEnergy=Ea;
gms.DetectionRate=Ni;
gms.AcouticPressure=Pa;
gms.InfrasonicNoiseLevel=Inl;








prt=load('IDAStatusPRT20182019.mat');
prt.iNl=prt.iNl';prt.pRs=prt.pRs';
prt.iNls=nanmedian(prt.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,prt.tTd,prt.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(prt.tT', bins); %... loc Nx1
loci(loci==0)=1;
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,NaN);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',prt.iNl(i,:),size(Te),@nansum,NaN);
end
prt.Time=Te;
prt.AcouticEnergy=Ea;
prt.DetectionRate=Ni;
prt.AcouticPressure=Pa;
prt.InfrasonicNoiseLevel=Inl;






lvn=load('IDAStatusLVN20182019v2.mat');
lvn.iNl=lvn.iNl';lvn.pRs=lvn.pRs';
j=find(lvn.tT>datenum(2018,12,6));
lvn.tT=lvn.tT(j);
lvn.nDs=lvn.nDs(j);
lvn.sCk=lvn.sCk(j);
lvn.iNl=lvn.iNl(:,j);
%>>>>> Remove outlayers
XX=1:size(lvn.iNl,2);
[lvn.iNl(1,:),I,Y0,LB,UB] = hampel(XX,lvn.iNl(1,:));
[lvn.iNl(2,:),I,Y0,LB,UB] = hampel(XX,lvn.iNl(2,:));
[lvn.iNl(3,:),I,Y0,LB,UB] = hampel(XX,lvn.iNl(3,:));
[lvn.iNl(4,:),I,Y0,LB,UB] = hampel(XX,lvn.iNl(4,:));
lvn.iNls=nanmedian(lvn.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,lvn.tTd,lvn.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(lvn.tT', bins); %... loc Nx1
loci(loci==0)=1;
clear Ea Pa Inl
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,NaN);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',lvn.iNl(i,:),size(Te),@nansum,NaN);
end
lvn.Time=Te;
lvn.AcouticEnergy=Ea;
lvn.DetectionRate=Ni;
lvn.AcouticPressure=Pa;
lvn.InfrasonicNoiseLevel=Inl;




hrm=load('IDAStatusHRM20182019.mat');
hrm.iNl=hrm.iNl';hrm.pRs=hrm.pRs';
j=find(hrm.tT>datenum(2018,12,6));
hrm.tT=hrm.tT(j);
hrm.nDs=hrm.nDs(j);
hrm.iNl=hrm.iNl(:,j);
j=find(hrm.tT>datenum(2018,12,14,12,0,0) & hrm.tT<datenum(2018,12,17,12,0,0));
hrm.tT(j)=[];
hrm.nDs(j)=[];
hrm.iNl(:,j)=[];
% %>>>>> Remove outlayers
XX=1:size(hrm.iNl,2);
[hrm.iNl(1,:),I,Y0,LB,UB] = hampel(XX,hrm.iNl(1,:));
[hrm.iNl(2,:),I,Y0,LB,UB] = hampel(XX,hrm.iNl(2,:));
[hrm.iNl(3,:),I,Y0,LB,UB] = hampel(XX,hrm.iNl(3,:));
[hrm.iNl(4,:),I,Y0,LB,UB] = hampel(XX,hrm.iNl(4,:));
[hrm.iNl(5,:),I,Y0,LB,UB] = hampel(XX,hrm.iNl(5,:));
hrm.iNls=nanmedian(hrm.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,hrm.tTd,hrm.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(hrm.tT', bins); %... loc Nx1
loci(loci==0)=1;
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,NaN);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',hrm.iNl(i,:),size(Te),@nansum,NaN);
end
hrm.Time=Te;
hrm.AcouticEnergy=Ea;
hrm.DetectionRate=Ni;
hrm.AcouticPressure=Pa;
hrm.InfrasonicNoiseLevel=Inl;



% lpb=load('IDAStatusLPB20182019.mat');
lpb=load('IDAStatusLPB20182019v2.mat');
lpb.iNl=lpb.iNl';lpb.pRs=lpb.pRs';
j=find(lpb.tT>datenum(2018,12,6));
lpb.tT=lpb.tT(j);
lpb.nDs=lpb.nDs(j);
lpb.sCk=lpb.sCk(j);
lpb.iNl=lpb.iNl(:,j);
j=find(lpb.tT>datenum(2019,2,2) & lpb.tT<datenum(2019,2,6,12,0,0));
lpb.tT(j)=[];
lpb.nDs(j)=[];
lpb.sCk(j)=[];
lpb.iNl(:,j)=[];
lpb.iNls=nanmedian(lpb.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,lpb.tTd,lpb.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(lpb.tT', bins); %... loc Nx1
loci(loci==0)=1;
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,NaN);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',lpb.iNl(i,:),size(Te),@nansum,NaN);
end
lpb.Time=Te;
lpb.AcouticEnergy=Ea;
lpb.DetectionRate=Ni;
lpb.AcouticPressure=Pa;
lpb.InfrasonicNoiseLevel=Inl;



alerts=load('IDAsAlerts2018-2019');
ids={'no1', 'no2','lvn', ...
    'gtn','gm2','gms','prt',...
    'rsp','lpb','hrm'};
sitename={'Grasdalen','Indreesdalen','Lavangsdalen',...
    'Guttannen','Reckingen','Blitzingen','Quinto',...
    'Ross Peak','Loop Brook', 'Hermit'}

% ids={'no1', 'no2','lvn', ...
%     'rsp','lpb'};
% sitename={'Grasdalen','Indreesdalen','Lavangsdalen',...
%     'Ross Peak','Loop Brook'}

dBalerts=[];
%%
%... INL
figure
for i=1:length(ids)
    time=datenum(alerts.T.(char(ids(i))));
    for ii=1:length(time)
        j=find(eval([char(ids(i)),'.tT>time(ii)']));
        eval([char(ids(i)),'.aiNl(ii)=',char(ids(i)),'.iNls(j(1))']);
        dBalerts=cat(1,dBalerts,eval([char(ids(i)),'.iNls(j(1))']));
    end
    
    ax(i)=subplot(length(ids),1,i);plot(eval([char(ids(i)),'.tT']),eval([char(ids(i)),'.iNls']),'.-');grid on,hold on
    legend(char(sitename(i)))
    stem(datenum(alerts.T.(char(ids(i)))),70+zeros(size(alerts.T.(char(ids(i))),1)),'r')
end
set(ax,'ylim',[-5 70])
linkaxes(ax,'xy') 

% % SCK
% figure
% for i=1:length(ids)
%     j=eval(['find(',char(ids(i)),'.iNls<15)']);
%     ax(i)=subplot(length(ids),1,i);plot(eval([char(ids(i)),'.tT(j)']),eval([char(ids(i)),'.sCk(j)']),'.');grid on,hold on
%     legend(char(sitename(i)))
%     stem(datenum(alerts.T.(char(ids(i)))),-10+zeros(size(alerts.T.(char(ids(i))),1)),'r')
% end
% set(ax,'ylim',[-10 10])
% linkaxes(ax,'xy')  
%%
% DTS
clear ax
psiz=3;
clr=colormap(jet);
clr=clr(1:floor(size(clr,1)/length(ids)):end,:);
figure
ax(1)=axes;set(ax(1),'pos',[.1 .55 .55 .35])
ax(2)=axes;set(ax(2),'pos',[.7 .55 .2 .35])
ax(3)=axes;set(ax(3),'pos',[.1 .1 .55 .35])
ax(4)=axes;set(ax(4),'pos',[.7 .1 .2 .35])


arg=-5:70;
rrg=0:50;
for i=1:length(ids)
%     ax(i)=subplot(length(ids),1,i);
    m=eval([char(ids(i)),'.iNls']);
    t=eval([char(ids(i)),'.tT']);
    p=plot(ax(3),eval([char(ids(i)),'.tT']),eval([char(ids(i)),'.nDs']),'o-k');grid(ax(3),'on'),hold(ax(3),'on')
    set(p,'markerfacecolor',clr(i,:),'markersize',psiz)
    p=plot(ax(1),eval([char(ids(i)),'.tT']),eval([char(ids(i)),'.iNls.*',char(ids(i)),'.nDs']),'o-k');grid(ax(1),'on'),hold(ax(1),'on')
    set(p,'markerfacecolor',clr(i,:),'markersize',psiz)
    
    [aa,cc]=hist(eval([char(ids(i)),'.iNls']),arg);
    [dd,ee]=hist(eval([char(ids(i)),'.nDs']),rrg);
    
    p=plot(ax(2),aa,arg,'o-k');grid(ax(2),'on'),hold(ax(2),'on')
    set(p,'markerfacecolor',clr(i,:),'markersize',psiz)
    p=plot(ax(4),dd,rrg,'o-k');grid(ax(4),'on'),hold(ax(4),'on')
    set(p,'markerfacecolor',clr(i,:),'markersize',psiz)
%     legend(char(sitename(i)))
%     stem(datenum(alerts.T.(char(ids(i)))),50+zeros(size(alerts.T.(char(ids(i))),1)),'r')
end

set([ax(1) ax(2)],'ylim',[-5 70])
set([ax(3) ax(4)],'ylim',[0 50])

% set(ax(4),'ylim',[0 50])

% linkaxes([ax(1) ax(2)],'x')
% legend(sitename)

%%
% close all
% psiz=6;
% clr=colormap(jet);
% clr=clr(1:floor(size(clr,1)/length(ids)):end,:);
% figure
% for i=1:2%length(ids)
% %     j=eval(['find(',char(ids(i)),'.iNls<15)']);
% %     ax(i)=subplot(length(ids),1,i);
%     p=plot(eval([char(ids(i)),'.tT']),eval(['smooth(',char(ids(i)),'.nDs,','1440)']),'ok');grid on,hold on
%     set(p,'markerfacecolor',clr(i,:),'markersize',psiz),hold on
% %     legend(char(sitename(i)))
% %     stem(datenum(alerts.T.(char(ids(i)))),10+zeros(size(alerts.T.(char(ids(i))),1)),'r')
% end
% set(gca,'ylim',[0 15])
% % linkaxes(ax,'xy')  
% legend(sitename)

%%
close all

first = datenum(2018,12,01);
last = datenum(2019,4,30);
period=1;
bins = period*(floor(first/period):ceil(last/period));
Te=bins(1:end)';

psiz=6;
clr=colormap(jet);
clr=clr(1:floor(size(clr,1)/length(ids)):end,:);
figure

for i=1:length(ids)
% 
% 
    [Ni, loci] = histc(eval([char(ids(i)),'.tT']), bins); %... loc Nx1
    loci(loci==0)=1;
%     Ni(isnan(Ni))=0;
    aa=eval([char(ids(i)),'.nDs']);
    aa(isnan(aa))=0;
    dtr = accumarray(loci,aa,size(Te),@nansum,NaN);
    aa=eval([char(ids(i)),'.iNls']);
    inl =  accumarray(loci,aa,size(Te),@mean,NaN);
    
    eval([char(ids(i)),'.DTR=dtr']);
    eval([char(ids(i)),'.INL=inl']);
    
    p=plot(Te,dtr,'ok');grid on,hold on
%     set(p,'color',clr(i,:))
    set(p,'markerfacecolor',clr(i,:),'markersize',psiz),hold on
    
    rate(i)=nanmean(dtr);
% 
% [Nw, locw] = histc(t', bins); %... loc Nx1
% locw(locw==0)=1;
% ampw = accumarray(locw',V2',size(Te),@mean,NaN);
% wdw = accumarray(locw',D1',size(Te),@mean,NaN);

% figure,plot(ampi,ampw,'.')
end

legend(sitename)



%%
rng=0:5:70;
for i=1:length(rng)-1
    
%     j=find(rsp.iNl(2,:)>=rng(i) & rsp.iNl(2,:)<rng(i+1));
    j=find(rsp.iNls>=rng(i) & rsp.iNls<rng(i+1));
    if isempty(j)
        rsp.nDsh(i)=0;
    else
        rsp.nDsh(i)=nansum(rsp.nDs(j));
    end
    
%     j=find(gtn.iNl(2,:)>=rng(i) & gtn.iNl(2,:)<rng(i+1));
    j=find(gtn.iNls>=rng(i) & gtn.iNls<rng(i+1));
    if isempty(j)
        gtn.nDsh(i)=0;
    else
        gtn.nDsh(i)=nansum(gtn.nDs(j));
    end
        
%     j=find(no1.iNl(2,:)>=rng(i) & no1.iNl(2,:)<rng(i+1));
    j=find(no1.iNls>=rng(i) & no1.iNls<rng(i+1));
    if isempty(j)
        no1.nDsh(i)=0;
    else
        no1.nDsh(i)=nansum(no1.nDs(j));
    end
    
    
%     j=find(no2.iNl(2,:)>=rng(i) & no2.iNl(2,:)<rng(i+1));
    j=find(no2.iNls>=rng(i) & no2.iNls<rng(i+1));
    if isempty(j)
        no2.nDsh(i)=0;
    else
        no2.nDsh(i)=nansum(no2.nDs(j));
    end
    
%     j=find(lvn.iNl(2,:)>=rng(i) & lvn.iNl(2,:)<rng(i+1));
    j=find(lvn.iNls>=rng(i) & lvn.iNls<rng(i+1));
    if isempty(j)
        lvn.nDsh(i)=NaN;
    else
        lvn.nDsh(i)=nansum(lvn.nDs(j));
    end
    
%     j=find(hrm.iNl(2,:)>=rng(i) & hrm.iNl(2,:)<rng(i+1));
    j=find(hrm.iNls>=rng(i) & hrm.iNls<rng(i+1));
    if isempty(j)
        hrm.nDsh(i)=0;
    else
        hrm.nDsh(i)=nansum(hrm.nDs(j));
    end
    
    j=find(gm2.iNls>=rng(i) & gm2.iNls<rng(i+1));
    if isempty(j)
        gm2.nDsh(i)=0;
    else
        gm2.nDsh(i)=nansum(gm2.nDs(j));
    end
    j=find(gms.iNls>=rng(i) & gms.iNls<rng(i+1));
    if isempty(j)
        gms.nDsh(i)=0;
    else
        gms.nDsh(i)=nansum(gms.nDs(j));
    end
    
    j=find(prt.iNls>=rng(i) & prt.iNls<rng(i+1));
    if isempty(j)
        prt.nDsh(i)=0;
    else
        prt.nDsh(i)=nansum(prt.nDs(j));
    end
    
    j=find(lpb.iNls>=rng(i) & lpb.iNls<rng(i+1));
    if isempty(j)
        lpb.nDsh(i)=0;
    else
        lpb.nDsh(i)=nansum(lpb.nDs(j));
    end
    
    
end

% [Nrsp,bin]=hist(rsp.iNl(1,j),rng);
% [Ngtn,bin]=hist(gtn.iNl(:,2),rng);

psiz=10;
clr=colormap(jet);
clr=clr(1:floor(size(clr,1)/length(ids)):end,:);
figure
for i=1:length(ids)
    p=semilogy(rng(1:end-1),(eval([char(ids(i)),'.nDsh'])),'ok');
    set(p,'markerfacecolor',clr(i,:),'markersize',psiz),hold on
end
%     p=semilogy(rng(1:end-1),no2.nDsh,'ok');set(p,'markerfacecolor','c','markersize',psiz)
%     p=semilogy(rng(1:end-1),lvn.nDsh,'ok');set(p,'markerfacecolor','k','markersize',psiz)
%     p=semilogy(rng(1:end-1),gtn.nDsh,'ok');set(p,'markerfacecolor','r','markersize',psiz)
%     p=semilogy(rng(1:end-1),gm2.nDsh,'ok');set(p,'markerfacecolor','w','markersize',psiz)
%     p=semilogy(rng(1:end-1),rsp.nDsh,'ok');set(p,'markerfacecolor','b','markersize',psiz)
%     p=semilogy(rng(1:end-1),hrm.nDsh,'ok');set(p,'markerfacecolor','m','markersize',psiz)

legend(sitename)

[NN,BB]=hist(dBalerts,rng);
pp=bar(rng,(NN));set(pp,'FaceAlpha',.2)

set(gca,'FontSize',14,'xlim',[rng(1) rng(end-1)])
set(gcf,'Color','w')
xlabel('INL (dB rel to GLW)')
ylabel('#detections')
grid
axis square

%%
oPrn=[];
for i=1:length(ids)    
    j=(eval([char(ids(i)),'.iNls>25']));
%     eval([char(ids(i)),'.aiNl(ii)=',char(ids(i)),'.iNls(j(1))']);
    oPrn=cat(1,oPrn,100*sum(j)/length(eval([char(ids(i)),'.iNls'])));       
end


%%

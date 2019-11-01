clear all,close all

global E FROM

% wpath='http://85.10.199.200/DETECTIONS/';
wpath='http://148.251.122.130/DETECTIONS/';

FROM=input('FROM (yyyy-mm-dd_HH)','s');
TO=input('TO (yyyy-mm-dd_HH)','s');
FROM=datenum(FROM,'yyyy-mm-dd_HH');
T0=datenum(TO,'yyyy-mm-dd_HH');
nownames=FROM:1/24:T0;
nfile=length(nownames);
stz='hrm';

prs=[];bkz=[];bkzsd=[];vel=[];velsd=[];smb=[];
fpk=[];cns=[];time=[];
    
if nfile>0
    data=[];
    for i=1:nfile
        filename=[stz,'_',datestr(nownames(i),'yyyymmdd_HHMMSS'),'.csv'];
        file=[wpath,stz,'_Det_Av/',stz,'_',datestr(nownames(i),'yyyymmdd'),'/',...
            filename];
        disp(file)
        try
            urlwrite(file,'pippo.csv');
            data=cat(1,data,textread('pippo.csv'));
        catch
            disp(['...file not found'])
            continue
        end
        
    end

    for i=1:size(data,2),
        eval(['VarName',num2str(i),'=data(:,',num2str(i),');'])
    end
    [tx,j]=unique(VarName1);
    tt=tx;
    time=cat(1,time,tt);
    prs=cat(1,prs,VarName2(j));
    bkz=cat(1,bkz,VarName3(j));
    bkzsd=cat(1,bkzsd,VarName4(j));
    vel=cat(1,vel,VarName5(j));
    velsd=cat(1,velsd,VarName6(j));
    smb=cat(1,smb,VarName7(j));
    fpk=cat(1,fpk,VarName8(j));
    cns=cat(1,cns,VarName9(j));
end
% j=bkz==0;
% bkz(j)='';prs(j)='';time(j)='';vel(j)='';smb(j)='';cns(j)='';fpk(j)='';bkzsd(j)='';

% j=bkz>89 & bkz<150 & vel<450;
% bkz=bkz(j);prs=prs(j);time=time(j);vel=vel(j);smb=smb(j);cns=cns(j);fpk=fpk(j);bkzsd=bkzsd(j);
% 
% j=bkzsd>0.53;
% bkz(j)='';prs(j)='';time(j)='';vel(j)='';smb(j)='';cns(j)='';fpk(j)='';bkzsd(j)='';
% save ida_natural time prs bkz vel smb vel cns velsd bkzsd fpk Ev_Nav

%%

station=iad_read_ascii2cell(['/Users/giacomo/softwarecode/iad2.0/conf_files/wyssen/conf_','hrm','_2018_tst.txt']);
% station=iad_read_ascii2cell(['/Users/giacomo/Documents/item/matlab/iad_av_detector/conf_files/wyssen/conf_','gms2','_2016_priv.txt']);
% station=iad_read_ascii2cell(['/Users/giacomo/Documents/item/matlab/iad_av_detector/conf_files/lgs/conf_','gry','_2017_priv.txt']);
% station=iad_read_ascii2cell(['/Users/giacomo/Documents/item/matlab/iad_av_detector/conf_files/wyssen/conf_','no1','_2017_priv.txt']);
% station=iad_read_ascii2cell(['/Users/giacomo/Documents/item/matlab/iad_av_detector/conf_files/wyssen/conf_','prt','_2016_priv.txt']);

% station=iad_read_ascii2cell(['/Users/giacomo/Documents/item/matlab/iad_av_detector/conf_files/wyssen/conf_','rp1','_2016_artillery.txt']);

% station=iad_read_ascii2cell(['/Users/giacomo/Documents/item/matlab/iad_av_detector/conf_files/wyssen/conf_','no2','_2016_priv.txt']);

% station=iad_read_ascii2cell(['/Users/giacomo/Documents/item/matlab/iad_av_detector/conf_files/wyssen/conf_','no3','_2016_priv.txt']);

% station=iad_read_ascii2cell(['/Users/giacomo/Documents/item/matlab/iad_av_detector/conf_files/wyssen/conf_','no1','_2017_priv.txt']);
DT=station.av_min_dets_continuity;
L=station.av_min_dets_length;%L=30
% station.av_min_dets_length=3;
% station.av_min_dets_continuity=6*station.av_shift*station.av_resampling+0.05;


% [detections,EVENTS,dts,Ev_Nav]=iad_detections2events_bis(DT,L,time',prs,smb,bkz,vel,cns,fpk,.5);
[detections,EVENTS,dts,Ev_Nav]=iad_detections2events(DT,L,time',prs,smb,bkz,vel,cns,fpk,.5);
%%
% DT=station.av_min_dets_continuity;
% L=station.av_min_dets_length;
% [detections,EVENTS,dts,Ev_Ex]=iad_detections2events(DT,L,time',prs,smb,bkz,vel,cns,fpk,2);

% [detections,EVENTS,dts,evts]=iad_detections2events(DT,L,txx,prs,cc,azz,slw,rs,Fp,shift)

%%
station.nav_minpressure(1)=0;
station.nav_mindur(1)=10;
iprobabilistic=find(Ev_Nav.data(:,3)>station.nav_mindur(1) & ... %... station.nav_mindur ???????????????????????????????
                Ev_Nav.data(:,6)>station.nav_minpressure(1) & ...
                Ev_Nav.data(:,9)<10000 & ...
                Ev_Nav.data(:,11)<station.nav_maxvel(1) & ...
                Ev_Nav.data(:,10)<station.nav_meanvel(1) & ...
                Ev_Nav.data(:,19)<0)

ideterministic=find(Ev_Nav.data(:,3)>station.nav_mindur(2) & ... %... station.nav_mindur ???????????????????????????????
        Ev_Nav.data(:,6)>station.nav_minpressure(2) & ...
        Ev_Nav.data(:,9)<10000 & ...
        Ev_Nav.data(:,11)<station.nav_maxvel(2) & ...
        Ev_Nav.data(:,10)<station.nav_meanvel(2) & ...
        Ev_Nav.data(:,19)<-.5)
                
E.Ev_Nav=Ev_Nav;E.Ev_Ex.data='';E.Ev_Cav.data='';
%%
% close all

FIG=figure;
set(FIG,'color','w')

% timeS=86400*(time-T0);

timeS=86400*(detections.time-FROM);
timS=86400*(time-FROM);

axx(1)=subplot(411);set(gca,'fontSize',14)

p=plot(timS,prs,'.');set(p,'color',[.5 .5 .5])
hold on
plot(timeS,detections.pressure,'.k'),grid on
% hold on

 
p=plot(86400*(Ev_Nav.data(iprobabilistic,1)-FROM),Ev_Nav.data(iprobabilistic,6),'sb');
set(p,'markersize',8,'markerfacecolor','k')
if ~isempty(iprobabilistic)
    for i=1:length(iprobabilistic),
        line([86400*(Ev_Nav.data(iprobabilistic(i),1)-FROM),86400*(Ev_Nav.data(iprobabilistic(i),2)-FROM)],...
            [0,0],'color','b','Linewidth',2)
    end
end

p=plot(86400*(Ev_Nav.data(ideterministic,1)-FROM),Ev_Nav.data(ideterministic,6),'or');
set(p,'markersize',10,'markerfacecolor','k')
if ~isempty(ideterministic)
    for i=1:length(ideterministic),
        line([86400*(Ev_Nav.data(ideterministic(i),1)-FROM),86400*(Ev_Nav.data(ideterministic(i),2)-FROM)],...
            [0,0],'color','r','Linewidth',2)
    end
end

axx(2)=subplot(412);set(gca,'fontSize',14)


p=plot(timS,bkz,'.');set(p,'color',[.5 .5 .5])
hold on
plot(timeS,detections.backazimuth,'.b'),grid on
hold on
p=plot(86400*(Ev_Nav.data(iprobabilistic,1)-FROM),Ev_Nav.data(iprobabilistic,8),'sb');
set(p,'markersize',8,'markerfacecolor','k')


p=plot(86400*(Ev_Nav.data(iprobabilistic,1)-FROM),Ev_Nav.data(iprobabilistic,8),'sb');
set(p,'markersize',8,'markerfacecolor','k')
if ~isempty(iprobabilistic)
    for i=1:length(iprobabilistic),
        line([86400*(Ev_Nav.data(iprobabilistic(i),1)-FROM),86400*(Ev_Nav.data(iprobabilistic(i),2)-FROM)],...
            [0,0],'color','b','Linewidth',2)
    end
end

p=plot(86400*(Ev_Nav.data(ideterministic,1)-FROM),Ev_Nav.data(ideterministic,8),'or');
set(p,'markersize',10,'markerfacecolor','k')
if ~isempty(ideterministic)
    for i=1:length(ideterministic),
        line([86400*(Ev_Nav.data(ideterministic(i),1)-FROM),86400*(Ev_Nav.data(ideterministic(i),2)-FROM)],...
            [0,0],'color','r','Linewidth',2)
    end
end


axx(3)=subplot(413);set(gca,'fontSize',14)

p=plot(timS,vel,'.');set(p,'color',[.5 .5 .5])
hold on
plot(timeS,detections.velocity,'.r'),grid on


axx(4)=subplot(414);set(gca,'fontSize',14)
p=plot(86400*(Ev_Nav.data(:,1)-FROM),Ev_Nav.data(:,19),'sk');set(p,'color','r')
set(axx(4),'ylim',[-1 0]),grid on


dcm_obj = datacursormode(FIG);
set(dcm_obj, 'UpdateFcn',{@iad_plot_results_callback,E,FROM},'DisplayStyle','window')

set(gca,'xlim',[86400*(FROM-FROM) 86400*(T0-FROM+1/24)])

h = zoom;
set(h,'ActionPostCallback',{@iad_setcurrLIM,FROM,axx});
set(h,'Enable','on');
iad_setcurrLIM([],[],FROM,axx)


return

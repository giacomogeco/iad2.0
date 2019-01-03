clear all,close all

global E FROM

wpath='http://85.10.199.200/DETECTIONS/';
FROM=input('FROM (yyyy-mm-dd_HH)','s');
TO=input('TO (yyyy-mm-dd_HH)','s');
FROM=datenum(FROM,'yyyy-mm-dd_HH');
T0=datenum(TO,'yyyy-mm-dd_HH');
nownames=FROM:1/24:T0;
nfile=length(nownames);
% stz={'rp1','no1','no2','no3','fru','gm2','gms','prt'};
stz={'gm2','gms'};
nstz=length(stz);

for istz=1:nstz

    prs=[];bkz=[];bkzsd=[];vel=[];velsd=[];smb=[];
    fpk=[];cns=[];time=[];

    if nfile>0
        data=[];
        for i=1:nfile
            filename=[char(stz(istz)),'_',datestr(nownames(i),'yyyymmdd_HHMMSS'),'.csv'];
            file=[wpath,char(stz(istz)),'_Det_Av/',char(stz(istz)),'_',datestr(nownames(i),'yyyymmdd'),'/',...
                filename];
            disp(file)
            try
                urlwrite(file,'pippo.csv');
                data=cat(1,data,textread('pippo.csv'));
            catch
                disp(['...file not founded'])
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
    dts.([char(stz(istz))]).time=time;
    dts.([char(stz(istz))]).prs=prs;
    dts.([char(stz(istz))]).bkz=bkz;
    dts.([char(stz(istz))]).bkzsd=bkzsd;
    dts.([char(stz(istz))]).vel=vel;
    dts.([char(stz(istz))]).velsd=velsd;
    dts.([char(stz(istz))]).smb=smb;
    dts.([char(stz(istz))]).fpk=fpk;
    dts.([char(stz(istz))]).cns=cns;
    
    try
%         station=iad_read_ascii2cell(['/Users/giacomo/Documents/item/matlab/iad_av_detector/conf_files/wyssen/conf_',stz,'_2016.txt']);
%         DT=station.av_min_dets_continuity;
%         L=station.av_min_dets_length;
% 
%         [detections,EVENTS,dts,Ev_Nav]=iad_detections2events(DT,L,dts.([char(stz(istz))]).time',...
%             dts.([char(stz(istz))]).prs,...
%             dts.([char(stz(istz))]).smb,...
%             dts.([char(stz(istz))]).bkz,...
%             dts.([char(stz(istz))]).vel,...
%             dts.([char(stz(istz))]).cns,...
%             dts.([char(stz(istz))]).fpk,...
%             .5);


% 
%         iprobabilistic=find(Ev_Nav.data(:,3)>station.nav_mindur(1) & ... %... station.nav_mindur ???????????????????????????????
%                     Ev_Nav.data(:,6)>station.nav_minpressure(1) & ...
%                     Ev_Nav.data(:,9)<10000 & ...
%                     Ev_Nav.data(:,11)<station.nav_maxvel(1) & ...
%                     Ev_Nav.data(:,12).*Ev_Nav.data(:,3)<station.nav_maxveltrend(1) & ...
%                     Ev_Nav.data(:,10)<station.nav_meanvel(1) & ...
%                     Ev_Nav.data(:,10)>station.nav_minvel(1));
% 
%         ideterministic=find(Ev_Nav.data(:,3)>station.nav_mindur(2) & ... %... station.nav_mindur ???????????????????????????????
%                     Ev_Nav.data(:,6)>station.nav_minpressure(2) & ...
%                     Ev_Nav.data(:,9)<10000 & ...
%                     Ev_Nav.data(:,11)<station.nav_maxvel(2) & ...
%                     Ev_Nav.data(:,12).*Ev_Nav.data(:,3)<station.nav_maxveltrend(2) & ...
%                     Ev_Nav.data(:,10)<station.nav_meanvel(2) & ...
%                     Ev_Nav.data(:,10)>station.nav_minvel(2));
% 
%         Ev_Nav.([char(stz(istz))])=Ev_Nav;

    end
    
end

return

%%
DT=3.01;
L=40;
[dtsgms,EGMS,dtsgms,Ev_Nav_Gms]=iad_detections2events(DT,L,dts.gms.time',...
             dts.gms.prs,...
             dts.gms.smb,...
            dts.gms.bkz,...
            dts.gms.vel,...
             dts.gms.cns,...
             dts.gms.fpk,...
             .5);
[dtsgm2,EGM2,dtsgm2,Ev_Nav_Gm2]=iad_detections2events(DT,L,dts.gm2.time',...
             dts.gm2.prs,...
             dts.gm2.smb,...
            dts.gm2.bkz,...
            dts.gm2.vel,...
             dts.gm2.cns,...
             dts.gm2.fpk,...
             .5);
%%
t1=datenum(2016,12,1);
t2=datenum(2017,5,1);

period=24/24;
first = t1;
last = t2;
bins = period*(floor(first/period):ceil(last/period));

[nev, lev] = histc(Ev_Nav_Gms.data(:,1), bins);
Ngms=nev(1:end-1)';
Tgms=bins(1:end-1);
% Pmean = accumarray(loc',E.maxpressure')./accumarray(loc',1); % faster
% than accumaray/mean
[nev, lev] = histc(Ev_Nav_Gm2.data(:,1), bins);
Ngm2=nev(1:end-1)';
Tgm2=bins(1:end-1);
figure;

axx(1)=subplot(211);set(gca,'fontSize',14)
p=plot(Tgms,Ngms,'ok');
set(p,'markersize',10,'markerfacecolor','r')

axx(2)=subplot(212);set(gca,'fontSize',14)
p=plot(Tgm2,Ngm2,'ok');
set(p,'markersize',10,'markerfacecolor','b')


%%

E.Ev_Nav=Ev_Nav;E.Ev_Ex.data='';E.Ev_Cav.data='';
%%
% close all

FIG=figure;
set(FIG,'color','w')

% timeS=86400*(time-T0);

timeS=86400*(detections.time-FROM);
timS=86400*(time-FROM);

axx(1)=subplot(311);set(gca,'fontSize',14)

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

axx(2)=subplot(312);set(gca,'fontSize',14)

% OBSERVATIONS %%%%%%%%%%%%%%%%%%%
% [dobs,a,b]=xlsread('/Users/giacomo/Documents/davos/eventi_2015-2016_validazione/ValidationAnalysis/goms/goms_obs.xls');
% rng=10;
% % AZo=[111 260 257 300 277 316 325 115];
% AZo=cell2mat(b(2:end,3));
% To=datenum(b(2:end,1));
% Te=datenum(b(2:end,2));
% % To=[datenum(2016,2,23,8,0,0),datenum(2016,2,23,12,0,0),datenum(2016,2,24,7,0,0),datenum(2016,2,24,13,0,0),datenum(2016,2,26,6,0,0),...
% %     datenum(2016,2,27,0,0,0),datenum(2016,2,28,12,0,0),datenum(2016,3,1,14,0,0)];
% % Te=[datenum(2016,2,23,10,0,0),datenum(2016,2,24,7,0,0),datenum(2016,2,24,9,0,0),datenum(2016,2,27,7,0,0),datenum(2016,2,27,7,0,0),...
% %     datenum(2016,2,28,0,0,0),datenum(2016,2,28,15,0,0),datenum(2016,3,2,7,0,0)]; 
% To=86400*(To-FROM);
% Te=86400*(Te-FROM);
% for i=1:length(Te)
%     ppp=patch([To(i) Te(i) Te(i) To(i) To(i)],[AZo(i)-rng AZo(i)-rng AZo(i)+rng AZo(i)+rng AZo(i)-rng],[1 0 0]);
%     set(ppp,'FaceAlpha',.5)
%     hold on
% end
% hold on
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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


axx(3)=subplot(313);set(gca,'fontSize',14)

p=plot(timS,vel,'.');set(p,'color',[.5 .5 .5])
hold on
plot(timeS,detections.velocity,'.r'),grid on

dcm_obj = datacursormode(FIG);
set(dcm_obj, 'UpdateFcn',{@iad_plot_results_callback,E,FROM},'DisplayStyle','window')

set(gca,'xlim',[86400*(FROM-FROM) 86400*(T0-FROM)])

h = zoom;
set(h,'ActionPostCallback',{@iad_setcurrLIM,FROM,axx});
set(h,'Enable','on');
iad_setcurrLIM([],[],FROM,axx)


return
%%
% working_dir='/Users/giacomo/Documents/item/matlab/iad_av_detector';
% slh='/';
% net='wyssen';
% ConfFileName='conf_fru_2015_priv.txt';
% station=iad_read_ascii2cell([working_dir,slh,'conf_files',slh,net,slh,ConfFileName]);
% 
% L=station.av_min_dets_length;
% DT=station.av_min_dets_continuity;
% [~,~,dts,Ev_Av]=iad_detections2events(DT,L,...
%     Det_Av.data(:,1)',...   % time
%     Det_Av.data(:,2),...    % pressure (Pa)
%     Det_Av.data(:,7),...    % semblance (0-1)
%     Det_Av.data(:,3),...    % backazimuth (�N)
%     Det_Av.data(:,5),...    % app. vel. (m/s)
%     Det_Av.data(:,9),...    % consistency (s)
%     Det_Av.data(:,8),...    % pick frequency (Hz)
%     station.av_window);

% [detections,EVENTS,dts,evts]=iad_detections2events(DT,L,txx,prs,cc,azz,slw,rs,Fp,shift)
%%


FIG=figure;
set(FIG,'color','w')

% timeS=86400*(time-T0);

timeS=86400*(detections.time-FROM);

axx(1)=subplot(311);set(gca,'fontSize',14)
plot(detections.time,detections.pressure,'.k'),grid on



axx(2)=subplot(312);set(gca,'fontSize',14)

plot(detections.time,detections.backazimuth,'.b'),grid on




axx(3)=subplot(313);set(gca,'fontSize',14)
plot(detections.time,detections.velocity,'.r'),grid on



linkaxes(axx,'x')

set(gca,'xlim',[FROM T0])
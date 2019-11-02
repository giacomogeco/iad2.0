function iadPlotResults(FROM, TO, array, working_dir, slh)
tfiles=[FROM TO+1/1440];
%% Events
E = iadReadLastEv(working_dir,slh,array, FROM, TO);
%%  detections
th=floor(tfiles(1)*24)/24:1/24:floor(tfiles(2)*24)/24;
nh=length(th);
for i=1:nh
    filenameEx(i,:)=[working_dir,slh,'detections',slh,lower(char(array.stationName)),'_Det_Ex',slh,...
        lower(char(array.stationName)),'_',datestr(th(i),'yyyymmdd'),slh,...
        lower(char(array.stationName)),'_',datestr(th(i),'yyyymmdd_HHMMSS'),'.csv'];    
    filenameAv(i,:)=[working_dir,slh,'detections',slh,lower(char(array.stationName)),'_Det_Av',slh,...
        lower(char(array.stationName)),'_',datestr(th(i),'yyyymmdd'),slh,...
        lower(char(array.stationName)),'_',datestr(th(i),'yyyymmdd_HHMMSS'),'.csv'];
%         gms_20131226_060000
end
global Ex Av
Ex.prs=[];Ex.bkz=[];Ex.bkzsd=[];Ex.vel=[];Ex.velsd=[];Ex.smb=[];
Ex.fpk=[];Ex.cns=[];Ex.time=[];Ex.iex=[];
Av=Ex;
if nh>0
    dataEx=[];dataAv=[];
    for i=1:nh
        fileEx=filenameEx(i,:);disp(fileEx)
        fileAv=filenameAv(i,:);disp(fileAv)
        try
            dataEx=cat(1,dataEx,textread(fileEx));
        catch            
        end
        try
            dataAv=cat(1,dataAv,textread(fileAv));
        catch
        end
    end
    if isempty(dataEx)
        Ex.time=T0;Ex.prs=0;Ex.bkz=0;Ex.bkzsd=0;Ex.vel=0;Ex.velsd=0;Ex.smb=0;Ex.fpk=0;Ex.cns=0;Ex.iex=0;
    else
        for i=1:size(dataEx,2)
            eval(['VarName',num2str(i),'=dataEx(:,',num2str(i),');'])
        end
        [tx,j]=unique(VarName1);
        tt=tx;
        Ex.time=cat(1,Ex.time,tt);
        Ex.prs=cat(1,Ex.prs,VarName2(j));
        Ex.bkz=cat(1,Ex.bkz,VarName3(j));
        Ex.bkzsd=cat(1,Ex.bkzsd,VarName4(j));
        Ex.vel=cat(1,Ex.vel,VarName5(j));
        Ex.velsd=cat(1,Ex.velsd,VarName6(j));
        Ex.smb=cat(1,Ex.smb,VarName7(j));
        Ex.fpk=cat(1,Ex.fpk,VarName8(j));
        Ex.cns=cat(1,Ex.cns,VarName9(j));
        Ex.iex=cat(1,Ex.iex,VarName10(j));
    end
    if isempty(dataAv)
        Av.time=T0;Av.prs=0;Av.bkz=0;Av.bkzsd=0;Av.vel=0;Av.velsd=0;Av.smb=0;Av.fpk=0;Av.cns=0;Av.iex=0;
    else
        for i=1:size(dataAv,2)
            eval(['VarName',num2str(i),'=dataAv(:,',num2str(i),');'])
        end
        [tx,j]=unique(VarName1);
        tt=tx;
        Av.time=cat(1,Av.time,tt);
        Av.prs=cat(1,Av.prs,VarName2(j));
        Av.bkz=cat(1,Av.bkz,VarName3(j));
        Av.bkzsd=cat(1,Av.bkzsd,VarName4(j));
        Av.vel=cat(1,Av.vel,VarName5(j));
        Av.velsd=cat(1,Av.velsd,VarName6(j));
        Av.smb=cat(1,Av.smb,VarName7(j));
        Av.fpk=cat(1,Av.fpk,VarName8(j));
        Av.cns=cat(1,Av.cns,VarName9(j));
        Av.iex=cat(1,Av.iex,VarName10(j));
    end
end
%% FIGURE
global T0
T0=tfiles(1);
FIG=figure;set(FIG,'name','AVALANCHES ACOUSTIC DETECTOR (powered by GeCo srl)',...
    'color','w','numbertitle','off','pos',[57 27 1260 778])
clear axx
Ex.timeS=86400*(Ex.time-T0);
Av.timeS=86400*(Av.time-T0);
axx(1)=subplot(511);
set(axx(1),'FontName','Bitstream charter','fontsize',12)
plot(Ex.timeS,Ex.prs,'.b'),grid on
hold on
plot(Av.timeS,Av.prs,'Ob')
ylm = get(gca,'ylim');
for i = 1:length(E.tim)
    X = [86400*(E.tim(i)-T0), 86400*(E.tim(i)-T0)+E.dur(i), 86400*(E.tim(i)-T0)+E.dur(i), 86400*(E.tim(i)-T0), 86400*(E.tim(i)-T0)];
    Y = [0, 0, ylm(2), ylm(2), 0];
    switch char(E.type(i))
        case 'Ex'
            p = patch(X, Y,'k');set(p,'EdgeColor','k', 'Linewidth',.5, 'Facecolor', 'y', 'FaceAlpha', .2)
        case 'Cav'
            p = patch(X, Y,'k');set(p,'EdgeColor','k', 'Linewidth',.5, 'Facecolor', 'r', 'FaceAlpha', .2)
        case 'Nav'
            p = patch(X, Y,'k');set(p,'EdgeColor','k', 'Linewidth',.5, 'Facecolor', 'g', 'FaceAlpha', .2)
    end
end
% leg_string{2}='Explosions';
% leg_string{3}='Controlled Avalanches';
% leg_string{4}='Natural Avalanches';
h=title([char(array.locationName),' ', datestr(FROM,0),' - ',datestr(TO)]);set(h,'fontsize',14,'fontweight','bold')
grid on
ylabel('Pa')

axx(2)=subplot(512);set(axx(2),'FontName','Bitstream charter','fontSize',14)
plot(Ex.timeS,Ex.fpk,'.r'),grid on
hold on
plot(Av.timeS,Av.fpk,'Or')
ylabel('Hz')
axx(3)=subplot(513);set(axx(3),'FontName','Bitstream charter','fontSize',14)
plot(Ex.timeS,Ex.iex,'.k'),grid on
hold on
plot(Av.timeS,Av.iex,'Ok')
ylabel('Exp. Index')
axx(4)=subplot(514);set(axx(4),'FontName','Bitstream charter','fontSize',14)
plot(Ex.timeS,Ex.bkz,'.b'),grid on
hold on
plot(Av.timeS,Av.bkz,'Ob')
ylabel('Back-azimuth (?N)')
% set(axx3,'ylim',[Ev_Nav.data(1,20])
axx(5)=subplot(515);set(axx(5),'FontName','Bitstream charter','fontSize',14)
plot(Ex.timeS,Ex.vel,'.r'),grid on
hold on
plot(Av.timeS,Av.vel,'Or')
ylabel('App. vel. (m/s)')
linkaxes(axx,'x')
set(axx,'color','none','xlim',[0 86400*(TO-FROM)])
dcm_obj = datacursormode(FIG);
set(dcm_obj, 'UpdateFcn',{@iadPlotResultsCallback,E,T0},'DisplayStyle','window')
h = zoom;
set(h,'ActionPostCallback',{@iadSetCurXlim,T0,axx});
set(h,'Enable','on');
iadSetCurXlim([],[],T0,axx)
set(axx,'Fontsize',14)
return




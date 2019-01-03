
% to=nownames(1);
% tend=nownames(end)+60/86400;%-1/100/86400;
% data=iad_read_ws_data(ConfFileName,working_dir,slh,net,to,tend,[],[]);
clear D
tfiles=(floor(FROM*1440/15))*15/1440:15/1440:(ceil(TO*1440/15))*15/1440;
% tfiles=tfiles(1:end-1);

for irc=1:length(station.wschannels)
    D.(char(station.wschannels(irc)))=[];
end
D.tt=[];
for ifil=1:length(tfiles)
    
    switch offlinefiletypes
        case 'gcf'
%             gcfstreamID={'A480Z4','A480N4','A480E4','A480X4'}; 
%             gcfGain=[0.2 0.2 0.2 0.2];
            data=iad_read_gcffile(upper(namestz),tfiles(ifil),gcfstreamID,gcfGain,station);
        case 'mat'
            matfilename=[matfilepath,upper(namestz),'/',datestr(tfiles(ifil),'yyyy'),...
        '/',upper(namestz),'_',datestr(tfiles(ifil),'yyyymmdd'),'/',...
        upper(namestz),'_',datestr(tfiles(ifil),'yyyymmdd_HHMMSS'),'.mat'];
        urlwrite(matfilename,'pippo.mat');
        load('pippo.mat')   

        case 'mseed'
                    
    end
    
%     matfilename=[matfilepath,upper(namestz),'/',datestr(tfiles(ifil),'yyyy'),...
%         '/',upper(namestz),'_',datestr(tfiles(ifil),'yyyymmdd'),'/',...
%         upper(namestz),'_',datestr(tfiles(ifil),'yyyymmdd_HHMMSS'),'.mat'];
% 
%     urlwrite(matfilename,'pippo.mat');
%     load('pippo.mat')
    if isempty(data)
        continue
    end
    D.tt=cat(1,D.tt,data.tt);
    for irc=1:length(station.wschannels)
        D.(char(station.wschannels(irc)))=cat(1,D.(char(station.wschannels(irc))),data.(char(station.wschannels(irc))));
    end
%     D.CH1=cat(1,D.CH1,data.CH1);
%     D.CH2=cat(1,D.CH2,data.CH2);
%     D.CH3=cat(1,D.CH3,data.CH3);
%     D.CH4=cat(1,D.CH4,data.CH4);
%     D.CH5=cat(1,D.CH5,data.CH5);
    
end


data = structfun(@(x) ( x' ), D, 'UniformOutput', false);
%             data=iad_rmseed(tfiles,station);

icut=data.tt>=FROM-1/1440 & data.tt<TO+1/1440;
data = structfun(@(x) ( x(icut) ), data, 'UniformOutput', false);
tv=data.tt;

global T0
T0=data.tt(1);TEND=data.tt(end);

load([working_dir,slh,'tmp',slh,station.eventfile]);

% for ich=1:length(station.wschannels)+1
%     if ich==length(station.wschannels)+1
%         tv=data.tt;
%     else
%     eval(['m',num2str(ich),'=','data.(char(station.wschannels(ich)));']);
%     end
% end
eff=100*(sum(isfinite(m1))/(station.smp(1)))/60;
M=[];
for irc=1:length(station.wschannels)
%     eval(['m',num2str(irc),'=','m',num2str(irc),'(:);']);
%     size(eval(['m',num2str(irc)]))
    M=cat(1,M,data.(char(station.wschannels(irc))));
end
% M=M';




tt0=tv;
Ms=sum(M,1);i=isfinite(Ms);M=M(:,i);tt=tv(i);

iactive=station.sensors==1;
M=M(iactive,:);

F=station.ex_frequencyband;
% F=[1 5];
Wp=[F(1) F(2)]/(station.smp(1)/2);
% Wp=[1 5]/(station.smp(1)/2);
% [b,a] = cheby1(station.av_filterorder,station.av_filterripple,Wp);
[b,a] = cheby1(station.ex_filterorder,station.ex_filterripple,Wp);

% Mmax=repmat(max(M'),[size(M,2) 1]);
% M=1.2*M./Mmax';
% M=Mf+M;

% close all
% figure,plot(filtrax(M(1,:),1,10,50)),grid on
% hold on
% plot(filtrax(Mf(1,:),1,20,50),'r')


%%
% close all
FIG=figure;set(FIG,'name','ITEM AVALANCHES ACOUSTIC DETECTOR (by item srl)',...
    'color','w','numbertitle','off')
clear axx
% %%%% LOGO %%%%%
% % This creates the 'background' axes
% rat=858/945;
% ha = axes('units','normalized', ...
%             'position',[.2 .2 .6 .6/rat]);
% % Move the background axes to the bottom
% uistack(ha,'bottom');
% % Load in a background image and display it using the correct colors
% % The image used below, is in the Image Processing Toolbox.  If you do not have %access to this toolbox, you can use another image file instead.
% I=imread(['img',slh,'LOGO_SPINOFF.png']);
% hi = imagesc(I);
% set(hi,'Alphadata',.3)
% colormap gray
% % Turn the handlevisibility off so that we don't inadvertently plot into the axes again
% % Also, make the axes invisible
% set(ha,'handlevisibility','off', ...
%             'visible','off')
% % Now we can use the figure, as required.
% % For example, we can put a plot in an axes
% % axes('position',[0.3,0.35,0.4,0.4])
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tts=86400*(tt-T0);
axx(1)=subplot(511);
set(axx(1),'FontName','Bitstream charter','fontsize',12)
% Mf=filtrax(M',station.av_frequencyband(1),station.av_frequencyband(2),station.smp(1));Mf=Mf';
% Mf=filtrax_soloavanti(M',station.ex_frequencyband(1),station.ex_frequencyband(2),station.smp(1));Mf=Mf';
% fp=FP.(strcat('f',num2str(1)));
Mf=filtfilt(b,a,M');Mf=Mf';

% Mf=filtrax(M',station.av_frequencyband(1),6,station.smp(1));Mf=Mf';
% Mf=iad_add_noise(Mf,.1);

mxx=max(max(Mf'));
for i=1:size(M,1)
%     p1=plot(tts,filtrax(Mf(i,:),1,24,station.smp(1))+(i-1)*mxx,'color',[.7 .7 .7]);hold on
    p1=plot(tts,Mf(i,:)+(i-1)*mxx,'color',[.7 .7 .7]);hold on
end


leg_string{1}='Infrasound';
if size(Ev_Ex.data,1)>0,
    plot(86400*(Ev_Ex.data(:,1)-T0),zeros(size(Ev_Ex.data,1),1),'sy','Linewidth',2)
    hold on
    for i=1:size(Ev_Ex.data,1),
        line([86400*(Ev_Ex.data(i,1)-T0),86400*(Ev_Ex.data(i,2)-T0)],...
         [0,0],'color','y','Linewidth',2)
    end
else
    line([0,0],[0,0],'color','r','Linewidth',2)
end
leg_string{2}='Wyssen Tower Explosions';

if size(Ev_Cav.data,1)>0,
    plot(86400*(Ev_Cav.data(:,1)-T0),zeros(size(Ev_Cav.data,1),1),'sk','Linewidth',2)
    hold on
    for i=1:size(Ev_Cav.data,1),
        line([86400*(Ev_Cav.data(i,1)-T0),86400*(Ev_Cav.data(i,2)-T0)],...
         [0,0],'color','k','Linewidth',2)
        hold on
    end
else
    line([0,0],[0,0],'color','k','Linewidth',2)
end
leg_string{3}='Controlled Avalanches';


if Ev_Av.data(1,1)~=0,
    plot(86400*(Ev_Av.data(:,1)-T0),zeros(size(Ev_Av.data,1),1),'dc','Linewidth',2)
    hold on
    for i=1:size(Ev_Av.data,1),
        
        line([86400*(Ev_Av.data(i,1)-T0),86400*(Ev_Av.data(i,2)-T0)],...
         [0,0],'color','c','Linewidth',2)
    end
else
    line([0,0],[0,0],'color','c','Linewidth',2)
end

if size(Ev_Nav.data,1)>0,
    plot(86400*(Ev_Nav.data(:,1)-T0),zeros(size(Ev_Nav.data,1),1),'dg','Linewidth',2)
    hold on
    for i=1:size(Ev_Nav.data,1),
        
        if Ev_Nav.data(i,17)==1,
            line([86400*(Ev_Nav.data(i,1)-T0),86400*(Ev_Nav.data(i,2)-T0)],...
             [0,0],'color','r','Linewidth',2)
        else
            line([86400*(Ev_Nav.data(i,1)-T0),86400*(Ev_Nav.data(i,2)-T0)],...
             [0,0],'color','g','Linewidth',2)
        end
    end
else
    line([0,0],[0,0],'color','g','Linewidth',2)
end

leg_string{4}='Natural Avalanches';
    
h=title([station.name,' ', datestr(to,0),' - ',datestr(tend)]);set(h,'fontsize',14,'fontweight','bold')
grid on
ylabel('Pressure (Pa)')
% datetick('x',13)
% hl=legend(leg_string,'FontName','Bitstream charter','Fontsize',12);



global E
E.Ev_Av=Ev_Av;E.Ev_Nav=Ev_Nav;E.Ev_Ex=Ev_Ex;E.Ev_Cav=Ev_Cav;

%% detections
th=floor(T0*24)/24:1/24:floor(TEND*24)/24;
nh=length(th);
for i=1:nh,
    
    filenameEx(i,:)=[working_dir,slh,'detections',slh,station.name,'_Det_Ex',slh,...
        station.name,'_',datestr(th(i),'yyyymmdd'),slh,...
        station.name,'_',datestr(th(i),'yyyymmdd_HHMMSS'),'.csv'];
    
    filenameAv(i,:)=[working_dir,slh,'detections',slh,station.name,'_Det_Av',slh,...
        station.name,'_',datestr(th(i),'yyyymmdd'),slh,...
        station.name,'_',datestr(th(i),'yyyymmdd_HHMMSS'),'.csv'];
%         gms_20131226_060000
end

% filename='/Users/giacomo/Documents/item/matlab/iad_av_detector/detections/gms_Det_Av/gms_20160229/gms_20160229_170000_3ch.csv'
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
        Ex.time=T0;
        Ex.prs=0;
        Ex.bkz=0;
        Ex.bkzsd=0;
        Ex.vel=0;
        Ex.velsd=0;
        Ex.smb=0;
        Ex.fpk=0;
        Ex.cns=0;
        Ex.iex=0;
    else
        for i=1:size(dataEx,2),
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
        Av.time=T0;
        Av.prs=0;
        Av.bkz=0;
        Av.bkzsd=0;
        Av.vel=0;
        Av.velsd=0;
        Av.smb=0;
        Av.fpk=0;
        Av.cns=0;
        Av.iex=0;
    else
        for i=1:size(dataAv,2),
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
% icut=Av.iex>0;
% Av = structfun(@(x) ( x(icut) ), Av, 'UniformOutput', false);
% icut=Ex.iex>0;
% Ex = structfun(@(x) ( x(icut) ), Ex, 'UniformOutput', false);


% save gms_20160229_170000_3ch time prs bkz bkzsd vel velsd smb fpk cns

Ex.timeS=86400*(Ex.time-T0);
Av.timeS=86400*(Av.time-T0);

axx(2)=subplot(512);set(axx(2),'FontName','Bitstream charter','fontSize',14)
plot(Ex.timeS,Ex.fpk,'.r'),grid on
hold on on
plot(Av.timeS,Av.fpk,'Or')
ylabel('(Hz)')

axx(3)=subplot(513);set(axx(3),'FontName','Bitstream charter','fontSize',14)
plot(Ex.timeS,Ex.iex,'.k'),grid on
hold on
plot(Av.timeS,Av.iex,'Ok')
ylabel('Explosion Index ()')

axx(4)=subplot(514);set(axx(4),'FontName','Bitstream charter','fontSize',14)
plot(Ex.timeS,Ex.bkz,'.b'),grid on
hold on
plot(Av.timeS,Av.bkz,'Ob')
ylabel('Back-azimuth (�N)')

axx(5)=subplot(515);set(axx(5),'FontName','Bitstream charter','fontSize',14)
plot(Ex.timeS,Ex.vel,'.r'),grid on
hold on
plot(Av.timeS,Av.vel,'Or')
ylabel('App. vel. (m/s)')



linkaxes(axx,'x')
set(axx,'color','none','xlim',[tts(1) tts(end)])

dcm_obj = datacursormode(FIG);
set(dcm_obj, 'UpdateFcn',{@iad_plot_results_callback,E,T0},'DisplayStyle','window')


h = zoom;
set(h,'ActionPostCallback',{@iad_setcurrLIM,T0,axx});
set(h,'Enable','on');
iad_setcurrLIM([],[],T0,axx)

return




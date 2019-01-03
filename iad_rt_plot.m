% 
% to=nownames(1);
% tend=nownames(end)+60/86400;%-1/100/86400;
% data=iad_read_ws_data(ConfFileName,working_dir,slh,net,to,tend,[],[]);
% global T0
% T0=data.tt(1);TEND=data.tt(end);
% 
% load([working_dir,slh,'tmp',slh,station.eventfile]);
% 
% for ich=1:length(station.wschannels)+1
%     if ich==length(station.wschannels)+1
%         tv=data.tt;
%     else
%     eval(['m',num2str(ich),'=','data.(char(station.wschannels(ich)));']);
%     end
% end
% eff=100*(sum(isfinite(m1))/(station.smp(1)))/60;
% for irc=1:length(station.wschannels)
%     eval(['m',num2str(irc),'=','m',num2str(irc),'(:);']);
% end
% M=[m1';m2';m3';m4'];
% tt=tv;
% Ms=sum(M,1);i=isfinite(Ms);M=M(:,i);tt=tv(i);

%%
close all
global H
H.figure=figure;
set(H.figure,'name','ITEM AVALANCHES ACOUSTIC DETECTOR (by item srl)',...
    'color','w','numbertitle','off','units','pixels',...ù
    'position',[0 400 1024 400])
clear axx
% This creates the 'background' axes
rat=858/945;
ha = axes('units','normalized', ...
            'position',[.2 .2 .6 .6/rat]);
% Move the background axes to the bottom
uistack(ha,'bottom');
% Load in a background image and display it using the correct colors
% The image used below, is in the Image Processing Toolbox.  If you do not have %access to this toolbox, you can use another image file instead.
I=imread(['img',slh,'LOGO_SPINOFF.jpg']);
hi = imagesc(I);
set(hi,'Alphadata',.3)
% colormap gray
% Turn the handlevisibility off so that we don't inadvertently plot into the axes again
% Also, make the axes invisible
set(ha,'handlevisibility','off', ...
            'visible','off')
% Now we can use the figure, as required.
% For example, we can put a plot in an axes
% axes('position',[0.3,0.35,0.4,0.4])


tts=86400*(tt-T0);
H.axx(1)=subplot(411);
set(H.axx(1),'FontName','Bitstream charter','fontsize',12)
H.trace=plot(0,0,'color',[.7 .7 .7]);
hold on

leg_string{1}='Infrasound';
if size(Ev_Ex.data,1)>0,
    H.ex_dot=plot(0,0,'sr','Linewidth',2);
    hold on
    for i=1:size(Ev_Ex.data,1),
        H.Ex_line=line([0,0],...
         [0,0],'color','r','Linewidth',2);
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
    
if size(Ev_Nav.data,1)>0,
    plot(86400*(Ev_Nav.data(:,1)-T0),zeros(size(Ev_Nav.data,1),1),'dg','Linewidth',2)
    hold on
    for i=1:size(Ev_Nav.data,1),
        line([86400*(Ev_Nav.data(i,1)-T0),86400*(Ev_Nav.data(i,2)-T0)],...
         [0,0],'color','g','Linewidth',2)
    end
else
    line([0,0],[0,0],'color','g','Linewidth',2)
end
leg_string{4}='Natural Avalanches';
    
h=title([station.name,' ', datestr(to,0),' - ',datestr(tend)]);set(h,'fontsize',14,'fontweight','bold')
grid on
ylabel('Pressure (Pa)')
datetick('x',13)
hl=legend(leg_string,'FontName','Bitstream charter','Fontsize',12);



global E
E.Ev_Nav=Ev_Nav;E.Ev_Ex=Ev_Ex;E.Ev_Cav=Ev_Cav;

%% detections
th=floor(T0*24)/24:1/24:floor(TEND*24)/24;
nh=length(th);
for i=1:nh,
    filename(i,:)=[working_dir,slh,'detections',slh,station.name,'_Det_Av',slh,...
        station.name,'_',datestr(th(i),'yyyymmdd'),slh,...
        station.name,'_',datestr(th(i),'yyyymmdd_HHMMSS'),'.csv'];
%         gms_20131226_060000
end
prs=[];bkz=[];bkzsd=[];vel=[];velsd=[];smb=[];
fpk=[];cns=[];time=[];
if nh>0
    data=[];
    for i=1:nh
        file=filename(i,:);disp(file)
        data=cat(1,data,textread(file));
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

timeS=86400*(time-T0);

axx(2)=subplot(412);set(axx(2),'FontName','Bitstream charter','fontSize',14)
plot(timeS,prs,'.k'),grid on
ylabel('Pressure (Pa)')

axx(3)=subplot(413);set(axx(3),'FontName','Bitstream charter','fontSize',14)
plot(timeS,bkz,'.b'),grid on
ylabel('Back-azimuth (Â°N)')

axx(4)=subplot(414);set(axx(4),'FontName','Bitstream charter','fontSize',14)
plot(timeS,vel,'.r'),grid on
ylabel('App. vel. (m/s)')

linkaxes(axx,'x')
set(axx,'color','none')

dcm_obj = datacursormode(FIG);
set(dcm_obj, 'UpdateFcn',@iad_plot_results_callback,'DisplayStyle','window')


h = zoom;
set(h,'ActionPostCallback',{@iad_setcurrLIM,T0,axx});
set(h,'Enable','on');
iad_setcurrLIM([],T0,axx)

return




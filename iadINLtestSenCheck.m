% clear all
close all
warning off
alerts=load('IDAsAlerts2018-2019');
ids={'no1', 'no2','lvn', ...
    'gtn','gm2','gms','prt',...
    'rsp','lpb','hrm'};
sitename={'Grasdalen','Indreesdalen','Lavangsdalen',...
    'Guttannen','Reckingen','Blitzingen','Quinto',...
    'Ross Peak','Loop Brook', 'Hermit'};

% ev1=[.1;.11;.12;.098;.097]; % bono
% ev2=[.1;.11;.12;.098;.005]; % sordo il 5

L=20;
DT=1.51;
for iid=1:length(ids)   
    disp(['... ',char(ids(iid)),' elaoation'])
    n=(eval(['size(',char(ids(iid)),'.pRs,1)']));
    ev=(eval([char(ids(iid)),'.pRs']));
    tev=(eval([char(ids(iid)),'.tTd']));
    ndts=(eval(['size(',char(ids(iid)),'.pRs,2)']));
    
    p0=zeros(1,ndts);
    [dts,~,~,Ev_Av,ev]=iad_detections2events_new(DT,L,...
        tev,...   % time
        ev(1,:),...    % pressure (Pa)
        ev',...
        p0,...    % semblance (0-1)
        p0,...    % backazimuth (???N)
        p0,...    % app. vel. (m/s)
        p0,...    % consistency (s)
        p0,...    % pick frequency (Hz)
        p0,...   % Explosion Index (Sandro 2017)   %%%%%%%%%%%%%Det_Av.data(:,10),...   % Explosion Index (Sandro 2017)
        .5);

    eval([char(ids(iid)),'.sCk=Ev_Av.data(:,7)'])
    eval([char(ids(iid)),'.tsCk=Ev_Av.data(:,1)'])
%     figure,plot(tev,no1.sCk,'.')
%     return
end


%%


first = datenum(2018,11,27);
last = datenum(2019,4,30);
period=15/1440;
bins = period*(floor(first/period):ceil(last/period));
Te=bins(1:end)';

psiz=4;
clr=jet(256);
clr=clr(1:floor(size(clr,1)/length(ids)):end,:);
figure,set(gcf,'Color','w')
for i=1:length(ids)
    t=eval([char(ids(i)),'.tsCk']);
    [Ne, loc] = histc(t', bins); %... loc Nx1
    Ae=eval([char(ids(i)),'.sCk']); %... Nx1
    amp = accumarray(loc',Ae',size(Te),@mean,NaN);%./accumarray(loc',1); % faster
%     amp = accumarray(loc,Ae)./accumarray(loc,2); % faster than accumaray/mean

    p=plot(Te,amp,'ok');
    set(p,'markerfacecolor',clr(i,:),'markersize',psiz)
    hold on
end
grid
set(gca,'yscale','log','FontSize',14)
datetick('x',12,'keeplimits')
legend(sitename)


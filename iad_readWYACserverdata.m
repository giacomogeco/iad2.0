
function out=iad_readWYACserverdata(station,namestz,t1,t2,f1,f2)

% clear all
% t1=datenum(2018,11,20,17,0,0);
% t2=datenum(2018,11,20,17,10,0);
% namestz='LVN';
% flag_filt=false;
if nargin<5,
    flag_filt=false;
else
    flag_filt=true;
end

t1s=t1-1/1440;
t2s=t2+1/1440;

switch namestz
    case 'RPC'
        id={'7903','7907','7919','7915','7911'};
    case 'LPB'
        id={'7875','7879','7863','7867'};
    case 'RSP'
        id={'7883','7887','7891','7899', '7895'};
    case 'HRM'
        id={'7847','7851','7855','7859', '7827'};
    case 'GTN'
        id={'7927','7923','7931','7935', '7943'};
    case 'LVN'
        id={'7955','7967','7951','7947', '7959'};
    case 'GM2'
        id={'7995','8007','7999','8003'};
    case 'GMS'
        id={'7971','7975','7979','7983'};    
    case 'OYA'
        id={'8073','8069'};  
end

key='zC8AqKrpAw-8tHawJGiDT-R80ab1PRic';
limit='3000';
struct='true';
json='true';
server='https://control.wyssenavalanche.com/app/api/ida/raw.php?';

disp(['Selected Data: ',datestr(t1(1),13),' - ',datestr(t2(end),13)])

dt=1/(86400*50);
out.tt=t1:dt:t2-dt;
texactc=round(out.tt*86400*50);
disp([num2str(length(out.tt)),' samples'])

tv=t1s:1/(1440):t2s;
for i=1:length(id)
    t=[];
    v=[];
    d=NaN*zeros(size(out.tt));
    for iv=1:length(tv)-1
        tminv=tv(iv);
        tmin1=datestr(tminv,'yyyy-mm-dd');
        tmin2=datestr(tminv,'HH:MM:SS');
        tminv=[tmin1,'%20',tmin2];
        tmaxv=tv(iv+1);
        tmax1=datestr(tmaxv,'yyyy-mm-dd');
        tmax2=datestr(tmaxv,'HH:MM:SS');
        tmaxv=[tmax1,'%20',tmax2];
    
        string=[server,...
        'key=',key,...
        '&id=', char(id(i)),...
        '&limit=',limit,...
        '&tmin=',tminv,...
        '&tmax=',tmaxv,...
        '&struct=',struct];
%         disp(string)
%         tic7
        try
            S = urlread(string,'Timeout',2);
        catch
            S=[];
        end
            
%         et=toc;
%         disp(['Wysse Server response time: ' , num2str(et),' s'])
        
        if ~isempty(S)
            a=strsplit(S, {',',';'});
            a=a(1:end-1);
            time=str2num(cell2mat(a(1:2:end)));
            time=datenum(1970,1,1)+time'/86400;
            dato=str2num(cell2mat(a(2:2:end)));
            t=cat(2,t,time);
            v=cat(2,v,dato);
        end       
    end
	% fine cumulo
    
    if size(v,2)~=size(t,2)
        [imin,~] = min([size(v,2) size(t,2)]);
        t=t(1:imin);
        v=v(1:imin);
    end
    
    troundc=round(t*86400*50);
    [~,i1,i2] = intersect(troundc,texactc);
    d(i2)=v(i1);

    if flag_filt
        out.(['m',num2str(i)])=filtrax_nan(d*5/2^16,f1(i),f2(i),50);
    else
        out.(['m',num2str(i)])=d*5/2^16;
    end
    
%     disp(['IDA-ID: ', char(id(i))])
%     ngaps=sum(isnan(out.(['m',num2str(i)])));
%     disp(['nGaps = ',num2str(ngaps),' samples'])

%     out.(['m',num2str(i)])=NaN*zeros(size(out.tt));
     
end

t=out.tt;
out=rmfield(out,'tt');
mtrx=cell2mat(struct2cell(out));
size(mtrx)
mtrx=mtrx(station.sensors>0,:);
emptychk=sum(mtrx,1);
if sum(isnan(emptychk))==size(emptychk,2)
    out=[];
    disp('!!! WARNING ARRAY DATA IS EMPTY !!!')
    return
else
    ii=isfinite(emptychk);
    out = structfun(@(x) ( x(ii) ), out, 'UniformOutput', false);
    out.tt=t(ii);
end

out = structfun(@(x) ( x' ), out, 'UniformOutput', false);

% t=out.tt;
% out=rmfield(out,'tt');
% out.tt=t;
return
%%
figure,set(gcf,'Color','w')
for i=1:length(id)
    ax(i)=subplot(length(id),1,i);
    sigf=filtrax_nan(out.(['m',num2str(i)]),.1,10,50);
    plot(out.tt,sigf,'k')
end
grid on
set(ax,'fontsize',16)
linkaxes(ax,'x')





function out=iadReadWAC3Data(array,station,t1,t2)
% clear all
% t1=datenum(2018,11,20,17,0,0);
% t2=datenum(2018,11,20,17,10,0);
% namestz='LVN';
% flag_filt=false;
o = weboptions('CertificateFilename','');
id=array.snid;
t1s=t1-1/1440;
t2s=t2+1/1440;
% disp(['Selected Data: ',datestr(t1(1),13),' - ',datestr(t2(end),13)])
dt=1/(86400*50);
out.tt=t1:dt:t2-dt;
texactc=round(out.tt*86400*station.smp);
% disp([num2str(length(out.tt)),' samples'])
tv=t1s:1/(1440):t2s;
for i=1:length(id)
    t=[];
    v=[];
    d=NaN*zeros(size(out.tt));
    idi = char(id(i));idi = idi(2:end);
    for iv=1:length(tv)-1
        tminv=tv(iv);
        tmin1=datestr(tminv,'yyyy-mm-dd');
        tmin2=datestr(tminv,'HH:MM:SS');
        tminv=[tmin1,'%20',tmin2];
        tmaxv=tv(iv+1);
        tmax1=datestr(tmaxv,'yyyy-mm-dd');
        tmax2=datestr(tmaxv,'HH:MM:SS');
        tmaxv=[tmax1,'%20',tmax2];   
        string=[station.server,...
        'key=',station.key,...
        '&id=', idi,...
        '&limit=',station.limit,...
        '&tmin=',tminv,...
        '&tmax=',tmaxv,...
        '&struct=',station.struct];
    
    disp(string)
        ktry=0;
        while 1      
            try
                S = webread(string,o);     
                break
            catch
                disp('!!! Warning conection Timeout !!!')
                ktry=ktry+1;
                pause(5)
            end          
            if ktry==2
                v=[];
                t=[];
                break
            end
        end
        if isempty(S)
            continue
        end
        if strcmp(station.json,'true')
            try
                a=jsondecode(S);
                a=a.values;
                time=a(:,1);
                time=datenum(1970,1,1)+time'/(86400*1000);
                dato=a(:,2)';
%                 dato=dato*25/2^16;
            catch
                disp('json dataset')
                disp('error jsondecode') 
                a=strsplit(S, {',',';'});
                a=a(1:end-1);
                time=str2num(cell2mat(a(1:2:end)));
                time=datenum(1970,1,1)+time'/86400;
                dato=str2num(cell2mat(a(2:2:end)));
%                 dato=dato*25/2^16;
                disp('!!! dato*25/2^16 !!!')
            end
        else
            a=strsplit(S, {',',';'});
            a=a(1:end-1);
            time=str2num(cell2mat(a(1:2:end)));
            time=datenum(1970,1,1)+time'/86400;
            dato=str2num(cell2mat(a(2:2:end)));
            dato=dato*25/2^16;
%             disp('!!! dato*25/2^16 !!!')
        end
        t=cat(2,t,time);
        v=cat(2,v,dato);
%         if ~isempty(S)
%             a=strsplit(S, {',',';'});
%             a=a(1:end-1);
%             time=str2num(cell2mat(a(1:2:end)));
%             time=datenum(1970,1,1)+time'/86400;
%             dato=str2num(cell2mat(a(2:2:end)));
%             t=cat(2,t,time);
%             v=cat(2,v,dato);
%         end       
    end % fine cumulo   
    if size(v,2)~=size(t,2)
        [imin,~] = min([size(v,2) size(t,2)]);
        t=t(1:imin);
        v=v(1:imin);
    end    
    troundc=round(t*86400*50);
    [~,i1,i2] = intersect(troundc,texactc);
    d(i2)=v(i1);
%     out.(['m',num2str(i)])=d;
    out.(char(id(i)))=d;
%     disp(['IDA-ID: ', char(id(i))])
%     ngaps=sum(isnan(out.(['m',num2str(i)])));
%     disp(['nGaps = ',num2str(ngaps),' samples'])   
end
t=out.tt;
out=rmfield(out,'tt');
mtrx=cell2mat(struct2cell(out));
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





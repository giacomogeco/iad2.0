clear all,close all
% string='https://control.wyssenavalanche.com/test/app/api/ida/status.php?key=zC8AqKrpAw-8tHawJGiDT-R80ab1PRic&id=';
o = weboptions('CertificateFilename','');
string='https://control.wyssenavalanche.com/test/app/api/ida/status.php?key=zC8AqKrpAw-8tHawJGiDT-R80ab1PRic&id=';
idaName={'IDA Avalanche Crest','IDA Connaught','IDA Crossover','IDA Fidelity','IDA Hermit','IDA Loop Brook',...
    'IDA Mannix','IDA Portal','IDA Ross Peak','IDA RP Compound','IDA RP Summit','IDA Smart','IDA West Boundary',...
    'IDA Lavangsdalen','IDA Grasdalen','IDA Indreesdalen',...
    'IDA Blitzingen','IDA Reckingen','IDA Quinto','IDA Guttannen',...
    'IDA Oyace',...
    'IDA Mount Superior'};
idaID={'8857','8861','8865','8869','7831','7835','8873','8877','7843','7839','8881','8885','8889',...
    '7963','7030','7034',...
    '7987','7991','8237','7939',...
    '8109',...
    '0000'};
idaNameShort={'AVC','CNG','CRO','FDY','HRM','LPB','MNX','PRL','RSP','RPC','RPS','SMT','WBY',...
    'LVN','GRD','IND',...
    'BLZ','RCK','PRT','GTN',...
    'OYA',...
    'MTS'};


nIDA=length(idaID);
% wpath='http://85.10.202.61/status/';
% FROM=input('FROM (yyyy-mm-dd_HH)','s');
% TO=input('TO (yyyy-mm-dd_HH)','s');
% FROM=datenum(FROM,'yyyy-mm-dd_HH');
% T0=datenum(TO,'yyyy-mm-dd_HH');
% nownames=FROM:1/24:T0;
% nfile=length(nownames);

for isn = 5 : 5%nIDA  
    try
        stringa = [string, char(idaID(isn))];
        S = webread(stringa,o);
    catch
        disp('...Connection timed out')
        continue
    end 
    
    if isempty(S)
        
        for i = 1:nsn
            IDA.(['s',char(idaID(isn))]).snid = NaN;
            IDA.(['s',char(idaID(isn))]).lon(i) = NaN;
            IDA.(['s',char(idaID(isn))]).lat(i) = NaN;
            IDA.(['s',char(idaID(isn))]).x(i) = NaN;
            IDA.(['s',char(idaID(isn))]).y(i) = NaN;
        end
        IDA.(['s',char(idaID(isn))]).id = idaID(isn);
        IDA.(['s',char(idaID(isn))]).locationName = idaName(isn);
        IDA.(['s',char(idaID(isn))]).stationName = idaNameShort(isn);
        continue
    end
        
    fname = fieldnames(S)';
    nsn = length(fname);
    for i = 1:nsn
        IDA.(['s',char(idaID(isn))]).snid = fieldnames(S)';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% !!!!! x and y inverted !!!! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        IDA.(['s',char(idaID(isn))]).lon(i) = str2double(S.(char(fname(i))).coordinatey);
        IDA.(['s',char(idaID(isn))]).lat(i) = str2double(S.(char(fname(i))).coordinatex);
     
        [x,y,~] = deg2utm(str2double(S.(char(fname(i))).coordinatex),str2double(S.(char(fname(i))).coordinatey));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        IDA.(['s',char(idaID(isn))]).x(i) = x;
        IDA.(['s',char(idaID(isn))]).y(i) = y;
        a = cell2mat(struct2cell(S.(char(fname(i))).status.Systemtime));
        IDA.(['s',char(idaID(isn))]).Systemtime(i) = datenum(a(1),a(2),a(3),a(4),a(5),a(6));
    end
    IDA.(['s',char(idaID(isn))]).id = idaID(isn);
    IDA.(['s',char(idaID(isn))]).locationName = idaName(isn);
    IDA.(['s',char(idaID(isn))]).stationName = idaNameShort(isn);
    
    array.x=IDA.(['s',char(idaID(isn))]).x;
    array.y=IDA.(['s',char(idaID(isn))]).y;
    array.z=zeros(1,nsn);
    array.snid=IDA.(['s',char(idaID(isn))]).snid;
    array.id=idaID(isn);
    array.locationName = idaName(isn);
    array.stationName = idaNameShort(isn);
    array.systemtime = datenum(a(1),a(2),a(3),a(4),a(5),a(6));

%     array.
    
    fileName = ['array',char(array.stationName),'.mat'];
    save(['arrays/wyssen/2018/',fileName],'array')
    
    
    
    
end
%     
% ids=fieldnames(STS);
return
%%
for i=1:nfile
    fileA=[wpath,'IDA_status_',...
        datestr(nownames(i),'yyyymmddHH'),...
        '.mat'];
    disp(fileA)
    try
        urlwrite(fileA,'pippo.mat');
       
    catch
        disp(['...file not founded'])
        continue
    end
    
    load('pippo.mat')
    
    for isn=1:length(sid)
%          try
%             stringa=[string, char(sid(isn))];
%             S = urlread(stringa,'Timeout',5);
%         catch
%             disp('...Connection timed out')
%             return
%          end
%         s=jsondecode(S);
%         ids=fieldnames(s);
        for ii=1:length(ids)
            STS.(['s',char(sid(isn))]).(['x',char(ids(ii))]).cur_batteryvoltage=cat(1,STS.(['s',char(sid(isn))]).(['x',char(ids(ii))]).cur_batteryvoltage,...
                status.(['s',char(sid(isn))]).(['x',char(ids(ii))]).cur_batteryvoltage);
            STS.(['s',char(sid(isn))]).(['x',char(ids(ii))]).cur_ida_latency=cat(1,STS.(['s',char(sid(isn))]).(['x',char(ids(ii))]).cur_ida_latency,...
                status.(['s',char(sid(isn))]).(['x',char(ids(ii))]).cur_ida_latency);
            STS.(['s',char(sid(isn))]).(['x',char(ids(ii))]).cur_ida_time=cat(1,STS.(['s',char(sid(isn))]).(['x',char(ids(ii))]).cur_ida_time,...
                status.(['s',char(sid(isn))]).(['x',char(ids(ii))]).cur_ida_time);
        end
    end
    
end
    

%%
% clr={'r','g','b','c','m','k','y','w','r'};
% c=colormap('jet');
% c=c(1:floor(size(c,1)/length(sid)):end,:);

psiz=12;
clr=colormap(jet);
clr=clr(1:floor(size(clr,1)/length(ids)):end,:);


figure
set(gcf,'Color','w','pos',[7 384 1412 421])
tt=[];aa=[];
for isn=1:1%length(sid)
%     try
%         stringa=[string, char(sid(isn))];
%         S = urlread(stringa,'Timeout',5);
%     catch
%         disp('...Connection timed out')
%         return
%      end
%     s=jsondecode(S);
%     ids=fieldnames(s);
    for ii=1:length(ids)
        t=STS.(['s',char(sid(isn))]).(['x',char(ids(ii))]).cur_ida_time;
        v=STS.(['s',char(sid(isn))]).(['x',char(ids(ii))]).cur_batteryvoltage;
        tt=cat(1,tt,t);
        aa=cat(1,aa,v);
        p1=plot(t,v,'ok');
        set(p1,'markerfacecolor',clr(ii,:));
        hold on
        
    end
    legend(ids)
    tt=[];aa=[];
    
end

set(gca,'xlim',[FROM T0+1/24],'ylim',[9 16])
datetick('x',15,'keeplimits')
grid on

set(gca,'FontSize',14)


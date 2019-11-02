clear all,close all
% ids={'8069','8077','8073'};
% sid='OYA';
% sid={'8109','7939'};
% sname={'OYA','GTN'};
% string='https://control.wyssenavalanche.com/test/app/api/ida/status.php?key=zC8AqKrpAw-8tHawJGiDT-R80ab1PRic&id=';

% sid={'7939','7963','7831','7835','7843','7839','7987','7991','8109'};
% sname={'GTN','LVN','HRM','LPB','RSP','RPC','BLZ','RCK','OYA'};
% sid={'8109','7939'};
% sname={'OYA','GTN'};

sid={'8109'};ids={'8069','8077','8073'};
sname={'OYA'};
string='https://control.wyssenavalanche.com/test/app/api/ida/status.php?key=zC8AqKrpAw-8tHawJGiDT-R80ab1PRic&id=';

wpath='http://85.10.202.61/status/';
FROM=input('FROM (yyyy-mm-dd_HH)','s');
TO=input('TO (yyyy-mm-dd_HH)','s');
FROM=datenum(FROM,'yyyy-mm-dd_HH');
T0=datenum(TO,'yyyy-mm-dd_HH');
nownames=FROM:1/24:T0;
nfile=length(nownames);

for isn=1:length(sid)
    
%     try
%         stringa=[string, char(sid(isn))];
%         S = urlread(stringa,'Timeout',5);
%     catch
%         disp('...Connection timed out')
%         return
%     end
%     s=jsondecode(S);
%     ids=fieldnames(s);

    for i=1:length(ids)
        STS.(['s',char(sid(isn))]).(['x',char(ids(i))]).cur_batteryvoltage=[];
        STS.(['s',char(sid(isn))]).(['x',char(ids(i))]).cur_ida_latency=[];
        STS.(['s',char(sid(isn))]).(['x',char(ids(i))]).cur_ida_time=[];
    end
end
%     
% ids=fieldnames(STS);

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


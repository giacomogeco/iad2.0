% function ida_read_beni

clear all
close all

% http://32032.hostserv.eu/app/api/ida2.php?key=zC8AqKrpAw-8tHawJGiDT-R80ab1PRic&id=7690&limit=1000&tmin=2018-07-24%2014:00:00&tmax=2018-07-24%2014:10:00&struct=true
% http://32032.hostserv.eu/app/api/ida2.php?key=zC8AqKrpAw-8tHawJGiDT-R80ab1PRic&id=7690&limit=1000&tmin=2018-08-02%2007:23:00&tmin=2018-08-02%2007:23:10&struct=true

%... GeCo
% key='zC8AqKrpAw-8tHawJGiDT-R80ab1PRic';
% id='7687'; %(this is the sensor id, other sensors 7688, 7687)
% limit='100';%(number of records, each record contains 77 samples, I know this number doesn't make sense, it is because of a radio optimization, default is 300)
% tmin='2018-07-19 00:00:00';% (start time UTC)
% tmax='2018-07-19 01:00:00';% (end time UTC)
% struct='true'; %(set this to get matlab-compatible output)
% json=true;% (set this to get json output)

%... Beni
key='zC8AqKrpAw-8tHawJGiDT-R80ab1PRic';
id1='7687'; %(this is the sensor id, other sensors 7688, 7687)
id2='7688';
id3='7689';
limit='1000';%(number of records, each record contains 77 samples, I know this number doesn't make sense, it is because of a radio optimization, default is 300)
tmin='2018-07-19 00:00:00';% (start time UTC)
tmax='2018-07-19 01:00:00';% (end time UTC)
struct='true'; %(set this to get matlab-compatible output)
json='false';% (set this to get json output)

server='http://32032.hostserv.eu/app/api/ida2.php?';
% string='http://32032.hostserv.eu/app/api/ida2.php?key=zC8AqKrpAw-8tHawJGiDT-R80ab1PRic&id=7689&limit=1000&tmin=2018-08-02%2008:00:00&tmax=2018-08-02%2008:10:00&struct=true';

w=5/86400;
sh=5/86400;
latency=60/86400;
smp=50;
% figure
% set(gcf,'Color','w')
% p=plot(0,0,'k');grid on
% set(gca,'xlim',[0 w*86400])
% tit=title('');

utclag=0;

k=0;
tend=now-utclag/24-latency;
while 1
    
    k=k+1;
    
    tnow=now-utclag/24;
    tend=tnow;
    tmax1=datestr(tend,'yyyy-mm-dd');
    tmax2=datestr(tend,'HH:MM:SS');
    tmax=[tmax1,'%20',tmax2];
    
    tstart=tend-w;
    tmin1=datestr(tstart,'yyyy-mm-dd');
    tmin2=datestr(tstart,'HH:MM:SS');
    tmin=[tmin1,'%20',tmin2];
    
    disp(['SELECTED DATA: ',datestr(tstart,13),' - ',datestr(tend,13)])
    
    string1=[server,...
        'key=',key,...
        '&id=',id1,...
        '&limit=',limit,...
        '&tmin=',tmin,...
        '&tmax=',tmax,...
        '&struct=',struct];
    string2=[server,...
        'key=',key,...
        '&id=',id2,...
        '&limit=',limit,...
        '&tmin=',tmin,...
        '&tmax=',tmax,...
        '&struct=',struct];
    string3=[server,...
        'key=',key,...
        '&id=',id3,...
        '&limit=',limit,...
        '&tmin=',tmin,...
        '&tmax=',tmax,...
        '&struct=',struct];
    
    tic
    S1= webread(string1);
%     S2 = webread(string2);
%     S3 = webread(string3);
    et=toc;
    ET(k)=et
    if ~isempty(S1)
       
        aa=strsplit(S1, {';', ','});
        time=str2num(cell2mat(aa(1:2:end)));
        time=datenum(1970,1,1)+time/86400;
        
        T1(k)=time(1);
        T2(k)=time(end);

        disp(datestr(tnow))
        disp(datestr(time(end)))
        lty(k)=round(10*86400*(time(end)-tnow))/10;
        disp(num2str(lty(k)))
    else
        if isempty(S)
            disp(['!!! WARNING NO SELECTED DATA FROM THE SERVER'])
        end
%         if STATUS==0
%             disp(['!!! WARNING NO ANSWER FROM THE SERVER'])
%         end
    end
    pause(2)
    
        
%     break
%     count=str2num(cell2mat(aa(2:2:end)));
% %     pa=(count*5/2^16)/.4;
% %     count=(count*25/2^16);
%     lty=round(10*86400*(time(end)-tnow))/10;
%     set(p,'xdata',86400*(time-time(1)),'ydata',count)
%     set(tit,'string',['NOW: ',datestr(-1/24,13),' - ','TIME: ',datestr(tstart,13),' - ',datestr(tend,13),...
%         'Latency: ',num2str(lty),' sec.'])
%     drawnow
%     tend=tend+sh;
%     pause(sh*86400)
       
end


function [status,result] = iadEvent2Wyssen(station,Event,Type,offline)

% Event=evnts;
% Type='Ex';

% # -*- coding: utf-8 -*-
% import requests
% url = 'https://control.wyssenavalanche.com/app/api/ida/...'
% data = dict(type='Nav', rtime='2017-12-05T12:43:22', dur=45.6, amp=187, sector='NULL', bkzOn=234.6, bkzEnd=256.3, bkzAv=242.5,
%             freq1=3.2, freq2=2.7, rel=H, sname=?RP2?, sid=7963)
% r = requests.post(url, data=data, allow_redirects=True)
% https://control.wyssenavalanche.com/app/api/ida/new-event.php
% Please also insert the key in your post data!!!
% key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic"

% reliability
if strcmp(Type,'Nav')
    if Event.data(:,17)==1
        reliability='H';
    else
        reliability='M';
    end
else
    reliability='H';
end

if strcmp(Type,'Nav')
    if ~isempty(station.zonefilename)  
        [~,sector]=iad_norway_zones_location(Event.data(20),Event.data(21),station.zonefilename);
        disp(sector)
    else
        sector='Null';
    end 
end

if strcmp(Type,'Ex')
    sector=char(Event.torretta);
end
if strcmp(Type,'Cav')
    sector='Null';
end


tpost=now;
% %... LOG FILE
wys.logdir=[pwd,'/log/iadEvents2Wyssen/',lower(station.name),'/'];
wys.logfilename=['pyWys_',lower(station.name),'_',datestr(Event.data(1),'yyyymmdd_HHMMSS'),'_',Type,'.py'];
filepy=[wys.logdir,...
    wys.logfilename];
%     pysend_gry_20170308_100049565_Nav.py
wys.url = 'https://control.wyssenavalanche.com/app/api/ida/new-event.php';
wys.apikey = 'zC8AqKrpAw-8tHawJGiDT-R80ab1PRic';


fid=fopen(filepy,'w', 'native', 'UTF-8');

fwrite(fid,'# -*- coding: utf-8 -*-');
fprintf(fid,'\n');
fwrite(fid,'import requests');
fprintf(fid,'\n');
fwrite(fid,'import base64');
fprintf(fid,'\n');
fwrite(fid,'from requests.auth import HTTPBasicAuth');
fprintf(fid,'\n');
%--------------------------------------------
fwrite(fid,['url = ','"',...
    wys.url,'"']);
fprintf(fid,'\n');

% data = dict(type='Nav', rtime='2017-12-05T12:43:22', dur=45.6, amp=187, sector='NULL', bkzOn=234.6, bkzEnd=256.3, bkzAv=242.5,
%             freq1=3.2, freq2=2.7, rel=H, sname=?RP2?, sid=7963)
fwrite(fid,['data = dict(',...
    ['key = "',wys.apikey,'", '],...
    ['type = "',Type,'", '],...
    ['rtime = "',datestr(Event.data(1,1),30),'", '],...
    ['dur = ',num2str(round(Event.data(1,3))),', '],...
    ['amp = ',num2str(round(Event.data(1,6)*1000)/1000),', '],...
    ['sector = "',sector,'", '],...
    ['bkzOn = ',num2str(round(Event.data(1,20))),', '],...
    ['bkzEnd = ',num2str(round(Event.data(1,21))),', '],...
    ['bkzAv = ',num2str(round(Event.data(1,8))),', '],...
    ['freq1 = ',num2str(round(Event.data(1,13))),', '],...
    ['freq2 = ',num2str(round(Event.data(1,23))),', '],...
    ['rel = "',reliability,'", '],...
    ['sname = "',char(upper(station.name)),'", '],...
    ['sid = ',num2str(station.sid)],...
    ')']);
fprintf(fid,'\n');

fwrite(fid,['r = requests.post(url, ', ...
    ['data=data',', '],...
    'allow_redirects=True)']);
fprintf(fid,'\n');

fwrite(fid,'print(r.content)');
fclose(fid);

% disp(['python ',wys.logdir,wys.logfilename,' &'])
if offline==0
    [status,result] = system(['python ',wys.logdir,wys.logfilename,' &']);
else
    status=NaN;
    result=NaN;
end


return

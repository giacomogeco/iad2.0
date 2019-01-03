function iadEvent2GeCo(Event,station,Type)

% station.name='RSP';
% Type='Cav';
% Event.data(1)=datenum(2018,12,11,8,51,0);
% Event.data(17)=1;
% recipients={'IAD@smshosting.it'};

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

msg=[upper(station.name),' ',Type,' ALERT ',...
    datestr(Event.data(1),31),' UT',' - Rel: ',reliability];

wys.logdir=[pwd,'/log/iadEvents2Wyssen/',lower(station.name),'/'];
wys.logfilename=['pyGeC_',lower(station.name),'_',datestr(Event.data(1),'yyyymmdd_HHMMSS'),'_',Type,'.py'];
filepy=[wys.logdir,...
    wys.logfilename];
disp(filepy)
if exist(filepy,'file')
    disp('Notificationn Already Sent')
    return
end

fid=fopen(filepy,'w');

string='from smtplib import SMTP';
fwrite(fid,string);
fprintf(fid,'\n');

string='import datetime';
fwrite(fid,string);
fprintf(fid,'\n');

string='smtp = SMTP(''smtp.gmail.com:587'')';
fwrite(fid,string);
fprintf(fid,'\n');

string='smtp.starttls()';
fwrite(fid,string);
fprintf(fid,'\n');

string='smtp.login(''sandrovezzosi@gmail.com'', ''paciugO80'')';
fwrite(fid,string);
fprintf(fid,'\n');

string='from_addr = "sandrovezzosi@gmail.com"';
fwrite(fid,string);
fprintf(fid,'\n');

% string=['to_addr = "',recipient,'"'];
% fwrite(fid,string);
% fprintf(fid,'\n');

string=['to_addr = ['];
for i = 1:length(station.mailing_list_item),
    string=[string,'''',station.mailing_list_item{i},''''];
    if i<length(station.mailing_list_item),
        string=[string,','];
    end
end
string=[string,']'];   
fwrite(fid,string);
fprintf(fid,'\n');

string=['subj = "','IDA-ALERT','"'];
fwrite(fid,string);
fprintf(fid,'\n');

string='date = datetime.datetime.now().strftime( "%d/%m/%Y %H:%M" )';
fwrite(fid,string);
fprintf(fid,'\n');

string=['message_text = "',msg,'"'];
fwrite(fid,string);
fprintf(fid,'\n');

string='msg = "From: %s\nTo: %s\nSubject: %s\nDate: %s\n\n%s" %( from_addr, to_addr, subj, date, message_text )';
fwrite(fid,string);
fprintf(fid,'\n');

string='smtp.sendmail(from_addr, to_addr, msg)';
fwrite(fid,string);
fprintf(fid,'\n');

string='smtp.quit()';
fwrite(fid,string);
fprintf(fid,'\n');
fclose(fid);

unix(['python ',filepy,' &'])



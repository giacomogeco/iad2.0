function iad_send_mail_python_multi(recipients,subject,msg,station)
 %recipients={'dario.d.donne@gmail.com','giacomo.ulivieri73@gmail.com'};
 %subject='prova';
 %msg='puppa';

if ~isdir('sended_emails'),
	mkdir('sended_emails')
end

cur_dir=[pwd,'/sended_emails/'];

tnow=datestr(now,'yyyymmdd_HHMMSSFFF');
fid=fopen([cur_dir,'pysend_',station.name,'_',tnow,'.py'],'w');

string='from smtplib import SMTP';
fwrite(fid,string);
fprintf(fid,'\n');

string='import datetime';
fwrite(fid,string);
fprintf(fid,'\n');

string='debuglevel = 0';
fwrite(fid,string);
fprintf(fid,'\n');

string='smtp = SMTP()';
fwrite(fid,string);
fprintf(fid,'\n');
string='smtp.set_debuglevel(debuglevel)';
fwrite(fid,string);
fprintf(fid,'\n');
string=['smtp.connect(''',station.mailserver,''', 25)'];
fwrite(fid,string);
fprintf(fid,'\n');

string=['smtp.login(''',station.mailsender,''',''',station.mailsenderpsw,''')'];
fwrite(fid,string);
fprintf(fid,'\n');

string=['from_addr = "',station.mailsender,'"'];
fwrite(fid,string);
fprintf(fid,'\n');

% string=['to_addr = "',recipient,'"'];
% fwrite(fid,string);
% fprintf(fid,'\n');

string=['to_addr = ['];

for i = 1:length(recipients),
    string=[string,'''',recipients{i},''''];
    if i<length(recipients),
        string=[string,','];
    end
end
    string=[string,']'];
    

    fwrite(fid,string);
    
    
    fprintf(fid,'\n');
string=['subj = "',subject,'"'];
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

unix(['python ',cur_dir,'pysend_',station.name,'_',tnow,'.py &'])



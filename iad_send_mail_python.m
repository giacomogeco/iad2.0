function iad_send_mail_python(recipient,subject,msg,station)
% recipient='dario.d.donne@gmail.com';
% subject='prova';
% msg='puppa';

fid=fopen('~/pysend.py','w');

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

string=['smtp.login(''',station.mailsender,''', ''',station.mailsenderpsw,''')'];
fwrite(fid,string);
fprintf(fid,'\n');

string=['from_addr = "',station.mailsender,'"'];
fwrite(fid,string);
fprintf(fid,'\n');

string=['to_addr = "',recipient,'"'];
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

unix('python ~/pysend.py &')



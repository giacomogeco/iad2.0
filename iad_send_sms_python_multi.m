function iad_send_sms_python_multi(recipients,msg)
% recipient='dario.d.donne@gmail.com';
% subject='prova';
% msg='puppa';



fid=fopen('~/pysend_sms.py','w');

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
string='smtp.connect(''mail.item-geophysics.it'', 25)';
fwrite(fid,string);
fprintf(fid,'\n');

string='smtp.login(''info@item-geophysics.it'', ''waveworm'')';
fwrite(fid,string);
fprintf(fid,'\n');

string='from_addr = "info@item-geophysics.it"';
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
string=['subj = "',msg,'"'];
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

unix('python ~/pysend_sms.py &')



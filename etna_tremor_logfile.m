function etna_tremor_logfile(working_dir,slh,last_mail_time,status)

% fprintf(fid,datestr(tv(1)));
%         fprintf(fid,'\t');
%         fprintf(fid,num2str(eff));
%         fprintf(fid,'\n');
%         fclose(fid);


fid=fopen([working_dir,slh,'log',slh,'alertlog.log'],'a+');
fprintf(fid,['ALERT: ',datestr(last_mail_time,'yyyymmdd_HHMMSS'),...
    ' - STATUS= ',num2str(status),'\n\n']);
fclose(fid);

return
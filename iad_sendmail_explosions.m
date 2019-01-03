

%% SEND MAIL EXPLOSIONS
if ~exist([working_dir,slh,'log',slh,station.mail_ex_logfile],'file'),
    last_mailed_time=tt(end)-60/86400;
else
    string=textread([working_dir,slh,'log',slh,station.mail_ex_logfile],'%s');
    % Lettura del logfile che mi restituisce l'ultimo minuto processato
    last_mailed_time=datenum(char(string),'yyyymmdd_HHMMSS');
end

if size(Ev_Ex.data,1)>0,
    ii=find(Ev_Ex.data(:,1)>last_mailed_time+1/86400);

    if ~isempty(ii),

        string='Explosion Alert at:\t';
	stringsms=['IDA ',upper(station.name),' Explosion Alert at: '];

        for i=1:length(ii),
            string=[string,datestr(Ev_Ex.data(ii(i),1)),'\n Sector: \t',Ev_Ex.torretta{ii(i)},'\n\n'];
	    stringsms=[stringsms,datestr(Ev_Ex.data(ii(i),1)),'; Sector: ',Ev_Ex.torretta{ii(i)}];
        end
	
	string=[string,'for further details, please visit http://www.ida-wyssen.com/'];

        disp(['>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MAIL EXPLOSIONS:',string]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%% EXP EMAIL FOR ITEM %%%%%%%%%%%%%%%%%%%%%%%%%%
	if station.mail_explosions_flag==1 & ~isempty(station.mailing_list_item)
            iad_send_mail_python_multi(station.mailing_list_item,['IDA ',upper(station.name),' Alert'],string,station)
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EXP EMAIL FOR CUSTOMER %%%%%%%%%%%%%%%%%%%%%%%%%%
	if station.mail_explosions_flag==1 & ~isempty(station.mailing_list_customer)
	     if strcmp(upper(station.name),'RP2')
	     else
             iad_send_mail_python_multi(station.mailing_list_customer,['IDA ',upper(station.name),' Alert'],string,station)
	     end
	end
        
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EXP SMS FOR ITEM %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if station.sms_explosions_flag==1 & ~isempty(station.sms_list_item)
             for i=1:length(station.sms_list_item)
		iad_send_sms_python(station.sms_list_item{i},['IDA-Alert'],stringsms,station)
		pause(1)
	     end
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EXP SMS FOR CUSTOMER %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if station.sms_explosions_flag==1 & ~isempty(station.sms_list_customer)
	     if strcmp(upper(station.name),'RP2')
	     else
             for isms=1:length(station.sms_list_customer)
		iad_send_sms_python(station.sms_list_customer{isms},['IDA-Alert'],stringsms,station)
		pause(1)
	     end
	     end
	end
        
      TEvEnd=Ev_Ex.data(ii(end),1);
    else
        TEvEnd=last_mailed_time;    
    end
else
     TEvEnd=last_mailed_time;    
end
%... log mail
fid=fopen([working_dir,slh,'log',slh,station.mail_ex_logfile],'w');
fwrite(fid,datestr(TEvEnd,'yyyymmdd_HHMMSS'));
fclose(fid);



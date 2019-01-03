%% SEND MAIL for controlled avalanche TO CUSTOMER
if ~exist([working_dir,slh,'log',slh,station.mail_cav_logfile],'file'),
    last_mailed_time=tt(end)-60/86400;
else
    string=textread([working_dir,slh,'log',slh,station.mail_cav_logfile],'%s');
     % Lettura del logfile che mi restituisce l'ultimo minuto processato
    last_mailed_time=datenum(char(string),'yyyymmdd_HHMMSS');
end

if size(Ev_Cav.data,1)>0,
    string='Controlled Avalanche Alert at:\t';
    stringsms=['IDA ',upper(station.name),' Controlled Avalanche Alert at: '];

% Notifiche con soglia al customer
    ii=find(Ev_Cav.data(:,1)>last_mailed_time+1/86400);

    if ~isempty(ii),
        for i=1:length(ii),
            string=[string,datestr(Ev_Cav.data(ii(i),1)),'\n\n'];
            stringsms=[stringsms,datestr(Ev_Cav.data(ii(i),1)),'\n'];
        end
        % "TOWER / SECTOR"
%             if Ev_Nav.data(ii(i),17)==1,
%                 relstring='';
%             else
%                 relstring='';
%             end
%             string=[string,relstring,'\n'];
%             stringsms=[stringsms,'; ',relstring];
		%... 1 SMS 7bit (GSM) fino a 160 caratteri con smshosting
                %... 1 SMS unicode fino a 70 caratteri con smshosting
		%... IDA RP2 Natural Avalanche Alert at 02-Dec-2017 15:15:54 (100%) - 61 carattei
		%... IDA RP2 Controlled Avalanche Alert at 02-Dec-2017 15:15:54 Sector - 61 carattei
		%... IDA RP2 Explosion Alert at 02-Dec-2017 15:15:54 Tower - 60 carattei
        string=[string,'for further details, please visit http://www.ida-wyssen.com/'];

        disp(['>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MAIL TRIGGERED AVALANCHE:',string]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAV EMAIL FOR ITEM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if station.mail_explosions_flag==1 & ~isempty(station.mailing_list_item)
            iad_send_mail_python_multi(station.mailing_list_item,['IDA ',upper(station.name),' Alert'],string,station)
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAV EMAIL FOR CUSTOMER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if station.mail_explosions_flag==1 && ~isempty(station.mailing_list_customer)
             iad_send_mail_python_multi(station.mailing_list_customer,['IDA ',upper(station.name),' Alert'],string,station)
        end
        
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAV SMS FOR ITEM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if station.sms_explosions_flag==1 & ~isempty(station.sms_list_item)
             for i=1:length(station.sms_list_item)
		iad_send_sms_python(station.sms_list_item{i},['IDA-Alert'],stringsms,station)
		pause(1)
	     end
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CAV SMS FOR CUSTOMER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if station.sms_explosions_flag==1 && ~isempty(station.sms_list_customer)
            for i=1:length(station.sms_list_customer)
                iad_send_sms_python(station.sms_list_customer{i},['IDA-Alert'],stringsms,station)
                pause(1)
            end
        end

        TEvEnd=Ev_Cav.data(ii(end),1);    
    else
        TEvEnd=last_mailed_time;    
    end
else
     TEvEnd=last_mailed_time;    
end

fid=fopen([working_dir,slh,'log',slh,station.mail_cav_logfile],'w');
fwrite(fid,datestr(TEvEnd,'yyyymmdd_HHMMSS'));
fclose(fid);
        

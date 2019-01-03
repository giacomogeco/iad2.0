%% SEND MAIL Big Natural Avalanches TO CUSTOMER
if ~exist([working_dir,slh,'log',slh,station.mail_pub_logfile],'file'),
    last_mailed_time=tt(end)-60/86400;
else
    string=textread([working_dir,slh,'log',slh,station.mail_pub_logfile],'%s');
     % Lettura del logfile che mi restituisce l'ultimo minuto processato
    last_mailed_time=datenum(char(string),'yyyymmdd_HHMMSS');
end

if size(Ev_Nav.data,1)>0,
% 		 string='Natural Avalanche Alert\nPossible Natural Avalanche has been detected by IDA Automatic Real Time Avalanche Monitoring System occurred at\n';
% 		stringsms=['IDA ',upper(station.name),' Natural Avalanche Alert at '];

		% Notifiche con soglia al customer
    ii=find(Ev_Nav.data(:,1)>last_mailed_time+1/86400 & ...	%... non più di una
        Ev_Nav.data(:,3)>station.mailthreshold_minduration & ...
        Ev_Nav.data(:,6)>station.mailthreshold_minpressure & ...
        Ev_Nav.data(:,17)>0);
            
    if ~isempty(ii),
        for i=1:length(ii),
                    
            for js=1:size(station.bazmail,1),

                if Ev_Nav.data(ii(i),8)>=station.bazmail(js,1) && Ev_Nav.data(ii(i),8)<=station.bazmail(js,2),
                    string=station.mailstring{js};
                    stringsms=string;
                    break
                end

                string='Natural Avalanche Alert\nPossible Natural Avalanche has been detected at \n';
                stringsms=['IDA ',upper(station.name),' Natural Avalanche Alert at '];	
            end
            % DATA
            string=[string,datestr(Ev_Nav.data(ii(i),1)),'\n'];
            stringsms=[stringsms,datestr(Ev_Nav.data(ii(i),1))];
            % Reliability
            if Ev_Nav.data(ii(i),17)==1,
                relstring='Rel: HIGH';
            else
                relstring='Rel: LOW';
            end
            string=[string,relstring,'\n'];
            stringsms=[stringsms,'; ',relstring];
            % ...
            string=[string,'for further details, please visit http://www.ida-wyssen.com/'];


            disp(['>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MAIL AVALANCHE:',string]);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%% AVALANCHES MAIL ALERT 4 CUSTOMER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if station.mail_avalanches_flag==1 && ~isempty(station.mailing_list_customer)
                disp(string)
                 iad_send_mail_python_multi(station.mailing_list_customer,['IDA ',upper(station.name),' Alert'],string,station.name)
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%% AVALANCHES SMS ALERT CUSTOMER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if station.sms_avalanches_flag==1 && ~isempty(station.sms_list_customer)
                for isms=1:length(station.sms_list_customer)
                     iad_send_sms_python(station.sms_list_customer{isms},['IDA ',upper(station.name),' Alert'],stringsms,station)
                    
                    pause(1)
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TEvEnd=Ev_Nav.data(ii(end),1);    
            fid=fopen([working_dir,slh,'log',slh,station.mail_pub_logfile],'w');
            fwrite(fid,datestr(TEvEnd,'yyyymmdd_HHMMSS'));
            fclose(fid);
        end
    else
        TEvEnd=last_mailed_time;    
    end
else
    TEvEnd=last_mailed_time;    
end

fid=fopen([working_dir,slh,'log',slh,station.mail_pub_logfile],'w');
fwrite(fid,datestr(TEvEnd,'yyyymmdd_HHMMSS'));
fclose(fid);
        
        

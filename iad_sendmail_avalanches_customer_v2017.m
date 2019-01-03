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
        Ev_Nav.data(:,17)>=0.5);	%... AL CUSTOMER SOLO LE 100% in tal modo controllando le soglie mailthreshold_... si manda tutte le allerte anche al customer (corretto 4 Dic 2017)
            
    if ~isempty(ii),
        for i=1:length(ii),
      
            for js=1:size(station.bazmail,1),
		
		%!!!!!!! MESSAGGI DIVERSI PER SETTORI DIVERSI !!!!!!
                if Ev_Nav.data(ii(i),8)>=station.bazmail(js,1) && Ev_Nav.data(ii(i),8)<=station.bazmail(js,2) && length(char(station.mailstring(js)))>1, % corretto errore Dec 19 2017
                    string=station.mailstring{js};
                    stringsms=string;
                    break
                else % corretto errore Dec 19 2017

                    string='Natural Avalanche Alert\nPossible Natural Avalanche has been detected at \n';
                    stringsms=['IDA ',upper(station.name),' Natural Avalanche Alert at '];	
                end
            end
            % DATA
            string=[string,datestr(Ev_Nav.data(ii(i),1)),'\n'];
            stringsms=[stringsms,datestr(Ev_Nav.data(ii(i),1))];
            % Reliability
            if Ev_Nav.data(ii(i),17)==1,
                relstring='Rel: HIGH';
            else
                relstring='Rel: MEDIUM';
            end
            string=[string,relstring,'\n'];
            stringsms=[stringsms,'; ',relstring];	
	    % path/sector
	

	if strcmp(upper(station.name),{'NO2'}),
		try
		    [zid,ztext]=iad_norway_zones_location(Ev_Nav.data(ii(i),20),Ev_Nav.data(ii(i),21),'IDA_Indreesdalen_zones');
		    
		    if strcmp('Uncertain Zone',ztext)
			    j3=findstr(stringsms,'Rel: HIGH');
			    stringsms(j3:j3+8)='';

			    j3=findstr(string,'Rel: HIGH');
			    string(j3:j3+8)='';
		    else
			    j1=strfind(stringsms,' fra ');
			    j2=strfind(stringsms,' av ');
			    stringsms=[stringsms(1:j1(1)+4),' ',ztext,' i ',stringsms(j2(1)+4:end)];
			    j3=findstr(stringsms,'Rel: HIGH');
			    stringsms(j3:j3+8)='';

			    j1=strfind(string,' fra ');
			    j2=strfind(string,' av ');
			    string=[string(1:j1(1)+4),' ',ztext,' i ',string(j2(1)+4:end)];
			    j3=findstr(string,'Rel: HIGH');
			    string(j3:j3+8)='';
		    end
		end
	end

	if strcmp(upper(station.name),{'NNN'}),
                try
                    [zid,ztext]=iad_norway_zones_location(Ev_Nav.data(ii(i),20),Ev_Nav.data(ii(i),21),'IDA_Grasdalen_zones');
                    if strcmp('Uncertain Zone',ztext)
                        j3=findstr(stringsms,'Rel: HIGH');
                        stringsms(j3:j3+8)='';

                        j3=findstr(string,'Rel: HIGH');
                        string(j3:j3+8)='';
                    else
                        j2=strfind(stringsms,' i ');
                        stringsms=[stringsms(1:j1(1)-2),' fra ',ztext,' i ',stringsms(j2(1)+4:end)];
                        j3=findstr(stringsms,'Rel: HIGH');
                        stringsms(j3:j3+8)='';

                        j2=strfind(string,' i ');
                        string=[string(1:j1(1)-2),' fra ',ztext,' i ',string(j2(1)+4:end)];
                        j3=findstr(string,'Rel: HIGH');
                        string(j3:j3+8)='';
                    end
                end
        end

	

	if sum(strcmp(upper(station.name),{'NO1', 'NO2', 'NO3'}))==1
		string=[string,' Mer informasjon her: www.ida-wyssen.com'];
	    stringsms=[stringsms,' www.ida-wyssen.com'];

	else
		string=[string,' for further details, please visit www.ida-wyssen.com'];
	    stringsms=[stringsms,' www.ida-wyssen.com'];
	end


		%... 1 SMS 7bit (GSM) fino a 160 caratteri con smshosting
        %... 1 SMS unicode fino a 70 caratteri con smshosting
		%... IDA RP2 Natural Avalanche Alert at 02-Dec-2017 15:15:54 (100%) - 61 carattei
		%... IDA RP2 Controlled Avalanche Alert at 02-Dec-2017 15:15:54 Sector - 61 carattei
		%... IDA RP2 Explosion Alert at 02-Dec-2017 15:15:54 Tower - 60 carattei
            


            disp(['>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MAIL AVALANCHE:',string]);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%% AVALANCHES MAIL ALERT 4 CUSTOMER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if station.mail_avalanches_flag==1 && ~isempty(station.mailing_list_customer)
                disp(string)
                 iad_send_mail_python_multi(station.mailing_list_customer,['IDA ',upper(station.name),' Alert'],string,station)
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%% AVALANCHES SMS ALERT CUSTOMER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if station.sms_avalanches_flag==1 && ~isempty(station.sms_list_customer)
                for isms=1:length(station.sms_list_customer)
		     %... iad_send_sms_python(recipient,subject,msg,station)
		     %... il subject è il sender dell'sms con smshosting 
                     iad_send_sms_python(station.sms_list_customer{isms},['IDA-Alert'],stringsms,station)
                    
                    pause(1)
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TEvEnd=Ev_Nav.data(ii(end),1);    
            fid=fopen([working_dir,slh,'log',slh,station.mail_pub_logfile],'w');
            fwrite(fid,datestr(TEvEnd,'yyyymmdd_HHMMSS'));
            fclose(fid);
            
                %.. POSTING ALERT TO regObs server
        	if sum(strcmp(upper(station.name),{'NO2', 'NO3'}))==1 ,
        		try
            			iad_To_regObs(station,now,Ev_Nav.data(ii(i),1),'alert')
           			 pause(1)
            			iad_To_regObs_production(station,now,Ev_Nav.data(ii(i),1),'alert')
           			 pause(1)
        		catch
            			disp('!!!! ERROR REGOBS')
        		end
        	end
     
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
        
        

%% SEND MAIL Natural Avalanches TO ITEM
        if ~exist([working_dir,slh,'log',slh,station.mail_av_logfile],'file'),
            last_mailed_time=tt(end)-60/86400;
        else
            string=textread([working_dir,slh,'log',slh,station.mail_av_logfile],'%s');
             % Lettura del logfile che mi restituisce l'ultimo minuto processato
            last_mailed_time=datenum(char(string),'yyyymmdd_HHMMSS');
        end

        if size(Ev_Nav.data,1)>0,
		 string=['Natural Avalanche Alert\nPossible Natural Avalanche detected by ',upper(station.name),' array at\n'];
		stringsms=['LGS ',upper(station.name),' Natural Avalanche Alert at '];

		% Notifiche con soglia a item
            ii=find(Ev_Nav.data(:,1)>last_mailed_time+1/86400);
            
            if ~isempty(ii),
                for i=1:length(ii),
                    string=[string,datestr(Ev_Nav.data(ii(i),1)),'\n'];
                    stringsms=[stringsms,datestr(Ev_Nav.data(ii(i),1))];
                end
                switch upper(station.name)
                    case 'GRY'
                        string=[string,'for further details, please visit http://www.lgs.geo.unifi/map3'];
                    case 'DVS'
                        string=[string,'for further details, please visit http://www.lgs.geo.unifi/davos'];
                end

		disp(['>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MAIL AVALANCHE:',string]);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%% AVALANCHES MAIL ALERT 4 ITEM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if station.mail_avalanches_flag==1 & ~isempty(station.mailing_list_item)
                     iad_send_mail_python_multi(station.mailing_list_item,['LGS ',upper(station.name),' Alert'],string,station.name)
		end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AVALANCHES SMS ALERT ITEM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if station.sms_avalanches_flag==1 & ~isempty(station.sms_list_item)
			for isms=1:length(station.sms_list_item)
				iad_send_sms_python(station.sms_list_item{isms},stringsms,station)
				pause(1)
			end
		end
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                TEvEnd=Ev_Nav.data(ii(end),1);    
            else
                TEvEnd=last_mailed_time;    
            end
        else
             TEvEnd=last_mailed_time;    
        end

        fid=fopen([working_dir,slh,'log',slh,station.mail_av_logfile],'w');
        fwrite(fid,datestr(TEvEnd,'yyyymmdd_HHMMSS'));
        fclose(fid);

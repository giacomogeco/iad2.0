% function iad(net,namestz,ConfFileName)
clear all,
close all
clear function
clear global
warning off
%    function iad(net,namestz,ConfFileName)
% net='wyssen';namestz='no1';ConfFileName='conf_no1_2015_priv.txt';
net='wyssen';namestz='no2';ConfFileName='conf_no2_2015_priv.txt';
% net='wyssen';namestz='gms';ConfFileName='conf_gms1_2015_priv.txt';
% net='wyssen';namestz='gms';ConfFileName='conf_gms1_2016_priv.txt';
% net='wyssen';namestz='gm2';ConfFileName='conf_gms2_2015_priv.txt';
% net='wyssen';namestz='fru';ConfFileName='conf_fru_2015_priv.txt';
% net='wyssen';namestz='fru';ConfFileName='conf_fru_2016_priv.txt';
% net='wyssen';namestz='dvs';ConfFileName='conf_dvs_2015_priv.txt';
% net='wyssen';namestz='prt';ConfFileName='conf_prt_2015_priv.txt';
% net='wyssen';namestz='no3';ConfFileName='conf_no3_2016_priv.txt';
% net='wyssen';namestz='rp1';ConfFileName='conf_rp1_2016_priv.txt';

save('/Users/giacomo/Documents/item/matlab/iad_av_detector/tmp/temp.mat','net','namestz','ConfFileName')
%%%%%%%%%% SET PATHS %%%%%%%%%%%
global working_dir slh
[working_dir,slh]=iad_setpath;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('/Users/giacomo/Documents/item/matlab/iad_av_detector/tmp/temp.mat')

offline=1;		%... offline (1) or realtime (0) analysis 

%%%%%%%%%% STATIONS & PROCESSING PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
station=iad_read_ascii2cell([working_dir,slh,'conf_files',slh,net,slh,ConfFileName]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clock_offset=station.clockoffset;		%... offset (ore) between pc clock and UTC time 

try,delete([working_dir,slh,'tmp',slh,station.last5min_det_file]);end
try,delete([working_dir,slh,'tmp',slh,station.eventfile]);end
try,delete([working_dir,slh,'log',slh,station.mail_av_logfile]);end
try,delete([working_dir,slh,'log',slh,station.mail_ex_logfile]);end
try,delete([working_dir,slh,'log',slh,station.mail_pub_logfile]);end
% try,delete([working_dir,slh,'log',slh,station.elab_logfile]);end
% try,delete([working_dir,slh,'log',slh,station.elab_logfile]);end

mkdir([working_dir,slh,'detections',slh,namestz,'_Det_Av']);
mkdir([working_dir,slh,'detections',slh,namestz,'_Det_Ex']);

istz=1;
on_start=1;
k_fault=0; %%%%%%%%%%%%%% inizializzazione del contatore di riprova di lettura del dato
tstart=floor((now-clock_offset/24)*86400/60)/86400*60+1/1440+station.lag/86400;
knodata=0;

global station
%% LOOP DI PROCESSING
while 1, 

    %... Reading Station Parameters ...%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    station=iad_read_ascii2cell([working_dir,slh,'conf_files',slh,net,slh,ConfFileName]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if now-clock_offset/24<=tstart && offline==0, %... SOLO SE REALTIME
        pause(2)
        disp(['... Waiting for start processing of ',upper(namestz),' infrasonic array'])
        continue
    end
    tstart=floor((now-clock_offset/24)*86400/60)/86400*60+1/1440+station.lag/86400;

    if ~exist([working_dir,slh,'log',slh,station.logfile],'file'),
        disp('log file does not exist ...')
         last_processed_filetime=(now-clock_offset/24)-60/86400;
         
         fid=fopen([working_dir,slh,'log',slh,station.logfile],'w');
         fwrite(fid,datestr(last_processed_filetime,'yyyymmdd_HHMMSS'));
         fclose(fid);
    else
        string=textread([working_dir,slh,'log',slh,station.logfile],'%s');
         % lettura del logfile che mi restituisce l'ultimo minuto processato
        last_processed_filetime=datenum(char(string),'yyyymmdd_HHMMSS');

    end
% last_processed_filetime=now-60/86400*5; %tempo dell'ultimo file processato

    % Generazione dei last files da leggere
    if offline==0
        nowlastname=ceil(last_processed_filetime*86400/60)/86400*60;
        nowname=floor(((now-clock_offset/24)*86400/60))/86400*60-180/86400;
        nownames=nowlastname:1/86400*60:nowname;

        if isempty(nownames),
            nownames=nowname;
        end

        if knodata>15, % ????????????????????
            disp('non arriva dato per troppo tempo....resetto il contatore')
            knodata=0;
            nownames=nowname;
        end
    else
        FROM=input('FROM (yyyy-mm-dd_HH:MM:SS)','s');
        TO=input('TO (yyyy-mm-dd_HH:MM:SS)','s');
        FROM=datenum(FROM,'yyyy-mm-dd_HH:MM:SS');
        TO=datenum(TO,'yyyy-mm-dd_HH:MM:SS');
        nownames=FROM:60/86400:TO;
        if isempty(FROM) || isempty(TO)
            disp('WARNING no correct timestap input data')
            break
        end
    end

    for i15=1:length(nownames),

        to=nownames(i15);
        tend=to+60/86400;%-1/100/86400;      
        disp(['Processing...',datestr(to),'_Lastminute'])

        ktry=0;
        while 1,
            ktry=ktry+1;
            
            disp(['Loading ',upper(namestz),' data From:',datestr(to,0),' To: ',datestr(tend,0)])
            
            
            data=iad_read_ws_data(ConfFileName,working_dir,slh,net,to,tend,[],[]);

            
            if isempty(data)
                eff=0;
            else
                for ich=1:length(station.wschannels)+1
                    if ich==length(station.wschannels)+1
                        tv=data.tt;
                    else
                        eval(['m',num2str(ich),'=','data.(char(station.wschannels(ich)));']);
%                         MD(ich,:)=data.(char(station.wschannels(ich)));
                    end
                end
                eff=100*(sum(isfinite(m1))/(station.smp(1)))/60;
            end

            if ktry>=3,break, end
            
            if eff<90,pause(5),
            else
                break
            end
        end

        if eff<40, continue, end

        if isempty(tv),
            knodata=knodata+1;
            string=textread([working_dir,slh,'log',slh,station.logfile],'%s');
            fid=fopen([working_dir,slh,'log',slh,station.logfile],'w');
            fwrite(fid,char(string));
            fclose(fid);
            pause(1)
            continue
        end
        
        for irc=1:length(station.wschannels)
            eval(['m',num2str(irc),'=','m',num2str(irc),'(:);']);
            %             m1=m1(:);m2=m2(:);m3=m3(:);m4=m4(:);
        end
        tv=tv(:);

        fid=fopen([working_dir,slh,'log',slh,'proc',slh,namestz,'_logproc_', datestr(now,'yyyymmdd'),'.txt'],'a');
        fprintf(fid,datestr(tv(1)));
        fprintf(fid,'\t');
        fprintf(fid,num2str(eff));
        fprintf(fid,'\n');
        fclose(fid);
        disp([num2str(eff),'% of data'])

        tstart=floor((now-clock_offset/24)*86400/60)/86400*60+1/1440+station.lag/86400;

        if on_start==1,
            for ich=1:length(station.wschannels)
                M(ich,:)=eval(['m',num2str(ich)])';
            end
            tt=tv';

            if all(M==0),
                knodata=knodata+1;
                string=textread([working_dir,slh,'log',slh,station.logfile],'%s');
                fid=fopen([working_dir,slh,'log',slh,station.logfile],'w');
                fwrite(fid,char(string));
                fclose(fid);
                pause(1)
                continue
            end

            on_start=0;
        else
             ii=find(tt<tv(1)-60/86400);  
             if ~isempty(ii),
                M(:,ii)='';
                tt(ii)='';
             end

             for ich=1:length(station.wschannels)
                 mm(ich,:)=eval(['m',num2str(ich)])';
             end
%                  mm=[m1';m2';m3';m4';m4'];
%                  mm=mm*Sconv;

            if all(mm==0),
                knodata=knodata+1;
                string=textread([working_dir,slh,'log',slh,station.logfile],'%s');
                fid=fopen([working_dir,slh,'log',slh,station.logfile],'w');
                fwrite(fid,char(string));
                fclose(fid);
                pause(10)
                continue
            end

             M=[M,mm];
             tt=[tt,tv'];
        end
%         Test 50 Hz
%         M=M(:,1:2:end);
%         tt=tt(1:2:end);
%         station.smp=[50 50 50 50];
        
        disp(['Processing from: ',datestr(tt(1),0),' To: ',datestr(tt(end),0)])
	disp('EXPLOSION')
        knodata=0;
        % Processo Detection per ESPLOSIONI
        Det_Ex=iad_mcc_analysis(tt,M,...
            station.ex_window,...
            station.ex_shift,...
            station.ex_frequencyband,...
            station.ex_minconsistency,...
            station.ex_resampling,...
            station.smp(1),...
            station.sensors,...
            station.arrayfile,...
            station.ex_trplts,...
            station.ex_maxlag,...
            station.ex_filterorder,...
            station.ex_filterripple,...
		station.ex_azmaxstd,...
		slh,working_dir);
	disp('AVALANCHES')
        % Processo Detection per VALANGHE naturali e controlled     
        Det_Av=iad_mcc_analysis(tt,M,...
            station.av_window,...
            station.av_shift,...
            station.av_frequencyband,...
            station.av_minconsistency,...
            station.av_resampling,...
            station.smp(1),...
            station.sensors,...
            station.arrayfile,...
            station.av_trplts,...
            station.av_maxlag,...
            station.av_filterorder,...
            station.av_filterripple,...
		station.av_azmaxstd,...
		slh,working_dir);
    
%         iv=Det_Av.data(:,5)>290;
%         Det_Av.data=Det_Av.data(iv,:);

        if isempty(Det_Av) && isempty(Det_Ex),
            fid=fopen([working_dir,slh,'log',slh,station.logfile],'w');
            fwrite(fid,datestr(tend,'yyyymmdd_HHMMSS'));
            datestr(tt(end),'yyyymmdd_HHMMSS')
            fclose(fid);
            continue
        end

        %    Salva detezioni Valanghe su CSV file
        iad_write_csv_dets(tt,Det_Av,working_dir,slh,namestz,'Det_Av') 
	 %    Salva detezioni Valanghe su DB
	if station.det2dB_flag & size(Det_Av.data,1)>0,
		disp('... detections to dB')
       		iad_detections2dB_insert(Det_Av.data,station,tt(1));
	end
        %    Salva detezioni Esplosioni
        iad_write_csv_dets(tt,Det_Ex,working_dir,slh,namestz,'Det_Ex')

        % carica last 5min
        try
            old_det=load([working_dir,slh,'tmp',slh,station.last5min_det_file]);
        catch
            old_det.Det_Ex.data=zeros(1,9);
            old_det.Det_Av.data=zeros(1,9);
        end

            % aggiorna last 5min detection
        ii=find(old_det.Det_Ex.data(:,1)<tt(end)-5/86400*60 | old_det.Det_Ex.data(:,1)==0); %trova le detezioni precedenti 5 min
        if ~isempty(ii),
            old_det.Det_Ex.data(ii,:)='';
        end
        Det_Ex.data=[old_det.Det_Ex.data;Det_Ex.data]; %problema dei doppi
        [i,j]=unique(Det_Ex.data(:,1));
        Det_Ex.data=Det_Ex.data(j,:);

        ii=find(old_det.Det_Av.data(:,1)<tt(end)-5/86400*60 | old_det.Det_Av.data(:,1)==0); %trova le detezioni precedenti 5 min

        if ~isempty(ii),
            old_det.Det_Av.data(ii,:)='';
        end
        Det_Av.data=[old_det.Det_Av.data;Det_Av.data];
        [~,j]=unique(Det_Av.data(:,1));
        Det_Av.data=Det_Av.data(j,:);
             
        save([working_dir,slh,'tmp',slh,namestz,'_last5min_det.mat'],...
            'Det_Ex','Det_Av')
        
%         figure(111),plot(Det_Av.data(:,1),Det_Av.data(:,3),'.')
%         datetick('x',13,'keeplimits')
%         pause
        disp('DET2EV-EX')
        % Ci sono detezioni associate a esplosioni?
        L=station.ex_min_dets_length;
        DT=station.ex_min_dets_continuity;
        [~,~,dts,Ev_Ex]=iad_detections2events_exp(station,DT,L,...
            Det_Ex.data(:,1)',...   % time
            Det_Ex.data(:,2),...    % pressure (Pa)
            Det_Ex.data(:,7),...    % semblance (0-1)
            Det_Ex.data(:,3),...    % backazimuth (�N)
            Det_Ex.data(:,5),...    % app. vel. (m/s)
            Det_Ex.data(:,9),...    % consistency (s)
            Det_Ex.data(:,8),...    % pick frequency (Hz)
            station.ex_window);       

        if Ev_Ex.data(1,1)>0
            Ev_Ex.torretta=[];ii=[];evindexes=[];
            for i=1:size(station.twr_baz,1)

                evindexes=find(Ev_Ex.data(:,8)>station.twr_baz(i,1) & Ev_Ex.data(:,8)<station.twr_baz(i,2) & ...
                    Ev_Ex.data(:,1)>0 & ...
                    Ev_Ex.data(:,6)>station.ex_minpressure & ...
                    Ev_Ex.data(:,10)<station.ex_maxappvel);

                if ~isempty(evindexes),                
                    for itorr=1:length(evindexes)
                        Ev_Ex.torretta=cat(2,Ev_Ex.torretta,station.twr_name(i));
                    end
                    ii=cat(1,ii,evindexes);
                end
                evindexes=[];
            end

            Ev_Ex.data=Ev_Ex.data(ii,:); % filtro in ampiezza e azimuth
        else
            Ev_Ex.torretta=[];
            Ev_Ex.data=[]; % non ci sono esplosioni
        end
        
        % Aggiorno gli eventi esplosivi
        try
            old_ev=load([working_dir,slh,'tmp',slh,station.eventfile]);
        catch
            old_ev.Ev_Ex.data=[];
            old_ev.Ev_Ex.torretta=[];
        end

        if ~isempty(old_ev.Ev_Ex.data),
            % Aggiorna gli eventi
            Ev_Ex.data=[old_ev.Ev_Ex.data;Ev_Ex.data]; %... Problema dei doppi
            Ev_Ex.torretta=[old_ev.Ev_Ex.torretta,Ev_Ex.torretta];
            [~,j]=unique(Ev_Ex.data(:,1));
            Ev_Ex.data=Ev_Ex.data(j,:);
            Ev_Ex.torretta=Ev_Ex.torretta(j);
        end
        
        
        % Leva le detection associate a valanghe presenti durante gli eventi esplosivi             
        if ~isempty(Ev_Ex.data), % Se ha trovato esplosioni...
            for iexp=1:size(Ev_Ex.data,1), % Per tutte le esplosioni
                ii=find(Det_Av.data(:,1)>=Ev_Ex.data(iexp,1)-5/86400 & Det_Av.data(:,1)<=Ev_Ex.data(iexp,2)+5/86400);
                if ~isempty(ii),
                    Det_Av.data(ii,:)=''; % Tolgo le detezione di valanghe nell'intervallo degli eventi esplosivi
                end
            end
        end
    	
	disp('DET2EV-AV')
        %  Trova eventi associati a valanghe
        if ~isempty(Det_Av.data), %se ci sono detection associate a valanghe
            L=station.av_min_dets_length;
            DT=station.av_min_dets_continuity;
            [~,~,dts,Ev_Av]=iad_detections2events(DT,L,...
                Det_Av.data(:,1)',...   % time
                Det_Av.data(:,2),...    % pressure (Pa)
                Det_Av.data(:,7),...    % semblance (0-1)
                Det_Av.data(:,3),...    % backazimuth (�N)
                Det_Av.data(:,5),...    % app. vel. (m/s)
                Det_Av.data(:,9),...    % consistency (s)
                Det_Av.data(:,8),...    % pick frequency (Hz)
                station.av_window);   
        else
            Ev_Av.data=zeros(1,16);
        end

    %              if i15==3,return,end
        % Riconoscimento valanghe controllate da naturali       
        if Ev_Av.data(1,1)>0, % ciclo di riconoscimento valanghe naturali dalle controllate

            if isempty(Ev_Ex.data), % se non ci sono esplosioni...
                Ev_Nav=Ev_Av; % tutti gli eventi sono Naturali
                Ev_Cav.data=[]; % non ci sono controlled avalanches
            else % se ci sono invece esplosioni

                Ev_Cav=Ev_Av; % associo tutti gli eventi a Controlled e poi ripulisco
                Ev_Nav.data=[]; %%%%%%%!!!!!!!
                
                ii=find(Ev_Cav.data(:,1)>0 & Ev_Cav.data(:,6)>0  & Ev_Cav.data(:,3)>station.cav_minduration);    %% ?????????????????????????????????
                Ev_Cav.data=Ev_Cav.data(ii,:); % filtro in ampiezza (per ora nn si sta usando)

                %% Trova tra gli eventi di valanga compatibilit� temporale ed azimuthale con le esplosioni
                k=0;
                for icav=size(Ev_Cav.data,1):-1:1,
                    ff=Ev_Cav.data(icav,1)-Ev_Ex.data(:,1);
                    ii=find(ff<station.cav_maxlag*60/86400 & ff>0); % vedo se c'e' un'esplosione entro due minuti dall'evento possibile di valangha
                    if isempty(ii), % se c'e' una valangha entro la soglia temporale
                        disp('incompatibile in tempo')
                        k=k+1;
                        Ev_Nav.data(k,:)=Ev_Cav.data(icav,:);
                        Ev_Cav.data(icav,:)=[]; %levare dal dataset Cav tutti gli eventi che non stanno entro i due minuti da un'esplosione
                    else
                        for iexp=1:length(ii),
                            azz=Ev_Ex.data(ii(iexp),8);
                            azza=Ev_Cav.data(icav,8);
                            zz=abs(rad2deg(abs(atan2(sind(azz-azza), cosd(azz-azza)))));
                            
                            izz=find(zz<station.cav_azlag); % Compatibilit� in azimuth
                            
                            if isempty(izz),
                                k=k+1;
                                disp('Incompatibile in azimuth')
                                Ev_Nav.data(k,:)=Ev_Cav.data(icav,:);
                                if iexp==length(ii),
                                    Ev_Cav.data(icav,:)=[];
                                end
                            else
                                disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Controlled Avalanches detected')
                                break
                            end
                        end
                    end
                end
            %% ripulisti degli eventi esplosivi                                                  
%                     ii=find(Ev_Ex.data(:,1)<tt(end)-5/86400*60); %trova le detezioni precedenti 5 min
%                     if ~isempty(ii),
%                         Ev_Ex.data(ii,:)=''; %problema dei doppi
%                     end     
%                     uploadDB(NatAV)
            end
        else % se non ci sono Ev_Av 
            Ev_Nav.data=[];
            Ev_Cav.data=[];
        end

        
%         evts.legend={'1.Tempo inizio finestra';'2.Tempo fine finstra';'3.Durata';'4.Coerenza media';...
%     '5.Coerenza STD';'6.Pressione max';'7.Pressione STD';'8.Azimuth medio';'9.Azimuth STD';...
%     '10.Velocity media';'11.Velocity max';'12.Velocity STD';'13.Frequenza media';'14.Frequenza STD';...
%     '15.Consistenza media';'16.Consistenza STD'};
        
        % Selezione valanghe naturali in base ad Ampiezza, Durata, App. Vel.,... 
        
        
        if size(Ev_Nav.data,1)>0,
            iprobabilistic=find(Ev_Nav.data(:,3)>station.nav_mindur(1) & ... %... station.nav_mindur ???????????????????????????????
                Ev_Nav.data(:,6)>station.nav_minpressure(1) & ...
                Ev_Nav.data(:,9)<10000 & ...
                Ev_Nav.data(:,11)<station.nav_maxvel(1) & ...
                Ev_Nav.data(:,12)<station.nav_maxveltrend(1) & ...
                Ev_Nav.data(:,10)<station.nav_meanvel(1));
            
            
            if ~isempty(iprobabilistic),
                %... Associao probabilit 50% (low probability) a tutti gli eventi
                Ev_Nav.data=Ev_Nav.data(iprobabilistic,:);
                Ev_Nav.data(:,17)=.5*ones(1,length(iprobabilistic));
				
				ideterministic=find(Ev_Nav.data(:,3)>station.nav_mindur(2) & ... %... station.nav_mindur ???????????????????????????????
					Ev_Nav.data(:,6)>station.nav_minpressure(2) & ...
					Ev_Nav.data(:,9)<10000 & ...
					Ev_Nav.data(:,11)<station.nav_maxvel(2) & ...
					Ev_Nav.data(:,12)<station.nav_maxveltrend(2) & ...
					Ev_Nav.data(:,10)<station.nav_meanvel(2));
				
                if ~isempty(ideterministic)
                    %... Associao probabili 100% (high probability) a gli eventi sopra la seconda soglia
                    Ev_Nav.data(ideterministic,17)=ones(1,length(ideterministic));
                end
           else
                Ev_Nav.data=[];
            end
        end

        % Merge eventi vecchi
        try
            old_ev=load([working_dir,slh,'tmp',slh,station.eventfile]);
        catch 
            old_ev.Ev_Ex.data=[];
            old_ev.Ev_Ex.torretta=[];
            old_ev.Ev_Nav.data=[];
            old_ev.Ev_Cav.data=[];
        end

        if ~isempty(old_ev.Ev_Ex.data),
        % aggiorna gli eventi
        %              ii=find(old_ev.Ev_Ex.data(:,1)<tt(end)-5/86400*60); %trova le detezioni precedenti 5 min
        %              if ~isempty(ii)
            ii=1:size(old_ev.Ev_Ex.data,1);
            Ev_Ex.data=[old_ev.Ev_Ex.data(ii,:);Ev_Ex.data]; %problema dei doppi
            Ev_Ex.torretta=[old_ev.Ev_Ex.torretta(ii),Ev_Ex.torretta];
        %              end
        end

        if ~isempty(old_ev.Ev_Nav.data),
        %              ii=find(old_ev.Ev_Nav.data(:,1)<tt(end)-5/86400*60); %trova le detezioni precedenti 5 min
        %              if ~isempty(ii),
            ii=1:size(old_ev.Ev_Nav.data,1);
            Ev_Nav.data=[old_ev.Ev_Nav.data(ii,:);Ev_Nav.data];
        %              end
        end

        if ~isempty(old_ev.Ev_Cav.data),
        %              ii=find(old_ev.Ev_Cav.data(:,1)<tt(end)-5/86400*60); %trova le detezioni precedenti 5 min
        %              if ~isempty(ii),
            ii=1:size(old_ev.Ev_Cav.data,1);
            Ev_Cav.data=[old_ev.Ev_Cav.data(ii,:);Ev_Cav.data];
        %              end
        end


        % Ripulisti delle sovrapposizioni degli eventi
        if size(Ev_Cav.data,1)>0,
        %                [i,j]=unique(Ev_Cav.data(:,1));
        %                [ii,jj]=unique(Ev_Cav.data(:,2));
        %                [j,i]=unique([j;jj]);
        %                Ev_Cav.data=Ev_Cav.data(j,:);
            if ~isempty(Ev_Ex.data), %se ha trovato esplosioni...
                for iexp=1:size(Ev_Ex.data,1), %per tutte le esplosioni
                    ii=find(Ev_Cav.data(:,1)>=Ev_Ex.data(iexp,1)-5/86400 & Ev_Cav.data(:,1)<=Ev_Ex.data(iexp,2)+5/86400);
                    if ~isempty(ii),
                        Ev_Cav.data(ii,:)=''; % Tolgo le detezione di valanghe nell'intervallo degli eventi esplosivi
                    if isempty(Ev_Cav.data),
                        break
                    end

                    end
                end
            end
        end

        i=size(Ev_Cav.data,1);
        while 1
            if i<=0,
                break
            end 
            ti=Ev_Cav.data(i,1);
            te=Ev_Cav.data(i,2);
            ii=find(Ev_Cav.data(:,1)>=ti & Ev_Cav.data(:,1)<=te);
            if length(ii)>1,
                Ev_Cav.data(ii(ii~=i),:)='';
                i=size(Ev_Cav.data,1)-1;
            else
                i=i-1;
            end
        end
    % 
        if size(Ev_Cav.data,1)>0,
            try
                iad_refresh_database(station.dB_Cav_name,Ev_Cav.data,[],tt(end)-900/86400,...
                    station)
            catch
                disp('!!!!!!!!!!!!!! ERROR POPULATING dB')
            end
        end

        i=size(Ev_Nav.data,1);
        while 1
            if i<=0,
                break
            end  

            ti=Ev_Nav.data(i,1);
            te=Ev_Nav.data(i,2);

            ii=find(Ev_Nav.data(:,1)>=ti & Ev_Nav.data(:,1)<=te);
            if length(ii)>1,
                Ev_Nav.data(ii(ii~=i),:)='';
                i=size(Ev_Nav.data,1)-1;
            else
                i=i-1;
            end
        end
        
        
        if size(Ev_Nav.data,1)>0,
            try
                iad_refresh_database(station.dB_Nav_name,Ev_Nav.data,[],tt(end)-900/86400,station) %GMT+1h
            catch 
                disp('!!!!!!!!!!!!!! ERROR POPULATING dB')
            end
        end

        i=size(Ev_Ex.data,1);
        while 1
            if i<=0,
                break
            end  

            ti=Ev_Ex.data(i,1);
            te=Ev_Ex.data(i,2);

            ii=find(Ev_Ex.data(:,1)>=ti & Ev_Ex.data(:,1)<=te);
            if length(ii)>1,
                Ev_Ex.data(ii(ii~=i),:)=[];
                Ev_Ex.torretta(ii(ii~=i))=[];
                i=size(Ev_Ex.data,1)-1;
            else
                i=i-1;
            end
        end

        if size(Ev_Ex.data,1)>0,
            try
                iad_refresh_database(station.dB_Ex_name,Ev_Ex.data,Ev_Ex.torretta,tt(end)-900/86400,...
                    station)
            catch
                disp('!!!!!!!!!!!!!! ERROR POPULATING dB')
            end
        end


        % Salva eventi nel file eventfile
        if size(Ev_Ex.data,1)>0,
            ii=find(Ev_Ex.data(:,1)<tt(end)-1); % Trova le detezioni precedenti 5 min
            if ~isempty(ii),
                Ev_Ex.data(ii,:)=''; % Problema dei doppi
                Ev_Ex.torretta(ii)='';
            end     
        end

        if size(Ev_Cav.data,1)>0,
            ii=find(Ev_Cav.data(:,1)<tt(end)-1); % Trova le detezioni precedenti 5 min
            if ~isempty(ii),
                Ev_Cav.data(ii,:)=''; % Problema dei doppi
            end     
        end     
            
        save([working_dir,slh,'tmp',slh,station.eventfile],...
            'Ev_Ex','Ev_Nav','Ev_Cav')

       % log file
        if tt(end)>0,
            fid=fopen([working_dir,slh,'log',slh,station.logfile],'w');
            fwrite(fid,datestr(tt(end),'yyyymmdd_HHMMSS'));
            disp([station.logfile,' created: ',datestr(tt(end),'yyyymmdd_HHMMSS')])
            fclose(fid);
        end

        string=textread([working_dir,slh,'log',slh,station.logfile],'%s');
        % Lettura del logfile che mi restituisce l'ultimo minuto processato
        last_processed_filetime=datenum(char(string),'yyyymmdd_HHMMSS');
	disp(['LPT: ',datestr(last_processed_filetime)])
            


	% MAIL ALERT EXPLOSIONS
        iad_sendmail_explosions

    % MAIL ALERT AVALANCHES 4 CUSTOMER
        iad_sendmail_avalanches_customer

	% MAIL ALERT AVALANCHES 4 ITEM
        iad_sendmail_avalanches_item

	 
        
    end %   fine ciclo last minute file
    if offline==1;
        iad_plot_results
        break
    end
%       pause(60)      
end % while 1


return
     



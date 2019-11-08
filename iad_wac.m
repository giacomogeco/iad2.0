% function iad_wac(net,namestz,winter,offline)
clear function
clear global
% clear all,
close all
clc
% net='wyssen';namestz='rsp';winter = '2018';offline = true;    %... Test 04-Jan-2019 01:10:00 - 04-Jan-2019 03:50:00 ok
net='wyssen';namestz='lpb';winter = '2018';offline = true;
% net='wyssen';namestz='hrm';winter = '2018';offline = true;

% net='wyssen';namestz='gtn';winter = '2019';offline = false;   %... test1 ok
% net='wyssen';namestz='lvn';winter = '2019';offline = false;   %... test1 ok
% net='wyssen';namestz='hrm';winter = '2019';offline = false;
% net='wyssen';namestz='lpb';winter = '2019';offline = false;
warning off
save([namestz,'_temp.mat'],'net','namestz','winter','offline')
%%%%%%%%%% SET PATHS %%%%%%%%%%%
global working_dir slh
[working_dir,slh]=iad_setpath;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([namestz,'_temp.mat'])
if offline
	cmdstring=['rm ',working_dir,slh,'tmp',slh,'*.mat'];system(cmdstring)
end
%%%%%%%%%% STATIONS & PROCESSING PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global station  % TODO check if gloal is necessary
station = iad_read_ascii2cell([working_dir,slh,'confElab',slh,net,slh,winter,slh,'conf',upper(namestz),'.txt']);
load([working_dir,slh,'arrays',slh,net,slh,winter,slh,'array',upper(namestz),'.mat']);  %... array variables 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clock_offset=station.clockoffset;		%... offset (ore) between pc clock and UTC time 
try delete([working_dir,slh,'tmp',slh,upper(namestz),'_LastDets.mat']);end
try delete([working_dir,slh,'tmp',slh,upper(namestz),'_events.mat']);end
try delete([working_dir,slh,'log',slh,upper(namestz),'.log']);end
mkdir([working_dir,slh,'detections',slh,namestz,'_Det_Av']);
mkdir([working_dir,slh,'detections',slh,namestz,'_Det_Ex']);
on_start=1;
tstart=floor((now-clock_offset/24)*86400/60)/86400*60+1/1440+station.lag/86400;
knodata=0;
nowOld=now();%... Sandro 12122018
sendTestRunning=false;%... End Sandro 12122018
%% LOOP DI PROCESSING
while 1
    %... Reading Station Parameters ...%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    station=iad_read_ascii2cell([working_dir,slh,'confElab',slh,net,slh,winter,slh,'conf',upper(namestz),'.txt']);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if now-clock_offset/24<=tstart && ~offline %... SOLO SE REALTIME
        pause(5)
        disp(['... Waiting for start processing of ',(char(array.locationName)),'. Next Start at ',datestr(tstart)])
        continue
    end
    if ~exist([working_dir,slh,'log',slh,upper(namestz),'.log'],'file')
        disp('log file does not exist ...')
         last_processed_filetime=tstart-1/1440-station.lag/86400;       
         fid=fopen([working_dir,slh,'log',slh,upper(namestz),'.log'],'w');
         fwrite(fid,datestr(last_processed_filetime,'yyyymmdd_HHMMSS'));
         fclose(fid);
    else
        string=textread([working_dir,slh,'log',slh,upper(namestz),'.log'],'%s');
        last_processed_filetime=datenum(char(string),'yyyymmdd_HHMMSS');   % lettura del logfile che mi restituisce l'ultimo minuto processato
        disp(['LAST PROCESSED TIME SAVED: ',datestr(last_processed_filetime)])
    end     % last_processed_filetime=now-60/86400*5; %tempo dell'ultimo file processato      
    if ~offline   % Generazione dei last files da leggere
        latency = 1440 * (tstart - last_processed_filetime);
        disp(['LATENCY: ',num2str(latency),' minutes'])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% REAL-TIME TRIGGER TIME UPDATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tstart=floor((now-clock_offset/24)*86400/60)/86400*60+1/1440+station.lag/86400;
        disp(['NEXT TIME TRIGGER TIME : ',datestr(tstart)])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        FROM=input('FROM (yyyy-mm-dd_HH:MM:SS)','s');
        TO=input('TO (yyyy-mm-dd_HH:MM:SS)','s');
        FROM=datenum(FROM,'yyyy-mm-dd_HH:MM:SS');
        TO=datenum(TO,'yyyy-mm-dd_HH:MM:SS');
        last_processed_filetime = FROM:60/86400:TO+1/1440;      
        tic
        if isempty(FROM) || isempty(TO)
            disp('WARNING no correct timestap input data')
            break
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN ELAORATION LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['>>>>>>>>>>>>>>>> START PROCESSING LOOP from: ',datestr(last_processed_filetime(1)),' to: ',datestr(last_processed_filetime(end)),' <<<<<<<<<<<<<<<<<'])
    for i15=1:length(last_processed_filetime)
        tend=last_processed_filetime(i15);
        to=tend-120/86400;     
        ktry=0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ATTEMPT TO GET DATA F$ORM SERVER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        while 1 %... provo 2 volte con 1 secondi di pausa a prendere l'ultimo minuto di dato dal server  (~ 10 s)
            ktry=ktry+1;           
            disp(['Loading ',upper(namestz),' data From:',datestr(to,0),' To: ',datestr(tend,0)])
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GET DATA FROM WAC.3 SERVER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            data=iadReadWAC3Data(array,station,to,tend);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isempty(data)
                eff=0;
            else               
                data = structfun(@(x) ( x' ), data, 'UniformOutput', false);
                icut=data.tt>=to & data.tt<tend;
                data = structfun(@(x) ( x(icut) ), data, 'UniformOutput', false); 
                eff = zeros(1,length(array.snid));
                for ich=1:length(array.snid)+1
                    if ich==length(array.snid)+1
                        tv=data.tt;
                    else
                        eval(['m',num2str(ich),'=','data.(char(array.snid(ich)));']);
                        eff(ich) = 100*(sum(isfinite(eval(['m',num2str(ich)])))/(station.smp(1)))/120;   %... Giacomo 24 Ott 2019
                    end
                end
                eff=eff(station.sensors==1);
                eff = mean(eff);  %... Giacomo 24 Ott 2019
            end
            if ktry >= 2
                break
            end            
            if eff<70,pause(1),
            else
                break       % GOOD
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LOG PROCESSS FILES UPDATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fid=fopen([working_dir,slh,'log',slh,'proc',slh,namestz,'_logproc_', datestr(now,'yyyymmdd'),'.txt'],'a');
        fprintf(fid,datestr(last_processed_filetime));
        fprintf(fid,'\t');
        fprintf(fid,num2str(eff));
        fprintf(fid,'\n');
        fclose(fid);     
        disp([num2str(eff),'% of data'])
        if eff<90        
            disp('!!!!!!!!!!!!!  WARNING NO ENOUGHT DATA (< 70%) ON LAST MINUTE REQUEST !!!!!!!!!!!!!!!!!')
            string=textread([working_dir,slh,'log',slh,upper(namestz),'.log'],'%s');
            fid=fopen([working_dir,slh,'log',slh,upper(namestz),'.log'],'w');
            fwrite(fid,datestr(last_processed_filetime+1/1440,'yyyymmdd_HHMMSS'));   %... Giacomo 24 Ott 2019
            fclose(fid);
            continue 
        end       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MCCA ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        M=[];
        for irc=1:length(array.snid)
%             eval(['m',num2str(irc),'=','m',num2str(irc),'(:);']);
            M(irc,:)=eval(['m',num2str(irc)])';
        end
        tt=tv(:);      
        if station.ExplYes
            disp('MCCA - High frequency (1-15 Hz, i.e. explosions) Analysis')
            disp(['Processing: ',datestr(tt(1),0),' To: ',datestr(tt(end),0)])
%             disp('EXPLOSION DETECTIONS')
            knodata=0;
            Det_Ex=iad_mcc_analysis(tt,M,station,array,'explosions'); % Processo Detection per ESPLOSIONI

        else
            Det_Ex.data=[];
        end
        disp('MCCA - Low frequency (1-7 Hz) Analysis')
        disp(['Processing: ',datestr(tt(1),0),' To: ',datestr(tt(end),0)])
        Det_Av=iad_mcc_analysis(tt,M,station,array,'avalanches');
        if ~isempty(station.noisezones) %... remove detections from stationary noise zones
            for inzs=1:size(station.noisezones,1)
                inoi=Det_Av.data(:,3)>station.noisezones(inzs,1) & Det_Av.data(:,3)<station.noisezones(inzs,2);
                Det_Av.data(inoi,:)=[];
                disp([num2str(sum(inoi)),'.............................. Noisy Detections Removed'])
            end
        end	
        if isempty(Det_Av.data) && isempty(Det_Ex.data)
            fid=fopen([working_dir,slh,'log',slh,upper(namestz),'.log'],'w');
            fwrite(fid,datestr(tend,'yyyymmdd_HHMMSS'));
            fclose(fid);
            disp('.............................. No Raw Detections')
            continue
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Storage raw detections %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(Det_Av.data)    %    Salva detezioni Valanghe su CSV file
            iad_write_csv_dets(tt,Det_Av,working_dir,slh,namestz,'Det_Av') 
        end
        if ~isempty(Det_Ex.data)    %    Salva detezioni Esplosioni su CSV file
            iad_write_csv_dets(tt,Det_Ex,working_dir,slh,namestz,'Det_Ex')
        end 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Buffering Last Detections for RT alerting  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        try %   
            old_det=load([working_dir,slh,'tmp',slh,upper(namestz),'_LastDets.mat']);    % carica last 5min
        catch
            old_det.Det_Ex.data=zeros(1,10);
            old_det.Det_Av.data=zeros(1,10);
        end
        ii=find(old_det.Det_Ex.data(:,1)<tt(end)-station.rawDetBuffer/1440 | old_det.Det_Ex.data(:,1)==0); %trova le detezioni precedenti 5 min
        if ~isempty(ii)
            old_det.Det_Ex.data(ii,:)='';
        end
        Det_Ex.data=[old_det.Det_Ex.data;Det_Ex.data]; %... ??? problema dei doppi ???
        [~,j]=unique(Det_Ex.data(:,1));
        Det_Ex.data=Det_Ex.data(j,:);      
        ii=find(old_det.Det_Av.data(:,1)<tt(end)-station.rawDetBuffer/1440 | old_det.Det_Av.data(:,1)==0); %trova le detezioni precedenti 5 min
        if ~isempty(ii)
            old_det.Det_Av.data(ii,:)='';
        end
        Det_Av.data=[old_det.Det_Av.data;Det_Av.data];
        [~,j]=unique(Det_Av.data(:,1));
        Det_Av.data=Det_Av.data(j,:);           
        save([working_dir,slh,'tmp',slh,upper(namestz),'_LastDets.mat'],'Det_Ex','Det_Av')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DET2EVS  EXPLOSIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(Det_Ex.data)    % Ci sono detezioni associate a esplosioni?
            disp('GROUPING - High frequency (1-15 Hz, i.e. explosions) Detection Grouping')
            L=station.ex_min_dets_length;
            DT=station.ex_min_dets_continuity;
            [~,~,dts,Ev_Ex]=iad_detections2events_exp(station,DT,L,...
                Det_Ex.data(:,1)',...   % time
                Det_Ex.data(:,2),...    % pressure (Pa)
                Det_Ex.data(:,7),...    % semblance (0-1)
                Det_Ex.data(:,3),...    % backazimuth (???N)
                Det_Ex.data(:,5),...    % app. vel. (m/s)
                Det_Ex.data(:,9),...    % consistency (s)
                Det_Ex.data(:,8),...    % pick frequency (Hz)
                Det_Ex.data(:,10),...   % Explosion Index (Sandro 2017)
                station.ex_shift);       
        else
            Ev_Ex.data=[];
        end     
        if ~isempty(Ev_Ex.data)
            disp('>>>> ALERT: POSSILE EXPLOSION EVENTS DETECTED <<<<<')
            Ev_Ex.torretta=[];ii=[];evindexes=[];
            for i=1:size(station.twr_baz,1)
%                  zz=abs(rad2deg(abs(atan2(sind(azz-azza), cosd(azz-azza)))));
                if station.twr_baz(i,1)>station.twr_baz(i,2)
                    out = iad_check_unwrap ( station.twr_baz(i,:) );    
                    out2=wrapTo180(Ev_Ex.data(:,8));
                    evindexes=find(out2>=out(1) & out2<=out(2) & ...
                    Ev_Ex.data(:,6)>station.ex_minpressure(1) & ...     %... no pressure threshold
                    Ev_Ex.data(:,10)<station.ex_maxappvel);
                else
                    evindexes=find(Ev_Ex.data(:,8)>=station.twr_baz(i,1) & Ev_Ex.data(:,8)<=station.twr_baz(i,2) & ...
                        Ev_Ex.data(:,6)>station.ex_minpressure(1) & ...     %... no pressure threshold
                        Ev_Ex.data(:,10)<station.ex_maxappvel);
                end
                if ~isempty(evindexes)               
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DETECTION REMOVING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Leva le detection associate a valanghe presenti durante gli eventi esplosivi             
        if ~isempty(Ev_Ex.data) % Se ha trovato esplosioni...
            for iexp=1:size(Ev_Ex.data,1) % Per tutte le esplosioni
                ii=find(Det_Av.data(:,1)>=Ev_Ex.data(iexp,1)-5/86400 & Det_Av.data(:,1)<=Ev_Ex.data(iexp,2)+5/86400);
                if ~isempty(ii)
                    Det_Av.data(ii,:)=''; % Tolgo le detezione di valanghe nell'intervallo degli eventi esplosivi
                end
            end
        end   	
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DET2EVS  AVALANCHES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('GROUPING - Low Frequency (1-7 Hz) Detections Grouping')
        %  Trova eventi associati a valanghe
        if ~isempty(Det_Av.data) %se ci sono detection associate a valanghe
            L=station.av_min_dets_length;
            DT=station.av_min_dets_continuity;
            [~,~,dts,Ev_Av]=iadGroupingDets(DT,L,...
                Det_Av.data(:,1)',...   % time
                Det_Av.data(:,2),...    % pressure (Pa)
                Det_Av.data(:,7),...    % semblance (0-1)
                Det_Av.data(:,3),...    % backazimuth (???N)
                Det_Av.data(:,5),...    % app. vel. (m/s)
                Det_Av.data(:,9),...    % consistency (s)
                Det_Av.data(:,8),...    % pick frequency (Hz)
                Det_Av.data(:,10),...   % Explosion Index (Sandro 2017)   %%%%%%%%%%%%%Det_Av.data(:,10),...   % Explosion Index (Sandro 2017)
                station.av_shift);   
        else
            Ev_Av.data=[];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EVENTS CLASSIFICATION (Controlled or not) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        if ~isempty(Ev_Av.data) % ciclo di riconoscimento valanghe naturali dalle controllate
            if isempty(Ev_Ex.data) % se non ci sono esplosioni...
                Ev_Nav=Ev_Av; % tutti gli eventi sono Naturali
                Ev_Cav.data=[]; % non ci sono controlled avalanches
            else % se ci sono invece esplosioni
                Ev_Cav=Ev_Av; % associo tutti gli eventi a Controlled e poi ripulisco
                Ev_Nav.data=[]; %%%%%%%!!!!!!!
                ii=find(Ev_Cav.data(:,1)>0 & Ev_Cav.data(:,6)>station.cav_minpressure  & Ev_Cav.data(:,3)>station.cav_minduration);    %% ?????????????????????????????????
                Ev_Cav.data=Ev_Cav.data(ii,:); 
                k=0;
                for icav=size(Ev_Cav.data,1):-1:1   % Trova tra gli eventi di valanga compatibilit??? temporale ed azimuthale con le esplosioni
                    ff=Ev_Cav.data(icav,1)-Ev_Ex.data(:,1);
                    ii=find(ff>station.cav_minlag/86400 & ff<station.cav_maxlag*60/86400); % vedo se c'e' un'esplosione entro due minuti dall'evento possibile di valangha
                    if isempty(ii) % se non c'e' una valangha entro la soglia temporale
                        disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Time-criterion Incompatible')
                        k=k+1;
                        Ev_Nav.data(k,:)=Ev_Cav.data(icav,:);
                        Ev_Cav.data(icav,:)=[]; %levare dal dataset Cav tutti gli eventi che non stanno entro i due minuti da un'esplosione
                    else
                        for iexp=1:length(ii)
                            azz=Ev_Ex.data(ii(iexp),8);
                            azza=Ev_Cav.data(icav,8);
                            zz=abs(rad2deg(abs(atan2(sind(azz-azza), cosd(azz-azza)))));                            
                            izz=find(zz<station.cav_azlag); % Compatibilit??? in azimuth                           
                            if isempty(izz)
                                k=k+1;
                                disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  Azimuth-criterion Incompatible')
                                Ev_Nav.data(k,:)=Ev_Cav.data(icav,:);
                                if iexp==length(ii)
                                    Ev_Cav.data(icav,:)=[];
                                end
                            else
                                disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Controlled Avalanches detected')
                                break
                            end
                        end
                    end
                end
            end
        else % se non ci sono Ev_Av 
            Ev_Nav.data=[];
            Ev_Cav.data=[];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% REMOVING EVENTS ALONG THE VALLEY CLASSIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(station.nav_shadowzones) && size(Ev_Nav.data,1)>0       %... remove events along valley (Jan 2017)    
            for inzs=1:size(station.nav_shadowzones,1)               
                 if station.nav_shadowzones(inzs,1)>station.nav_shadowzones(inzs,2)
                    out = iad_check_unwrap ( station.nav_shadowzones(inzs,:) );    
                    out2=wrapTo180(Ev_Nav.data(:,8));                   
                    inoi=out2>out(1) & out2<out(2);
                    Ev_Nav.data(inoi,:)=[];
                    disp(['.............................. Shadow Zone Events removed: ',num2str(sum(inoi))])                                      
                else
                    inoi=Ev_Nav.data(:,8)>station.nav_shadowzones(inzs,1) & Ev_Nav.data(:,8)<station.nav_shadowzones(inzs,2);
                    Ev_Nav.data(inoi,:)=[];
                    disp(['.............................. Shadow Zone Events removed: ',num2str(sum(inoi))])
                 end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%% AVALANCHES RECOGNITIONS (WAVE PARAMETERS THRESHOLDS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(Ev_Nav.data)
            iprobabilistic=find(Ev_Nav.data(:,3) > station.nav_mindur(1) & ...    %... Duration
                Ev_Nav.data(:,6) > station.nav_minpressure(1) & ...               %... Amplitude
                Ev_Nav.data(:,11) < station.nav_maxvel(1) & ...                   %... App. Vel.
                Ev_Nav.data(:,19) < station.nav_maxveltrend(1) & ...                                        %... App. Vel. "trend"
                Ev_Nav.data(:,10) < station.nav_meanvel(1) & ...                  %... App. Vel.
                Ev_Nav.data(:,10) > station.nav_minvel(1) & ...
                abs(Ev_Nav.data(:,21)-Ev_Nav.data(:,20)) < station.nav_maxbazstd(1));                       %... App. Vel.         
            if ~isempty(iprobabilistic)
                Ev_Nav.data=Ev_Nav.data(iprobabilistic,:);  %... Associao probabilit 50% (low probability) a tutti gli eventi
                Ev_Nav.data(:,17)=.5*ones(1,length(iprobabilistic));				
%                 abs(Ev_Nav.data(:,21)-Ev_Nav.data(:,20))
%                 station.nav_maxbazstd(2)                
                ideterministic=find(Ev_Nav.data(:,3)>station.nav_mindur(2) & ...    %... Duration
                    Ev_Nav.data(:,6)>station.nav_minpressure(2) & ...               %... Amplitude
                    Ev_Nav.data(:,11)<station.nav_maxvel(2) & ...                   %... App. Vel.
                    Ev_Nav.data(:,19)<station.nav_maxveltrend(2) & ...                                      %... App. Vel. "trend"
                    Ev_Nav.data(:,10)<station.nav_meanvel(2) & ...                  %... App. Vel.
                    Ev_Nav.data(:,10)>station.nav_minvel(2) & ...
                    abs(Ev_Nav.data(:,21)-Ev_Nav.data(:,20)) < station.nav_maxbazstd(2) | ... %... App. Vel.
                   (Ev_Nav.data(:,3)>100 & Ev_Nav.data(:,6)>.8));  % se dura pi?? di 100s e la pressione supera 0.2                     				
                if ~isempty(ideterministic) %... Associao probabili 100% (high probability) a gli eventi sopra la seconda soglia
                    Ev_Nav.data(ideterministic,17)=ones(1,length(ideterministic));
                end
            else
                Ev_Nav.data=[];
            end
        else
            Ev_Nav.data=[];
        end     
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CLEAN OVERLAPPING AND TAIL EVENTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        LastEv = iadReadLastEv(working_dir, slh, array, last_processed_filetime(i15)-1/24, last_processed_filetime(i15)); % TODO remove now
        if ~isnan(LastEv.dur(1)) && ~isempty(Ev_Nav.data) 
            iCav = strmatch('Cav',LastEv.type);          
            if ~isempty(iCav) 
                disp('pippa')
                LastCavStartTime = LastEv.tim(iCav);
                LastCavDur = LastEv.dur(iCav);
                k = 0;
                iD = [];
                for ido = 1:length(LastCavStartTime)
                    ii = find(Ev_Nav.data(:,1) >= LastCavStartTime(ido) & Ev_Nav.data(:,1) < LastCavStartTime(ido) + LastCavDur(ido)/86400);
                    if ~isempty(ii)
                        k = k + 1;
                        iD(k) = ii;
                    end
                end
                if ~isempty(iD)
                    disp('.............................. Cav that turn into Nav Event removed')
                    Ev_Nav.data(iD,:) = [];
                end 
            end
        end    

        if ~isnan(LastEv.dur(1))
            if ~isempty(Ev_Ex.data)
                iEx = strmatch('Ex',LastEv.type);
                if ~isempty(iEx)
                    LastEvTime = LastEv.tim(iEx);
                    LastEvDur = LastEv.dur(iEx);
                    k = 0;
                    iD = [];
                    for ido = 1:length(LastEvTime)
                        ii = find(Ev_Ex.data(:,1) > LastEvTime(ido) & Ev_Ex.data(:,1) < LastEvTime(ido) + LastEvDur(ido)/86400);
                        if ~isempty(ii)
                            k = k + 1;
                            iD(k) = ii;
                        end
                    end
                    if ~isempty(ii)
                        Ev_Ex.data(iD,:) = [];
                        disp('.............................. tailing Ex Event removed')
                    end
                end       
            end
            if ~isempty(Ev_Cav.data)
                iCav = strmatch('Cav',LastEv.type);
                if ~isempty(iCav)
                    LastEvTime = LastEv.tim(iCav);
                    LastEvDur = LastEv.dur(iCav);
                    k = 0;
                    iD = [];
                    for ido = 1:length(LastEvTime)
                        ii = find(Ev_Cav.data(:,1) > LastEvTime(ido) & Ev_Cav.data(:,1) < LastEvTime(ido) + LastEvDur(ido)/86400);
                        if ~isempty(ii)
                            k = k + 1;
                            iD(k) = ii;
                        end
                    end
                    if ~isempty(ii)
                        Ev_Cav.data(iD,:) = [];
                        disp('.............................. tailing Cav Event removed')
                    end
                end
            end           
            if ~isempty(Ev_Nav.data)                
                iNav = strmatch('Nav',LastEv.type);
                if ~isempty(iNav)
                    LastEvTime = LastEv.tim(iNav);
                    LastEvDur = LastEv.dur(iNav);
                    k = 0;
                    iD = [];
                    for ido = 1:length(LastEvTime)
                        ii = find(Ev_Nav.data(:,1) > LastEvTime(ido) & Ev_Nav.data(:,1) < LastEvTime(ido) + LastEvDur(ido)/86400);
                        if ~isempty(ii)
                            k = k + 1;
                            iD(k) = ii;
                        end
                    end
                    if ~isempty(iD)
                        disp('.............................. tailing Nav Event removed')
                        Ev_Nav.data(iD,:) = [];
                    end
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TEST ALERTING /(Sandro 12/12/2018) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(isfield(station,'testTime'))
%             iadNotificationTest
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% POSTING ALERTs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        iadNotifications
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%         if tt(end)>0    % log file ?????????????????????????????????????
%             fid=fopen([working_dir,slh,'log',slh,upper(namestz),'.log'],'w');
%             fwrite(fid,datestr(last_processed_filetime(end)+1/1440,'yyyymmdd_HHMMSS'));
%             disp([upper(namestz),'.log',' created: ',datestr(last_processed_filetime(end)+1/1440,'yyyymmdd_HHMMSS')])
%             fclose(fid);
%         end             
    end
    fid=fopen([working_dir,slh,'log',slh,upper(namestz),'.log'],'w');
    fwrite(fid,datestr(last_processed_filetime(end)+1/1440,'yyyymmdd_HHMMSS'));
    disp([upper(namestz),'.log',' created: ',datestr(last_processed_filetime(end)+1/1440,'yyyymmdd_HHMMSS')])
    fclose(fid);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END LAST MINUTES DATA LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if offline
        toc
        iadPlotResults(FROM, TO, array, working_dir, slh);
        break
    end     
end % while 1
return

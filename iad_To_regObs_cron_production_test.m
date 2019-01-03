function iad_To_regObs_cron_production_test
% station.name='NO1';t0=now;flag='24h';

working_dir='/home/item/Documents/MATLAB/iad_av_detector';
slh='/';
net='wyssen';
idanames = {'NO1', 'NO2', 'NO3'};	
% Location = {'46138', '46137', '46136'};
Location = {'53111', '53109', '53108'};
ConfFileName={'conf_no1_2017_priv.txt', 'conf_no2_2017_priv.txt', 'conf_no3_2017_priv.txt'};

% namestz=upper(station.name);
tpost=now;
tend=floor(tpost*24)/24;
tstart=tend-1;

%... DEMO
regObs.logdir='/log/database_regObs/';
regObs.app_token='F74DD149-1A47-442B-96B8-37D75EEF33A2';
% regObs.ObserverGuid='EBEE33DC-F751-4EBE-8AFF-5F1894113075';
regObs.ObserverGuid='A07CBF80-D7BA-43E6-8310-6555A00E42D5';
% regObs.ObserverGroupID={'149'}; % integer
regObs.ObserverGroupID={'145'}; % integer
% regObs.url='https://api.nve.no/hydrology/demo/regobs/webapi/registration';
regObs.url='https://api.nve.no/hydrology/regobs/webapi_v3.2.0/registration/insert';
regObs.user='skreddeteksjon@wyssen-svv';
regObs.pass='wadWth17';

%     pysend_gry_20170308_100049565.py
        
for i=1:length(idanames)
    
%     [working_dir,slh,'conf_files',slh,net,slh,char(ConfFileName(i))]
    station=iad_read_ascii2cell([working_dir,slh,'conf_files',slh,net,slh,char(ConfFileName(i))]);
    count=iad_checkdB_events(station,station.dB_Nav_name,tstart,tend);
	
    if count==0,
    
        regObs.logfilename=['pyregObs_',lower(char(idanames(i))),'_',datestr(tpost,'yyyymmdd_HHMMSS'),'.py'];

        regObs.Comment='Ingen skred er automatisk detektert i maleomradet siste 24 timer.';

        filepy=[working_dir,regObs.logdir,...
            regObs.logfilename];

        fid=fopen(filepy,'w', 'native', 'UTF-8');

        fwrite(fid,'# -*- coding: utf-8 -*-');
        fprintf(fid,'\n');

        fwrite(fid,'import json');
        fprintf(fid,'\n');

        fwrite(fid,'import uuid');
        fprintf(fid,'\n');

        fwrite(fid,'import requests');
        fprintf(fid,'\n');

        fwrite(fid,'from requests.auth import HTTPBasicAuth');
        fprintf(fid,'\n');

        fwrite(fid,['url = ','"',...
            regObs.url,'"']);
        fprintf(fid,'\n');

        fwrite(fid,'Guid = uuid.uuid4()');
        fprintf(fid,'\n');

        tstarts=datestr(tstart,'yyyy-mm-ddTHH:00:00Z');
        tends=datestr(tend,'yyyy-mm-ddTHH:00:00Z');
        % 2016-11-25T23:00:00Z
    %     iLocation=strcmp(idanames,namestz);

%         string1=['''','{"Registrations": ',...
%             '[ { "Id": "',''''];
%         fwrite(fid,['string1 = ',string1]);
%         fprintf(fid,'\n');
        string1=['''','{"Id": "',''''];
        fwrite(fid,['string1 = ',string1]);
        fprintf(fid,'\n');

        string2=['''','","GeoHazardTID": 10,',...
            '"DtObsTime":','"',datestr(tpost,'yyyy-mm-ddTHH:MM:SSZ'),'",',...
            '"AvalancheActivityObs2": [ {',...
            '"DtStart":','"',tstarts,'",',...
            '"DtEnd":','"',tends,'",',...
            '"EstimatedNumTID": 1,',...
            '"Comment": "Ingen skred er automatisk detektert i maleomradet siste 24 timer."',...
            '} ],',...
            '"ObserverGuid":','"',regObs.ObserverGuid,'",',...
            '"ObserverGroupID":',char(regObs.ObserverGroupID),',',...
            '"SourceTID": 24,',...
            '"Email": false,',...
            '"ObsLocation": {',...
            '"ObsLocationId": ',char(Location(i)),...
            '}',...
            '}',''''];

        string2 = unicode2native(string2, 'UTF-8');

        fwrite(fid,['string2 = ',string2]);
        fprintf(fid,'\n');

        fwrite(fid,'Guid = Guid.urn');
        fprintf(fid,'\n');
        fwrite(fid,'Guid = Guid[9:]');
        fprintf(fid,'\n');

        fwrite(fid,'data = string1 + Guid + string2');
        fprintf(fid,'\n');

        fwrite(fid,'data_json = json.dumps(data)');
        fprintf(fid,'\n');

        fwrite(fid,'data_json = json.loads(data_json)');
        fprintf(fid,'\n');

        fwrite(fid,'data_json = data_json.encode(''utf-8'')');
        fprintf(fid,'\n');

        string=['headers = {','"','Content-type','"',':','"','application/json','",',...
            '"','regObs_apptoken','":','"',regObs.app_token,'",',...
            '"','ApiJsonVersion','":','"','3.2.0','"','}'];
        fwrite(fid,string);
        fprintf(fid,'\n');

        fwrite(fid,['auth = HTTPBasicAuth(','"',regObs.user,'",',...
            '"',regObs.pass,'"',')']);
        fprintf(fid,'\n');

        fwrite(fid,'response = requests.post(url, data=data_json, headers=headers, auth=auth)');
        fprintf(fid,'\n');

        fclose(fid);       



    %     disp(['python ',working_dir,regObs.logdir,regObs.logfilename,' &'])
        [s,w] = unix(['python ',working_dir,slh,regObs.logdir,regObs.logfilename,' &']);
        pause(1)
    end
%     disp(w)
    
end
return









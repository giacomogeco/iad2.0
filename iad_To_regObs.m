 function iad_To_regObs(station,tpost,tprocess,flag)
% station.name='NO1';t0=now;flag='24h';


working_dir='/home/dario/IDA_processing/item_av_detector';
slh='/';

idanames = {'NO1', 'NO2', 'NO3'};	
Location = {'46138', '46137', '46136'};

namestz=upper(station.name);
tend=tprocess;
tstart=tend-1;

%... DEMO
regObs.logdir='/log/database_regObs/';
regObs.logfilename=['pyregObs_',lower(namestz),'_',datestr(tpost,'yyyymmdd_HHMMSS'),'.py'];
regObs.app_token='F74DD149-1A47-442B-96B8-37D75EEF33A2';
regObs.ObserverGuid='EBEE33DC-F751-4EBE-8AFF-5F1894113075';
regObs.ObserverGroupID={'149'}; % integer
regObs.url='https://api.nve.no/hydrology/demo/regobs/webapi/registration';
regObs.user='skreddeteksjon@wyssen-svv';
regObs.pass='wadWth17';

%     pysend_gry_20170308_100049565.py

switch flag
    
    case 'alert'
        
        regObs.Comment=['Ett skred detektert vha. infralyd ',...
            datestr(tprocess,'yyyy-mm-dd, UTC HH:MM:SS')];
        
%         http://85.10.199.200/item_drumplot/NO1_RealTime1.png
        pictureurl=['http://148.251.122.130/item_drumplot/',...
            upper(namestz),'_RealTime1.png'];
        
%         NO1_20170517_1_4
    %    i6=ceil(24*(tprocess-floor(tprocess))/6);
     %   pictureurl=['http://148.251.122.130/item_drumplot/',...
      %      datestr(tprocess,'yyyymmdd'),'/',upper(namestz),'_',datestr(tprocess,'yyyymmdd'),'_',num2str(i6),'_1.png'];

        filepy=[pwd,regObs.logdir,...
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
        
        fwrite(fid,'import base64');
        fprintf(fid,'\n');
        
        fwrite(fid,'from requests.auth import HTTPBasicAuth');
        fprintf(fid,'\n');
        
        fwrite(fid,['url = ','"',...
            regObs.url,'"']);
        fprintf(fid,'\n');
        
        fwrite(fid,'Guid = uuid.uuid4()');
        fprintf(fid,'\n');
        
        iLocation=strcmp(idanames,namestz);
        
        string1=['''','{"Registrations": ',...
            '[ { "Id": "',''''];
        fwrite(fid,['string1 = ',string1]);
        fprintf(fid,'\n');
      
        string2=['''','","GeoHazardTID": 10,',...
            '"DtObsTime":','"',datestr(tpost,'yyyy-mm-ddTHH:MM:SSZ'),'",',...
            '"DangerObs": [ {',...
            '"DangerSignTID": 2,',...
            '"Comment": "',regObs.Comment,'",',...
            '} ],',...
            '"Picture": [ {',...
            '"RegistrationTID": "13",',...
            '"PictureImageBase64": "data:image/png;base64,',''''];
        string2 = unicode2native(string2, 'UTF-8');
        fwrite(fid,['string2 = ',string2]);
        fprintf(fid,'\n');
        
        string4=['''','","PictureComment": "Plott av infralydsignal siste 6 timer."',...
            '}],',...
            '"ObserverGuid":','"',regObs.ObserverGuid,'",',...
            '"ObserverGroupID":',char(regObs.ObserverGroupID),',',...
            '"SourceTID": 24,',...
            '"Email": false,',...
            '"ObsLocation": {',...
            '"ObsLocationId": ',char(Location(iLocation)),...
            '}',...
            '} ] }',''''];
        fwrite(fid,['string4 = ',string4]);
        fprintf(fid,'\n');
        
        fwrite(fid,['string3 = ','''',pictureurl,'''']);
        fprintf(fid,'\n');
        fwrite(fid,'string3 = base64.b64encode(requests.get(string3).content)');
        fprintf(fid,'\n');
              
        fwrite(fid,'Guid = Guid.urn');
        fprintf(fid,'\n');
        fwrite(fid,'Guid = Guid[9:]');
        fprintf(fid,'\n');
       
        fwrite(fid,'data = string1 + Guid + string2 + string3 + string4');
        fprintf(fid,'\n');
        
        fwrite(fid,'data_json = json.dumps(data)');
        fprintf(fid,'\n');
        
        fwrite(fid,'data_json = json.loads(data_json)');
        fprintf(fid,'\n');
        
        fwrite(fid,'data_json = data_json.encode(''utf-8'')');
        fprintf(fid,'\n');
        
        string=['headers = {','"','Content-type','"',':','"','application/json','",',...
            '"','regObs_apptoken','":','"',regObs.app_token,'",',...
            '"','ApiJsonVersion','":','"','3.0.6','"','}'];
        fwrite(fid,string);
        fprintf(fid,'\n');
        
        fwrite(fid,['auth = HTTPBasicAuth(','"',regObs.user,'",',...
            '"',regObs.pass,'"',')']);
        fprintf(fid,'\n');
                
        fwrite(fid,'response = requests.post(url, data=data_json, headers=headers, auth=auth)');
        fprintf(fid,'\n');

        fclose(fid); 
                
    case '24h'
        
        regObs.Comment='Ingen skred er automatisk detektert i måleområdet siste 24 timer.';
   
        filepy=[pwd,regObs.logdir,...
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
        iLocation=strcmp(idanames,namestz);

        string1=['''','{"Registrations": ',...
            '[ { "Id": "',''''];
        fwrite(fid,['string1 = ',string1]);
        fprintf(fid,'\n');
      
        string2=['''','","GeoHazardTID": 10,',...
            '"DtObsTime":','"',datestr(tpost,'yyyy-mm-ddTHH:MM:SSZ'),'",',...
            '"AvalancheActivityObs2": [ {',...
            '"DtStart":','"',tstarts,'",',...
            '"DtEnd":','"',tends,'",',...
            '"EstimatedNumTID": 1,',...
            '"Comment": "Ingen skred er automatisk detektert i måleområdet siste 24 timer."',...
            '} ],',...
            '"ObserverGuid":','"',regObs.ObserverGuid,'",',...
            '"ObserverGroupID":',char(regObs.ObserverGroupID),',',...
            '"SourceTID": 24,',...
            '"Email": false,',...
            '"ObsLocation": {',...
            '"ObsLocationId": ',char(Location(iLocation)),...
            '}',...
            '} ] }',''''];
        
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
            '"','ApiJsonVersion','":','"','3.0.6','"','}'];
        fwrite(fid,string);
        fprintf(fid,'\n');
        
        fwrite(fid,['auth = HTTPBasicAuth(','"',regObs.user,'",',...
            '"',regObs.pass,'"',')']);
        fprintf(fid,'\n');
                
        fwrite(fid,'response = requests.post(url, data=data_json, headers=headers, auth=auth)');
        fprintf(fid,'\n');

        fclose(fid);       
end


% disp(['python ',working_dir,slh,regObs.logdir,regObs.logfilename,' &'])
[s,w] = unix(['python ',working_dir,slh,regObs.logdir,regObs.logfilename,' &']);

% disp(w)
return

% 2017-05-17 11:56:43
% 2017-05-17 13:36:43
% 2017-05-17 13:39:47









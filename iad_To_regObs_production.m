 function iad_To_regObs_production(station,tpost,tprocess,flag)
% station.name='NO1';t0=now;flag='24h';


% # -*- coding: utf-8 -*-
% import json
% import uuid
% import requests
% import base64
% from requests.auth import HTTPBasicAuth
% # url = "http://tst-h-web03.nve.no/regobswebapi/registration/insert"
% url = "https://api.nve.no/hydrology/regobs/webapi_v3.2.0/registration/insert"
% Guid = uuid.uuid4()
% Guid = Guid.urn
% Guid = Guid[9:]
% string1 = '{"Id": "'
% string2 = '","GeoHazardTID": 10,"DtObsTime":"2017-11-16T04:58:32Z","DangerObs": [ {"DangerSignTID": 2,"Comment": "Ett skred detektert vha. infralyd 2017-11-12, UTC 04:54:34",} ],"Picture": [ {"RegistrationTID": "13","PictureImageBase64": "data:image/png;base64,'
% string4 = '","PictureComment": "Plott av infralydsignal siste 6 timer.gybugvybikgvuobuhjunih"}]ølkølkøkl,"ObserverGuid":"A07CBF80-D7BA-43E6-8310-6555A00E42D5","ObserverGroupID":145,"SourceTID": 24,"Email": false,"ObsLocation": {"ObsLocationId": 53109}}'
% string3 = 'http://148.251.122.130/item_drumplot/NO2_RealTime1.png'
% string3 = requests.get(string3).content
% string3 = base64.b64encode(string3)
% string3 = str(string3, "utf-8")
% data = '{0}{1}{2}{3}{4}'.format(string1, Guid, string2, string3, string4)
% data_json = json.dumps(data)
% data_json = json.loads(data_json)
% data_json = data_json.encode('utf-8')
% headers = {"Content-type":"application/json","regObs_apptoken":"F74DD149-1A47-442B-96B8-37D75EEF33A2","ApiJsonVersion":"3.2.0"}
% auth = HTTPBasicAuth("skreddeteksjon@wyssen-svv","wadWth17")
% response = requests.post(url, data=data_json, headers=headers, auth=auth)
% print(response.text, response.reason)

working_dir='/home/item/Documents/MATLAB/iad_av_detector';
slh='/';

idanames = {'NO1', 'NO2', 'NO3'};	
Location = {'53111', '53109', '53108'};
% Location = {'46138', '46137', '46136'};

namestz=upper(station.name);
tend=tprocess;
tstart=tend-1;

%... DEMO
regObs.logdir='/log/database_regObs/';
regObs.logfilename=['pyregObs_',lower(namestz),'_',datestr(tpost,'yyyymmdd_HHMMSS'),'.py'];
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

switch flag
    
    case 'alert'
        
        regObs.Comment=['Ett skred detektert vha. infralyd ',...
            datestr(tprocess,'yyyy-mm-dd, UTC HH:MM:SS')];
        
%         regObs.Comment='!!!! THIS IS A TEST !!!!';
        
%         http://85.10.199.200/item_drumplot/NO1_RealTime1.png
        pictureurl=['http://148.251.122.130/item_drumplot/',...
            upper(namestz),'_RealTime1.png'];
        
%         NO1_20170517_1_4
%         i6=ceil(24*(tprocess-floor(tprocess))/6);
%         pictureurl=['http://85.10.199.200/item_drumplot/',...
%             datestr(tprocess,'yyyymmdd'),'/',upper(namestz),'_',datestr(tprocess,'yyyymmdd'),'_',num2str(i6),'_1.png'];

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
        
%         fwrite(fid,'Guid = uuid.urn');
%         fprintf(fid,'\n');
%         
%         fwrite(fid,'Guid = Guid[9:]');
%         fprintf(fid,'\n');
        
        iLocation=strcmp(idanames,namestz);
        
        
%         string1 = '{"Id": "'
% string2 = '","GeoHazardTID": 10,"DtObsTime":"2017-11-16T04:58:32Z","DangerObs": [ {"DangerSignTID": 2,"Comment": "Ett skred detektert vha. infralyd 2017-11-12, UTC 04:54:34",} ],
% "Picture": [ {"RegistrationTID": "13","PictureImageBase64": "data:image/png;base64,'
% string4 = '","PictureComment": "Plott av infralydsignal siste 6 timer.gybugvybikgvuobuhjunih"}]ølkølkøkl,"ObserverGuid":"A07CBF80-D7BA-43E6-8310-6555A00E42D5","ObserverGroupID":145,"SourceTID": 24,"Email": false,"ObsLocation": {"ObsLocationId": 53109}}'
% string3 = 'http://148.251.122.130/item_drumplot/NO2_RealTime1.png'
        
%         string1=['''','{"Registrations": ',...
%             '[ { "Id": "',''''];
        string1=['''','{"Id": "',''''];
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
        fwrite(fid,'string3 = requests.get(string3).content');
        fprintf(fid,'\n');
        fwrite(fid,'string3 = base64.b64encode(string3)');
        fprintf(fid,'\n');
        fwrite(fid,'string3 = str(string3).encode("utf-8")');
%         fwrite(fid,'string3 = base64.b64encode(requests.get(string3).content)');
        fprintf(fid,'\n');
              
        fwrite(fid,'Guid = Guid.urn');
        fprintf(fid,'\n');
        fwrite(fid,'Guid = Guid[9:]');
        fprintf(fid,'\n');
       
        fwrite(fid,'data = string1 + Guid + string2 + string3 + string4');
        fprintf(fid,'\n');
%         fwrite(fid,['data = ','''','{0}{1}{2}{3}{4}','''','.format(string1, Guid, string2, string3, string4)']);
%         fprintf(fid,'\n');
        
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
[s,w] = system(['python ',working_dir,slh,regObs.logdir,regObs.logfilename,' &']);

% disp(w)
return

% 2017-05-17 11:56:43
% 2017-05-17 13:36:43
% 2017-05-17 13:39:47









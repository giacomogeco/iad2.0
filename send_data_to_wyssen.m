 function send_data_to_wyssen(stz,time,prs,dur,bkz,rel,type)

% stz={'GMS'};
% time=now;
% prs=3;
% dur=30;
% bkz=5;
filesh=[getenv('HOME'),...
    '/IDA_processing/item_av_detector/log/database_wyssen/',...
    'send_data_to_wyssen.sh'];
[a,b]=fileparts(filesh);
fid=fopen(filesh,'w');
 
    fwrite(fid,['cd ',a]);
    fprintf(fid,'\n');
    
for i=1:length(time),
    
    string='wget "http://mif.wyssenavalanche.com/idadata/?';

    string=[string,'STZ=',upper(stz{i}),'&'];
    string=[string,'time=',datestr(time(i),'yyyy-mm-dd_HHMMSS'),'&'];
    string=[string,'pressure=',num2str(prs(i)),'&'];
    string=[string,'duration=',num2str(dur(i)),'&'];
    string=[string,'backazimuth=',num2str(bkz(i)),'&'];
    string=[string,'reliability=',num2str(rel),'&'];
    string=[string,'type=',type{i},'"'];
    
    
 
    fwrite(fid,string);
    fprintf(fid,'\n');

    if i>1,
        fwrite(fid,'sleep 3s');
        fprintf(fid,'\n');
    end
    
end

fclose(fid);
system(['sh ',filesh,' &'])

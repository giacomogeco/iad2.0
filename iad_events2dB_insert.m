function iad_events2dB_insert(tablename,Mpriv,torretta,station)
% date=num2str('2013-11-19 09:30:11');
% clear query
% Mpriv=[now,100,50,0.7,0,1200,120,0,0,0,0,0,0,0,0,0,0,0;...
%     now+5/1440,100,50.2,0.7,81,0,0,0,0,0,0.6,0,0,0,0,0,0,0];
% % size di Mpriv numero di eventi x 12 o 13 colonne
% torretta={'ciao';'puppa'};
% tablename='gms_explosions';

% stz=tablename(1:3);
% size(Mpriv)
tag=tablename(5:end);
% tag='explosions'
% switch tag
%     case 'explosions'
%         colnames='(T,Date,PRS,CO,D,BAZ,BAZd,SLW,SLWd,FP,RS,SNR,PROBABILITY,WyssenTower)';
%     otherwise
%         colnames='(T,Date,PRS,CO,D,BAZ,BAZd,SLW,SLWd,FP,RS,SNR,PROBABILITY)';
% end
% size(Mpriv)
%%%%%%%%%%%%%%%%% Connection parameter %%%%%%%%%%%%%%%%%%%%%%%%%%%
% host='localhost';
% user='root';
% password='nIcChE2001';
% db='W_events';

% sudo ln -s /usr/local/mysql/lib/libmysqlclient.18.dylib /usr/lib/libmysqlclient.18.dylib
mysql('open', station.dBhost, station.dBuser, station.dBpassword );
mysql('use',station.dBname)  
mysql('status')

% size(Mpriv)
for i=1:size(Mpriv,1)
     switch tag
         case 'explosions'
             disp(['Explosions, ',char(torretta(i))])
%              query=['insert into ',tablename,' values (''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'')'];
             query=['replace into ',tablename,' values (''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'')'];
             
%              fprintf(query,...
%              num2str((Mpriv(i,1)-datenum(1970,1,0))*86400),...
%              datestr(Mpriv(i,1),31),...
%              num2str(Mpriv(i,2)),...
%              num2str(Mpriv(i,3)),...
%              num2str(Mpriv(i,4)),...
%              num2str(Mpriv(i,5)),...
%              num2str(Mpriv(i,6)),...
%              num2str(Mpriv(i,7)),...
%              num2str(Mpriv(i,8)),...
%              num2str(Mpriv(i,9)),...
%              num2str(Mpriv(i,10)),...
%              num2str(Mpriv(i,11)),...
%              num2str(Mpriv(i,12)),...
%              torretta{i},... 
%              num2str(Mpriv(i,14)),...
%              num2str(Mpriv(i,15)),...
%              num2str(Mpriv(i,16)),...
%              num2str(Mpriv(i,17)),...
%              num2str(Mpriv(i,18)))
             
             mysql(sprintf(query,...
             num2str((Mpriv(i,1)-datenum(1970,1,0))*86400),...
             datestr(Mpriv(i,1),31),...
             num2str(Mpriv(i,2)),...
             num2str(Mpriv(i,3)),...
             num2str(Mpriv(i,4)),...
             num2str(Mpriv(i,5)),...
             num2str(Mpriv(i,6)),...
             num2str(Mpriv(i,7)),...
             num2str(Mpriv(i,8)),...
             num2str(Mpriv(i,9)),...
             num2str(Mpriv(i,10)),...
             num2str(Mpriv(i,11)),...
             num2str(Mpriv(i,12)),...
             torretta{i},...    %... 14
             num2str(Mpriv(i,14)),...
             num2str(Mpriv(i,15)),...
             num2str(Mpriv(i,16)),...
             num2str(Mpriv(i,17)),...
             num2str(Mpriv(i,18)),...
             num2str(Mpriv(i,19)),...
             num2str(Mpriv(i,20))));
         
         otherwise
             disp('Avalanche')
%              query=['insert into ',tablename,' values (''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'')'];
             query=['replace into ',tablename,' values (''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'')'];
             mysql(sprintf(query,...
             num2str((Mpriv(i,1)-datenum(1970,1,0))*86400),...
             datestr(Mpriv(i,1),31),...
             num2str(Mpriv(i,2)),...
             num2str(Mpriv(i,3)),...
             num2str(Mpriv(i,4)),...
             num2str(Mpriv(i,5)),...
             num2str(Mpriv(i,6)),...
             num2str(Mpriv(i,7)),...
             num2str(Mpriv(i,8)),...
             num2str(Mpriv(i,9)),...
             num2str(Mpriv(i,10)),...
             num2str(Mpriv(i,11)),...
             num2str(Mpriv(i,12)),...
             num2str(Mpriv(i,14)),...
             num2str(Mpriv(i,15)),...
             num2str(Mpriv(i,16)),...
             num2str(Mpriv(i,17)),...
             num2str(Mpriv(i,18)),...
             num2str(Mpriv(i,19)),...
             num2str(Mpriv(i,20))));
     end
end
% disp(query)
mysql('closeall')


% torretta
% 
% [ t, p ] = mysql('select T,Date from isc_avalanches where date="2012-12-10 07:41:40"');
% return
% var_name = input('Enter the name: ','s');  %# Treats input like a string
% commandString = sprintf('insert into table (name) values (''%s'')', var_name);
%                             %# Note the two apostrophes --^
% mysql(commandString);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% query=['delete from ',stz,'_avalanches where Date > (''',date,''') '];
% commandString = sprintf('insert into table (name) values (''%s'')', var_name);
% tablename='prova';
% colnames='prova';
% commandString = sprintf('insert into table (prova) values (''%s'')', num2str(120))
% mysql(query)
% query = sprintf(['insert into table ',tablename, 'values (''%s'')', var_name]);
% mysql('close')
% return
% Mpriv=cat(1,now,100,50,0.7,0,0,0,0,0,0,0,0,0);
% torretta={'ciao'};
% query=['insert into gms_explosions values (''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'')'];
% for i=1:size(Mpriv,1)
%      switch tag
%          case 'explosions'
%              query=['insert into ',tablename,' values (''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'')'];
%              mysql(sprintf(query,...
%              num2str((Mpriv(i,1)-datenum(1970,1,0))*86400),...
%              datestr(Mpriv(i,1),31),...
%              num2str(Mpriv(i,2)),...
%              num2str(Mpriv(i,3)),...
%              num2str(Mpriv(i,4)),...
%              num2str(Mpriv(i,5)),...
%              num2str(Mpriv(i,6)),...
%              num2str(Mpriv(i,7)),...
%              num2str(Mpriv(i,8)),...
%              num2str(Mpriv(i,9)),...
%              num2str(Mpriv(i,10)),...
%              num2str(Mpriv(i,11)),...
%              num2str(Mpriv(i,12)),...
%              torretta{i})); %... 14
%          otherwise
%              query=['insert into ',tablename,' values (''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'')'];
%              mysql(sprintf(query,...
%              num2str((Mpriv(i,1)-datenum(1970,1,0))*86400),...
%              datestr(Mpriv(i,1),31),...
%              num2str(Mpriv(i,2)),...
%              num2str(Mpriv(i,3)),...
%              num2str(Mpriv(i,4)),...
%              num2str(Mpriv(i,5)),...
%              num2str(Mpriv(i,6)),...
%              num2str(Mpriv(i,7)),...
%              num2str(Mpriv(i,8)),...
%              num2str(Mpriv(i,9)),...
%              num2str(Mpriv(i,10)),...
%              num2str(Mpriv(i,11)),...
%              num2str(Mpriv(i,12)),...
%              num2str(Mpriv(i,12))));    %... 13
%      end
% end
% % disp(query)
% mysql('closeall')

return

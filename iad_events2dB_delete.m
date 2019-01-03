function iad_events2dB_delete(tablename,date,station)
% date=num2str('2013-11-27 00:30:11');
% date=datestr(datenum(2013,11,27,0,0,0),31);
% tablename={'isc_avalanches'};   %... cell
if ~iscell(tablename),
    tablename={tablename};
end

%%%%%%%%%%%%%%%%% Connection parameter %%%%%%%%%%%%%%%%%%%%%%%%%%%
% host='192.168.0.100';
% user='item';
% password='x5XEbNKhNf7sfLHA';
% db='Sql661975_1';
mysql( 'open', station.dBhost, station.dBuser, station.dBpassword );
mysql('use',station.dBname)  
mysql('status')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(tablename)
    query=['delete from ',char(tablename),' where Date > (''',date,''') '];
    mysql(query)
end
mysql('closeall')
% commandString = sprintf('insert into table (name) values (''%s'')', var_name);
% query = sprintf(['insert into table ',tablename, 'values (''%s'')', var_name]);
return
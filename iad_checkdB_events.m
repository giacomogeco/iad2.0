function count=iad_checkdB_events(station,tablename,t0,t1)
% date=num2str('2013-11-27 00:30:11');
% date=datestr(datenum(2013,11,27,0,0,0),31);
% tablename={'isc_avalanches'};   %... cell

% station.dB_Nav_name
%%%%%%%%%%%%%%%%% Connection parameter %%%%%%%%%%%%%%%%%%%%%%%%%%%
% host='192.168.0.100';
% user='item';
% password='x5XEbNKhNf7sfLHA';
% db='Sql661975_1';
mysql('open', station.dBhost, station.dBuser, station.dBpassword);
mysql('use',station.dBname)  
mysql('status')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

query=['SELECT COUNT(*) FROM ',char(tablename),...
    ' where Date > (''',datestr(t0,31),''') AND Date < (''',datestr(t1,31),''')'];
count=mysql(query);

mysql('closeall')
% commandString = sprintf('insert into table (name) values (''%s'')', var_name);
% query = sprintf(['insert into table ',tablename, 'values (''%s'')', var_name]);
return
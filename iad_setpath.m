function [working_dir,slh]=iad_setpath

switch computer
    case {'GLNXA64','MACI64'},
        slh='/';
    otherwise
        slh='\';
end
mainpath=mfilename('fullpath');
i=strfind(mainpath,slh);
mainpath=mainpath(1:i(end)-1);
cd(mainpath)
javaaddpath([mainpath,slh,'jar/usgs.jar'])
clear mainpath slh

switch computer
    case {'GLNXA64','MACI64'},
        slh='/';
    otherwise
        slh='\';
end
mainpath=mfilename('fullpath');
i=strfind(mainpath,slh);
mainpath=mainpath(1:i(end)-1);
cd(mainpath)
javaaddpath([mainpath,slh,'jar/mysql-connector-java-5.0.6-bin.jar'])
clear mainpath slh

% RESOURCES
switch computer case {'GLNXA64','MACI64'},slh='/';otherwise,slh='\';end
mainpath=mfilename('fullpath');
i=strfind(mainpath,slh);
mainpath=mainpath(1:i(end)-1);
cd(mainpath)
addpath(genpath([mainpath,slh,'resources']))


switch computer,case {'GLNXA64','MACI64'},slh='/';otherwise,slh='\';end
working_dir=mfilename('fullpath');
i=strfind(working_dir,slh);
working_dir=working_dir(1:i(end)-1);

return
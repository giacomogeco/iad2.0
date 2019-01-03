function station=iad_read_ascii2cell(file)

fid = fopen(file);
TLINE=1;
i=1;

% TO BE USED IN FUTURE:
while TLINE~=-1
    tline = fgetl(fid);
    if strcmp(tline,'')
        lineCells{i}='';
    else
        TLINE=tline;
        lineCells{i}=TLINE;
        
    end
    i=i+1;
end
fclose(fid);

lineCells=lineCells(1:length(lineCells)-1)';

for i=1:numel(lineCells)
    try
        eval(lineCells{i})
    catch
        
        disp('WARNING: error in input script')
        disp(lineCells{i})
    end
end

return

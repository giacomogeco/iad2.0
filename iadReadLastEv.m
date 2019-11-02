
function E = iadReadLastEv(working_dir,slh,array, FROM, TO)

D = dir([working_dir,slh,'log',slh,'iadEvents2Wyssen',slh,lower(char(array.stationName)),slh,'*.py']);
if isempty(D)
    E.type = 'NaN';
    E.dur = NaN;
    E.tim = TO;
    E.amp = NaN;
    E.bkzOn = NaN;
    E.bkzEnd = NaN;
    E.bkzAv = NaN;
    E.f1 = NaN;
    E.f2 = NaN;
    E.rel = 'NaN';
else
    fname = char({D.name});ftime=fname(:,11:25);
    talerts = datenum(ftime,'yyyymmdd_HHMMSS');
    ii = find(talerts >= FROM & talerts < TO);
    if ~isempty(ii)
        fname = {D.name}; fname = fname(ii);
        for i = 1:length(fname)
            f = char(fname(i));
            fid = fopen([working_dir,slh,'log',slh,'iadEvents2Wyssen',slh,lower(char(array.stationName)),slh,f]);
            C = textscan(fid, '%s');
            fclose(fid);
            CC =char(C{1}{24}); ii = findstr(CC,'"'); CC(ii) = []; E.type{i} = CC(1:end-1);
            CC =char(C{1}{30}); ii = findstr(CC,','); CC(ii) = []; E.dur(i) = str2double(CC);
            CC =char(C{1}{27}); ii = findstr(CC,'"'); CC(ii) = []; CC = CC(1:end-1); E.tim(i) = datenum(CC,'yyyymmddTHHMMSS');
            CC =char(C{1}{33}); ii = findstr(CC,','); CC(ii) = []; E.amp(i) = str2double(CC);
            CC =char(C{1}{39}); ii = findstr(CC,','); CC(ii) = []; E.bkzOn(i) = str2double(CC);
            CC =char(C{1}{42}); ii = findstr(CC,','); CC(ii) = []; E.bkzEnd(i) = str2double(CC);
            CC =char(C{1}{45}); ii = findstr(CC,','); CC(ii) = []; E.bkzAv(i) = str2double(CC);
            CC =char(C{1}{48}); ii = findstr(CC,','); CC(ii) = []; E.f1(i) = str2double(CC);
            CC =char(C{1}{51}); ii = findstr(CC,','); CC(ii) = []; E.f2(i) = str2double(CC);
            CC =char(C{1}{54}); ii = findstr(CC,'"'); CC(ii) = []; E.rel{i} = CC(1:end-1);
        end
    else
        E.type = 'NaN';
        E.dur = NaN;
        E.tim = TO;
        E.amp = NaN;
        E.bkzOn = NaN;
        E.bkzEnd = NaN;
        E.bkzAv = NaN;
        E.f1 = NaN;
        E.f2 = NaN;
        E.rel = 'NaN';
    end
end
return
function out = iad_check_unwrap ( in )


out=unwrap(in/180*pi);
out=out/pi*180;

ii=find(out>360);
if ~isempty(ii)
    out=unwrap(in(end:-1:1)/180*pi);
    out=out(end:-1:1);
    out=out/pi*180;
end
    
    return

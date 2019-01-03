function resid=iad_consistency(lag,cmb,nstz)

if isempty(cmb),
    %... tutte le combinazione triangolari
    cmb=iad_combntns(1:nstz,3);
    cmb=[cmb cmb(:,1)];
else
    %... combinazioni predefinite
    cmb=[cmb cmb(1)];
end

resid=zeros(size(cmb,1),size(cmb,2));
for ii=1:size(cmb,1),
    for i=1:size(cmb,2)-1,
        resid(ii,i)=lag(cmb(ii,i),cmb(ii,i+1));
    end
end

return

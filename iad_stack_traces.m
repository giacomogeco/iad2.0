function [st,sts]=iad_stack_traces(pp,tfly)

st=zeros(size(pp));

for i=1:size(pp,1)
    
    lag=round(tfly(i));
    
    if lag==0
        st(i,:)=pp(i,:);
    end
    if lag>0
        st(i,:)=[pp(i,lag:end),zeros(1,lag-1)];
    end
    if lag<0
        st(i,:)=[zeros(1,lag-1),pp(i,1:end-lag)];
    end
    
end

sts=sum(st,1)/size(pp,1);

return
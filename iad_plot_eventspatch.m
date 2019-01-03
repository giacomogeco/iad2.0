function iad_plot_eventspatch(Ev_Ex,Ev_Cav,Ev_Nav,T0)

if size(Ev_Ex.data,1)>0,
    plot(86400*(Ev_Ex.data(:,1)-T0),zeros(size(Ev_Ex.data,1),1),'sy','Linewidth',2)
    hold on
    for i=1:size(Ev_Ex.data,1),
        line([86400*(Ev_Ex.data(i,1)-T0),86400*(Ev_Ex.data(i,2)-T0)],...
         [0,0],'color','y','Linewidth',2)
    end
else
    line([0,0],[0,0],'color','r','Linewidth',2)
end
leg_string{2}='Wyssen Tower Explosions';

if size(Ev_Cav.data,1)>0,
    plot(86400*(Ev_Cav.data(:,1)-T0),zeros(size(Ev_Cav.data,1),1),'sk','Linewidth',2)
    hold on
    for i=1:size(Ev_Cav.data,1),
        line([86400*(Ev_Cav.data(i,1)-T0),86400*(Ev_Cav.data(i,2)-T0)],...
         [0,0],'color','k','Linewidth',2)
        hold on
    end
else
    line([0,0],[0,0],'color','k','Linewidth',2)
end
leg_string{3}='Controlled Avalanches';


if Ev_Av.data(1,1)~=0,
    plot(86400*(Ev_Av.data(:,1)-T0),zeros(size(Ev_Av.data,1),1),'dc','Linewidth',2)
    hold on
    for i=1:size(Ev_Av.data,1),
        
        line([86400*(Ev_Av.data(i,1)-T0),86400*(Ev_Av.data(i,2)-T0)],...
         [0,0],'color','c','Linewidth',2)
    end
else
    line([0,0],[0,0],'color','c','Linewidth',2)
end

if size(Ev_Nav.data,1)>0,
    plot(86400*(Ev_Nav.data(:,1)-T0),zeros(size(Ev_Nav.data,1),1),'dg','Linewidth',2)
    hold on
    for i=1:size(Ev_Nav.data,1),
        
        if Ev_Nav.data(i,17)==1,
            line([86400*(Ev_Nav.data(i,1)-T0),86400*(Ev_Nav.data(i,2)-T0)],...
             [0,0],'color','r','Linewidth',2)
        else
            line([86400*(Ev_Nav.data(i,1)-T0),86400*(Ev_Nav.data(i,2)-T0)],...
             [0,0],'color','g','Linewidth',2)
        end
    end
else
    line([0,0],[0,0],'color','g','Linewidth',2)
end

leg_string{4}='Natural Avalanches';
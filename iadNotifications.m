% function iadNotifications

if size(Ev_Ex.data,1)>0     %%%%%%%%% EX
    try     %%%%%%%%% WYSSEN POST
        for iPst=1:size(Ev_Ex.data,1)
            evnts.data=Ev_Ex.data(iPst,:);
            evnts.torretta=Ev_Ex.torretta(iPst);
            [postStatus,postResponse] = iadEvent2Wyssen(array,station,evnts,'Ex',offline);
            if postStatus==0
                    disp('>>>>>>>>>> SUCCESS POSTING EX EVENT TO WAC.3 <<<<<<<<<<<<')
            else
            end
        end
    catch
        disp('>>>>>>>>>> !! ERROR POSTING EX EVENT TO WAC.3 !! <<<<<<<<<<<<')
    end %%%%%%%%% end WYSSEN POST
%             if ~offline %%%%%%%%%%% NOTIFICATION TO GeCo
%                 try
%                     for iPst=1:size(Ev_Ex.data,1)
%                         evnts.data=Ev_Ex.data(iPst,:);
%                         iadEvent2GeCo(evnts,station,'Ex') 
%                     end
%                 catch
%                     disp('>>>>>>>>>> !! ERROR POSTING EX EVENT TO GeCo !! <<<<<<<<<<<<')
%                 end
%             end %%%%%%%%%%% end NOTIFICATION TO GeCo
end  %%%%%%%%% end EX
if size(Ev_Cav.data,1)>0
    try %%%%%%%%%% WYSSEN POST
        for iPst=1:size(Ev_Cav.data,1)
        evnts.data=Ev_Cav.data(iPst,:);
        [postStatus,postResponse] = iadEvent2Wyssen(array,station,evnts,'Cav',offline);
            if postStatus==0
                    disp('>>>>>>>>>> SUCCESS POSTING CAV EVENT TO WAC.3 <<<<<<<<<<<<')
            else

            end
        end
    catch
        disp('>>>>>>>>>> !! ERROR POSTING CAV EVENT TO WAC.3 !! <<<<<<<<<<<<')
    end
%             if ~offline
%                 try
%                     for iPst=1:size(Ev_Cav.data,1)
%                         evnts.data=Ev_Cav.data(iPst,:);
%                         iadEvent2GeCo(evnts,station,'Cav') 
%                     end
%                 catch
%                     disp('>>>>>>>>>> !! ERROR POSTING CAV EVENT TO GeCo !! <<<<<<<<<<<<')
%                 end
%             end 
end
if size(Ev_Nav.data,1)>0    %%%%%%%% NAV
    try   %%%%%%%%%% WYSSEN POST                
        for iPst=1:size(Ev_Nav.data,1)
            evnts.data=Ev_Nav.data(iPst,:);
            [postStatus,postResponse] = iadEvent2Wyssen(array,station,evnts,'Nav',offline);  
            if postStatus==0
                    disp('>>>>>>>>>> SUCCESS POSTING NAV EVENT TO WAC.3 <<<<<<<<<<<<')
            else
            end
        end                 
    catch 
        disp('>>>>>>>>>> !! ERROR POSTING NAV EVENT TO WAC.3 !! <<<<<<<<<<<<')
    end     %%%%%%%%%% end WYSSEN POST 
%             if ~offline %%%%%%%%%%% NOTIFICATION TO GeCo
%                 try
%                     for iPst=1:size(Ev_Nav.data,1)
%                         evnts.data=Ev_Nav.data(iPst,:);
%                         iadEvent2GeCo(evnts,station,'Nav') 
%                     end
%                 catch
%                     disp('>>>>>>>>>> !! ERROR POSTING NAV EVENT TO GeCo !! <<<<<<<<<<<<')
%                 end
%             end %%%%%%%%%%% end NOTIFICATION TO GeCo   
end    

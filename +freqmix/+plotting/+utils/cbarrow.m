function h = cbarrow(max_edge)
%% cbarrow documentation

%hcb = findobj(gcf,'Type','Colorbar'); 
%cba = hcb(1); 

%cb = colorbar; 

%cbpos = [0.829761915033750,0.109523798657032,0.0380952380952381,0.816666688400221];%cb.Position; 
%ax1 = gca; 
%ax1pos = get(ax1,'OuterPosition');


%h = axes('position',[0 0 1 1],'tag','cbarrow');
%hold on

%uparrowx = cbpos(1)+0.05 + [0 cbpos(3) cbpos(3)/2 0]; 
%uparrowy = cbpos(2)+cbpos(4) - [cbpos(4) cbpos(4) 0 cbpos(4)];  
%uparrowy = cbpos(2)+cbpos(4) - [0 0 cbpos(4) 0];  

%hu = patch(uparrowx, uparrowy, [0 0 0]); 

hu = patch([1.5 3 3], [0.8 0.9 0.7], [0 0 0]); 

%axis off
%axis([0 1 0 1]) 
% If original current axes were resized, unresize them: 
%set(ax1,'OuterPosition',ax1pos)
%axes(ax1) 

%annotation('textbox',[uparrowx(2)-0.01 uparrowy(3)+0.03 0.0 0.0], ...
%    'String',0,'FontSize',12)

%annotation('textbox',[uparrowx(2) uparrowy(1)+0.03 0.0 0.0], ...
%    'String',round(max_edge,4),'FontSize',12)

% Delete output if user did not request it: 
if nargout==0
    clear h
end


end
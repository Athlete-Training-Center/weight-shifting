%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   weight_shifting
%
%   ~~
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset setting
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bodyweight setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[body_weight_kg, selectedFoot, percent] = InputGUI_WS;
FootDict = containers.Map({'right', 'left'}, {1, 2});

gravity = 9.80665; % gravity acceleration (m/s^2)
bodyweight_N = body_weight_kg * gravity;

% Connect to QTM
ip = '127.0.0.1';
% Connects to QTM and keeps the connection alive.
QCM('connect', ip, 'frameinfo', 'force');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a figure window
figureHandle = figure(1);
hold on
% set the figure size
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
% remove ticks from axes
set(gca,'XTICK',[],'YTick',[])

% setting figure size to real force plate size
%           600mm      600mm
%        ---------------------
%      x↑         ¦           ¦
%       o → y     ¦           ¦ 400mm
%       ¦         ¦           ¦ 
%        ---------------------
% original coordinate : left end(x = 0) and center
xlim=[0 1200];
ylim = [0, 100]; % body weight kg * gravity limit
% set limits for axes
set(gca, 'xlim', xlim, 'ylim', ylim)

% center coordinate for figure size
centerpoint = [(xlim(1) + xlim(2)) / 2, (ylim(1) + ylim(2)) / 2];

% bar blank between vertical center line and each bar
margin = 300;

loc_x = [centerpoint(1) + margin .* (-1)^(FootDict(selectedFoot)+1), ylim(1)]; % x y

% each bar width
width = 100; 
% each bar height
height = ylim(2) - ylim(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% draw target line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % for body weight
target_value = percent;

target_line = plot([loc_x(1) - width/2, loc_x(1) + width/2], [target_value target_value], 'LineWidth', 3, 'Color', 'black');
text(loc_x(1) - width/2 - 100, target_value+20, sprintf("%d %% for \nbody weight", percent), 'FontSize', 20, 'HorizontalAlignment', 'center', 'Color', 'black');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% draw outlines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% draw force plate line
plot([0 0],get(gca,'ylim'),'k', 'linewidth',3)
plot([xlim(2) xlim(2)],get(gca,'ylim'),'k', 'linewidth',3)
plot([centerpoint(1) centerpoint(1)],get(gca,'ylim'),'k', 'linewidth',3)
plot(get(gca,'xlim'),[ylim(2) ylim(2)],'k', 'linewidth',3)
plot(get(gca,'xlim'),[ylim(1) ylim(1)],'k', 'linewidth',3)
title('Left                                                            Right','fontsize',30)

% make handles for each bar to update vGRF and AP COP data
plot_bar = plot([loc_x(1)-width/2, loc_x(1)+width/2], [ylim(1), ylim(1) + 100], 'LineWidth', width - 10,'Color','red');

% make bar frame
plot([loc_x(1)-width/2 loc_x(1)+width/2],[height height],'k', 'linewidth',1) % top
plot([loc_x(1)-width/2 loc_x(1)-width/2],[ylim(1) height],'k', 'linewidth',1); % left
plot([loc_x(1)+width/2 loc_x(1)+width/2],[ylim(1) height],'k', 'linewidth',1); % right


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRF data list for variability graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
grf_array = cell(1,1);
i=1;

while true
    %use event function to avoid crash
    try
        event = QCM('event');
        % Fetch data from QTM
        [frameinfo,force] = QCM;

        if ~ishandle(figureHandle)
            QCM('disconnect');
            break;
        end
        
        % get GRF Z from plate 1,2   unit: kgf
        grf = abs(force{2,FootDict(selectedFoot)}(1,3));
        
        % GRF percentage of body weight
        grf_percent = (grf / bodyweight_N) * 100;

        % Update each bar
        set(plot_bar,'xdata', [loc_x(1), loc_x(1)],'ydata', [ylim(1), grf_percent]);

        % append cop to cop_list
        grf_array{i} = grf_percent;
        i = i+1;

        drawnow;
        
    catch exception
        disp(exception.message);
        break
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% draw the graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
grf_array = cell2mat(grf_array);
n = length(grf_array);

[numRows, numCols] = size(grf_array);

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    
hold on;

title(sprintf('Percent Difference from Target Value plate (%s)', selectedFoot), 'FontSize', 20);
xlabel('Time ', 'FontSize', 15);
ylabel('Difference ', 'FontSize', 15);
grid on;

plot((1: numCols), grf_array, 'black');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate RMSE(Root Mean Sqaure Error)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
text_position_x = round(numCols / 2);

rmse = sqrt(sum((grf_array - target_value).^2) / n);
disp(['Lower Mean Percent Difference: ', num2str(rmse), '%']);
plot([1 numCols], [target_value target_value], ...
    'black','LineWidth', 1, 'LineStyle','--');

% 하단 평균 퍼센트 차이 텍스트 추가
text_position_y = target_value-10;
text(text_position_x, text_position_y, ['RMSE: ', num2str(rmse), '%'], ...
    'FontSize', 15, 'HorizontalAlignment', 'center', 'Color', 'blue');

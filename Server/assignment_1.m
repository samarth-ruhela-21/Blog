close all;
clc;

activities = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'};
durations = [8, 10, 8, 10, 16, 17, 18, 14, 9, 0];

precedence = [
  0 0 0 1 1 0 0 0 0 0;
  0 0 0 0 0 1 0 0 0 0;
  0 0 0 0 0 0 1 1 0 0;
  0 0 0 0 0 1 0 0 0 0;
  0 0 0 0 0 0 0 0 0 0;
  0 0 0 0 0 0 0 0 1 0;
  0 0 0 0 0 0 0 0 1 0;
  0 0 0 0 0 0 0 0 0 0;
  0 0 0 0 0 0 0 0 0 1;
  0 0 0 0 0 0 0 0 0 0;
];

fprintf('=== CORRECTED CRITICAL PATH METHOD ANALYSIS ===\n\n');

n_activities = length(activities);
ES = zeros(1, n_activities);
EF = zeros(1, n_activities);

for i = 1:n_activities
    preds = find(precedence(:, i)');
    if isempty(preds)
        ES(i) = 0;
    else
        ES(i) = max(EF(preds));
    end
    EF(i) = ES(i) + durations(i);
end

LF = zeros(1, n_activities) + max(EF);
LS = zeros(1, n_activities);

for i = n_activities:-1:1
    succs = find(precedence(i, :));
    if isempty(succs)
        LF(i) = max(EF);
    else
        LF(i) = min(LS(succs));
    end
    LS(i) = LF(i) - durations(i);
end

TF = LS - ES;

critical_activities = find(TF == 0);
critical_path = activities(critical_activities);

fprintf('Activity\tDuration\tES\tEF\tLS\tLF\tTF\tCritical?\n');
fprintf('--------\t--------\t--\t--\t--\t--\t--\t---------\n');

for i = 1:n_activities
    is_critical = 'Yes';
    if TF(i) > 0
        is_critical = 'No';
    end
    fprintf('%s\t\t%d\t\t%d\t%d\t%d\t%d\t%d\t%s\n', ...
            activities{i}, durations(i), ES(i), EF(i), LS(i), LF(i), TF(i), is_critical);
end

fprintf('\n=== CORRECT RESULTS ===\n');
fprintf('Minimum Project Duration: %d days\n', max(EF));
fprintf('Critical Path: %s\n', strjoin(critical_path, ' → '));

figure('Position', [100, 100, 1200, 800]);
hold on;
title('Project Network Diagram with Critical Path (A → D → F → I → J)', 'FontSize', 16, 'FontWeight', 'bold');
axis equal;
axis off;

node_positions = [
    1, 3;
    1, 1;
    1, -1;
    3, 3;
    3, 4;
    5, 2;
    3, -1;
    3, -2;
    7, 2;
    9, 2;
];

start_pos = [-1, 2];
end_pos = [11, 2];

plot(start_pos(1), start_pos(2), 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
text(start_pos(1), start_pos(2)-0.3, 'Start', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

plot(end_pos(1), end_pos(2), 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
text(end_pos(1), end_pos(2)-0.3, 'End', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

plot([start_pos(1), node_positions(1,1)], [start_pos(2), node_positions(1,2)], 'k-', 'LineWidth', 1);
plot([start_pos(1), node_positions(2,1)], [start_pos(2), node_positions(2,2)], 'k-', 'LineWidth', 1);
plot([start_pos(1), node_positions(3,1)], [start_pos(2), node_positions(3,2)], 'k-', 'LineWidth', 1);

plot([node_positions(5,1), end_pos(1)], [node_positions(5,2), end_pos(2)], 'k-', 'LineWidth', 1);
plot([node_positions(8,1), end_pos(1)], [node_positions(8,2), end_pos(2)], 'k-', 'LineWidth', 1);
plot([node_positions(10,1), end_pos(1)], [node_positions(10,2), end_pos(2)], 'k-', 'LineWidth', 1);

for i = 1:n_activities
    if ismember(i, critical_activities)
        color = [1, 0.6, 0.6];
        edge_color = 'r';
    else
        color = [0.8, 0.8, 1];
        edge_color = 'b';
    end
    
    if strcmp(activities{i}, 'J')
        plot(node_positions(i,1), node_positions(i,2), 'ro', 'MarkerSize', 20, 'MarkerFaceColor', color, 'LineWidth', 2);
    else
        rectangle('Position', [node_positions(i,1)-0.4, node_positions(i,2)-0.3, 0.8, 0.6], ...
                  'FaceColor', color, 'EdgeColor', edge_color, 'LineWidth', 2);
    end
    
    if strcmp(activities{i}, 'J')
        text(node_positions(i,1), node_positions(i,2), 'J', ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    else
        text(node_positions(i,1), node_positions(i,2), ...
            sprintf('%s\n%d', activities{i}, durations(i)), ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    for j = 1:n_activities
        if precedence(i, j) == 1
            if ismember(i, critical_activities) && ismember(j, critical_activities)
                arrow_color = 'r';
                line_width = 3;
            else
                arrow_color = 'k';
                line_width = 1;
            end
            
            dx = node_positions(j,1) - node_positions(i,1);
            dy = node_positions(j,2) - node_positions(i,2);
            quiver(node_positions(i,1)+0.4, node_positions(i,2), dx-0.8, dy, 0, ...
                   'Color', arrow_color, 'LineWidth', line_width, 'MaxHeadSize', 0.5);
        end
    end
end

legend_labels = {};
if any(critical_activities)
    patch([0,0,0,0], [0,0,0,0], [1,0.6,0.6], 'EdgeColor', 'r', 'LineWidth', 2);
    legend_labels{end+1} = 'Critical Activity';
end
patch([0,0,0,0], [0,0,0,0], [0.8,0.8,1], 'EdgeColor', 'b', 'LineWidth', 2);
legend_labels{end+1} = 'Non-critical Activity';
plot([0,0], [0,0], 'r-', 'LineWidth', 3);
legend_labels{end+1} = 'Critical Path';
plot([0,0], [0,0], 'k-', 'LineWidth', 1);
legend_labels{end+1} = 'Non-critical Path';
plot([0,0], [0,0], 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
legend_labels{end+1} = 'Dummy Activity';

legend(legend_labels, 'Location', 'northeastoutside');
set(gcf, 'Color', 'w');

fprintf('\n=== ANALYSIS COMPLETE ===\n');
fprintf('Critical Path: A → D → F → I → J\n');
fprintf('Project Duration: 44 days (confirmed)\n');
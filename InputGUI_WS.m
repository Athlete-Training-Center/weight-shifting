function [paramter, option, percent] = InputGUI_WS
    % Initialize output variables
    paramter = '';
    option = '';
    percent = '';

    sentence = {'Input the body weight (kg) : ', 'choose left or right foot (left/right) : ', 'Input the percent about body weight (%) : '};
    
    % Create a figure for the GUI
    fig = figure('Position', [300, 300, 400, length(sentence) * 100], 'MenuBar', 'none', 'Name', 'Dual Input GUI', 'NumberTitle', 'off', 'Resize', 'off', 'CloseRequestFcn', @closeCallback);
    
    % Create the first input label and text box
    uicontrol('Style', 'text', 'Position', [50, 220, 200, 30], 'String', sentence{1}, 'HorizontalAlignment', 'left', 'FontSize', 10);
    parameter_Box = uicontrol('Style', 'edit', 'Position', [250, 220, 100, 30], 'FontSize', 10);

    % Create the second input label and text box
    uicontrol('Style', 'text', 'Position', [50, 160, 200, 30], 'String', sentence{2}, 'HorizontalAlignment', 'left', 'FontSize', 10);
    option_Box = uicontrol('Style', 'edit', 'Position', [250, 160, 100, 30], 'FontSize', 10);

    % Create the first input label and text box
    uicontrol('Style', 'text', 'Position', [50, 100, 200, 30], 'String', sentence{3}, 'HorizontalAlignment', 'left', 'FontSize', 10);
    percent_Box = uicontrol('Style', 'edit', 'Position', [250, 100, 100, 30], 'FontSize', 10);

    % Create a submit button
    uicontrol('Style', 'pushbutton', 'Position', [150, 20, 100, 40], 'String', 'Submit', 'FontSize', 10, 'Callback', @submitCallback);

    % Store initial data in the figure's UserData property
    data.paramter = '';
    data.option = '';
    data.percent = '';
    set(fig, 'UserData', data);

    % Wait for the user to close the figure
    uiwait(fig);

    % Check if the figure still exists before retrieving data
    if isvalid(fig)
        data = get(fig, 'UserData');
        paramter = data.paramter;
        option = data.option;
        percent = data.percent;
        delete(fig);
    else
        disp('Figure was closed before data could be retrieved.');
    end

    % Callback function for the submit button
    function submitCallback(~, ~)
        paramter = str2double(get(parameter_Box, 'String'));
        option = get(option_Box, 'String');
        percent = str2double(get(percent_Box, 'String'));
        %{
        % Check the input values
        if isnan(paramter) || paramter < 30 || paramter > 200
            errordlg('Bad size! body weight must be between 30 and 220 kg.', 'Input Error');
            return;
        end
        
        if isnan(option) || ~ismember(option, ["left", "right"])
            errordlg('Option must be R or L', 'Input Error');
            return;
        end

        if isnan(percent) || percent < 0 || percent > 100
            errordlg('bad value! the percent must be 0 ~ 100')
        end
        %}
        
        % Store the inputs in the figure's UserData property
        data.paramter = paramter;
        data.option = option;
        data.percent = percent;
        set(fig, 'UserData', data);

        % Resume the GUI
        uiresume(fig);
    end

    % Callback function for closing the figure
    function closeCallback(~, ~)
        % Resume the GUI
        uiresume(fig);
        % Delete the figure
        delete(fig);
    end
end

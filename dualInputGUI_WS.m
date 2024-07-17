function [body_weight_kg, option] = dualInputGUI_WS
    % Initialize output variables
    body_weight_kg = '';
    option = '';

    % Create a figure for the GUI
    fig = figure('Position', [300, 300, 400, 200], 'MenuBar', 'none', 'Name', 'Dual Input GUI', 'NumberTitle', 'off', 'Resize', 'off', 'CloseRequestFcn', @closeCallback);

    % Create the first input label and text box
    uicontrol('Style', 'text', 'Position', [50, 140, 200, 30], 'String', 'Input the body weight (kg) : ', 'HorizontalAlignment', 'left', 'FontSize', 10);
    body_weight_kg_Box = uicontrol('Style', 'edit', 'Position', [250, 140, 100, 30], 'FontSize', 10);

    % Create the second input label and text box
    uicontrol('Style', 'text', 'Position', [50, 80, 200, 30], 'String', 'Input the option (R,L) : ', 'HorizontalAlignment', 'left', 'FontSize', 10);
    option_Box = uicontrol('Style', 'edit', 'Position', [250, 80, 100, 30], 'FontSize', 10);

    % Create a submit button
    uicontrol('Style', 'pushbutton', 'Position', [150, 20, 100, 40], 'String', 'Submit', 'FontSize', 10, 'Callback', @submitCallback);

    % Store initial data in the figure's UserData property
    data.body_weight_kg = '';
    data.option = '';
    set(fig, 'UserData', data);

    % Wait for the user to close the figure
    uiwait(fig);

    % Check if the figure still exists before retrieving data
    if isvalid(fig)
        data = get(fig, 'UserData');
        body_weight_kg = data.body_weight_kg;
        option = data.option;
        delete(fig);
    else
        disp('Figure was closed before data could be retrieved.');
    end

    % Callback function for the submit button
    function submitCallback(~, ~)
        body_weight_kg = str2double(get(body_weight_kg_Box, 'String'));
        option = get(option_Box, 'String');
        
        % Check the input values
        if isnan(body_weight_kg) || body_weight_kg < 30 || body_weight_kg > 200
            errordlg('Bad size! body weight must be between 30 and 220 kg.', 'Input Error');
            return;
        end
        
        if isnan(option) || ~ismember(option, ['R','L'])
            errordlg('Option must be R or L', 'Input Error');
            return;
        end

        % Store the inputs in the figure's UserData property
        data.body_weight_kg = body_weight_kg;
        data.option = option;
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

    disp(body_weight_kg);
    disp(option);
end

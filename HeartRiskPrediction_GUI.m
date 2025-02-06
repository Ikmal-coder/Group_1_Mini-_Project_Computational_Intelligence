function HeartRiskPrediction_GUI
    % Create the main GUI figure
    hFig = figure('Position', [300, 200, 800, 600], ...
        'Name', 'Heart Risk Prediction System', ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'Resize', 'off');
    
    % Title
    uicontrol('Style', 'text', ...
        'Position', [250, 550, 300, 30], ...
        'String', 'Heart Risk Prediction System', ...
        'FontSize', 14, ...
        'FontWeight', 'bold');

    % Input labels and text boxes
    labels = {'Cholesterol (mg/dl):', 'Blood Pressure (Hg-mm):', ...
        'Physical Activity (0-1):', 'Age (years):', ...
        'BMI (kg/m^2):', 'Smoking (0-False, 1-True):', ...
        'Diabetes (mg/dl):'};
    defaultValues = {'200', '120', '0.5', '40', '25', '0', '150'};
    inputs = cell(length(labels), 1);

    for i = 1:length(labels)
        uicontrol('Style', 'text', ...
            'Position', [50, 500 - 50 * i, 200, 30], ...
            'String', labels{i}, ...
            'HorizontalAlignment', 'right');
        
        inputs{i} = uicontrol('Style', 'edit', ...
            'Position', [260, 505 - 50 * i, 100, 30], ...
            'String', defaultValues{i});
    end

    % Output display
    uicontrol('Style', 'text', ...
        'Position', [50, 100, 200, 30], ...
        'String', 'Predicted Heart Risk:', ...
        'HorizontalAlignment', 'right');
    outputDisplay = uicontrol('Style', 'text', ...
        'Position', [260, 100, 200, 30], ...
        'String', '', ...
        'BackgroundColor', 'white', ...
        'FontSize', 12, ...
        'FontWeight', 'bold');

    % Plot area for surface plot
    ax = axes('Parent', hFig, ...
        'Position', [0.55, 0.2, 0.4, 0.6]);
    title(ax, 'Risk Surface Plot');
    xlabel(ax, 'Cholesterol (mg/dl)');
    ylabel(ax, 'Blood Pressure (Hg-mm)');
    zlabel(ax, 'Heart Risk');
    hold(ax, 'on');

    % Load Fuzzy Inference System
    fis = loadHeartRiskFIS();

    % Button to run the simulation
    uicontrol('Style', 'pushbutton', ...
        'Position', [400, 50, 150, 50], ...
        'String', 'Predict Risk', ...
        'FontSize', 12, ...
        'FontWeight', 'bold', ...
        'Callback', @(~, ~) runSimulation());

    % Callback function for prediction
    function runSimulation()
        % Gather inputs
        inputData = zeros(1, 7);
        for j = 1:7
            inputData(j) = str2double(get(inputs{j}, 'String'));
        end
        
        % Evaluate FIS
        predictedRisk = evalfis(fis, inputData);
        set(outputDisplay, 'String', sprintf('%.2f', predictedRisk));
        
        % Update surface plot
        [X, Y] = meshgrid(0:10:500, 0:10:200);
        Z = zeros(size(X));
        for i = 1:size(X, 1)
            for j = 1:size(X, 2)
                Z(i, j) = evalfis(fis, [X(i, j), Y(i, j), inputData(3:end)]);
            end
        end
        
        % Plot surface
        cla(ax);
        surf(ax, X, Y, Z);
        shading(ax, 'interp');
        view(ax, [45 30]);
    end
end

function fis = loadHeartRiskFIS()
    % Create a Fuzzy Inference System (FIS) for heart risk prediction
    fis = mamfis('Name', 'HeartRiskPrediction');

    % Define Inputs
    fis = addInput(fis, [0 500], 'Name', 'Cholesterol');
    fis = addMF(fis, 'Cholesterol', 'trapmf', [0 0 190 200], 'Name', 'Normal');
    fis = addMF(fis, 'Cholesterol', 'trimf', [190 250 320], 'Name', 'Medium');
    fis = addMF(fis, 'Cholesterol', 'trimf', [230 320 500], 'Name', 'High');
    fis = addMF(fis, 'Cholesterol', 'trapmf', [280 500 500 500], 'Name', 'VeryHigh');

    fis = addInput(fis, [0 200], 'Name', 'BloodPressure');
    fis = addMF(fis, 'BloodPressure', 'trapmf', [0 0 120 130], 'Name', 'Normal');
    fis = addMF(fis, 'BloodPressure', 'trimf', [120 150 159], 'Name', 'Medium');
    fis = addMF(fis, 'BloodPressure', 'trapmf', [150 200 200 200], 'Name', 'VeryHigh');

    fis = addInput(fis, [0 1], 'Name', 'PhysicalActivity');
    fis = addMF(fis, 'PhysicalActivity', 'trapmf', [0 0 0.3 0.6], 'Name', 'False');
    fis = addMF(fis, 'PhysicalActivity', 'trapmf', [0.3 0.6 1 1], 'Name', 'True');

    fis = addInput(fis, [18 75], 'Name', 'Age');
    fis = addMF(fis, 'Age', 'trapmf', [18 18 34 38], 'Name', 'Young');
    fis = addMF(fis, 'Age', 'trimf', [34 45 58], 'Name', 'MiddleAge');
    fis = addMF(fis, 'Age', 'trimf', [40 58 75], 'Name', 'Old');
    fis = addMF(fis, 'Age', 'trapmf', [53 75 75 75], 'Name', 'VeryOld');

    fis = addInput(fis, [15 50], 'Name', 'BMI');
    fis = addMF(fis, 'BMI', 'trapmf', [15 15 24 25], 'Name', 'Normal');
    fis = addMF(fis, 'BMI', 'trimf', [24 28 32], 'Name', 'Overweight');
    fis = addMF(fis, 'BMI', 'trapmf', [30 50 50 50], 'Name', 'Obese');

    fis = addInput(fis, [0 1], 'Name', 'Smoking');
    fis = addMF(fis, 'Smoking', 'trapmf', [0 0 0.3 0.6], 'Name', 'False');
    fis = addMF(fis, 'Smoking', 'trapmf', [0.3 0.6 1 1], 'Name', 'True');

    fis = addInput(fis, [50 400], 'Name', 'Diabetes');
    fis = addMF(fis, 'Diabetes', 'trapmf', [50 50 150 160], 'Name', 'Normal');
    fis = addMF(fis, 'Diabetes', 'trapmf', [150 160 400 400], 'Name', 'Diabetic');

    % Define Output
    fis = addOutput(fis, [0 1], 'Name', 'HeartRisk');
    fis = addMF(fis, 'HeartRisk', 'trapmf', [0 0 0.3 0.5], 'Name', 'Low');
    fis = addMF(fis, 'HeartRisk', 'trimf', [0.3 0.5 0.7], 'Name', 'Medium');
    fis = addMF(fis, 'HeartRisk', 'trapmf', [0.5 0.7 1 1], 'Name', 'High');

    % Define Rules
    rules = [
        "Cholesterol==VeryHigh & BloodPressure==VeryHigh => HeartRisk=High";
        "Cholesterol==Medium & BloodPressure==Medium => HeartRisk=Medium";
        "Cholesterol==Normal & BloodPressure==Normal => HeartRisk=Low";
        "PhysicalActivity==False & Age==VeryOld => HeartRisk=High";
        "PhysicalActivity==True & Age==Young => HeartRisk=Low";
        "BMI==Obese & Smoking==True => HeartRisk=High";
        "BMI==Normal & Smoking==False => HeartRisk=Low";
        "Diabetes==Diabetic & Age==Old => HeartRisk=High";
        "Diabetes==Normal & PhysicalActivity==True => HeartRisk=Low";
    ];

    fis = addRule(fis, rules);
end

HeartRiskPrediction_GUI
HeartRiskPrediction_GUI
HeartRiskPrediction_GUI
% Create a new Fuzzy Inference System (FIS)
fis = mamfis('Name', 'HeartRiskPrediction');

%% Define Inputs

% 1. Cholesterol (mg/dl)
fis = addInput(fis, [0 500], 'Name', 'Cholesterol');
fis = addMF(fis, 'Cholesterol', 'trapmf', [0 0 190 200], 'Name', 'Normal');
fis = addMF(fis, 'Cholesterol', 'trimf', [190 250 320], 'Name', 'Medium');
fis = addMF(fis, 'Cholesterol', 'trimf', [230 320 500], 'Name', 'High');
fis = addMF(fis, 'Cholesterol', 'trapmf', [280 500 500 500], 'Name', 'VeryHigh');

% 2. Blood Pressure (Hg-mm)
fis = addInput(fis, [0 200], 'Name', 'BloodPressure');
fis = addMF(fis, 'BloodPressure', 'trapmf', [0 0 120 130], 'Name', 'Normal');
fis = addMF(fis, 'BloodPressure', 'trimf', [120 150 159], 'Name', 'Medium');
fis = addMF(fis, 'BloodPressure', 'trapmf', [150 200 200 200], 'Name', 'VeryHigh');

% 3. Physical Activity (True/False)
fis = addInput(fis, [0 1], 'Name', 'PhysicalActivity');
fis = addMF(fis, 'PhysicalActivity', 'trapmf', [0 0 0.3 0.6], 'Name', 'False');
fis = addMF(fis, 'PhysicalActivity', 'trapmf', [0.3 0.6 1 1], 'Name', 'True');

% 4. Age (Years)
fis = addInput(fis, [18 75], 'Name', 'Age');
fis = addMF(fis, 'Age', 'trapmf', [18 18 34 38], 'Name', 'Young');
fis = addMF(fis, 'Age', 'trimf', [34 45 58], 'Name', 'MiddleAge');
fis = addMF(fis, 'Age', 'trimf', [40 58 75], 'Name', 'Old');
fis = addMF(fis, 'Age', 'trapmf', [53 75 75 75], 'Name', 'VeryOld');

% 5. BMI (Kg/m^2)
fis = addInput(fis, [15 50], 'Name', 'BMI');
fis = addMF(fis, 'BMI', 'trapmf', [15 15 24 25], 'Name', 'Normal');
fis = addMF(fis, 'BMI', 'trimf', [24 28 32], 'Name', 'Overweight');
fis = addMF(fis, 'BMI', 'trapmf', [30 50 50 50], 'Name', 'Obese');

% 6. Smoking (True/False)
fis = addInput(fis, [0 1], 'Name', 'Smoking');
fis = addMF(fis, 'Smoking', 'trapmf', [0 0 0.3 0.6], 'Name', 'False');
fis = addMF(fis, 'Smoking', 'trapmf', [0.3 0.6 1 1], 'Name', 'True');

% 7. Diabetes (mg/dl)
fis = addInput(fis, [50 400], 'Name', 'Diabetes');
fis = addMF(fis, 'Diabetes', 'trapmf', [50 50 150 160], 'Name', 'Normal');
fis = addMF(fis, 'Diabetes', 'trapmf', [150 160 400 400], 'Name', 'Diabetic');

%% Define Output

% Heart Risk (Low, Medium, High)
fis = addOutput(fis, [0 1], 'Name', 'HeartRisk');
fis = addMF(fis, 'HeartRisk', 'trapmf', [0 0 0.3 0.5], 'Name', 'Low');
fis = addMF(fis, 'HeartRisk', 'trimf', [0.3 0.5 0.7], 'Name', 'Medium');
fis = addMF(fis, 'HeartRisk', 'trapmf', [0.5 0.7 1 1], 'Name', 'High');

%% Define Fuzzy Rules

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
disp('Fuzzy Rules:');
showrule(fis)

%% Plot Membership Functions for Inputs and Output
for i = 1:length(fis.Inputs)
    figure;
    plotmf(fis, 'input', i);
    title([fis.Inputs(i).Name, ' Membership Functions']);
    xlabel(fis.Inputs(i).Name);
    ylabel('Membership Degree');
end

% Plot Output Membership Functions
figure;
plotmf(fis, 'output', 1);
title('Heart Risk Membership Functions');
xlabel('Heart Risk');
ylabel('Membership Degree');

%% Test the System

% Example Input: [Cholesterol, BloodPressure, PhysicalActivity, Age, BMI, Smoking, Diabetes]
inputData = [300, 180, 0.8, 50, 37, 1, 300]; % Modify based on scenario

% Evaluate the System
predictedRisk = evalfis(fis, inputData);

% Display the Risk
disp(['Predicted Heart Risk: ', num2str(predictedRisk)]);

%% Surface Plot for Cholesterol and Blood Pressure
[X, Y] = meshgrid(0:10:500, 0:10:200);
Z = zeros(size(X));
for i = 1:size(X, 1)
    for j = 1:size(X, 2)
        Z(i, j) = evalfis(fis, [X(i, j), Y(i, j), 0.5, 50, 25, 0.5, 150]);
    end
end

figure;
surf(X, Y, Z);
xlabel('Cholesterol (mg/dl)');
ylabel('Blood Pressure (Hg-mm)');
zlabel('Heart Risk');
title('Heart Risk Surface Plot');



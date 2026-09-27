%% T2 - Respuesta de frecuencia para distintas duraciones de rampa (Tr)
% Requiere: modelo Simulink con bloque "To Workspace" 
%   -> Variable name: pu
%   -> Save format: Structure With Time
% La variable Tr debe estar referenciada en el bloque Ramp (no un valor fijo)

clear; clc;

Tr = 0.0001;
modelName = 'renew_energy_assignment1_part2';  % <-- cambia esto por el nombre real del .slx
Tsim = 100;                         % tiempo de simulación (s)

Tr_values = [0.0001, 1, 2.5, 5, 10, 20, 30, 60];  % duraciones de rampa (s)
n = length(Tr_values);

% Precalcular colores para que se distingan las 8 curvas
colors = lines(n);

results = cell(n,1);  % para guardar cada estructura pu

for i = 1:n
    Tr = Tr_values(i);       % se sube al workspace base
    assignin('base','Tr',Tr);
    
    set_param(modelName, 'StopTime', num2str(Tsim));
    
    simOut = sim(modelName);   % ejecuta la simulación
    
    pu = simOut.get('pu');     % obtiene la estructura "pu" (Structure With Time)
    
    results{i}.time = pu.time;
    results{i}.data = pu.signals.values;
    results{i}.Tr   = Tr;
end

%% Graficar las 8 respuestas juntas
figure; hold on; grid on;

legendEntries = cell(n,1);

for i = 1:n
    plot(results{i}.time, results{i}.data, 'LineWidth', 1.4, 'Color', colors(i,:));
    legendEntries{i} = sprintf('T_r = %.4g s', results{i}.Tr);
end

xlabel('Time (s)');
ylabel('\Delta f (pu)');
title('Frecuency response for different Tr ramp durations');
legend(legendEntries, 'Location', 'southeast');
hold off;

%% (Opcional) Extraer f_nadir y su tiempo para cada Tr (útil para T3)
fnadir = zeros(n,1);
t_nadir = zeros(n,1);

for i = 1:n
    [fnadir(i), idx] = min(results{i}.data);
    t_nadir(i) = results{i}.time(idx);
end

T = table(Tr_values', fnadir, t_nadir, ...
    'VariableNames', {'Tr_s','fnadir_pu','t_nadir_s'});
disp(T);

%% Exportar tabla a Excel
writetable(T, fullfile(pwd, 'fnadir_ramp_results.xlsx'), 'Sheet', 'Tr_fnadir');
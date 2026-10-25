

%% RETO 3 - ALGORITMO DE CONTROL Y CARGAS (SIGE)
% Control de energia para una institucion educativa rural
% Simulacion de 24 horas con bateria y control de cargas.

clear;
clc;
close all;

%% 1. HORAS DEL DIA
horas = 1:24;

%% 2. DATOS DEL RETO 2
% Generacion solar (kW)
solar = [0 0 0 0 0 4 8 12 17 21 24 25 ...
         24 21 17 12 8 4 0 0 0 0 0 0];

% Generacion eolica (kW)
eolica = [7 8 6 9 10 8 11 7 9 12 10 13 ...
          11 8 12 14 10 9 13 11 8 10 7 9];

% Demanda de la comunidad (kW)
demanda = [3 3 2 3 4 6 7 8 8 9 10 9 ...
           8 9 10 9 8 15 14 15 15 4 3 3];

%% 3. CONFIGURACION DE LA BATERIA
capacidad = 100;       % Capacidad de la bateria (kWh)
SOC_inicial = 50;      % Estado de carga inicial (%)
SOC_minimo = 0;        % Limite minimo (%)
SOC_maximo = 100;      % Limite maximo (%)

%% 4. RESERVAR ESPACIO PARA LOS RESULTADOS
generacion_total = solar + eolica;
balance = generacion_total - demanda;
SOC_hora = zeros(1,24);

escuela = strings(1,24);
bombeo = strings(1,24);
alumbrado = strings(1,24);
ruta = strings(1,24);

SOC = SOC_inicial;

%% 5. SIMULACION DE LAS 24 HORAS
for h = 1:24

    % Calcular el balance energetico
    balance(h) = generacion_total(h) - demanda(h);

    % Actualizar el estado de carga de la bateria
    if balance(h) >= 0
        excedente = balance(h);
        SOC = SOC + (excedente / capacidad) * 100;
    else
        faltante = abs(balance(h));
        SOC = SOC - (faltante / capacidad) * 100;
    end

    % Limitar el SOC entre 0 % y 100 %
    SOC = max(SOC_minimo, min(SOC_maximo, SOC));
    SOC_hora(h) = SOC;

    % Seleccionar ruta segun el SOC actualizado
    if SOC > 40
        % RUTA SEGURA: todos los servicios activos
        ruta(h) = "Segura";
        escuela(h) = "Activa";
        bombeo(h) = "Activo";
        alumbrado(h) = "Activo";

    elseif SOC > 20
        % RUTA DE ALERTA: desconectar alumbrado publico
        % Condicion: 20 % < SOC <= 40 %
        ruta(h) = "Alerta";
        escuela(h) = "Activa";
        bombeo(h) = "Activo";
        alumbrado(h) = "Desconectado";

    else
        % RUTA DE EMERGENCIA: priorizar la escuela
        % Condicion: SOC <= 20 %
        ruta(h) = "Emergencia";
        escuela(h) = "Activa";
        bombeo(h) = "Desconectado";
        alumbrado(h) = "Desconectado";
    end
end

%% 6. MOSTRAR REPORTE EN LA CONSOLA
fprintf('\nREPORTE DEL CONTROLADOR SIGE - 24 HORAS\n');
fprintf('Capacidad de bateria: %.0f kWh | SOC inicial: %.1f %%\n\n', ...
        capacidad, SOC_inicial);

fprintf('Hora | Solar | Eolica | Generacion | Demanda | Balance | SOC | Ruta | Escuela | Bombeo | Alumbrado\n');
fprintf('%s\n', repmat('-',1,115));

for h = 1:24
    fprintf('%02d   | %5.1f | %6.1f | %10.1f | %7.1f | %+7.1f | %5.1f%% | %-10s | %-7s | %-12s | %-12s\n', ...
        horas(h), solar(h), eolica(h), generacion_total(h), ...
        demanda(h), balance(h), SOC_hora(h), char(ruta(h)), ...
        char(escuela(h)), char(bombeo(h)), char(alumbrado(h)));
end

fprintf('\nSOC minimo registrado: %.1f %%\n', min(SOC_hora));
fprintf('SOC maximo registrado: %.1f %%\n', max(SOC_hora));
fprintf('Horas en ruta segura: %d\n', sum(ruta == "Segura"));
fprintf('Horas en ruta de alerta: %d\n', sum(ruta == "Alerta"));
fprintf('Horas en ruta de emergencia: %d\n', sum(ruta == "Emergencia"));

%% 7. GRAFICA DEL ESTADO DE CARGA (SOC)
figure('Name','Estado de carga de la bateria - SIGE','Color','w');

plot(horas, SOC_hora, '-o', 'LineWidth', 1.5, 'MarkerSize', 5);
hold on;
yline(40, '--', 'Limite de alerta (40%)');
yline(20, '--', 'Limite de emergencia (20%)');
yline(100, ':', 'SOC maximo (100%)');
yline(0, ':', 'SOC minimo (0%)');
grid on;
xlim([1 24]);
xticks(1:24);
ylim([0 105]);
xlabel('Hora del dia');
ylabel('Estado de carga SOC (%)');
title('Estado de carga de la bateria durante 24 horas');
hold off;

%% 8. GRAFICA DE GENERACION Y DEMANDA
figure('Name','Generacion y demanda - SIGE','Color','w');

plot(horas, generacion_total, '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(horas, demanda, '-s', 'LineWidth', 1.5, 'MarkerSize', 4);
grid on;
xlim([1 24]);
xticks(1:24);
xlabel('Hora del dia');
ylabel('Potencia (kW)');
title('Comparacion de generacion hibrida y demanda');
legend('Generacion total','Demanda de la comunidad','Location','best');
hold off;

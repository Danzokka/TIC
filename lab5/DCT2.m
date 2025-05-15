% Script para compressão de imagens utilizando DCT
% Disciplina: Teoria da Informação e Codificação

% Função para calcular MSE e PSNR conforme as fórmulas fornecidas
function [mse, psnr_db] = calcular_psnr(X_original, X_comprimida)
    % Calcula o MSE conforme a fórmula fornecida no enunciado
    numerador = sum(sum((X_original - X_comprimida).^2));
    denominador = sum(sum(X_original.^2));
    mse = numerador / denominador;
    
    % Calcula o PSNR em dB usando a fórmula fornecida no enunciado
    psnr_db = 10 * log10(65025 / mse);
end

% 1. Carregando a imagem e convertendo para escala de cinza
% Tente carregar a imagem fornecida pelo professor
try
    % Tente carregar a imagem Lenna
    X = imread('512px-Lenna_(test_image).bmp');
catch
    % Se não encontrar, use uma imagem de demonstração do MATLAB
    disp('Arquivo de imagem não encontrado. Usando imagem de demonstração.');
    X = imread('cameraman.tif');
end

% Converta para escala de cinza se necessário
if size(X, 3) > 1
    X = rgb2gray(X);
end

% Converta para double no intervalo [0,1]
X = im2double(X);

% Obtenha as dimensões da imagem
[L, C] = size(X);

% 2. Calcule a DCT em duas dimensões
X_dct = dct2(X);

% Exiba a imagem original e a imagem no domínio da DCT
figure(1);
subplot(1,2,1);
imshow(X);
title('Imagem Original');
subplot(1,2,2);
imshow(log(abs(X_dct) + 1), []);
title('Logaritmo da Magnitude da DCT');

% 3, 4, 5, 6. Realizar compressão para diferentes taxas de compressão
taxas = [0.05:0.05:0.95]; % Taxas de 5% a 95% em passos de 5%
num_taxas = length(taxas);
psnr_vals = zeros(1, num_taxas);

figure(2);
subplot_dim = ceil(sqrt(num_taxas));

% Loop para cada taxa de compressão
for i = 1:num_taxas
    taxa = taxas(i);
    
    % Determinar quantos coeficientes manter
    L_final = round(taxa * L);
    C_final = round(taxa * C);
    
    % Criar uma matriz de zeros e manter apenas os coeficientes desejados
    X_dct_modif = zeros(size(X_dct));
    X_dct_modif(1:L_final, 1:C_final) = X_dct(1:L_final, 1:C_final);
    
    % Calcular o fator de compressão
    fator_compressao = 1 - (L_final * C_final) / (L * C);
    
    % Recuperar a imagem com a DCT inversa
    X_modif = idct2(X_dct_modif);
    
    % Calcular MSE e PSNR
    [mse, psnr_db] = calcular_psnr(X, X_modif);
    psnr_vals(i) = psnr_db;
    
    % Exibir a imagem comprimida
    subplot(subplot_dim, subplot_dim, i);
    imshow(X_modif);
    title(sprintf('Taxa: %.2f, PSNR: %.2f dB', taxa, psnr_db));
end

% Plotar o gráfico de PSNR versus taxa de compressão
figure(3);
plot(taxas, psnr_vals, 'b-o', 'LineWidth', 2);
grid on;
xlabel('Taxa de Manutenção de Coeficientes');
ylabel('PSNR (dB)');
title('PSNR vs. Taxa de Manutenção');

% Teste com uma imagem artificial
% Crie uma imagem simples artificial
artificial_img = zeros(512, 512);
for i = 1:512
    for j = 1:512
        if mod(floor(i/64) + floor(j/64), 2) == 0
            artificial_img(i, j) = 1;
        end
    end
end

% Repita os passos 2-6 para a imagem artificial
X = artificial_img;
[L, C] = size(X);
X_dct = dct2(X);

figure(4);
subplot(1,2,1);
imshow(X);
title('Imagem Artificial Original');
subplot(1,2,2);
imshow(log(abs(X_dct) + 1), []);
title('DCT da Imagem Artificial');

% Loop para cada taxa de compressão na imagem artificial
art_psnr_vals = zeros(1, num_taxas);
for i = 1:num_taxas
    taxa = taxas(i);
    
    L_final = round(taxa * L);
    C_final = round(taxa * C);
    
    X_dct_modif = zeros(size(X_dct));
    X_dct_modif(1:L_final, 1:C_final) = X_dct(1:L_final, 1:C_final);
    
    X_modif = idct2(X_dct_modif);
    
    [mse, psnr_db] = calcular_psnr(X, X_modif);
    art_psnr_vals(i) = psnr_db;
end

% Comparar os resultados entre imagem real e artificial
figure(5);
plot(taxas, psnr_vals, 'b-o', 'LineWidth', 2); hold on;
plot(taxas, art_psnr_vals, 'r-s', 'LineWidth', 2);
grid on;
xlabel('Taxa de Manutenção de Coeficientes');
ylabel('PSNR (dB)');
title('Comparação: PSNR vs. Taxa de Manutenção');
legend('Imagem Real', 'Imagem Artificial');
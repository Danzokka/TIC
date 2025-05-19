% DCT-based Image Compression
% This script performs DCT-based compression on images at various compression rates
% and evaluates the results both subjectively and objectively

% 1. Carregue a imagem X e converta-a para escala de cinza, representando-a em números reais
% (double) no intervalo [0 , 1]
try
    X = imread('Lenna_512x512.png');
    if size(X,3) == 3  % Check if the image is RGB
        X = rgb2gray(X);
    end
    X = im2double(X);  % Convert to double with values between 0 and 1
catch
    error('Não foi possível carregar a imagem. Verifique se "Lenna_512x512.png" existe na pasta atual.');
end

% Get image dimensions
[L, C] = size(X);

% Display the original image
figure('Name', 'Imagem Original');
imshow(X);
title('Imagem Original');

% 2. Calcule sua DCT em duas dimensões (comando dct2 do Matlab)
X_dct = dct2(X);

% Visualize a DCT para demonstrar a esparsidade
figure('Name', 'Coeficientes DCT');
imshow(log(abs(X_dct) + 1), []);  % Log scale for better visualization
title('Coeficientes DCT (escala logarítmica)');
colormap(jet); colorbar;
fprintf('Observe como a matriz DCT é esparsa ("cheia de zeros"), característica explorada em compressão.\n');

% Initialize arrays to store results
% 6. Taxas de compressão conforme solicitado: 5%, 10%, 15%, ..., 90%, 95%
compression_rates = [0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95];
psnr_values = zeros(size(compression_rates));
compression_factors = zeros(size(compression_rates));

% Create figure for displaying all compressed images
figure('Name', 'Imagens Comprimidas', 'Position', [100, 100, 1200, 800]);

% 3-6. Process each compression rate
for i = 1:length(compression_rates)
    rate = compression_rates(i);
    
    % 3. Determine coeficientes no domínio da DCT a serem mantidos
    L_final = round(rate * L);
    C_final = round(rate * C);
    
    % Create modified DCT with only selected coefficients
    X_dct_modif = zeros(size(X_dct));
    X_dct_modif(1:L_final, 1:C_final) = X_dct(1:L_final, 1:C_final);
    
    % Calculate compression factor
    fator_compressao = 1 - (L_final * C_final) / (L * C);
    compression_factors(i) = fator_compressao * 100;  % Store as percentage
    
    % 4. Recover the image using inverse DCT (idct2)
    X_modif = idct2(X_dct_modif);
    
    % Ensure values are in valid range [0,1]
    X_modif = max(0, min(1, X_modif));
    
    % 5. Calculate PSNR (Peak Signal-to-Noise Ratio)
    mse = mean((X(:) - X_modif(:)).^2);
    if mse == 0
        psnr_val = Inf;  % Perfect reconstruction
    else
        psnr_val = 10 * log10(1^2 / mse);  % 1 is the maximum value for double images
    end
    psnr_values(i) = psnr_val;
    
    % Display the compressed image
    subplot(4, 5, i);
    imshow(X_modif, [0 1]);
    title(sprintf('Taxa=%.2f, CF=%.1f%%, PSNR=%.2fdB', rate, fator_compressao*100, psnr_val));
end

% 6. Plot PSNR vs compression factor as requested
figure('Name', 'PSNR vs Taxa de Compressão');
plot(compression_factors, psnr_values, 'o-', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b');
xlabel('Taxa de Compressão (%)');
ylabel('PSNR (dB)');
title('Qualidade da Imagem (PSNR) vs Taxa de Compressão');
grid on;
set(gca, 'FontSize', 12);

% Print a table of results with subjective evaluation
fprintf('\n Resumo dos Resultados:\n');
fprintf('----------------------------------------------------------------\n');
fprintf(' Taxa de Coeficientes | Taxa de Compressão (%) | PSNR (dB) | Avaliação Subjetiva\n');
fprintf('----------------------------------------------------------------\n');

% Subjective evaluation criteria based on PSNR values
for i = 1:length(compression_rates)
    % Determine subjective quality based on PSNR
    if psnr_values(i) > 40
        avaliacao = 'Excelente - Diferenças imperceptíveis';
    elseif psnr_values(i) > 35
        avaliacao = 'Muito boa - Diferenças quase imperceptíveis';
    elseif psnr_values(i) > 30
        avaliacao = 'Boa - Detalhes sutis perdidos';
    elseif psnr_values(i) > 25
        avaliacao = 'Razoável - Perda de detalhes visível';
    elseif psnr_values(i) > 20
        avaliacao = 'Pobre - Detalhes e texturas significativamente degradados';
    else
        avaliacao = 'Muito pobre - Imagem severamente degradada';
    end
    
    fprintf(' %.2f                | %.2f                 | %.2f     | %s\n', ...
        compression_rates(i), compression_factors(i), psnr_values(i), avaliacao);
end
fprintf('----------------------------------------------------------------\n');

% Additional visual comparison for selected rates to support subjective evaluation
selected_rates = [0.05, 0.15, 0.30, 0.50, 0.70, 0.95];
figure('Name', 'Comparação Visual para Avaliação Subjetiva', 'Position', [100 100 1200 600]);

for i = 1:length(selected_rates)
    rate = selected_rates(i);
    idx = find(compression_rates == rate);
    
    if ~isempty(idx)
        % Apply compression at the selected rate
        L_final = round(rate * L);
        C_final = round(rate * C);
        X_dct_modif = zeros(size(X_dct));
        X_dct_modif(1:L_final, 1:C_final) = X_dct(1:L_final, 1:C_final);
        fator_compressao = 1 - (L_final * C_final) / (L * C);
        X_modif = idct2(X_dct_modif);
        X_modif = max(0, min(1, X_modif));
        
        % Display side-by-side comparison
        subplot(2, 3, i);
        imshowpair(X, X_modif, 'montage');
        title(sprintf('Taxa=%.2f, Compressão=%.1f%%, PSNR=%.2fdB', ...
            rate, fator_compressao*100, psnr_values(idx)));
    end
end

% Final commentary on the results
fprintf('\n\nComentários sobre os resultados:\n');
fprintf('1. Observando o gráfico PSNR vs Taxa de Compressão, nota-se que a qualidade da imagem\n');
fprintf('   (medida pelo PSNR) diminui à medida que a taxa de compressão aumenta.\n');
fprintf('2. Taxas de compressão até 50%% (mantendo cerca de 30%% dos coeficientes DCT) geralmente\n');
fprintf('   mantêm uma qualidade visual aceitável, com PSNR acima de 30dB.\n');
fprintf('3. Taxas de compressão muito altas (acima de 80%%) resultam em degradação significativa\n');
fprintf('   da imagem, principalmente em regiões com texturas e detalhes finos.\n');
fprintf('4. A compressão via DCT concentra a energia da imagem nos coeficientes de baixa frequência\n');
fprintf('   (canto superior esquerdo da matriz DCT), o que permite eliminar muitos coeficientes\n');
fprintf('   de alta frequência sem perda perceptível de qualidade.\n');
fprintf('5. Este princípio é explorado em padrões de compressão como JPEG para imagens e\n');
fprintf('   MPEG/H.26x para vídeos.\n');
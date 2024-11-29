function output_image = edge_detection(original_img, opt)
% 0 = Laplace    
% 1 = LoG
% 2 = Sobel
% 3 = Prewitt
% 4 = Roberts
% 5 = Canny
    % Baca gambar input
    if size(original_img, 3) == 3
        gray_img = rgb2gray(original_img); % Ubah menjadi grayscale jika berwarna
    else
        gray_img = original_img;
    end


    % Tampilkan gambar asli
    figure;
    subplot(1, 3, 1);
    imshow(original_img);
    title('Original Image');
    
    if opt == 0
        % Laplace
        laplace_kernel = [0 -1 0; -1 4 -1; 0 -1 0];
        edge_laplace = conv2(double(gray_img), laplace_kernel, 'same');
        subplot(1, 3, 2);
        imshow(uint8(abs(edge_laplace)));
        title('Laplace');
        res = edge_laplace;
    elseif opt == 1
         % Laplacian of Gaussian (LoG)
        h = fspecial('log', [5 5], 0.5); % Kernel LoG
        edge_log = imfilter(double(gray_img), h, 'replicate');
        subplot(1, 3, 2);
        imshow(uint8(abs(edge_log)));
        title('LoG');
        res = edge_log;
    elseif opt == 2
        % Sobel
        sobel_x = [-1 0 1; -2 0 2; -1 0 1];
        sobel_y = [-1 -2 -1; 0 0 0; 1 2 1];
        edge_sobel_x = conv2(double(gray_img), sobel_x, 'same');
        edge_sobel_y = conv2(double(gray_img), sobel_y, 'same');
        edge_sobel = sqrt(edge_sobel_x.^2 + edge_sobel_y.^2);
        subplot(1, 3, 2);
        imshow(uint8(edge_sobel));
        title('Sobel');
        res = edge_sobel;
    elseif opt == 3
        % Prewitt
        prewitt_x = [-1 0 1; -1 0 1; -1 0 1];
        prewitt_y = [-1 -1 -1; 0 0 0; 1 1 1];
        edge_prewitt_x = conv2(double(gray_img), prewitt_x, 'same');
        edge_prewitt_y = conv2(double(gray_img), prewitt_y, 'same');
        edge_prewitt = sqrt(edge_prewitt_x.^2 + edge_prewitt_y.^2);
        subplot(1, 3, 2);
        imshow(uint8(edge_prewitt));
        title('Prewitt');
        res = edge_prewitt;
    elseif opt == 4
        % Roberts
        roberts_x = [1 0; 0 -1];
        roberts_y = [0 1; -1 0];
        edge_roberts_x = conv2(double(gray_img), roberts_x, 'same');
        edge_roberts_y = conv2(double(gray_img), roberts_y, 'same');
        edge_roberts = sqrt(edge_roberts_x.^2 + edge_roberts_y.^2);
        subplot(1, 3, 2);
        imshow(uint8(edge_roberts));
        title('Roberts');
        res = edge_roberts;
    elseif opt == 5
        % Canny (built-in untuk pembanding)
        edge_canny = edge(gray_img, 'canny');
        subplot(1, 3, 2);
        imshow(edge_canny);
        title('Canny');
        res = edge_canny;
    else
        % Defaults to Roberts
        roberts_x = [1 0; 0 -1];
        roberts_y = [0 1; -1 0];
        edge_roberts_x = conv2(double(gray_img), roberts_x, 'same');
        edge_roberts_y = conv2(double(gray_img), roberts_y, 'same');
        edge_roberts = sqrt(edge_roberts_x.^2 + edge_roberts_y.^2);
        subplot(1, 3, 2);
        imshow(uint8(edge_roberts));
        title('Roberts');
        res = edge_roberts;
    end
     % Segmentasi
    % Ambil hasil deteksi tepi
    threshold = graythresh(uint8(res));
    segmented_image = imbinarize(uint8(res), threshold);
    
    % Inversi segmentasi untuk menutup bagian luar tepi
    inverted_mask = imcomplement(segmented_image);
    
    % Cari komponen terhubung dan label daerah
    labeled_regions = bwlabel(inverted_mask, 4); % 4-connex untuk region detection
    
    % Identifikasi area dalam tepi (area tertutup)
    % Asumsi latar belakang terhubung ke label pertama
    inside_mask = ismember(labeled_regions, 1); % Hanya area dalam tepi
    
    % Terapkan masker ke citra asli
    if size(original_img, 3) == 3
        % Jika citra berwarna, terapkan mask ke setiap saluran
        masked_image = original_img;
        for channel = 1:3
            channel_data = masked_image(:, :, channel);
            channel_data(inside_mask) = 0;
            masked_image(:, :, channel) = channel_data;
        end
    else
        % Jika citra grayscale, terapkan mask langsung
        masked_image = original_img;
        masked_image(inside_mask) = 0;
    end
    
    % Tampilkan citra hasil masking
    subplot(1, 3, 3);
    imshow(masked_image);
    title('Segmented Image');
    output_image = masked_image;
end

function output_image = houghtrans(image, p, q, threshold)
    [row, col, depth] = size(image);
    imggray = image;
    % Convert to gray
    if depth > 1
        imggray = rgb2gray(imggray);
    end
    canny = edge(imggray, "canny", 0.3);
    figure,imshow(canny)
    % Matrices for cosine and sine values
    Rad2Deg = 0.017453;
    cosmat = zeros(p, 1);
    sinmat = zeros(p, 1);
    for i = 0:p-1
        theta = double(i * 180.0 / (p - 1) - 90.0);
        theta = double(theta * Rad2Deg);
        cosmat(i + 1) = double(cos(theta));
        sinmat(i + 1) = double(sin(theta));
    end
    MatrixP = zeros(p, q);
    SQRTD = sqrt(double(row^2) + double(col^2));

    % Accumulator array
    for k = 0:row-1
        for l = 0:col-1
            if canny(k + 1, l + 1) == 1
                for i = 0:p-1
                    r = k * cosmat(i + 1) + l * sinmat(i + 1);
                    b = SQRTD;
                    r = r + b;
                    r = r / (SQRTD * 2.0);
                    r = r * (q - 1);
                    r = r + 0.5;
                    j = floor(r);
                    if j >= 0 && j < q
                        MatrixP(i + 1, j + 1) = MatrixP(i + 1, j + 1) + 1;
                    end
                end
            end
        end
    end

    % Plot lines on the original image
    output_image = image;
    for i = 0:p-1
        for j = 0:q-1
            if MatrixP(i + 1, j + 1) > threshold
                r = j * (SQRTD * 2.0) / (q - 1) - SQRTD;
                for k = 0:row-1
                    l = (r - k * cosmat(i + 1)) / sinmat(i + 1);
                    if l >= 0 && l < col
                        % Draw on the output image
                        if depth > 1
                            output_image(k + 1, round(l + 1), 1) = 255; % Red channel
                            output_image(k + 1, round(l + 1), 2) = 0;   % Green channel
                            output_image(k + 1, round(l + 1), 3) = 0;   % Blue channel
                        else
                            output_image(k + 1, round(l + 1)) = 255;   % For grayscale
                        end
                    end
                end
            end
        end
    end
end

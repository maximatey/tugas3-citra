function [output_image, edge_image] = houghtrans(image, p, q, threshold)
    [row, col, depth] = size(image);
    imggray = image;
    % Convert to gray
    if depth > 1
        imggray = rgb2gray(imggray);
    end
    canny = edge(imggray, "canny", [0.03,0.18]);
    roi = zeros(row,col);
    roi(ceil(row*2/3):end,:) = 1;
    canny = canny & roi;
%     figure,imshow(canny)
    edge_image = canny;
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
                x1 = 0; % Start at the top of the image
                x2 = row - 1; % Bottom of the image
                y1 = (r - x1 * cosmat(i + 1)) / sinmat(i + 1); % Calculate y for the top edge
                y2 = (r - x2 * cosmat(i + 1)) / sinmat(i + 1); % Calculate y for the bottom edge

                % Check bounds for y1 and y2
                if y1 >= 0 && y1 < col
                    if y2 >= 0 && y2 < col
                        % Draw a line between (x1, y1) and (x2, y2)
                        if depth > 1
                            output_image = insertShape(output_image, 'Line', [y1, x1, y2, x2], 'Color', 'red', 'LineWidth', 1);
                        else
                            output_image = insertShape(output_image, 'Line', [y1, x1, y2, x2], 'Color', [255, 255, 255], 'LineWidth', 1);
                        end
                    end
                end
            end
        end
    end
end

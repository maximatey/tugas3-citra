function houghtrans(image)
    [row,col,depth] = size(image);
    imggray = image;
    % Convert to gray
    if(depth>1)
        imggray = rgb2gray(imggray);
    end
    canny = edge(imggray,"canny");
    imshow(canny)
end
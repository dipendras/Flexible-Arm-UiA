function pos = blockPos(x, y, b, h)

    % pos = [left top right bottom]
    pos = [
        x - b/2
        y - h/2
        x + b/2
        y + h/2
    ]';

end
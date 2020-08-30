function edge_PSNR = EdgePsnr(original_HRImg,our_HRImg)
BW = edge(original_HRImg,'sobel');
BW = double(BW);
[row,col] = find(BW);
mse = 0;
[number,dim] = size(row);
for i = 1:number
    diff_img = our_HRImg(row(i,1),col(i,1))-original_HRImg(row(i,1),col(i,1));
    mse = mse + diff_img*diff_img;
end
mse = mse/number;
edge_PSNR=10*log10(255^2/mse);

% [m,n] = size(BW);

% count = 0;
% for i = 1:m
%     for j = 1:n
%         if BW(m,n) == 0
%             diff_img = our_HRImg(m,n)-original_HRImg(m,n);
%             mse = mse + diff_img*diff_img;
%             count = count + 1;
%         end
%     end
% end
% mse = mse/count;
% edge_PSNR=10*log10(255^2/mse);
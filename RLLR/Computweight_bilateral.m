function weight=Computweight_bilateral(center,sample,swin,location_diff)
kernel = make_kernel(swin);
kernel = kernel / sum(sum(kernel));%normalization
d = (center-sample).*(center-sample).*(kernel.*0.05).*kernel;
dd = sqrt(sum(d(:)));
diff_location = sqrt(sum(location_diff .* location_diff.*0.004));
weight = exp(-dd)*exp(-diff_location);
if weight<1e-10
 weight=0;
end


end
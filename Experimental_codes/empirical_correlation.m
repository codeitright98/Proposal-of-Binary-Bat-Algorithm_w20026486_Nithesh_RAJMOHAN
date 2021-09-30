

bench_functions = {@sphere, @rosenbrock, @linear_step, @noisy_quartic, @foxholes};
bat_functions = numel(bench_functions);


correlation = empirical_correlation(bench_functions, {[-5.12, 5.12], [-5.12, 5.12], [-5.12, 5.12], [-1.28, 1.28], [-65.536, 65.536]}, 1000);



corr = imagesc(correlation);
set(corr, 'alphadata', 0.6)
colormap(jet);


legends = {'$f_{1}$','$f_{2}$','$f_{3}$', '$f_{4}$', '$f_{5}$'};
set(gca,'xtick', 1:bat_functions,'xticklabel',legends, 'ytick', 1:bat_functions, 'yticklabel',legends, 'fontname', 'times', 'fontsize', 18, 'TickLabelInterpreter', 'latex'); 


[r,c] = size(correlation);
for i = 1 : r
    for j = 1 : c
        textHandles(j,i) = text(j,i,num2str(correlation(i,j)),'horizontalAlignment','center', 'fontname', 'times', 'fontsize', 18); %#ok
    end
end


lr_triangle = tril(correlation, -1);
mean_correlation = sum(sum(lr_triangle)) / sum(1:bat_functions-1);
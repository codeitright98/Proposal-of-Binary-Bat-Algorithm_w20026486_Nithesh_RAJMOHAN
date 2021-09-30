

total_runs = 1e2;

becnmark_functions = {@sphere, @rosenbrock, @linear_step, @noisy_quartic, @foxholes};


lower_boundary = [-5.12, -5.12, -5.12, -1.28, -65.536]; 
upper_boundary = abs(lower_boundary);


Global_minima = [0, 0, 0, 0, 0.998];


parameters = allcomb(0, [1, 2], [0.1, 0.4, 0.7, 1], [0.5, 0.9, 1.4, 1.9], [0.5, 0.9, 1.4, 1.9], [0.1, 0.5, 1]);
set_param = size(parameters, 1);


intial_functions = numel(becnmark_functions);
for i = 1 : initial_functions
    for k = 1  : set_param
        result.(func2str(becnmark_functions{i})).(['paramset', num2str(k)]).fht = nan(total_runs, 1);
    end
end

firstparams = @(p, lb, ub, f, minval) struct( 'bench_function',                  f,      ...
                                          'bat_dim',               2,      ...
                                          'init_post',    [],     ...
                                          'lower_bound',          lb,     ...
                                          'upper_bound',          ub,     ...
                                          'freqmin',                 p(1),   ...
                                          'freqmax',                 p(2),   ...
                                          'r0',                   p(3),   ...
                                          'a',                    p(4),   ...
                                          'g',                    p(5),   ...
                                          'loudness',             p(6),   ...
                                          'epsilon',              1e-3,   ...
                                          'nb_bats',              20,     ...
                                          'max_iter',             2500,   ...
                                          'known_best_fitness',   minval, ...
                                          'tol',                  1e-2,   ...
                                          'positions_hist_flag',  false);
                                      
% Parameter set generating function
firstparams = @(p, lb, ub, f, minval) struct( 'fun',                  f,      ...
                                          'nb_dim',               2,      ...
                                          'initial_positions',    [],     ...
                                          'lower_bound',          lb,     ...
                                          'upper_bound',          ub,     ...
                                          'fmin',                 0,   ...
                                          'fmax',                 2,   ...
                                          'r0',                   0.7,   ...
                                          'a',                    1.9,   ...
                                          'g',                    0.1,   ...
                                          'loudness',             1,   ...
                                          'epsilon',              1e-3,   ...
                                          'nb_bats',              20,     ...
                                          'max_iter',             2500,   ...
                                          'known_best_fitness',   minval, ...
                                          'tol',                  1e-2,   ...
                                          'positions_hist_flag',  false);  



counter = 0;

total_runs = nb_functions * set_param * total_runs;

% For each objective function
for i = 1 : bat_functions
    
  % For each parameter set
  for j = 1 : set_param
      
      % Calculate first hitting times
      for k = 1 : total_runs
          counter = counter + 1;
          result.(func2str(becnmark_functions{i})).(['paramset', num2str(j)]).fht(k) = bat(firstparams(parameters(j,:), lower_boundary(i), upper_boundary(i), becnmark_functions{i}, Global_minima(i)));
      end
      
   
      % Calculate nanmedian (i.e. ignores NaNs)
      result.(func2str(becnmark_functions{i})).(['paramset', num2str(j)]).median = nanmedian(result.(func2str(becnmark_functions{i})).(['paramset', num2str(j)]).fht);
      
      % Calculate percentage of targets hit
      result.(func2str(becnmark_functions{i})).(['paramset', num2str(j)]).converged_percentage = 1 - sum(isnan(result.(func2str(becnmark_functions{i})).(['paramset', num2str(j)]).fht))/total_runs;
  end
  
end

%%

for i = 1 : bat_functions
    
    % Create rankings structure
    rankings.(func2str(becnmark_functions{i})) = nan(set_param, 2);
    
    for j = 1 : set_param
        for k = 1 : total_runs
            
            % Calculate percentage of hits
            conv_percentage = (1 - sum(isnan(result.(func2str(becnmark_functions{i})).(['paramset', num2str(j)]).fht))/total_runs)*100;
            result.(func2str(becnmark_functions{i})).(['paramset', num2str(j)]).converged_percentage = conv_percentage;
            
            % Calculate median and adjusted median
            med = nanmedian(result.(func2str(becnmark_functions{i})).(['paramset', num2str(j)]).fht);
            result.(func2str(becnmark_functions{i})).(['paramset', num2str(j)]).median = med;
            adjd_med = med/(conv_percentage/100);
            result.(func2str(becnmark_functions{i})).(['paramset', num2str(j)]).adjusted_median = adjd_med;
           
        end
        
         % Store adjusted median for ranking
         ras.(func2str(becnmark_functions{i}))(j,1) = adjd_med;
        
    end
    
    % Store adjusted median for ranking
    [~, ras.(func2str(becnmark_functions{i}))(:,2)] = sort(ras.(func2str(becnmark_functions{i}))(:,1),'ascend');
    
end

% Find best parameter set (i.e. minimum sum of ranks over the test set)
sum_of_ranks = zeros(set_param, 1);
for i = 1 : nb_functions
    sum_of_ranks = sum_of_ranks + ras.(func2str(becnmark_functions{i}))(:,2);
end

[minimum_rank, minimum_rank_ix] = min(sum_of_ranks);

best_paramset = parameters(minimum_rank_ix, :);


function [fis, limits] = fis_vetor(arr, params)
    % expand membership functions
    in_n_out = cellfun(@(x) size(x, 1), params.mf);
    i = 1;
    aux = [];
    for k = 1:length(params.mf)
        fuzzmf = params.mf{k};
        for j = 1:length(fuzzmf)
            [~, ~, x_limits, ~, mf] = fuzzmf{j}{:};
            x_mean = mean(x_limits);
            if strcmp(mf{1}, 'trapmf')
                if params.msimetrico
                    ax = [arr(i) arr(i) arr(i+1:i+2)];
                    aux = [aux ax x_mean 2*x_mean-flip(ax)];
                    i = i + 3;
                else
                    assert(strcmp(mf{end}, 'trapmf'), 'fun��es extremo devem ser do mesmo tipo!');
                    aux = [aux arr(i) arr(i) arr(i+1:i+5) arr(i+6) arr(i+6)];
                    i = i + 7;
                end
            else
                if params.msimetrico
                    aux = [aux arr(i:i+3) x_mean 2*x_mean-flip(arr(i:i+3))];
                    i = i + 4;
                else
                    aux = [aux arr(i:i+8)];
                    i = i + 9;
                end
            end
        end
    end
    % expand rule weights
    function y = expand(x)
        y = [];
        n = size(x,2) - 1;
        z = sum(x(1:n) == 2);
        choose = unique(nchoosek(repmat([1 3], [1 n-z]), n-z), 'rows');
        for r = 1:size(choose,1)
            c = 1;
            y(r,n+1) = x(n+1);
            for m = 1:n
                if x(m) == 1
                    y(r,m) = choose(r,c);
                    c = c + 1;
                else
                    y(r,m) = 2;
                end
            end
            for ex = 1:size(params.exclude, 1)
                if all(y(r,1:n) == params.exclude(ex, :))
                    y(r,n+1) = 0;
                end
            end
            for re = 1:size(params.reverse, 1)
                if all(y(r,1:n) == params.reverse(re, :))
                    y(r,n+1) = 1 - y(r,n+1);
                end
            end
        end
    end
    if params.wsimetrico
        for k = 1:length(params.mf)
            ruleList = [unique(nchoosek(repmat(1:2, [1 in_n_out(k)]), in_n_out(k)), 'rows') arr(i+(0:2^in_n_out(k)-1))'];
            % expand in place
            ruleAux = arrayfun(@(i) expand(ruleList(i,:)), 1:size(ruleList, 1), 'UniformOutput', false);
            % extract and sort
            ruleList = sortrows(vertcat(ruleAux{:}));
            aux = [aux ruleList(:,4)'];
            i = i + 2^in_n_out(k);
        end
        arr = aux;
    else
        arr = [aux arr(i:end)];
    end
%%    
    % apply pso fuzzy array to build a fis
    limits = struct();
    i = 1;
    for k = 1:length(params.mf) % conjunto fuzzy
        fuzzmf = params.mf{k};
        fis(k) = newfis('tipper');
        [n_io, n_in, n_out] = deal(0);        
        for j = 1:length(fuzzmf) % entradas e sa�das    
            [mf_io, mf_name, x_limits, ~, mf] = fuzzmf{j}{:};
            limits.(mf_name) = struct('min', min(x_limits), 'max', max(x_limits));
            fis(k) = addvar(fis(k), mf_io, mf_name, x_limits);
            if strcmp(mf_io, 'input')
                n_in = n_in + 1;
                n_io = n_in;
            elseif strcmp(mf_io, 'output')
                n_out = n_out + 1;
                n_io = n_out;
            end
            x_max = max(x_limits);
            x_min = min(x_limits);
            for jj = 1:length(mf)
                ii = i + (jj-1)*3;
                if strcmp(mf{jj}, 'trapmf') && (jj == 1)
                    fis(k) = addmf(fis(k), mf_io, n_io, [mf_name '-' num2str(jj)], mf{jj}, [x_min x_min mean(arr(ii:ii+1)) arr(ii+2)]);
                elseif strcmp(mf{jj}, 'trapmf') && (jj == 3)
                    fis(k) = addmf(fis(k), mf_io, n_io, [mf_name '-' num2str(jj)], mf{jj}, [arr(ii) mean(arr(ii+1:ii+2)) x_max x_max]);
                elseif strcmp(mf{jj}, 'trimf')
                    fis(k) = addmf(fis(k), mf_io, n_io, [mf_name '-' num2str(jj)], mf{jj}, sort(arr(ii:ii+2)));
                end
                for iii = ii:(ii + 2)
                end
            end
            i = iii + 1;
        end
    end
    for k = 1:length(params.mf)
        ruleList = [unique(nchoosek(repmat(1:3, [1 in_n_out(k)]), in_n_out(k)), 'rows') arr(i+(0:3^in_n_out(k)-1))'];
        ruleList(:,end+1) = 1;
        fis(k) = addrule(fis(k), ruleList);
        i = i + 3^in_n_out(k);
    end
end
% Лабораторная работа 4: Перебор
% Тема: Определение оптимального времени первого троллейбуса
% Индивидуальное задание 11

% ========================= Базовый полный перебор =========================
% Вычисление времени ожидания одного пассажира (скорректировано)
wait_time(Ti, K, T, Wait) :-
    Wait is ((T - Ti) mod K + K) mod K.

% Суммарное время ожидания для всех пассажиров при заданном T
sum_wait_times([], _, _, 0).
sum_wait_times([Ti|Tail], K, T, Total) :-
    wait_time(Ti, K, T, W),
    sum_wait_times(Tail, K, T, Rest),
    Total is W + Rest.

% Максимальное время ожидания для всех пассажиров при заданном T
max_wait_times([Ti|Tail], K, T, Max) :-
    wait_time(Ti, K, T, W),
    max_wait_times(Tail, K, T, W, Max).

max_wait_times([], _, _, CurMax, CurMax).
max_wait_times([Ti|Tail], K, T, CurMax, Max) :-
    wait_time(Ti, K, T, W),
    NewCur is max(CurMax, W),
    max_wait_times(Tail, K, T, NewCur, Max).

% Поиск лучшего T полным перебором (O(K * N))
best_T_sum_brute(Times, K, BestT) :-
    Upper is K - 1,
    findall(T-Sum, (between(0, Upper, T), sum_wait_times(Times, K, T, Sum)), Pairs),
    min_pair(Pairs, BestT).

best_T_max_brute(Times, K, BestT) :-
    Upper is K - 1,
    findall(T-Max, (between(0, Upper, T), max_wait_times(Times, K, T, Max)), Pairs),
    min_pair(Pairs, BestT).

% ==================== Усовершенствованный алгоритм (O(N + K^2)) ====================
% Строим гистограмму: counts[R] = количество пассажиров с ti mod K = R
build_histogram(Times, K, Hist) :-
    list_of_zeros(K, Zeros),
    count_remainders(Times, K, Zeros, Hist).

list_of_zeros(0, []).
list_of_zeros(N, [0|T]) :- N > 0, N1 is N-1, list_of_zeros(N1, T).

count_remainders([], _, Hist, Hist).
count_remainders([Ti|Tail], K, HistIn, HistOut) :-
    R is Ti mod K,
    increase_at(R, HistIn, HistUpd),
    count_remainders(Tail, K, HistUpd, HistOut).

increase_at(0, [H|T], [H1|T]) :- H1 is H+1.
increase_at(N, [H|T], [H|TNew]) :- N>0, N1 is N-1, increase_at(N1, T, TNew).

% Сумма ожиданий для T по гистограмме
sum_by_hist(Hist, K, T, Total) :-
    sum_by_hist(0, K, T, Hist, 0, Total).

sum_by_hist(_, _, _, [], Acc, Acc).
sum_by_hist(R, K, T, [Cnt|Rest], Acc, Total) :-
    Wait is ((T - R) mod K + K) mod K,
    Contrib is Wait * Cnt,
    NewAcc is Acc + Contrib,
    R1 is R+1,
    sum_by_hist(R1, K, T, Rest, NewAcc, Total).

% Максимальное ожидание для T по гистограмме
max_by_hist(Hist, K, T, Max) :-
    max_by_hist(0, K, T, Hist, 0, Max).

max_by_hist(_, _, _, [], Cur, Cur).
max_by_hist(R, K, T, [Cnt|Rest], Cur, Max) :-
    ( Cnt > 0 ->
        Wait is ((T - R) mod K + K) mod K,
        NewCur is max(Cur, Wait)
    ;
        NewCur = Cur
    ),
    R1 is R+1,
    max_by_hist(R1, K, T, Rest, NewCur, Max).

% Оптимальные T с использованием гистограммы
best_T_sum_hist(Times, K, BestT) :-
    build_histogram(Times, K, Hist),
    Upper is K - 1,
    findall(T-S, (between(0, Upper, T), sum_by_hist(Hist, K, T, S)), Pairs),
    min_pair(Pairs, BestT).

best_T_max_hist(Times, K, BestT) :-
    build_histogram(Times, K, Hist),
    Upper is K - 1,
    findall(T-M, (between(0, Upper, T), max_by_hist(Hist, K, T, M)), Pairs),
    min_pair(Pairs, BestT).

% ==================== Вспомогательные предикаты ====================
% Выбор пары с минимальным значением (второй элемент)
min_pair([P|Ps], Best) :- min_pair(Ps, P, Best).
min_pair([], Best, Best).
min_pair([P|Ps], Current, Best) :-
    P = _-V1, Current = _-V2,
    ( V1 < V2 -> min_pair(Ps, P, Best) ; min_pair(Ps, Current, Best) ).

% ==================== Единый предикат для запросов ====================
optimal_first_bus(Times, K, T_sum, T_max) :-
    best_T_sum_hist(Times, K, T_sum),
    best_T_max_hist(Times, K, T_max).

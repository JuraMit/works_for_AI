% ---------- Метод пузырька ----------

bsort(List, Sorted) :-
    swap(List, List1), !,     
    bsort(List1, Sorted).
bsort(Sorted, Sorted).

swap([X,Y|Rest], [Y,X|Rest]) :-
    X > Y.                    
swap([Z|Rest], [Z|Rest1]) :-
    swap(Rest, Rest1).      

% ---------- Метод вставки ----------

isort([], []).                
isort([X|Xs], Sorted) :-
    isort(Xs, SortedTail),    
    insert(X, SortedTail, Sorted).

insert(X, [], [X]).          
insert(X, [Y|Ys], [X,Y|Ys]) :-
    X =< Y, !.                 
insert(X, [Y|Ys], [Y|Zs]) :-
    X > Y,                  
    insert(X, Ys, Zs).

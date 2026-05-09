% Факты
father(john, jim).
father(john, ann).
father(bob, mike).
father(bob, lisa).
father(mike, tom).
father(mike, kate).
father(jim, peter).
father(david, emma).

brother_fact(jim, ann).
brother_fact(mike, lisa).
brother_fact(tom, kate).
brother_fact(peter, jim).

% Правила
brother(X, Y) :-
    brother_fact(X, Y);
    brother_fact(Y, X).

is_father(X, Y) :- father(X, Y).

uncle(X, Y) :-
    brother(X, Parent),
    is_father(Parent, Y),
    X \= Y.

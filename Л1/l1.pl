% ===== ФАКТЫ =====
father(john, jim).
father(john, ann).

father(bob, mike).
father(bob, lisa).

father(mike, tom).
father(mike, kate).

father(jim, peter).

father(david, emma).


% ===== ПРАВИЛА =====
brother(X, Y) :-
    father(F, X),
    father(F, Y),
    X \= Y.

is_father(X, Y) :-
    father(X, Y).

uncle(X, Y) :-
    brother(X, Parent),
    father(Parent, Y).

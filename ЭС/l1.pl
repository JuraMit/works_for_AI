% Факты: кто что изучает
study(mark, math).
study(misha, docs).
study(masha, book).

% Правило: X видит Y, если Y — это объект, который есть в списке у X
see(masha, mouse).
see(masha, book).
see(masha, notebook).
see(masha, mark).

% Простое правило: если A видит B, и B изучает C, то A знает, что B изучает C
knows_about_study(A, B, Subject) :- see(A, B), study(B, Subject).

% Цель для проверки (запрос):
% ?- knows_about_study(masha, mark, What)

% Лабораторная работа 3: Базы данных
% Предметная область: Кинотеатры (информация для зрителей)
% Индивидуальное задание 11

% Динамические предикаты для хранения данных
:- dynamic film/7.
:- dynamic cinema/5.
:- dynamic session/7.

% =================== Меню и главный цикл ===================
main :-
    write('=== База данных "Кинотеатры" ==='), nl,
    repeat,
    menu,
    write('> '), read(Choice),
    process(Choice),
    Choice = 0, !.

menu :-
    nl, write('Меню:'), nl,
    write('1. Добавить фильм'), nl,
    write('2. Добавить кинотеатр'), nl,
    write('3. Добавить сеанс'), nl,
    write('4. Просмотр всех фильмов'), nl,
    write('5. Просмотр всех кинотеатров'), nl,
    write('6. Просмотр сеансов'), nl,
    write('7. Запрос: какие фильмы идут в кинотеатре?'), nl,
    write('8. Запрос: в каких кинотеатрах идёт фильм?'), nl,
    write('9. Удалить фильм (каскадно удаляются его сеансы)'), nl,
    write('10. Удалить кинотеатр (каскадно удаляются его сеансы)'), nl,
    write('11. Удалить конкретный сеанс'), nl,
    write('0. Выход'), nl.

% =================== Обработка выбора ===================
process(1) :- add_film, !.
process(2) :- add_cinema, !.
process(3) :- add_session, !.
process(4) :- show_films, !.
process(5) :- show_cinemas, !.
process(6) :- show_sessions, !.
process(7) :- films_in_cinema, !.
process(8) :- cinemas_for_film, !.
process(9) :- delete_film, !.
process(10) :- delete_cinema, !.
process(11) :- delete_session, !.
process(0) :- write('До свидания!'), nl.
process(_) :- write('Неверный пункт меню!'), nl, fail.

% =================== Добавление фильма ===================
add_film :-
    write('Название фильма: '), read(Film),
    write('Описание: '), read(Descr),
    write('Жанр: '), read(Genre),
    write('Длительность (мин): '), read(Duration),
    write('Рейтинг (0-10): '), read(Rating),
    write('Продано билетов в России (млн): '), read(RusTickets),
    write('Продано билетов в мире (млн): '), read(WorldTickets),
    ( film(Film,_,_,_,_,_,_) ->
        write('Такой фильм уже существует!'), nl
    ;
        assertz(film(Film, Descr, Genre, Duration, Rating, RusTickets, WorldTickets)),
        write('Фильм добавлен.'), nl
    ).

% =================== Добавление кинотеатра ===================
add_cinema :-
    write('Название кинотеатра: '), read(Cinema),
    write('Адрес: '), read(Address),
    write('Схема проезда: '), read(Directions),
    write('Описание: '), read(Descr),
    write('Список залов в формате [зал(1,100), зал(2,80), ...]: '), read(Halls),
    ( cinema(Cinema,_,_,_,_) ->
        write('Такой кинотеатр уже существует!'), nl
    ;
        assertz(cinema(Cinema, Address, Directions, Descr, Halls)),
        write('Кинотеатр добавлен.'), nl
    ).

% =================== Добавление сеанса ===================
add_session :-
    write('Фильм: '), read(Film),
    write('Кинотеатр: '), read(Cinema),
    write('Дата (ГГГГ-ММ-ДД): '), read(Date),
    write('Время (ЧЧ:ММ): '), read(Time),
    write('Номер зала: '), read(Hall),
    write('Цена детского билета: '), read(ChildPrice),
    write('Цена взрослого билета: '), read(AdultPrice),
    ( film(Film,_,_,_,_,_,_),
      cinema(Cinema,_,_,_,_) ->
        ( session(Film, Cinema, Date, Time, Hall, _, _) ->
            write('Такой сеанс уже существует!'), nl
        ;
            assertz(session(Film, Cinema, Date, Time, Hall, ChildPrice, AdultPrice)),
            write('Сеанс добавлен.'), nl
        )
    ;
        write('Ошибка: фильм или кинотеатр не найдены!'), nl
    ).

% =================== Просмотр ===================
show_films :-
    write('Список фильмов:'), nl,
    forall(film(Film, Descr, Genre, Dur, Rating, Rus, World),
           (write('Название: '), write(Film), nl,
            write('  Описание: '), write(Descr), nl,
            write('  Жанр: '), write(Genre), nl,
            write('  Длительность: '), write(Dur), write(' мин'), nl,
            write('  Рейтинг: '), write(Rating), nl,
            write('  Билеты Россия/Мир (млн): '), write(Rus), write('/'), write(World), nl,
            nl)).

show_cinemas :-
    write('Список кинотеатров:'), nl,
    forall(cinema(Name, Addr, Dir, Descr, Halls),
           (write('Название: '), write(Name), nl,
            write('  Адрес: '), write(Addr), nl,
            write('  Проезд: '), write(Dir), nl,
            write('  Описание: '), write(Descr), nl,
            write('  Залы (номер/мест): '), write(Halls), nl, nl)).

show_sessions :-
    write('Все сеансы:'), nl,
    forall(session(Film, Cinema, Date, Time, Hall, Child, Adult),
           (write('Фильм: '), write(Film),
            write(', Кинотеатр: '), write(Cinema),
            write(', Дата: '), write(Date),
            write(', Время: '), write(Time),
            write(', Зал: '), write(Hall),
            write(', Цена дет/взр: '), write(Child), write('/'), write(Adult), nl)).

% =================== Запросы, демонстрирующие связь 1:N ===================
films_in_cinema :-
    write('Введите название кинотеатра: '), read(Cinema),
    ( cinema(Cinema,_,_,_,_) ->
        write('Фильмы, идущие в кинотеатре '), write(Cinema), write(':'), nl,
        ( setof(Film, Date^Time^Hall^Child^Adult^session(Film, Cinema, Date, Time, Hall, Child, Adult), Films) ->
            forall(member(F, Films),
                   (write(F), nl,
                    write('  Сеансы:'), nl,
                    forall(session(F, Cinema, Date, Time, Hall, Child, Adult),
                           (write('    '), write(Date), write(' '), write(Time),
                            write(' зал '), write(Hall),
                            write(' цена дет/взр: '), write(Child), write('/'), write(Adult), nl)))
                  )
        ;
            write('  Нет сеансов в этом кинотеатре.'), nl
        )
    ;
        write('Кинотеатр не найден!'), nl
    ).

cinemas_for_film :-
    write('Введите название фильма: '), read(Film),
    ( film(Film,_,_,_,_,_,_) ->
        write('Кинотеатры, в которых идёт фильм "'), write(Film), write('":'), nl,
        ( setof(Cinema, Date^Time^Hall^Child^Adult^session(Film, Cinema, Date, Time, Hall, Child, Adult), Cinemas) ->
            forall(member(C, Cinemas),
                   (write('  '), write(C), nl,
                    forall(session(Film, C, Date, Time, Hall, Child, Adult),
                           (write('    '), write(Date), write(' '), write(Time),
                            write(' зал '), write(Hall),
                            write(' цена дет/взр: '), write(Child), write('/'), write(Adult), nl)))
                  )
        ;
            write('  Этот фильм нигде не идёт.'), nl
        )
    ;
        write('Фильм не найден!'), nl
    ).

% =================== Удаление записей с каскадным эффектом ===================
delete_film :-
    write('Название удаляемого фильма: '), read(Film),
    ( film(Film,_,_,_,_,_,_) ->
        retractall(film(Film,_,_,_,_,_,_)),
        retractall(session(Film, _, _, _, _, _, _)),
        write('Фильм и все его сеансы удалены.'), nl
    ;
        write('Фильм не найден!'), nl
    ).

delete_cinema :-
    write('Название удаляемого кинотеатра: '), read(Cinema),
    ( cinema(Cinema,_,_,_,_) ->
        retractall(cinema(Cinema,_,_,_,_)),
        retractall(session(_, Cinema, _, _, _, _, _)),
        write('Кинотеатр и все его сеансы удалены.'), nl
    ;
        write('Кинотеатр не найден!'), nl
    ).

delete_session :-
    write('Удаление конкретного сеанса:'), nl,
    write('Фильм: '), read(Film),
    write('Кинотеатр: '), read(Cinema),
    write('Дата: '), read(Date),
    write('Время: '), read(Time),
    write('Зал: '), read(Hall),
    ( session(Film, Cinema, Date, Time, Hall, _, _) ->
        retract(session(Film, Cinema, Date, Time, Hall, _, _)),
        write('Сеанс удалён.'), nl
    ;
        write('Такой сеанс не найден!'), nl
    ).

% =================== Начальные факты ===================
film('Дюна 2', 'Продолжение фантастической саги', фантастика, 166, 8.5, 12.3, 250.0).
film('Головоломка 2', 'Эмоции снова в деле', мультфильм, 96, 7.9, 18.7, 400.0).
cinema('Космос', 'ул. Пушкина, 10', 'м. Тверская, авт. 15', 'Большой современный кинотеатр', [зал(1,200), зал(2,150)]).
cinema('Звезда', 'пр. Мира, 25', 'м. Проспект Мира', 'Уютный кинотеатр в центре', [зал(1,120)]).
session('Дюна 2', 'Космос', '2026-05-10', '19:00', 1, 300, 450).
session('Дюна 2', 'Звезда', '2026-05-11', '18:00', 1, 280, 420).
session('Головоломка 2', 'Космос', '2026-05-10', '12:00', 2, 200, 300).

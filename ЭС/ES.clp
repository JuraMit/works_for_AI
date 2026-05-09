;;; ==============================================
;;; Экспертная система "Кинорекомендатель" (CLIPS)
;;; ==============================================

;; Объявляем шаблоны для управляющих фактов
(deftemplate preferred-genre
    (slot genre)
)

(deftemplate min-rating
    (slot rating)
)

(deftemplate phase
    (slot name)
)

;; *** База знаний: фильмы ***
(deffacts movies
    (movie "Побег из Шоушенка" драма 9.1)
    (movie "Тёмный рыцарь" боевик 9.0)
    (movie "Интерстеллар" фантастика 8.6)
    (movie "Гладиатор" исторический 8.5)
    (movie "Криминальное чтиво" криминал 8.9)
    (movie "Властелин колец" фэнтези 8.8)
    (movie "Форрест Гамп" драма 8.8)
    (movie "Матрица" фантастика 8.7)
    (movie "Джон Уик 4" боевик 7.8)
    (movie "Зеленая миля" драма 9.0)
)

;; *** Начальное состояние ***
(deffacts start-phase
    (phase (name ask-genre))
)

;; *** Правило: запрос жанра ***
(defrule ask-genre
    ?phase <- (phase (name ask-genre))
    =>
    (retract ?phase)
    ;; Удаляем старые предпочтения (если были)
    (do-for-all-facts ((?g preferred-genre)) (retract ?g))
    (do-for-all-facts ((?r min-rating)) (retract ?r))
    (printout t crlf "Какой жанр вы предпочитаете? ")
    (bind ?genre (read))
    (assert (preferred-genre (genre ?genre)))
    (assert (phase (name ask-rating)))
)

;; *** Правило: запрос минимального рейтинга ***
(defrule ask-rating
    ?phase <- (phase (name ask-rating))
    =>
    (retract ?phase)
    (printout t "Какой минимальный рейтинг (от 0 до 10)? ")
    (bind ?rating (read))
    (if (not (numberp ?rating))
        then
        (printout t "Ошибка: нужно число. Попробуйте снова." crlf)
        (assert (phase (name ask-rating)))
        else
        ;; Удаляем старый рейтинг (если был)
        (do-for-all-facts ((?r min-rating)) (retract ?r))
        (assert (min-rating (rating ?rating)))
        (assert (phase (name recommend)))
    )
)

;; *** Правило: рекомендация фильмов ***
(defrule recommend-movie
    (phase (name recommend))
    (preferred-genre (genre ?genre))
    (min-rating (rating ?rating))
    ?m <- (movie ?title ?genre ?r)
    (test (>= ?r ?rating))
    =>
    (printout t "Рекомендуем: " ?title " (рейтинг " ?r ")" crlf)
)

;; *** Правило: окончание вывода ***
(defrule end-recommendation
    (declare (salience -10))   ; низкий приоритет, чтобы сработать последним
    ?phase <- (phase (name recommend))
    =>
    (retract ?phase)
    (printout t crlf "Надеемся, что-нибудь подойдёт! Хотите ещё? (y/n) ")
    (bind ?ans (read))
    (if (eq ?ans y)
        then
        (assert (phase (name ask-genre)))   ; повторный цикл
        else
        (printout t "Спасибо за использование системы. До свидания!" crlf)
    )
)
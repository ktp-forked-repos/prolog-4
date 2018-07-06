:- set_prolog_flag(verbose, silent).


%% Récuperation de toutes les combinaisons possibles d'hypothèses pour un type
%% swipl -s hypotheses.pl -t get_hypotheses --quiet -- exemples mammifere

%% Récuperation de toutes les combinaisons possibles d'hypothèses pour un type à une taille définie
%% swipl -s hypotheses.pl -t get_hypotheses_limite --quiet -- exemples mammifere 3

%% Récuperation de toutes les combinaisons possibles d'hypothèses pour un type à une taille maimale
%% swipl -s hypotheses.pl -t get_hypotheses_limite_taille --quiet -- exemples mammifere 3

%% Récuperation de toutes les combinaisons correctes et utilisables avec leurs exemples liés
%% swipl -s hypotheses.pl -t get_correct_hypotheses --quiet -- exemples mammifere 3


get_hypotheses :-
  current_prolog_flag(argv,Args),
  nth0(0,Args,Base),
  nth0(1,Args,Type),
  consult(Base),
  exemple(_,Type,E),
  forall(generalisation(E,H), (write(H), nl)).


get_hypotheses_limite :-
  current_prolog_flag(argv,Args),
  nth0(0,Args,Base),
  nth0(1,Args,Type),
  nth0(2,Args,Limite),
  atom_number(Limite, LimiteNombre),
  consult(Base),
  exemple(_,Type,E),
  forall((generalisation(E,H),length(H,LimiteNombre)), (write(H), nl)).

get_hypotheses_limite_taille :-
  current_prolog_flag(argv,Args),
  nth0(0,Args,Base),
  nth0(1,Args,Type),
  nth0(2,Args,Limite),
  atom_number(Limite, LimiteNombre),
  consult(Base),
  exemple(_,Type,E),
  forall((generalisation(E,H),modele(H,M),length(H,L),L<LimiteNombre), (write(H-M), nl)).

get_correct_hypotheses :-
  current_prolog_flag(argv,Args),
  nth0(0,Args,Base),
  nth0(1,Args,Type),
  nth0(2,Args,Limite),
  atom_number(Limite, LimiteNombre),
  consult(Base),
  exemple(_,Type,E),
  forall((generalisation(E,H),modele(H,M),length(H,L),L<LimiteNombre,\+ (member(X,M),exemple(X,C,_),C\=Type)), (write(H-M), nl)).

covers(H1,H2) :- 
    subset(H1,H2).

generalisation(H1,H2) :-
    length(H1,N),
    template(H2,N),
    sousliste(H2,H1).

template(_,0) :- !, fail.
template([_],_).
template([_|T],N) :-
    M is N-1,
    template(T,M).

sousliste([X],[X|_]).
sousliste(X,[_|T]) :-
    sousliste(X,T).
sousliste([X|T],[X|V]) :-
    sousliste(T,V).

modele(H,M) :-
    findall(N,(exemple(N,_,L),covers(H,L)),M).
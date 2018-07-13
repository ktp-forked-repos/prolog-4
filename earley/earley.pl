:- dynamic liaison/4.

:- set_prolog_flag(verbose, silent).

%% Récuperation du tableau du parser Earley
%% swipl -s earley.pl -t get_structure_earley --quiet -- elle,mange,du,poisson,avec,une,fourchette

get_structure_earley :-
  current_prolog_flag(argv,Args),
  nth0(0,Args,StringPhrase),
  atomic_list_concat(Phrase, ',', StringPhrase),
  consult(regles),
  earley(Phrase, s, DernierGraphe),
  write(DernierGraphe).


earley(Mots, Categorie, DernierGraphe) :-
	analyse_graphe([[liaison(debut, ['.', Categorie], 0, 0), 0, []]], [], Graphe),
	parser(Mots, 0, DernierePosition, Graphe, DernierGraphe),
	member([liaison(debut, [Categorie, '.'], 0, DernierePosition), _, _], DernierGraphe).

analyse_graphe([], Graphe, Graphe).
analyse_graphe([[Entree, Compte, Crea] | Entrees], Graphe, NouveauGraphe) :-
	\+ member([Entree, _, _], Graphe),
	!,
	length(Graphe, Compte),
	analyse_graphe(Entrees, [[Entree, Compte, Crea] | Graphe], NouveauGraphe).
analyse_graphe([_ | Entrees], Graphe, NouveauGraphe) :-
	analyse_graphe(Entrees, Graphe, NouveauGraphe).

parser([], FinalNode, FinalNode, Graphe, Graphe) :- !.
parser(Mots, Pos, DernierePosition, Graphe, DernierGraphe) :-
	prediction(Pos, Graphe, GraphePrediction),
	NextPos is Pos + 1,
	lecture(Mots, MotsRestants, Pos, NextPos, GraphePrediction, ScanGraphe),
	completion(NextPos, ScanGraphe, GrapheCompletion),
	!,
	parser(MotsRestants, NextPos, DernierePosition, GrapheCompletion, DernierGraphe).

lecture([Mot | MotsRestants], MotsRestants, PositionActuelle, NextPos, Graphe, GrapheLecture) :-
	findall(
	[liaison(TYPE, [Mot, '.'], PositionActuelle, NextPos), X, []],
	(
		mot(TYPE, [Mot]),
		once((member([liaison(ELEMENTGAUCHE, ACTIVE_ELEMENTDROIT, PositionInitiale, PositionActuelle), _, _], Graphe),
		append(B, ['.', TYPE | E], ACTIVE_ELEMENTDROIT)))
	),
	NouveauGrapheEntrees),
	NouveauGrapheEntrees \== [],
	analyse_graphe(NouveauGrapheEntrees, Graphe, GrapheLecture),
	!.
lecture(Mots, Mots, PositionActuelle, NextPos, Graphe, GrapheLecture) :-
	findall(
	[liaison(TYPE, [[], '.'], PositionActuelle, NextPos), X, []],
	(
		mot(TYPE, []),
		once((member([liaison(ELEMENTGAUCHE, ACTIVE_ELEMENTDROIT, PositionInitiale, PositionActuelle), _, _], Graphe),
		append(B, ['.', TYPE | E], ACTIVE_ELEMENTDROIT)))
	),
	NouveauGrapheEntrees),
	NouveauGrapheEntrees \== [],
	analyse_graphe(NouveauGrapheEntrees, Graphe, GrapheLecture),
	!.

prediction(PositionActuelle, Graphe, GraphePrediction) :-
	findall(
	[liaison(TYPE, ['.' | ELEMENTDROIT], PositionActuelle, PositionActuelle), X, []],
	(
		member([liaison(ELEMENTGAUCHE, ACTIVE_ELEMENTDROIT, PositionInitiale, PositionActuelle), _, _], Graphe),
		append(B, ['.', TYPE | E], ACTIVE_ELEMENTDROIT),
		grammaire(TYPE, ELEMENTDROIT),
		\+ member([liaison(TYPE, ['.' | ELEMENTDROIT], PositionActuelle, PositionActuelle), _, _], Graphe)
	),
	NouveauGrapheEntrees),
	NouveauGrapheEntrees \== [],
	analyse_graphe(NouveauGrapheEntrees, Graphe, NouveauGraphe),
	prediction(PositionActuelle, NouveauGraphe, GraphePrediction),
	!.
prediction(_, Graphe, Graphe).

completion(PositionActuelle, Graphe, GrapheCompletion) :-
	findall(
	[liaison(ELEMENTGAUCHE2, ELEMENTDROIT3, PositionPrecedente, PositionActuelle), X, [Compte | Prev]],
	(
		member([liaison(ELEMENTGAUCHE, COMPLETE_ELEMENTDROIT, PositionInitiale, PositionActuelle), Compte, _], Graphe),
		append(_, ['.'], COMPLETE_ELEMENTDROIT),
		member([liaison(ELEMENTGAUCHE2, ELEMENTDROIT2, PositionPrecedente, PositionInitiale), _, Prev], Graphe),
		append(B, ['.', ELEMENTGAUCHE | E], ELEMENTDROIT2),
		append(B, [ELEMENTGAUCHE, '.' | E], ELEMENTDROIT3),
		\+ member([liaison(ELEMENTGAUCHE2, ELEMENTDROIT3, PositionPrecedente, PositionActuelle), _, _], Graphe)
	),
	GrapheComplet),
	GrapheComplet \== [],
	analyse_graphe(GrapheComplet, Graphe, NouveauGraphe),
	completion(PositionActuelle, NouveauGraphe, GrapheCompletion),
	!.
completion(_, Graphe, Graphe).
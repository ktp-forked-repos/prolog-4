:- set_prolog_flag(verbose, silent).

%% Récuperation de tous les préfixes et suffixes
%% swipl -s topdown.pl -t get_structure_grammaticale --quiet -- elle,mange,du,poisson,avec,une,fourchette

get_structure_grammaticale :-
  current_prolog_flag(argv,Args),
  nth0(0,Args,StringPhrase),
  atomic_list_concat(Phrase, ',', StringPhrase),
  consult(regles),
  topdown(Phrase,Arborescence).

topdown(Phrase, Arborescence) :- parser(s, Phrase, [], Arborescence),write(Arborescence).

parser(Grammaire, [Mot|S], S, [Grammaire,[Mot]]) :- 
	mot(Grammaire, Mot).
parser(Grammaire, S1, S, [Grammaire, Arborescence]) :- 
	grammaire(Grammaire, Feuille),
	parser2(Feuille, S1, S, Arborescence).

parser2([C|Grammaire], S1, S, [A|Arborescence]) :-
	parser(C, S1, S2, A),
	parser2(Grammaire, S2, S, Arborescence).
parser2([], S, S, []).

:- set_prolog_flag(verbose, silent).

%% Récuperation de tous les préfixes et suffixes
%% swipl -s bottomup.pl -t get_structure_grammaticale --quiet -- elle,mange,du,poisson,avec,une,fourchette

get_structure_grammaticale :-
  current_prolog_flag(argv,Args),
  nth0(0,Args,StringPhrase),
  atomic_list_concat(Phrase, ',', StringPhrase),
  consult(regles),
  bottomup(Phrase).

bottomup([s]).

bottomup(Phrase) :-
	nl,write('ETAT: '),write(Phrase),
    split(Phrase,Avant,Milieu,Apres),
	( grammaire(Grammaire, Milieu);
	  (Milieu = [Mot], mot(Grammaire,Mot))
    ),
	tab(3),write('REGLE: '),write(grammaire(Grammaire, Milieu)),nl,
    split(NouvellePhrase,Avant,[Grammaire], Apres),
	bottomup(NouvellePhrase).

split(ABC, A, B, C) :-
	append(A, BC, ABC),
	append(B, C, BC).
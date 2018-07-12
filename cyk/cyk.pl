:- dynamic graphe/3.

:- set_prolog_flag(verbose, silent).

%% Récuperation du tableau du parser CYK
%% swipl -s cyk.pl -t get_structure_cyk --quiet -- elle,mange,du,poisson,avec,une,fourchette

get_structure_cyk :-
  current_prolog_flag(argv,Args),
  nth0(0,Args,StringPhrase),
  atomic_list_concat(Phrase, ',', StringPhrase),
  consult(regles),
  cyk(Phrase, s).

cyk(Phrase,Type):-
   retractall(graphe(_,_,_)),
   remplir_graphe(Phrase,0,X),
   graphe(0,X,Type),
   forall(graphe(Numero,Numero2,Categorie), (NouveauNumero is Numero+1,write([NouveauNumero,Numero2]), write(" "), write(Categorie), nl)).

remplir_graphe([],X,X).
remplir_graphe([Mot|Mots],YMoinsUn,X):-
   Y is YMoinsUn + 1,
   remplir_graphe_mot(Mot,YMoinsUn,Y),
   Z is Y - 2,
   remplir_graphe_grammaire(Z,Y),
   remplir_graphe(Mots,Y,X).

remplir_graphe_grammaire(X,Y):-
   X < 0,
   !;
   creation_phrase_avec(X,Y),
   XMoinsUn is X - 1,
   remplir_graphe_grammaire(XMoinsUn,Y).

remplir_graphe_mot(Mot,XMoinsUn,X):-
   mot(Type,Mot),
   ajouter_graphe(XMoinsUn,X,Type),
   fail; 
   true.

creation_phrase_avec(X,Y):-
   XPlusUn is X + 1,
   YMoinsUn is Y - 1,
   between(XPlusUn,YMoinsUn,N),
   graphe(X,N,Grammaire1),
   graphe(N,Y,Grammaire2),
   grammaire(Type, [Grammaire1, Grammaire2]),
   ajouter_graphe(X,Y,Type),
   fail
 ; true.

ajouter_graphe(Debut,Fin,Type):- 
   graphe(Debut,Fin,Type),
   !; 
   assertz(graphe(Debut,Fin,Type)).

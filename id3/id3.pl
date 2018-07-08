:- set_prolog_flag(verbose, silent).

:- dynamic node/3.

%% Récuperation de l'arbre de décision
%% swipl -s id3.pl -t get_arbredecision --quiet -- exemples

%% Récupération de l'arbre de décision en commençant par un certain niveau de profondeur
%% swipl -s id3.pl -t get_arbredecisionniveau --quiet -- exemples 3

get_arbredecision :-
  current_prolog_flag(argv,Args),
  nth0(0,Args,Base),
  consult(Base),
  id3(1),
  afficherarbre.


get_arbredecisionniveau :-
  current_prolog_flag(argv,Args),
  nth0(0,Args,Base),
  nth0(1,Args,Limite),
  atom_number(Limite, LimiteNombre),
  consult(Base),
  id3(LimiteNombre),
  afficherarbre.

id3(Profondeur) :-
    retractall(node(_,_,_)),
    findall(N,exemple(N,_,_),E),
    exemple(_,_,L), !,
    get_attributes(L,A),
    idarbre(E,root,A,Profondeur),
    assert_rules, !.

idarbre(E,Parent,_,Profondeur) :-
    length(E,Len),
    Len=<Profondeur,
    distr(E, Distr),
    assertz(node(feuille,Distr,Parent)), !.
idarbre(E,Parent,_,_) :-
    distr(E, [C]),
    assertz(node(feuille,[C],Parent)).
idarbre(Es,Parent,As,Profondeur) :- 
    choisir_attribut(Es,As,A,Values,Reste), !,
    partition(Values,A,Es,Parent,Reste,Profondeur).
idarbre(E,Parent,_,_) :- !,
    node(Parent,Test,_),
    write('Probleme de donnees '), write(E), write(' au noeud '), writeln(Test).

get_attributes([],[]) :- !.
get_attributes([A=_|T],[A|W]) :-
    get_attributes(T,W).

partition([],_,_,_,_,_) :- !.
partition([V|Vs],A,Es,Parent,Reste,Profondeur) :-
    get_souspartie(Es,A=V,Ei), !,
    nom(Node), 
    assertz(node(Node,A=V,Parent)),
    idarbre(Ei,Node,Reste,Profondeur), !,
    partition(Vs,A,Es,Parent,Reste,Profondeur).

choisir_attribut(Es,As,A,Values,Reste) :-
    length(Es,LenEs),
    contenu_information(Es,LenEs,I), !,
    findall((A-Values)/Gain, 
            (member(A,As),
             get_values(Es,A,[],Values),
             separation_sous_branche(Values,Es,A,Ess),
             information_residuelle(Ess,LenEs,R),
             Gain is I - R),
            All),
    maximum(All,(A-Values)/_),
    effacer(A,As,Reste), !.

separation_sous_branche([],_,_,[]) :- !.
separation_sous_branche([V|Vs],Es,A,[Ei|Reste]) :-
    get_souspartie(Es,A=V,Ei), !,
    separation_sous_branche(Vs,Es,A,Reste).

information_residuelle([],_,0) :- !.
information_residuelle([Ei|Es],Len,Res) :-
    length(Ei,LenEi),
    contenu_information(Ei,LenEi,I), !,
    information_residuelle(Es,Len,R),
    Res is R + I*LenEi/Len.

contenu_information(Es,Len,I) :-
    setof(C,E^L^(member(E,Es),exemple(E,C,L)),Classes), !,
    sum_terms(Classes,Es,Len,I).

sum_terms([],_,_,0) :- !.
sum_terms([C|Cs],Es,Len,Info) :-
    findall(E,(member(E,Es),exemple(E,C,_)),InC),
    length(InC,N),
    sum_terms(Cs,Es,Len,I),
    Info is I - (N/Len)*(log(N/Len)/log(2)).

get_values([],_,Values,Values) :- !.
get_values([E|Es],A,Vs,Values) :-
    exemple(E,_,L),
    member(A=V,L), !,
    (member(V,Vs), !, get_values(Es,A,Vs,Values);
     get_values(Es,A,[V|Vs],Values)
    ).

get_souspartie([],_,[]) :- !.
get_souspartie([E|Es],A,[E|W]) :-
    exemple(E,_,L),
    member(A,L), !,
    get_souspartie(Es,A,W).
get_souspartie([_|Es],A,W) :-
    get_souspartie(Es,A,W).

assert_rules :-
    chemin(root,Path,Conclusion),
    fail.
assert_rules.

chemin(Parent,[],Class) :-
    node(feuille,Class,Parent), !.
chemin(Parent,[A|Path],feuille) :-
    node(Son,A,Parent),
    chemin(Son,Path,feuille).

distr(S,Dist) :-
    setof(C,X^L^(member(X,S),exemple(X,C,L)),Cs),
    nombre_categories(Cs,S,Dist).

nombre_categories([],_,[]) :- !.
nombre_categories([C|L],E,[C/N|T]) :-
    findall(X,(member(X,E),exemple(X,C,_)),W),
    length(W,N), !,
    nombre_categories(L,E,T).

nom(M) :-
   retract(nam(N)),
   M is N+1,
   assert(nam(M)), !.
nom(1) :-
   assert(nam(1)).

effacer(X,[X|T],T) :- !.
effacer(X,[Y|T],[Y|Z]) :-
   effacer(X,T,Z).

souspartie([],_) :- !.
souspartie([X|T],L) :-
   member(X,L), !,
   souspartie(T,L).

maximum([X],X) :- !.
maximum([X/M|T],Y/N) :-
    maximum(T,Z/K),
    (M>K,Y/N=X/M ; Y/N=Z/K), !.

afficherarbre :-
    afficherarbre(root,0).

afficherarbre(Parent,_) :- 
    node(feuille,Class,Parent), !,
    write(' => '),write(Class).


afficherarbre(Parent,Pos) :-
    findall(Son,node(Son,_,Parent),L),
    Pos1 is Pos+2,
    afficher_liste(L,Pos1).

afficher_liste([],_) :- !.
afficher_liste([N|T],Pos) :-
    node(N,Label,_),
    nl, tab(Pos), write(Label),
    afficherarbre(N,Pos),
    afficher_liste(T,Pos).
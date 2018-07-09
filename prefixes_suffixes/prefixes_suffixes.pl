:- set_prolog_flag(verbose, silent).

%% Récuperation de tous les préfixes et suffixes
%% swipl -s prefixes_suffixes.pl -t get_prefixes_suffixes --quiet -- hyperbolique

get_prefixes_suffixes :-
  current_prolog_flag(argv,Args),
  nth0(0,Args,Mot),
  consult(liste_prefixes),
  consult(liste_suffixes),
  string_chars(Mot, MotList),
  liste_prefixes_suffixes(Racine,MotList).


liste_prefixes_suffixes(Racine,Mot):- nl,write('Liste des préfixes: '),
								  liste_prefixes(Reste,Mot),
								  nl,write('Liste des suffixes: '),
								  liste_suffixes(Racine,Reste).

liste_prefixes(Reste,Mot):- recuperation_prefixe(Coupure,Mot),liste_prefixes(Reste,Coupure).
liste_prefixes(Reste,Reste).

recuperation_prefixe(Reste,Mot):- prefixe(Prefixe),
								  append(Prefixe,Reste,Mot),
								  string_chars(PrefixeString, Prefixe),
								  nl,write(PrefixeString). 

liste_suffixes(Reste,Mot):- recuperation_suffixe(Coupure,Mot),liste_suffixes(Reste,Coupure).
liste_suffixes(Reste,Reste).

recuperation_suffixe(Reste,Mot):- suffixe(Suffixe),
								  append(Reste,Suffixe,Mot),
								  string_chars(PrefixeSuffixe, Suffixe),
								  nl,write(PrefixeSuffixe). 
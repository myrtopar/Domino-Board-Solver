put_dominos:-
	dominos1(Dominolist),
	frame1(Frame),
	cons_frame(Frame, 1, [], ConsFrame),
	rows(Frame, R),
	columns(Frame, C),
	row_frame(ConsFrame, 1, R, [], RF),             
	column_frame(ConsFrame, 1, C, [], CF),
	combine_soldom(Dominolist, RF, CF, [], Soldom),
	generate_solution(Soldom, [], Solution),
	create_domino_table(RF, Solution, [], Domino_table),
	print_table(Domino_table), !.
/*σχολια υπαρχουν στο τελος του αρχειου*/
	
rows(Frame, R):-
	length(Frame, R).
	
columns([Line1|_], C):-
	length(Line1, C).
	
/*me ta cons frame kai cons line ftiaxnetai mia lista me consecutively tous arithmoys tou frame, oi opoioi exoun tin morfi: [3-(1,1), 1-(1,2), 2-(1,3)...]. Oi aritmoi
mesa stis ( , ) einai ta coords tou kathe arithmou sto frame dhladh (row,column).*/   
cons_frame([], _, Nframe, Nframe).
cons_frame([Line1|Frame], L, Space, Nframe):-
	cons_line(Line1, L, 1, [], Line),
	append(Space, Line, Space1),
	L1 is L+1,
	cons_frame(Frame, L1, Space1, Nframe).

cons_line([], _, _, Cons_line, Cons_line).	
cons_line([H|Rest], L, C, Space, Cons_line):-
	append(Space, [H-(L,C)], Space1),
	C1 is C+1,
	cons_line(Rest, L, C1, Space1, Cons_line).
	
/*me ta column frame kai column list ftiaxnetai mia lista me listes tin kathe stili, arithmimeni me coords*/	
column_frame(_, N, C, Col_list, Col_list):-
	N > C.
column_frame(ConsFrame, N, C, Space, Col_list):-    /*c einai to plithos olwn twn columns*/
	N =< C,
	column_list(ConsFrame, N, [], List),
	append(Space, [List], Space1),
	N1 is N+1, 
	column_frame(ConsFrame, N1, C, Space1, Col_list).

column_list([], _, List, List).
column_list([_-(_,C)|ConsFrame], N, Space, List):-
	N =\= C,
	column_list(ConsFrame, N, Space, List).
column_list([Number-(R,C)|ConsFrame], N, Space, List):-
	N =:= C, 
	append(Space,[Number-(R,C)],Space1),
	column_list(ConsFrame, N, Space1, List).

/*me ta row frame kai row list ftiaxnetai mia lista me listes tin kathe grammi, arithmimeni me coords*/
row_frame(_, N, R, Row_list, Row_list):-
	N > R.
row_frame(ConsFrame, N, R, Space, Row_list):-       /*r einai to plithos olwn twn rows, to N ksekinaei apo 1 kai se kathe anadromi auksanetai kata 1*/
	N =< R, 
	row_list(ConsFrame, N, [], List),
	append(Space, [List], Space1),
	N1 is N+1, 
	row_frame(ConsFrame, N1, R, Space1, Row_list).

row_list([], _, List, List).
row_list([_-(R,_)|ConsFrame], N, Space, List):-
	R =\= N,
	row_list(ConsFrame, N, Space, List).
row_list([Number-(R,C)|ConsFrame], N, Space, List):-
	N =:= R, 
	append(Space,[Number-(R,C)],Space1),
	row_list(ConsFrame, N, Space1, List).


/*6 cases αναζητησεων στο frame
Η search_list παιρνει ενα ντομινο και μια σειρα στο frame και τοποθετει στην λιστα possiblepositions ολες τις θεσεις σε αυτη τη σειρα
στις οποιες μπορει το ντομινο να τοποθετηθει, αν υπαρχουν*/
search_list((_,_), [_], PossiblePositions, PossiblePositions).

search_list((X,Y), [Figure-(_,_)|List], Space, PossiblePositions):-
	not X == Figure, 
	not Y == Figure,
	search_list((X,Y), List, Space, PossiblePositions).

search_list((X,Y), [Figure-(R,C)|List], Space, PossiblePositions):-
	X == Figure,
	next_element([Figure-(R,C)|List], 1, Next-(R1,C1)),
	Y == Next,
	append(Space, [(R,C)-(R1,C1)],Space1),
	search_list((X,Y), List, Space1, PossiblePositions).

search_list((X,Y), [Figure-(R,C)|List], Space, PossiblePositions):-
	X == Figure,
	next_element([Figure-(R,C)|List], 1, Next-(_,_)),
	not Y == Next,
	search_list((X,Y), List, Space, PossiblePositions).

search_list((X,Y), [Figure-(R,C)|List], Space, PossiblePositions):-
	Y == Figure,
	next_element([Figure-(R,C)|List], 1, Next-(R1,C1)),
	X == Next,
	append(Space, [(R1,C1)-(R,C)],Space1),
	search_list((X,Y), List, Space1, PossiblePositions).

search_list((X,Y), [Figure-(R,C)|List], Space, PossiblePositions):-
	Y == Figure,
	next_element([Figure-(R,C)|List], 1, Next-(_,_)),
	not X == Next,
	search_list((X,Y), List, Space, PossiblePositions).

next_element(List, Index, Element):-
	Next is Index+1,
	element_at_pos(List, Next, Element).

element_at_pos(List, Position, Element) :-
	L is Position - 1,
    append(Preceding, [Element | _], List),
    length(Preceding, L).
	
/*Η positions παιρνει ενα ντομινο και μια λιστα (σειρα η στηλη) και μεσω της search_list επιστρεφει ολες τις πιθανες θεσεις που μπορει
να τοποθετηθει το ντομινο πανω στη σειρα αυτη*/	
positions((_,_), [], Positions, Positions).
positions((X,Y), [H|Frame], Space, Positions):-
	search_list((X,Y), H, [], PossiblePositions),
	append(Space, PossiblePositions, Space1),
	positions((X,Y), Frame, Space1, Positions).

/*Η search_domain ψαχνει ολες τις πιθανες θεσεις τοποθετησης ενος ντομινο σε ολες τις σειρες και σε ολες τις στηλες του πινακα και ετσι
φτιαχνει το τελικο domain του καθε ντομινο*/
search_domain((X,Y), RowFrame, ColFrame, Domain):-
	positions((X,Y), RowFrame, [], RowPositions),
	positions((X,Y), ColFrame, [], ColumnPositions),
	append(RowPositions, ColumnPositions, Domain).

combine_soldom([], _, _, SolDom, SolDom).
combine_soldom([Domino|Rest], RowFrame, ColFrame, Space, Soldom):-
	search_domain(Domino, RowFrame, ColFrame, Domain),
	append(Space, [Domino-Domain], Space1),
	combine_soldom(Rest, RowFrame, ColFrame, Space1, Soldom).

generate_solution([], Solution, Solution).
generate_solution(SolDom1, Space, Solution) :-
   mrv_var(SolDom1, Domino-Domain, SolDom2),
   member(X, Domain),
   append(Space, [Domino-X], Space1), 
   update_domains(X, SolDom2, SolDom3),
   generate_solution(SolDom3, Space1, Solution).

mrv_var([Domino-Domain], Domino-Domain, []).
mrv_var([Domino1-Domain1|SolDom1], Domino-Domain, SolDom3) :-
   mrv_var(SolDom1, Domino2-Domain2, SolDom2),
   length(Domain1, N1),
   length(Domain2, N2),
   (N1 < N2 ->
   (Domino = Domino1, Domain = Domain1, SolDom3 = SolDom1) ;
   (Domino = Domino2, Domain = Domain2, SolDom3 = [Domino1-Domain1|SolDom2])).
	
update_domains(_, [], []).
update_domains(Coord1-Coord2, [Domino-Domain1|SolDom1], [Domino-Domain2|SolDom2]) :-  
   update_domain(Coord1, Coord2, Domain1, Domain2),
   update_domains(Coord1-Coord2, SolDom1, SolDom2).

update_domain(Coord1, Coord2, Domain1, Domain3):-       /*ta 2 coordinates pou molis apotimithikan kai to domain apo to opoio tha diagrafoun*/
	remove_all(Coord1, Domain1, Domain2),
	remove_all(Coord2, Domain2, Domain3).

remove_if_exists(_, [], []).
remove_if_exists(X, [X|List], List) :-
   !.
remove_if_exists(X, [Y|List1], [Y|List2]) :-
   remove_if_exists(X, List1, List2).

/*Η remove_all δεχεται ενα domain και μια συντεταγμενη (X,Y) στον πινακα και διαγραφει απο το domain αυτο καθε ζευγος συντεταγμενων
που περιεχουν το (X,Y), αν υπαρχει*/
remove_all((X,Y), Removed, Removed):-
	not member((X,Y)-(_,_), Removed),
	not member((_,_)-(X,Y), Removed),
	!.
remove_all((X,Y), List, Removed):-
	member((X,Y)-(_,_), List),
	remove_if_exists((X,Y)-(_,_), List, NList),
	remove_all((X,Y), NList, Removed).
	
remove_all((X,Y), List, Removed):-
	member((_,_)-(X,Y), List),
	remove_if_exists((_,_)-(X,Y), List, NList),
	remove_all((X,Y), NList, Removed).
	
/*H create_domino_list φτιαχνει την καθε γραμμη του frame τοποθετωντας παυλες αναμεσα σε καθε ζευγαρι διπλανων στοιχειων
πανω στα οποια τοποθετειται ντομινο*/
create_domino_list([Figure-(_,_)], _, Space, Domino_list):-
	append(Space, [Figure], Domino_list).
create_domino_list([Figure-(R,C)|Frame_row], Solution, Space, Domino_list):-
	append(Space, [Figure], Space1),
	find_comp_domino(Solution, Figure, R, C, Comp-(RComp,CComp)),
	next_element([Figure-(R,C)|Frame_row], 1, Next-(RNext,CNext)),
	(not Next == Comp;  RNext =\= RComp; CNext =\= CComp),
	append(Space1, [' '], Space2),
	create_domino_list(Frame_row, Solution, Space2, Domino_list).

create_domino_list([Figure-(R,C)|Frame_row], Solution, Space, Domino_list):-
	append(Space, [Figure], Space1),
	find_comp_domino(Solution, Figure, R, C, Comp-(RComp,CComp)),
	next_element([Figure-(R,C)|Frame_row], 1, Next-(RNext,CNext)),
	(Next == Comp, RNext =:= RComp, CNext =:= CComp),
	append(Space1, [-], Space2),
	create_domino_list(Frame_row, Solution, Space2, Domino_list).
	
/*Η create_whitespace_dash_list φτιαχνει την λιστα (την γραμμη) που μεσολαβει αναμεσα απο 2 γραμμες του frame*/	
create_whitespace_dash_list([], _, Whitespace_dash_list, Whitespace_dash_list).
create_whitespace_dash_list([Figure-(R,C)|Frame_row], Solution, Space, Whitespace_dash_list):-
	find_comp_domino(Solution, Figure, R, C, _-(RComp,CComp)),
	R1 is R+1,
	(CComp =\= C; RComp =\= R1),
	append(Space, ['  '], Space1),
	create_whitespace_dash_list(Frame_row, Solution, Space1, Whitespace_dash_list).

create_whitespace_dash_list([Figure-(R,C)|Frame_row], Solution, Space, Whitespace_dash_list):-
	find_comp_domino(Solution, Figure, R, C, _-(RComp,CComp)),
	R1 is R+1,
	(CComp =:= C, RComp =:= R1),
	append(Space, [|], Space1),
	append(Space1, [' '], Space2),
	create_whitespace_dash_list(Frame_row, Solution, Space2, Whitespace_dash_list).
	
/*H find_comp_domino παιρνει απο τα ορισματα τον αριθμο απο ενα domino και τις συντεταγμενες του και βρισκει το συμπληρωμα του και τις συντεταγεμενες αυτου*/
find_comp_domino([(D1, D2)-((R1, C1)-(R2, C2))|_], Figure, R, C, D2-(R2,C2)):-    
	(D1 == Figure, R1 =:= R, C1 =:= C),
	!.
find_comp_domino([(D1, D2)-((R1, C1)-(R2, C2))|_], Figure, R, C, D1-(R1,C1)):-
	(D2 == Figure, R2 =:= R, C2 =:= C),
	!.
find_comp_domino([_|Solution], Figure, R, C, Compl_domino-(R3,C3)):-
	find_comp_domino(Solution, Figure, R, C,  Compl_domino-(R3,C3)).


create_domino_table([], _, Domino_table, Domino_table).	
create_domino_table([H|ConsFrame], Solution, Space, Domino_table):-
	create_domino_list(H, Solution, [], Domino_list),
	create_whitespace_dash_list(H, Solution, [], Wlist),
	append(Space, [Domino_list], Space1),
	append(Space1, [Wlist], Space2),
	create_domino_table(ConsFrame, Solution, Space2, Domino_table).

print_table([]).	
print_table([H|Domino_table]):-
	print_line(H),
	write('\n'),
	print_table(Domino_table).

print_line([]).	
print_line([A|List]):-
	write(A),
	print_line(List).
	
dominos1([(0,0),(0,1),(0,2),(0,3),(0,4),(0,5),(0,6),
			    (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),
	                  (2,2),(2,3),(2,4),(2,5),(2,6),
                            (3,3),(3,4),(3,5),(3,6),
                                  (4,4),(4,5),(4,6),
                                        (5,5),(5,6),
                                              (6,6)]).
											 
frame1([[3,1,2,6,6,1,2,2],
        [3,4,1,5,3,0,3,6],
        [5,6,6,1,2,4,5,0],
        [5,6,4,1,3,3,0,0],
	    [6,1,0,6,3,2,4,0],
	    [4,1,5,2,4,3,5,5],
        [4,1,0,2,4,5,2,0]]).
	   
dominos2([(0,0),(0,1),(0,2),(0,3),(0,4),(0,5),(0,6),(0,7),(0,8),(0,9),(0,a),
                (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,a),
                      (2,2),(2,3),(2,4),(2,5),(2,6),(2,7),(2,8),(2,9),(2,a),
                            (3,3),(3,4),(3,5),(3,6),(3,7),(3,8),(3,9),(3,a),
                                  (4,4),(4,5),(4,6),(4,7),(4,8),(4,9),(4,a),
                                        (5,5),(5,6),(5,7),(5,8),(5,9),(5,a),
                                              (6,6),(6,7),(6,8),(6,9),(6,a),
                                                    (7,7),(7,8),(7,9),(7,a),
                                                          (8,8),(8,9),(8,a),
                                                                (9,9),(9,a),
                                                                      (a,a)]).

frame2([[6,5,0,5,5,3,3,1,1,4,6],
        [1,2,2,a,a,5,7,0,1,0,7],
        [5,8,6,0,8,0,9,7,7,4,2],
        [4,0,9,0,7,7,9,9,8,8,0],
        [1,a,3,8,8,5,a,8,0,0,3],
        [9,2,3,5,7,6,9,1,6,3,9],
        [2,2,2,5,8,6,0,4,6,a,a],
        [9,4,2,1,7,9,5,4,a,4,a],
        [9,a,4,9,5,5,6,6,0,a,2],
        [1,a,1,2,1,1,8,2,2,7,8],
        [7,7,3,3,4,3,6,6,4,3,1],
        [5,9,6,3,3,a,7,4,4,8,8]]). 

dominos3([(a,b),(b,c),(c,d),(d,e),(e,f),(f,g),(g,h),(h,i),(i,j),(j,k),(k,l),(l,m),
          (a,c),(b,d),(c,e),(d,f),(e,g),(f,h),(g,i),(h,j),(i,k),(j,l),(k,m),(l,n),
          (a,d),(b,e),(c,f),(d,g),(e,h),(f,i),(g,j),(h,k),(i,l),(j,m),(k,n),(l,o),
          (a,e),(b,f),(c,g),(d,h),(e,i),(f,j),(g,k),(h,l),(i,m),(j,n),(k,o),(l,p),
          (a,f),(b,g),(c,h),(d,i),(e,j),(f,k),(g,l),(h,m),(i,n),(j,o),(k,p),(l,q),
          (a,g),(b,h),(c,i),(d,j),(e,k),(f,l),(g,m),(h,n),(i,o),(j,p),(k,q),(l,r),
          (a,h),(b,i),(c,j),(d,k),(e,l),(f,m),(g,n),(h,o),(i,p),(j,q),(k,r),(l,s),
          (a,i),(b,j),(c,k),(d,l),(e,m),(f,n),(g,o),(h,p),(i,q),(j,r),(k,s),(l,t),
          (a,j),(b,k),(c,l),(d,m),(e,n),(f,o),(g,p),(h,q),(i,r),(j,s),(k,t),(l,u),
          (a,k),(b,l),(c,m),(d,n),(e,o),(f,p),(g,q),(h,r),(i,s),(j,t),(k,u),(l,v),
          (a,l),(b,m),(c,n),(d,o),(e,p),(f,q),(g,r),(h,s),(i,t),(j,u),(k,v),(l,w),
          (a,m),(b,n),(c,o),(d,p),(e,q),(f,r),(g,s),(h,t),(i,u),(j,v),(k,w),(l,x)]).

frame3([[d,g,i,r,d,f,g,l,n,f,i,s,f,k,w,l],
        [k,e,a,j,k,e,s,k,j,k,b,i,r,c,j,o],
        [l,q,j,p,n,h,k,l,s,j,r,t,f,v,k,k],
        [x,k,a,d,f,m,m,o,c,g,d,h,j,i,c,u],
        [g,q,i,b,m,a,f,e,i,b,l,a,e,i,f,g],
        [n,a,o,i,p,g,r,l,r,h,a,o,g,l,p,i],
        [d,c,d,g,e,f,n,h,b,t,j,e,d,h,c,i],
        [i,m,g,b,q,i,b,f,c,l,l,b,u,i,h,t],
        [j,h,c,g,f,a,s,l,f,l,e,c,d,j,i,j],
        [p,s,n,d,a,p,c,l,b,e,k,j,u,t,h,g],
        [c,f,g,g,b,h,n,e,j,h,m,i,j,f,h,c],
        [f,l,w,h,e,o,h,j,k,j,v,d,b,b,n,k],
        [h,r,g,n,m,d,a,d,h,l,k,b,h,m,a,i],
        [o,j,l,e,k,g,d,m,e,h,k,r,j,j,l,k],
        [e,c,o,h,a,n,f,k,d,q,k,k,a,j,f,p],
        [v,l,i,q,p,p,k,o,m,e,d,l,g,m,k,s],
        [e,n,i,g,e,q,l,m,i,o,g,m,i,c,l,k],
        [q,n,j,q,l,h,f,o,b,j,p,c,l,l,u,t]]). 

/*στο κατηγορημα put_dominos πρωτα φτιαχνεται η λιστα Consframe δηλαδη consecutive frame. Ειναι ουσιαστικα ολοκληρο το frame
αλλα οχι σπασμενο σε λιστες αλλα συνεχομενο με τα στοιχεια σειρα σειρα. Επιπλεον, καθε στοιχειο στην consframe εχει την μορφη
Figure-(Row, Column). Επειτα κατασκευαζονται οι 2 λιστες RF, CF. Η RF εχει ως μελη λιστες οπου η καθε λιστα εχει τα στοιχεια 
της εκαστοτε σειρας με τις συντεταγμενες σειρας-στηλης τους (Figure-(Row, Column)). Η CF εχει ως μελη λιστες οπου η καθε λιστα εχει τα
στοιχεια της εκαστοτε στηλης με τις συντεταγμενες σειρας-στηλης τους. Το combine_soldom δημιουργει μια λιστα που καθε στοιχειο της 
εχει την μορφη Domino-Domain. Για να το κανει αυτο βρισκει πρωτα το domain του καθε ντομινο με το κατηγορημα search_domain. Το
search_domain μεσω του positions και των λιστων RF, CF βρισκει τις πιθανες θεσεις του καθε ντομινο σε ολες τις στηλες και σε ολες
τις γραμμες του πινακα. Αυτο που επιστρεφει εν τελει η search_domain ειναι μια λιστα με ολες τις πιθανες θεσεις που μπορει να μπει
ενα ντομινο. Εχοντας τωρα τον πινακα με ολα τα Domino-Domain, χρησιμοποιειται το κατηγορημα generate_solution για να παραξει τη λυση 
με τις τελικες θεσεις του καθε ντομινο, το οποιο βρισκει την mrv μεταβλητη, επιλεγει καποια απο τις πιθανες θεσεις που εχει το domain
και με το update_domains διαγραφει την θεση που επιλεχθηκε απο ολα τα υπολοιπα domains των αλλων ντομινο. Καθε φορα που επιλεγεται 
μια θεση στον πινακα για καποιο ντομινο, το ντομινο αυτο μαζι με τις συντεταγμενες αυτων των θεσεων μπαινουν στον πινακα Solution ο 
οποιος αποτελει και την λυση, δηλαδη την πληρη καλυψη του πινακα με ντομινο. Πλεον μενει μονο να τυπωθει η λυση. Αυτο γινεται με την 
το κατηγορημα create_domino_table το οποιο μεσω των create_domino_list και create_whitespace_dash_list τυπωνει σειρα σειρα την λυση.
Τυπωνει ενα ενα τα στοιχεια του frame και αν για καποιο στοιχειο το επομενο ειναι το συμπληρωματικο του ντομινο, βαζει αναμεσα τους μια
παυλα. Αν το επομενο δεν ειναι το συμπληρωματικο του βαζει ενα κενο. Μετα απο καθε λιστα με στοιχεια και παυλες, τυπωνεται ακριβως απο
κατω και μια λιστα με καθετες παυλες και κενα. Αυτη φτιαχνεται με το create_whitespace_dash_list το οποιο για καθε στοιχειο του frame
βρισκει το συμπληρωματικο ντομινο αυτου που βρισκεται σε αυτη τη θεση του frame. Αν το συμπληρωματικο ειναι στην ιδια στηλη και στην 
ακριβως επομενη γραμμη σημαινει οτι ειναι ακριβως απο κατω του οποτε στην λιστα μπαινει μια καθετη παυλα. Οι 2 ειδων λιστες που 
φτιαχνονται, αυτη με τα στοιχεια και τις παυλες και αυτη με τις καθετες παυλες και τα κενα, τυπωνονται εναλλαξ και ετσι φαινεται στο 
output η ολοκληρωμενη λυση του πινακα.*/
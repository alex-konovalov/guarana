#############################################################################
##
#W polycy.gi              GUARANA package                     Bjoern Assmann
##
## Examples of infinite polycyclic groups that can be used
## to test the Mal'cev collection.
##
#H  @(#)$Id$
##
#Y 2006
##
##

GUARANA.Tr_n_O := function( n, pol )
    local R, H, pcpH, pol_deg, ind_f, counter, ind_diag, ind_c, 
          ind_n, ind, new_pcs, G, indeces, N, NN, C, CC, i;

    R := GUARANA.Triang_PresentTriang( n, pol );
    H := R.Tr;
    pcpH := Pcp( H );
    pol_deg := Degree( pol );

    # get indeces of elms of finite order 
    ind_f := [];
    counter := 1;
    for i in [1..n] do 
	Add( ind_f, counter );
	counter := counter + pol_deg;
    od;

    # get indeces of elms on diagonal of infinite order 
    ind_diag := [1..n*pol_deg];
    ind_c := Difference( ind_diag, ind_f );

    # get indeces of elms of upper triangular part
    ind_n := [n*pol_deg+1..Length(pcpH)];

    ind := Concatenation( ind_f, ind_c, ind_n );
    new_pcs := pcpH{ind};

    # change collector
    G := GUARANA.PcpGroupByPcs( H, new_pcs ); 

    indeces := [ [1..n], [n+1..n*pol_deg], [n*pol_deg+1..Length(pcpH)]];
    N := Subgroup( G, Pcp(G){indeces[3]} );
    NN := GUARANA.PcpGroupByPcs( G, Pcp(G){indeces[3]} );
    C := Subgroup( G, Pcp(G){indeces[2]} );
    CC := GUARANA.PcpGroupByPcs( G, Pcp(G){indeces[2]} );
    return [G,indeces,N,NN,C,CC];
end;

GUARANA.Tr_n_O1 := function( n )
    local x, pol;
    x := Indeterminate( Rationals );
    pol := x^2 - 3;
    return GUARANA.Tr_n_O( n, pol );
end;

GUARANA.Tr_n_O2 := function( n )
    local x, pol;
    x := Indeterminate( Rationals );
    pol := x^3 - x^2 + 4;
    return GUARANA.Tr_n_O( n, pol );
end;

GUARANA.Tr_n_O3 := function( n )
    local x, pol;
    x := Indeterminate( Rationals );
    pol := x_1^4+5*x_1^3-x_1^2+x_1+3;
    return GUARANA.Tr_n_O( n, pol );
end;

# - function for triang examples 
# - function for free-nilpotent-by automorphism examples.

## 
## OUT
## Examples that can be used to test Malcev collection. 
##
GUARANA.SomePolyMalcevExams := function( n )
  local T, H, ll, pcs, G, indeces, N, NN, C, CC, h1, h2, h3, h4, f1, f2, f3, g1, g2, g3, g4, i, pcpH;
    if n=1 then 
	T := GUARANA.NilpotentByFreeAbelianExams(1);
	H := T.G;
        ll := [1,3,5,2,4,6,7,8,9,10,11,12];
        pcs := Pcp(H){ll};
	G := GUARANA.PcpGroupByPcs( H, pcs ); 
	indeces := [[1,2,3],[4,5,6],[7,8,9,10,11,12]];
	N := Subgroup( G, Pcp(G){indeces[3]} );
	NN := GUARANA.PcpGroupByPcs( G, Pcp(G){indeces[3]} );
	C := Subgroup( G, Pcp(G){indeces[2]} );
	CC := GUARANA.PcpGroupByPcs( G, Pcp(G){indeces[2]} );
	return [G,indeces,N,NN,C,CC];
    elif n=2 then 
	T := GUARANA.NilpotentByFreeAbelianExams(2);
	H := T.G;
	ll := Concatenation( [ [1,3,5,7], [2,4,6,8],[9..20]] ); 
        pcs := Pcp(H){ll};
	G := GUARANA.PcpGroupByPcs( H, pcs ); 
	indeces := [[1..4],[5..8],[9..20]];
	N := Subgroup( G, Pcp(G){indeces[3]} );
	NN := GUARANA.PcpGroupByPcs( G, Pcp(G){indeces[3]} );
	C := Subgroup( G, Pcp(G){indeces[2]} );
	CC := GUARANA.PcpGroupByPcs( G, Pcp(G){indeces[2]} );
	return [G,indeces,N,NN,C,CC];
    elif n = 3 then 
	# in this example C and N have non trivial intersection
	T := GUARANA.NilpotentByFreeAbelianExams(2);
	H := T.G;
	pcpH := Pcp( H );
	h1 := pcpH[4]*pcpH[19];
	h2 := pcpH[6]*pcpH[19];
	h3 := pcpH[19];
	h4 := pcpH[20];
	f1 := pcpH[1]*pcpH[9];
	f2 := pcpH[3]*pcpH[12];
	f3 := pcpH[5]*pcpH[14];
        pcs := [f1,f2,f3,h1,h2];
	for i in [1..Length( Pcp(T.N)) ] do 
	    Add( pcs, Pcp(T.N)[i] );
	od;
	G := GUARANA.PcpGroupByPcs( H, pcs );
	indeces := [[1..3],[4,5],[6..17]];
	N := Subgroup( G, Pcp(G){indeces[3]} );
	NN := GUARANA.PcpGroupByPcs( G, Pcp(G){indeces[3]} );
	g1 := Pcp(G)[4];
	g2 := Pcp(G)[5];
	g3 := Pcp(G)[16];
	g4 := Pcp(G)[17];
	C := Subgroup( G, [g1,g2,g3,g4] );
	CC := GUARANA.PcpGroupByPcs( G, [g1,g2,g3,g4] );
	return [G,indeces,N,NN,C,CC];
    fi;
end;



#############################################################################
##
#E 

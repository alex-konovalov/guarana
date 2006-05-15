#############################################################################
##
#W collec.gi              GUARANA package                     Bjoern Assmann
##
## Methods for collection in CN.
## Methods for collection in G using the collection in CN
## as a black box algorithm.
##
#H  @(#)$Id$
##
#Y 2006
##
##

#############################################################################
##
#F GUARANA.CutExpVector( malcevRec, exp )
##
## IN
## malcevRec ............................ malcev record
## exp .................................. exponent vector of an elment
##                                        g in G.
##
## OUT
## [exp_f,exp_c,exp_n] where exp is the concantenation of these and
## exp_f specifies the exponents of the finite part G/CN
## exp_fa specifies the exponents of the free abelian part CN/N
## exp_n specifies the exponents of the nilpotent part  N.
##
GUARANA.CutExpVector := function( malcevRec, exp )
    local indeces, exp_f, exp_fa, exp_n;
    indeces := malcevRec.indeces;
    exp_f := exp{indeces[1]};
    exp_fa := exp{indeces[2]};
    exp_n := exp{indeces[3]};
    return [exp_f, exp_fa, exp_n];
end;

#############################################################################
##
#F GUARANA.RandomGrpElm( args )
##
## IN
## args[1]=malcevRec ............... malcev record
## args[2]=range ................... range of random element
## args[3]=grp ..................... optional string specifying whether
##                                   and elment in G,CN or N should be given.
##                                   Default is "G".
## args[4]=form .................... string that is either 
##                                   "exp" or "elm" depending on 
##                                   how the random element should be
##                                   given. 
##
## OUT
## Random group elment of N,CN or G given by a exponent vector or 
## as actual group element
##
GUARANA.RandomGrpElm := function( args )
    local malcevRec, range, form, grp, hl, domain, indeces, rels, exp, i;

    malcevRec := args[1];
    range := args[2];
    if IsBound( args[3]  ) then 
	grp := args[3];
    else
	grp := "G";
    fi;
    if IsBound( args[4] ) then 
        form := args[4];
    else
	form := "exp";
    fi;

    hl := HirschLength( malcevRec.G  );
    domain := [-range..range];
    indeces := malcevRec.indeces;
    rels := RelativeOrdersOfPcp( Pcp( malcevRec.G ));

    exp := List( [1..hl], x-> 0 );
    if grp = "N" then 
	for i in indeces[3] do
	    exp[i] := Random( domain );
	od;
    elif grp = "CN" then 
	for i in Concatenation( indeces[2], indeces[3] ) do
	    exp[i] := Random( domain );
	od;
    elif grp = "G" then 
	for i in Concatenation( indeces[2], indeces[3] ) do
	    exp[i] := Random( domain );
	od;
	for i in indeces[1] do
	    exp[i] := Random( domain ) mod rels[i];
	od;
    else
	Error( " " );
    fi;
	    
    if form = "exp" then 
	return exp;
    else 
	return GUARANA.GrpElmByExpsAndPcs( Pcp( malcevRec.G ), exp );
    fi;
end;

#############################################################################
##
#F GUARANA.Collection_CN( malcevRec, exp_g, exp_h )
#F GUARANA.Collection_CN_Star( malcevRec, exp_g, exp_h )
#F GUARANA.Collection_CN_DT( malcevRec, exp_g, exp_h )
##
## IN
## malcevRec ........................ malcev record
## exp_g,exp_h  ..................... exponent vectors of group elements
##                                    g,h in CN 
## 
## OUT 
## The exponent vector of g*h
##
## COMMENT
## g h = c(g)n(g) c(h)n(h)
##     = c(g)c(h) n(g)^c(h) n(h)
##     = c(gh) t n(g)^c(h) n(h)
##
## In Collection_CN_Star the computation in N are done in L(N) 
## via the operation star. 
## 
GUARANA.CN_Collection_Star := function( malcevRec, exp_g, exp_h )
    local exp_g_cut, exp_h_cut, c_g, c_h, n_g, n_h, log, id_C, c_g_C, 
          c_h_C, c_gh, c_gh_C, log_c_g, log_c_h, log_c_g_c_h, log_c_gh, 
	  log_t_LC, log_t, log_n_h, y, z, n_gh, f_gh, exp_gh, i;

    # test whether g,h in CN
    exp_g_cut := GUARANA.CutExpVector( malcevRec, exp_g );
    exp_h_cut := GUARANA.CutExpVector( malcevRec, exp_h );
    if exp_g_cut[1] <> exp_g_cut[1]*0 then
	Error( "g is not in CN" );
    elif exp_h_cut[1] <> exp_h_cut[1]*0 then
	Error( "h is not in CN" );
    fi;

    c_g := exp_g_cut[2];
    c_h := exp_h_cut[2];
    n_g := exp_g_cut[3];
    n_h := exp_h_cut[3];

    # map n(g) to L(N) and apply the automorphism corresponding to c(h)
    log := GUARANA.AbstractLog( [malcevRec.recL_NN, n_g, "vecByVec"] );
    for i in malcevRec.indeces[2] do
        log := log*malcevRec.lieAuts[i]^exp_h[i];
    od;

    # get exp vector of c(g), c(h), c(gh) with repsect to the pcp of CC
    id_C := List( [1..malcevRec.recL_CC.dim], x-> 0 );
    c_g_C := id_C + c_g;
    c_h_C := id_C + c_h;
    c_gh := c_g + c_h;
    c_gh_C := id_C + c_gh;

    # compute log(t) with respect to the basis of L(C)
    log_c_g := GUARANA.AbstractLog( [malcevRec.recL_CC, c_g_C, "vecByVec"] );
    log_c_h := GUARANA.AbstractLog( [malcevRec.recL_CC, c_h_C, "vecByVec"] );
    log_c_g_c_h := GUARANA.Star( [malcevRec.recL_CC, log_c_g, log_c_h,
                                  "vec" ] );
    log_c_gh := GUARANA.AbstractLog( [malcevRec.recL_CC, c_gh_C, "vecByVec"] );
    log_t_LC := GUARANA.Star( [malcevRec.recL_CC, -log_c_gh, log_c_g_c_h,
                               "vec" ] );

    # check wheter log(t) has the right form
    if log_t_LC{[1..malcevRec.lengths[2]]} <> 
       0*log_t_LC{[1..malcevRec.lengths[2]]} then 
        Error( "log(t) does not have the correct form" );
    fi;
    
    # compute log(t) with respect to the basis of L(N)
    log_t := GUARANA.MapFromLCcapNtoLN( malcevRec, log_t_LC );

    # compute log( n(h) )
    log_n_h := GUARANA.AbstractLog( [malcevRec.recL_NN, n_h, "vecByVec"] );

    # compute z=log(t)*log(n(g)^c(h))*log(n(h))
    y := GUARANA.Star( [malcevRec.recL_NN, log_t, log, "vec" ] );
    z := GUARANA.Star( [malcevRec.recL_NN, y, log_n_h, "vec" ] );
    
    # compute n(gh)
    n_gh := GUARANA.AbstractExp( [malcevRec.recL_NN, z, "vecByVec"] );

    # get exp of finite part
    f_gh := List( [1..malcevRec.lengths[1]], x-> 0 );

    exp_gh := Concatenation( f_gh,c_gh, n_gh );
    return exp_gh;
end;

GUARANA.CN_Collection_DT := function( malcevRec, exp_g, exp_h )

end;

GUARANA.CN_Collection := function( malcevRec, exp_g, exp_h )
    local method;

    method := malcevRec.collCN_method;
    if method = "star" then 
	return GUARANA.CN_Collection_Star( malcevRec, exp_g, exp_h );
    elif method = "deepThought" then 
	Error( "Sorry not implemented yet" );
    else
	Error( " " );
    fi;
end;

#############################################################################
##
#F GUARANA.CconjF_SingleElmConjByFiniteElm( malcevRec, i,x_i, exp_f )
##
## IN
## malcevRec .......................... Malcev record
## i .................................. index of c_i, which is a part
##                                      of the pcs of CN/N. 
##                                      Note that i is the position of 
##                                      the c_i in the pcs of G 
##                                      (and not in the pcs of CN/N ).
## x_i ................................ integer
## exp_f  ................................ short expvector (with respect 
##                                         to the pcs of G/CN ) of an elment
##                                         f in G, that is a product of 
##                                         generators of the finite part of 
##                                         the pcs. 
## OUT
## Exponent vector of ( c_i^x_i )^f
## 
GUARANA.CconjF_SingleElmConjByFiniteElm := function( malcevRec, i,x_i,exp_f)
    local c_i_f, c_i_f_x_i;

    # look up c_i^f
    c_i_f := GUARANA.CconjF_LookUp( malcevRec, i, exp_f );

    # power it by x_i
    c_i_f_x_i := GUARANA.CN_Power( malcevRec, c_i_f, x_i );

    return c_i_f_x_i;
end;

#############################################################################
##
#F GUARANA.CconjF_ElmConjByFiniteElm( malcevRec, exp_c, exp_f )
##
## IN
## malcevRec ........................ Malcev record
## exp_c ............................ short exponent vector (with respect 
##                                    to pcs of CN/N) of an element 
##                                    in C.
##                                    c = c_1^x_1 ... c_k^x_k 
##                                    where k is the rank of CN/N.
## exp_f  ................................ short expvector (with respect 
##                                         to the pcs of G/CN ) of an elment
##                                         f in G, that is a product of 
##                                         generators of the finite part of the
##                                         pcs. 
## OUT
## Exponent vector of c^f
##
## COMMENT
## c^f = (c_1^x_1 ... c_k^x_k )^f
##     = (c_1^x_1)^f ... (c_k^x_k)^f
## 
GUARANA.CconjF_ElmConjByFiniteElm := function( malcevRec, exp_c, exp_f )
    local hl, res, x_i, ii, c_i_x_i_f, i;
   
    res := List( [1..Length(Pcp(malcevRec.G))], x-> 0 );

    for i in [1..Length( exp_c )] do
	x_i := exp_c[i];
	if x_i <> 0 then 
	    ii := i + malcevRec.lengths[1];
	    # comput (c_i^x_i)^f
	    c_i_x_i_f := GUARANA.CconjF_SingleElmConjByFiniteElm( malcevRec,
	                                                          ii, x_i,
								  exp_f );
	    res := GUARANA.CN_Collection( malcevRec, res, c_i_x_i_f );
	fi;
    od;
    return res;
end;

#############################################################################
##
#F GUARANA.CN_ConjugationByFiniteElm( malcevRec, exp_g, exp_f )
##
## IN
## malcevRec ............................. Malcev record
## exp_g  ................................ exponent vector of g in CN
## exp_f  ................................ short expvector (with respect 
##                                         to the pcs of G/CN ) of an elment
##                                         f in G, that is a product of 
##                                         generators of the finite part of the
##                                         pcs. 
##
## OUT
## Exponent vector of the normal form g^f
##
## COMMENT
## g^f = ( c(g) n(g) )^f
##     =  c(g)^f n(g)^f
##
GUARANA.CN_ConjugationByFiniteElm := function( malcevRec, exp_g, exp_f )
    local exp_g_cut, c_g, n_g, c_g_f, log, c_g_f_cut, c_c_g_f, n_c_g_f, 
          log2, log3, n_g_f, i,f;

    # check whether g is in CN
    exp_g_cut := GUARANA.CutExpVector( malcevRec, exp_g );
    if exp_g_cut[1] <> exp_g_cut[1]*0 then
	Error( "g is not in CN" );
    fi; 
    c_g := exp_g_cut[2];
    n_g := exp_g_cut[3];

    # compute c(g)^f
    c_g_f := GUARANA.CconjF_ElmConjByFiniteElm( malcevRec, c_g, exp_f );

    # map n(g) to L(N) and apply the automorphism corresponding to f
    log := GUARANA.AbstractLog( [malcevRec.recL_NN, n_g, "vecByVec"] );
    for i in malcevRec.indeces[1] do
	if exp_f[i] <> 0 then 
            log := log*malcevRec.lieAuts[i]^exp_f[i];
	fi;
    od;

    # compute the product of  n( c(g)^f) and n(g)^f which is equal to 
    # n( g^f )
    c_g_f_cut := GUARANA.CutExpVector( malcevRec, c_g_f );
    c_c_g_f := c_g_f_cut[2];
    n_c_g_f := c_g_f_cut[3];
    log2 := GUARANA.AbstractLog( [malcevRec.recL_NN, n_c_g_f, "vecByVec"] );
    log3 := GUARANA.Star( [malcevRec.recL_NN, log2, log, "vec" ] );
    n_g_f := GUARANA.AbstractExp( [malcevRec.recL_NN, log3, "vecByVec"] );
    
    # get exp of finite part
    f := List( [1..malcevRec.lengths[1]], x-> 0 );

    return Concatenation( f, c_c_g_f, n_g_f );
end;

## IN
## malcevRec ............................ Malcev record
## exp_g     .............................exponent vector of a group element
##                                        g in G
##
## OUT
## Exponent vector of c(g)n(g) with respect to the full pcs of G.
##
GUARANA.GetCNPart := function( malcevRec, exp_g )
    local exp_cn;
    exp_cn := ShallowCopy( exp_g );
    exp_cn{malcevRec.indeces[1]} := 0*exp_cn{malcevRec.indeces[1]};
    return exp_cn;
end;

## COMMENT
## g h = f(g)c(g)n(g) f(h)c(h)n(h) 
##     = f(g)f(h)        (c(g)n(g))^f(h)    c(h)n(h)
##     = f(gh) u         v                  w
## 
GUARANA.G_Collection := function( malcevRec, exp_g, exp_h )
    local exp_g_cut, exp_h_cut, f_g, f_h, a, f_gh, u, b, v, w, uv, 
          uvw, exp_gh;

    exp_g_cut := GUARANA.CutExpVector( malcevRec, exp_g );
    exp_h_cut := GUARANA.CutExpVector( malcevRec, exp_h );

    f_g := exp_g_cut[1];
    f_h := exp_h_cut[1];

    # get f(gh) and u
    a := GUARANA.G_CN_LookUpProduct( malcevRec, f_g, f_h );
    f_gh := a{malcevRec.indeces[1]};
    u := GUARANA.GetCNPart( malcevRec, a ); 

    # compute v
    b := GUARANA.GetCNPart( malcevRec, exp_g );
    v := GUARANA.CN_ConjugationByFiniteElm( malcevRec, b, f_h );
    
    # compute w
    w := GUARANA.GetCNPart( malcevRec, exp_h );

    # compute normal form of uvw.
    uv := GUARANA.CN_Collection( malcevRec, u, v );
    uvw := GUARANA.CN_Collection( malcevRec, uv, w );

    exp_gh := uvw;
    exp_gh{malcevRec.indeces[1]} := f_gh;

    return exp_gh;
end;

#############################################################################
##
## Test functions
##
if false then 
   ll := GUARANA.SomePolyMalcevExams( 3 );
   R := GUARANA.InitialSetupCollecRecord( ll );
   GUARANA.AddCompleteMalcevInfo( R );
   g := GUARANA.RandomGrpElm( [R,10, "CN"] );
   h := GUARANA.RandomGrpElm( [R,10, "CN"] );
fi;

GUARANA.Test_CconjF_SingleElmConjByFiniteElm := function( malcevRec, pow,
                                                range )
    local i, n, exp_h, exp_f, malcev, c_i, f, cftl;
							  
    # get random index
    i := Random( malcevRec.indeces[2] );

    # get random exp vector of finite part 
    n := Length( malcevRec.G_CN.rels );
    exp_h := GUARANA.RandomGrpElm( [malcevRec, range, "G", "exp" ]);
    exp_f := exp_h{[1..n]}; 
    Print( exp_f, "\n" );

    # compute (c_i^x_i)^f with Malcev
    malcev :=GUARANA.CconjF_SingleElmConjByFiniteElm( malcevRec, i,pow,exp_f);
    Print( malcev, "\n" );

    # compute it with Cftl
    c_i := Pcp( malcevRec.G )[i];
    f := GUARANA.GrpElmByExpsAndPcs( Pcp(malcevRec.G), exp_f );
    cftl := (c_i^pow)^f;
    Print( Exponents( cftl ), "\n" );

    return Exponents( cftl ) = malcev;

end;

GUARANA.Test_CconjF_ElmConjByFiniteElm := function( malcevRec, range )
    local g, exp_g, exp_g_cut, exp_c, n, exp_h, exp_f, exp_c_f, f, c, c_f;

    # get random element in C
    g := GUARANA.RandomGrpElm( [malcevRec, range, "CN", "elm" ]);
    exp_g := Exponents( g );
    exp_g_cut := GUARANA.CutExpVector( malcevRec, exp_g );
    exp_c := exp_g_cut[2];

    # get random exp vector of finite part 
    n := Length( malcevRec.G_CN.rels );
    exp_h := GUARANA.RandomGrpElm( [malcevRec, range, "G", "exp" ]);
    exp_f := exp_h{[1..n]}; 
    Print( exp_f, "\n" );

    # compute c^f with Malcev 
    exp_c_f := GUARANA.CconjF_ElmConjByFiniteElm( malcevRec, exp_c, exp_f );
    Print( exp_c_f, "\n" );

    # comput c^f with Cftl
    f := GUARANA.GrpElmByExpsAndPcs( Pcp(malcevRec.G), exp_f );
    c := GUARANA.GrpElmByExpsAndPcs( Pcp(malcevRec.G){malcevRec.indeces[2]}, 
	                             exp_c );
    c_f := c^f;
    Print( Exponents( c_f ), "\n" );

    return Exponents( c_f ) = exp_c_f;
end;

GUARANA.Tests_CconjF_ElmConjByFiniteElm := function( malcevRec, range )
    local no, test, i;

    no := 100;
    for i in [1..no] do 
	test := GUARANA.Test_CconjF_ElmConjByFiniteElm( malcevRec, range );
        if test = true then
	    Print( "yeah" );
	else
	    Error( " " );
	fi;
    od;
end;
	    
GUARANA.Test_CN_ConjugationByFiniteElm := function( malcevRec, range )
    local g, exp_g, n, exp_h, exp_f, exp_g_f, f, g_f;

    # get random element in CN
    g := GUARANA.RandomGrpElm( [malcevRec, range, "CN", "elm" ]);
    exp_g := Exponents( g );

    # get random exp vector of finite part 
    n := Length( malcevRec.G_CN.rels );
    exp_h := GUARANA.RandomGrpElm( [malcevRec, range, "G", "exp" ]);
    exp_f := exp_h{[1..n]}; 
    Print( exp_f, "\n" );

    # compute g^f with Malcev 
    exp_g_f := GUARANA.CN_ConjugationByFiniteElm( malcevRec, exp_g, exp_f );
    Print( exp_g_f, "\n" );

    # comput g^f with Cftl
    f := GUARANA.GrpElmByExpsAndPcs( Pcp(malcevRec.G), exp_f );
    g_f := g^f;
    Print( Exponents( g_f ), "\n" );

    if Exponents( g_f ) <> exp_g_f then
	Error( "hallo" );
    fi;

    return Exponents( g_f) = exp_g_f;
end;

GUARANA.Test_CN_Collection_Star := function( malcevRec, range )
    local g, exp_g, h, exp_h, exp_gh, gh;
   
    # get random elements in CN
    g := GUARANA.RandomGrpElm( [malcevRec, range, "CN", "elm" ]);
    exp_g := Exponents( g );
    h := GUARANA.RandomGrpElm( [malcevRec, range, "CN", "elm" ]);
    exp_h := Exponents( h );

    # comput gh with Malcev
    exp_gh := GUARANA.CN_Collection_Star( malcevRec, exp_g, exp_h );

    # comput gh with Cfts
    gh := g*h;

    return Exponents( gh ) = exp_gh;
end;

GUARANA.Tests_CN_Collection_Star := function( malcevRec, range )
    local no, test, i;
    
    no := 100;
    for i in [1..no] do
	test := GUARANA.Test_CN_Collection_Star( malcevRec, range );
	if test = true then
	    Print( "yeah" );
	else 
	    Error( " " );
	fi;
    od;
end;

GUARANA.Test_G_Collection := function( malcevRec, range )
    local g, exp_g, h, exp_h, exp_gh, gh, exp_gh2;
   
    # get random elements in G
    g := GUARANA.RandomGrpElm( [malcevRec, range, "G", "elm" ]);
    exp_g := Exponents( g );
    h := GUARANA.RandomGrpElm( [malcevRec, range, "G", "elm" ]);
    exp_h := Exponents( h );

    # comput gh with Malcev
    exp_gh := GUARANA.G_Collection( malcevRec, exp_g, exp_h );
    #Print( exp_gh, "\n" );

    # comput gh with Cfts
    gh := g*h;
    exp_gh2 := Exponents( gh );
    #Print( exp_gh2, "\n" );

    return exp_gh2 = exp_gh;
end;

GUARANA.Tests_G_Collection := function( malcevRec, range )
    local no, test, i;
    
    no := 100;
    for i in [1..no] do
	test := GUARANA.Test_G_Collection( malcevRec, range );
	if test = true then
	    Print( i );
	else 
	    Error( " " );
	fi;
    od;
end;
#############################################################################
##
#E

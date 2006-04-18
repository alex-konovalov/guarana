#############################################################################
##
#W setup.gi               GUARANA package                     Bjoern Assmann
##
## Methods for the setup of the Malcev correspondence between the 
## radicable hull of a T-group and its corresponding Lie algebra. 
## For this setup we use the Bch formula (and not a unitriangular
## matrix representation). 
## We assume that certain informations about the T-group are given;
## in particular we assume that the pcp is given with respect to 
## a Mal'cev basis. These information about the T-group are stored
## in a record named recTGroup. 
##
#H  @(#)$Id$
##
#Y 2006
##
##

#############################################################################
##
#F GUARANA.SetUpLieAlgebraRecordByMalcevbasis( recTGroup )
##
## IN
## recTGroup .............. record containing some information about
##                          a T-group. In particular a pcp with 
##                          respect to a Mal'cev basis. 
##
## OUT
## An empty data structure that contain be filled with information
## about the corresponding Lie algebra. 
##
GUARANA.SetUpLieAlgebraRecordByMalcevbasis := function( recTGroup )
    local NN,hl,T,L;
    
    # get dimension of algebra
    NN := recTGroup.NN;
    hl := HirschLength( NN );

    # get prototype for structure constant table and Lie algebra 
    T:= EmptySCTable( hl, 0, "antisymmetric" );
    L:= LieAlgebraByStructureConstants( Rationals, T );

    # set the structure constants we already know,
    # i.e. lie brackets involving log g_i where g_i in Z(NN)
        # not necessary, because empty entries are interpreted 
        # as commuting elements

    return rec( L := L, 
                recTGroup := recTGroup, 
		scTable := T,
	        weights := recTGroup.weights,
		class := recTGroup.class );
end;

#############################################################################
##
#F GUARANA.EvaluateLieBracket( x,y, com, info )
##
## IN
## x,y .................. elements of Lie algebra.
## com .................  commutator given as list containing 1,2.
##                        x corresponds to 1
##                        y corresponds to 2 
##                        For example [1,2,1] corresponds to 
##                        the commutator [x,y,x]
## info ................  string that is either "lieAlgebra" or 
##                        "matrix". In the first case the 
##                        x,y are elements of a Lie algebra given
##                        by strcuture constants. In the second 
##                        case x,y are matrices. 
## 
## OUT
## The result of Com( x,y ). 
##
GUARANA.EvaluateLieBracket := function( x, y, com, info )
    local r,l,tmp,i;
    tmp := [x,y];
    r := tmp[com[1]];

    l := Length( com );
    if info = "lieAlgebra" then
        for i in [2..l] do
            r := r * tmp[com[i]];
        od; 
    elif info = "matrix" then 
        for i in [2..l] do
            r := LieBracket( r, tmp[com[i]] );
        od;
    else 
        Error( "wront input \n " );
    fi;
    return r;
end;

#############################################################################
##
## Same for group commutators.
## g corresponds to 1
## h corresponds to 2 
##
GUARANA.EvaluateGroupCommutator := function( g, h, com )
    local tmp,r,l,i;
    tmp := [g,h];
    r := tmp[com[1]];

    l := Length( com );
    for i in [2..l] do
        r := Comm( r, tmp[com[i]] );
    od;
    return r;
end;

#############################################################################
##
#F GUARANA.WeightOfCommutator( com, wx, wy )
## 
## IN 
## com ................. commutator in x,y
## wx .................. weight of x
## wy .................  weight of y 
## 
## OUT
## Weight of com(x,y).
##
GUARANA.WeightOfCommutator := function( com, wx, wy )
    local weight,a;
    weight := 0;
    for a in com do
        if a = 1 then
            weight := weight + wx;
        elif a = 2 then
            weight := weight + wy;
        else
            Error( "Wrong input\n" );
        fi;
    od;
    return weight;
end;

#############################################################################
##
##
GUARANA.CheckWeightOfCommutator := function( com, wx, wy, class )
    local w;
    w := GUARANA.WeightOfCommutator( com, wx, wy );
    if w > class then
        return false;
    else
        return true;
    fi;
end;

#############################################################################
##
#F GUARANA.Star_Simple( x, y, wx, wy, class, info )
##
## IN
## x,y ................... elements of a Lie algebra.
##                         so brackets of Length class + 1 are always 0.
## wx,wy ................. their weights. 
## class ................  nilpotency class of the Lie algebra. 
## info .................  strings which determines how lie brackets
##                         are evaluated
##
## OUT 
## x*y, where "*" is the BCH operation 
##
## This is a very simple implementation.
## TODO 
## Can this be done in a better way ? Maybe with a nice data 
## structure containing the information about the Bch-formula. 
## 
GUARANA.Star_Simple := function( x, y, wx, wy, class, info  )
    local i,r,bchSers,com,a,term,max,min,bound;
    bchSers := GUARANA.recBCH.bchSers;
    
    # start with terms which are not given by Lie brackets
    r := x + y;

    # trivial check 
    if x = 0*x or y = 0*y then
        return r;
    fi;

    # compute upper bound for the Length of commutators, which 
    # can be involved
    max := Maximum( wx,wy );
    min := Minimum( wx,wy );
    # max + min* (bound-1 ) <= class
    bound := Int( (class-max)/min + 1 );

    # up to bound  compute the commutators and add them.
    # Note that the list contains commutators of length i at position i-1.
    for i in [1..bound-1] do
        for term in bchSers[i] do
            com := term[2];
            # check if weight of commutator is not to big
            if GUARANA.CheckWeightOfCommutator( com, wx, wy, class ) then
                a := GUARANA.EvaluateLieBracket( x, y, com, info );
                r := r + term[1]*a; 
            fi;
        od;
    od;
    return r;
end;

#############################################################################
##
##
GUARANA.WeightOfLieAlgElm := function( recLieAlg, elm )
    local basisL,coeff,i,e;
    basisL := Basis( recLieAlg.L );
    coeff := Coefficients( basisL, elm );
    for i in [1..Length(coeff)] do
        e := coeff[i];
        if e <> 0 then
            return recLieAlg.weights[i];
        fi;
    od;
    return recLieAlg.class;
end;

#############################################################################
##
#F GUARANA.AbstractLog_Simple_ByExponent( recLieAlg, exp )
## 
## IN
## recLieAlg ............... Lie algebra record
## exp ..................... exponent vector of a group element g. 
## 
## OUT 
## Log( g )
##
GUARANA.AbstractLog_Simple_ByExponent := function( recLieAlg, exp )
    local  gensL,r,i,e,x,y,wx,wy,class;

    # setup
    gensL := GeneratorsOfAlgebra( recLieAlg.L );
    class := recLieAlg.class;

    r := Zero( recLieAlg.L );
    # go backwards through exponents. 
    # TODO  Which direction is more efficient ?
    for i in Reversed([1..Length( exp )] ) do
        e := exp[i];
        if e <> 0 then 
            x := e*gensL[i];
            y := r;
            # if y is the identity then x*y = x
            if y = Zero( recLieAlg.L ) then
                r := x;
            else
                # compute weights of x,y
                wx := recLieAlg.weights[i];
                wy := GUARANA.WeightOfLieAlgElm( recLieAlg, y );
                r := GUARANA.Star_Simple( x,y,wx,wy,class, "lieAlgebra" );
            fi;
        fi;
    od;
    return r;
end;

#############################################################################
##
#F GUARANA.AbstractLogCoeff_Simple_ByExponent( recLieAlg, exp )
## 
## IN
## recLieAlg ............... Lie algebra record
## exp ..................... exponent vector of a group element g. 
## 
## OUT 
## Log( g ) given as a coefficient vector. 
##
GUARANA.AbstractLogCoeff_Simple_ByExponent := function( recLieAlg,  exp )
    local r;
    r := GUARANA.AbstractLog_Simple_ByExponent( recLieAlg,   exp );
    return Coefficients( Basis( recLieAlg.L ), r);
end;

#############################################################################
##
#F GUARANA.AbstractLog_Simple_ByElm( recLieAlg, g )
## 
## IN
## recLieAlg ............... Lie algebra record
## g .....................   group element g. 
## 
## OUT 
## Log( g )
##
GUARANA.AbstractLog_Simple_ByElm := function( recLieAlg,   g )
    local exp,hl,l,expNN;
    
    # get exponents with respect to gens of T group NN
    # (g might an elment of PcpGroup which contains NN as a normal sugroup,
    # then Exponents(g) would be longer hl(NN))
    exp := Exponents( g );
    hl := HirschLength( recLieAlg.recTGroup.NN );
    l := Length( exp );
    expNN := exp{[l-hl+1..l]};
    return GUARANA.AbstractLog_Simple_ByExponent( recLieAlg,   expNN );
end;

#############################################################################
##
#F GUARANA.AbstractLogCoeff_Simple_ByElm( recLieAlg, g )
## 
## IN
## recLieAlg ............... Lie algebra record
## g .....................   group element g. 
## 
## OUT 
## Log( g ) given by a coefficient vector.
##
GUARANA.AbstractLogCoeff_Simple_ByElm := function( recLieAlg,   g )
    local r;
    r := GUARANA.AbstractLog_Simple_ByElm( recLieAlg,   g );
    return Coefficients( Basis( recLieAlg.L ), r);
end;

#############################################################################
##
#F  GUARANA.EvaluateLieBracketsInTermsOfLogarithmsSers 
##
## IN
## recLieAlg ................... Lie algebra record
## g,h ......................... group elements 
## wg,wh ........................weights of g,h
##
## OUT 
## [Log g, Log h] 
## This is computed by using an  identity that expresses
## Lie brackets as a linear combination of logarithms of group
## commutators. 
##
GUARANA.EvaluateLieBracketsInTermsOfLogarithmsSers 
                            := function(  recLieAlg, g,h,wg,wh )
    local bchLBITOL,r,max,min,bound,class,i,term,com,a,log_a;
    bchLBITOL := GUARANA.recBCH.bchLBITOL;
  
    r := Zero( recLieAlg.L );

    # compute upper bound for the Length of commutators, which 
    # can be involved
    class := recLieAlg.class;
    max := Maximum( wg,wh );
    min := Minimum( wg,wh );
    # max + min* (bound-1 ) <= class
    bound := Int( (class-max)/min + 1 );

    # up to bound  compute the commutators and add them.
    # Note that the list contains commutators of length i at position i-1.
    for i in [1..bound-1] do
        for term in bchLBITOL[i] do
            com := term[2];
            # check if weight of commutator is not to big
            if GUARANA.CheckWeightOfCommutator( com, wg, wh, class ) then
                # evaluate commutator in the group
                a := GUARANA.EvaluateGroupCommutator( g, h, com );
                # map to the Lie algebra
                log_a := GUARANA.AbstractLog_Simple_ByElm( recLieAlg,  a );
                r := r + term[1]*log_a; 
            fi;
        od;
    od;
    return r;
end;

#############################################################################
##
#F GUARANA.LieAlgElm2CoeffGenList( L, x )
##
## IN
## L .............. Lie algebra 
## x .............. elments of L
##
## OUT 
## a list, as required for SetEntrySCTable
##
GUARANA.LieAlgElm2CoeffGenList := function( L, x )
    local basis, coeff,i,ll;
    basis := Basis( L );
    coeff := Coefficients( basis, x );
    ll := [];
    for i in [1..Length(coeff)] do
        if coeff[i] <> 0 then
            Append( ll, [coeff[i],i] );
        fi;
    od;
    return ll;
end;


#N := PcpGroupByMatGroup( PolExamples(4 ) );
#recTGroup := GUARANA.TGroupRec( N );  
#recLieAlg := GUARANA.SetUpLieAlgebraRecordByMalcevbasis( recTGroup );

# F := FreeGroup( 3 );
# N := NilpotentQuotient( F, 5 );
# recTGroup := GUARANA.TGroupRec( N );
# recLieAlg := GUARANA.SetUpLieAlgebraRecordByMalcevbasis( recTGroup );

#############################################################################
##
#F GUARANA.ComputeStructureConstants( recLieAlg )
##
## IN  
## recLieAlg ........... lie algebra record. 
##
## OUT
## 0
##
## This function computes the structure constants of the Lie algebra
## and stores them in the Lie algebra record.
##
## TODO 
## check wehter this function works fine. 
##
GUARANA.ComputeStructureConstants := function( recLieAlg )
    local factors, index_x, index_y, indices,indicesNoCenter,l,g,h,wg,wh,
          lie_elm,ll,gens,T,out;

    # setup
    indices := recLieAlg.recTGroup.indices;
    l := Length( indices );
    indicesNoCenter := indices{[1..l-1]};
    gens := GeneratorsOfGroup( recLieAlg.recTGroup.NN );
    T := recLieAlg.scTable;

    # go through blocks of generators backwards, 
    # where a block corresponds to the generators of the factors
    # of the upper central series
    for factors in Reversed( indicesNoCenter ) do
        for index_y in Reversed( factors ) do
            for index_x in  [1..index_y-1]   do
                g := gens[index_x];
                h := gens[index_y];
                wg := recLieAlg.weights[index_x];
                wh := recLieAlg.weights[index_y];
                # compute [log(g),log(h)]
                lie_elm := GUARANA.EvaluateLieBracketsInTermsOfLogarithmsSers( 
                                             recLieAlg, g,h, wg, wh );
                # set entry in structure constant table 
                ll := GUARANA.LieAlgElm2CoeffGenList( recLieAlg.L, lie_elm );
                if Length( ll ) > 0 then
                    SetEntrySCTable( T, index_x, index_y, ll );
                fi;
            od;
        od;
        # update Lie algebra with new structure constant table
        recLieAlg.L:= LieAlgebraByStructureConstants( Rationals, T );
    od;
    return 0;
end;
#############################################################################
##
#F GUARANA.ComputeStructureConstants_UCS( recLieAlg )
##
## IN  
## recLieAlg ........... lie algebra record. 
##
## OUT
## 0
##
## This function computes the structure constants of the Lie algebra
## and stores them in the Lie algebra record.
## We assume here that the Mal'cev basis goes through the upper
## central series of N. This knowledge is used to reduce 
## the number of structure constants that has to be computed. 
##
GUARANA.ComputeStructureConstants_UCS := function( recLieAlg )
    local factors, index_x, index_y, indices,indicesNoCenter,l,g,h,wg,wh,
          lie_elm,ll,gens,T,out;

    # setup
    indices := recLieAlg.recTGroup.indices;
    l := Length( indices );
    indicesNoCenter := indices{[1..l-1]};
    gens := GeneratorsOfGroup( recLieAlg.recTGroup.NN );
    T := recLieAlg.scTable;

    # go through blocks of generators backwards, 
    # where a block corresponds to the generators of the factors
    # of the upper central series
    for factors in Reversed( indicesNoCenter ) do
        for index_y in Reversed( factors ) do
            for index_x in  [1..index_y-1]   do
                g := gens[index_x];
                h := gens[index_y];
                wg := recLieAlg.weights[index_x];
                wh := recLieAlg.weights[index_y];
                # compute [log(g),log(h)]
                lie_elm := GUARANA.EvaluateLieBracketsInTermsOfLogarithmsSers( 
                                             recLieAlg, g,h, wg, wh );
                # set entry in structure constant table 
                ll := GUARANA.LieAlgElm2CoeffGenList( recLieAlg.L, lie_elm );
                if Length( ll ) > 0 then
                    SetEntrySCTable( T, index_x, index_y, ll );
                fi;
            od;
        od;
        # update Lie algebra with new structure constant table
        recLieAlg.L:= LieAlgebraByStructureConstants( Rationals, T );
    od;
    return 0;
end;

GUARANA.Abstract_Exponential_ByElm := function(  recLieAlg, x )
    local indices,basis,class,tail,coeffs,largestAbelian,exp_x,i,factor,
          divider,w_divider,w_tail,l,exp_x_2ndPart,j;

    indices := recLieAlg.recTGroup.indices;
    basis := Basis( recLieAlg.L );
    class := recLieAlg.class;

    # divide some exponents untill the remaining element lies in an
    # abelian group.
    tail := x;
    coeffs := Coefficients( basis, tail );
    largestAbelian := recLieAlg.recTGroup.largestAbelian;
    exp_x := [];
    for i in [1..largestAbelian-1] do
        factor := indices[i];
        for j in factor do 
            # get element to divide of
            divider := -coeffs[j]*basis[j];

            # save exponents of divider
            Add( exp_x, coeffs[j] );

            # divide off
            w_divider := GUARANA.WeightOfLieAlgElm ( recLieAlg, divider );
            w_tail := GUARANA.WeightOfLieAlgElm ( recLieAlg, tail );
            tail := GUARANA.Star_Simple(  divider, tail, w_divider, 
                                     w_tail, class, "lieAlgebra"  );
        
            # set up coefficient vector
            coeffs := Coefficients( basis, tail );
        od;
    od;

    # test intermediate result
    l := Length( exp_x );
    if not coeffs{[1..l]} = 0 *  coeffs{[1..l]} then
        Error( "Failure in Abstract_Exponential \n" );
    fi;

    # get the remaining coefficients 
    exp_x_2ndPart := coeffs{[l+1..Length(coeffs)]};
    
    return Concatenation( exp_x, exp_x_2ndPart );
    
end;

GUARANA.Abstract_Exponential_ByVector := function(  recLieAlg, vec )
    local basis,x;
    basis := Basis( recLieAlg.L );
    x := LinearCombination( basis, vec );
    return GUARANA.Abstract_Exponential_ByElm(  recLieAlg, x ); 
end;

GUARANA.LieAlgebraByTGroupRec := function(  recTGroup )
    local recLieAlg;

    recLieAlg := GUARANA.SetUpLieAlgebraRecordByMalcevbasis( recTGroup );
    GUARANA.ComputeStructureConstants( [ recLieAlg] );
   
    return recLieAlg;
end;

#############################################################################
#
# TEST Functions
#
#############################################################################


GUARANA.Test_LogOfExp := function(  recLieAlg, noTests )
    local x,exp,x2,i;

    for i in [1..noTests] do
        x := Random( recLieAlg.L );
        exp := GUARANA.Abstract_Exponential_ByElm(  recLieAlg, x );
        x2 := GUARANA.AbstractLog_Simple_ByExponent( recLieAlg,  exp );
        if not x = x2 then
            Error( "Mist\n" );
        fi;
    od;
    return 0;
end;

GUARANA.Test_ExpOfLog := function(  recLieAlg, noTests,range )
    local i,hl,domain,exp,x,exp2;
    hl := HirschLength( recLieAlg.recTGroup.NN );
    domain := [-range..range];
    for i in [1..noTests] do
        exp := List( [1..hl], x -> Random( domain ) );
        x := GUARANA.AbstractLog_Simple_ByExponent( recLieAlg,  exp );
        exp2 := GUARANA.Abstract_Exponential_ByElm(  recLieAlg, x );
        if not exp = exp2 then
            Error( "Mist\n" );
        fi;
    od;
    return 0;
end;


GUARANA.Test := function( n )
    local P,F,G,elm,string,A,ll,lie,kk,kk2;        
 
    P := PolynomialRing( Rationals, n );
    F := GUARANA.Compute_F( n );;
    G := GUARANA.Compute_G( n, P );;
    elm := GUARANA.Logarithm( F*G )[1][n+1];
    string := String( elm );
    A := FreeAlgebraWithOne( Rationals, 2 );
    ll := GUARANA.SumOfSigmaExpresions2List( n, string );
    lie := GUARANA.MonomialList2LieBracketList( ll );
    Length( ll );
    Length( lie );
    kk := List( lie, x->x[2] );
    kk2 := AsSet( kk );
    return [ Length( lie ), Length( AsSet( kk ) )];
end;


GUARANA.List2Number := function( base, ll )
    local n,l,numb,i;
    n := Length( ll );
    #throw away the first two entries 1 and 0
    l := ll{[3..n]};

    numb := 0;
    for i in Reversed( [3..n]) do
        if ll[i]<>0 then
            numb := numb + base^(n-i);
        fi;
    od;
    return numb;
end;

# produce random element of Tr_0(dim,Q)
GUARANA.RandomNilpotentMat := function( dim )
    local range,ll,kk,g,j,k;
    range := 7;
    ll := [ - range .. range ];
    kk := [ - range .. range ];
    ll := Filtered( ll, function ( x )
            return x <> 0;
        end );
    kk := Filtered( kk, function ( x )
            return x <> 0;
        end );

    g := NullMat( dim, dim, Rationals );
    for j  in [ 1 .. dim ]  do
        for k  in [ j .. dim ]  do
            if j < k  then
                g[j][k] := RandomList( ll ) / RandomList( kk );
            else
                g[j][k] := 0;
            fi;
        od;
    od;
    return g;
end;

GUARANA.TestBchSeriesOrdered := function(  n )
    local no_tests,i,x,y,wx,wy,x_star_y,exp_x_star_y,exp_x,exp_y;

    no_tests := 100;
    for i in [1..no_tests] do
        # produce two random matrices x,y in Tr_0(n,Q)
        x := GUARANA.RandomNilpotentMat( n );
        y := GUARANA.RandomNilpotentMat( n );
        wx := 1;
        wy := 1;

        # compute  exp(x*y) with BCH, 
        # note that we need terms of length at most n-1
        x_star_y := GUARANA.Star_Simple (  x, y, wx, wy, n-1, "matrix"  );
        exp_x_star_y := GUARANA.Exponential( Rationals, x_star_y );   

        # compute exp(x)exp(y) and compare
        exp_x := GUARANA.Exponential( Rationals, x );
        exp_y := GUARANA.Exponential( Rationals, y );

        if not exp_x_star_y = exp_x*exp_y then
            Error( "Mist \n " );
        fi;

    od;
    return 0;
end;

# recComSers as computed by GUARANA.ComputeCommutatorSeries
# recComSers := GUARANA.ComputeCommutatorSeries( 6, 3 );
GUARANA.Test_ComputeCommutatorSeries := function( recComSers, n, kappa )
    local  no_tests,i,x,y,wx,wy,exp_x,exp_y,exp_z,r,class,
          sers,com,a,term,exp_z_bch,weight, pos;

    no_tests := 10;
    for i in [1..no_tests] do
        # produce two random matrices x,y in Tr_0(n,Q)
        x := GUARANA.RandomNilpotentMat( n );
        y := GUARANA.RandomNilpotentMat( n );
        wx := 1;
        wy := 1;
   
        # compute kappa( exp(x),exp(y) ) normally
        exp_x := GUARANA.Exponential( Rationals, x );
        exp_y := GUARANA.Exponential( Rationals, y );
        exp_z := GUARANA.EvaluateGroupCommutator( exp_x, exp_y, kappa );

        # compute z where exp(z)= kappa( exp(x),exp(y) ) with extended BCH
        r := NullMat( n,n );
        class := n-1;
        weight := Length( kappa );
        pos := Position( recComSers.coms[weight], kappa );
        sers := recComSers.lie[weight][pos];
        for term in sers do
            com := term[2];
            #Print( "term ", term, "\n" );
            # check if weight of commutator is not to big
            if GUARANA.CheckWeightOfCommutator( com, wx, wy, class ) then
                # evaluate commutator in the lie algebra
                a := GUARANA.EvaluateLieBracket( x, y, com, "matrix" );
                r := r + term[1]*a;
                #        Print( "log_a ", log_a, "\n" );
                #        Print( "r ", r, "\n\n" );
            fi;
        od;
        exp_z_bch := GUARANA.Exponential( Rationals, r );

        # compare
        if not exp_z_bch = exp_z then 
            Error( "Mist\n" );
        fi;
    od;
    return 0;
end;

GUARANA.TestSeriesLieBracketInTermsOfLogs := function(  n )
    local no_tests,i,x,y,x_bracket_y,g,h,wg,wh,r,class,max,min,bound,j,
          term,a,log_a,x_bracket_y_2,bchLBITOL,com;

    no_tests := 10;
    for j in [1..no_tests] do
        # produce two random matrices x,y in Tr_0(n,Q)
        x := GUARANA.RandomNilpotentMat( n );
        y := GUARANA.RandomNilpotentMat( n );
              
        # compute [x,y] in normal way
        x_bracket_y := LieBracket( x, y );

        # compute [x,y] with series "liebrackets in terms of logs"
            g := GUARANA.Exponential( Rationals, x );
            h := GUARANA.Exponential( Rationals, y );
            wg := 1;
            wh := 1;

            bchLBITOL := GUARANA.recBCH.bchLBITOL;
            r := NullMat( n,n );
            # compute upper bound for the Length of commutators, which 
            # can be involved
            class := n-1;
            max := Maximum( wg,wh );
            min := Minimum( wg,wh );
            # max + min* (bound-1 ) <= class
            bound := Int( (class-max)/min + 1 );

            # up to bound  compute the commutators and add them.
            # Note that the list contains comms of length i at position i-1.
            for i in [1..bound-1] do
                for term in bchLBITOL[i] do
                    com := term[2];
                    #Print( "term ", term, "\n" );
                    # check if weight of commutator is not to big
                    if GUARANA.CheckWeightOfCommutator( com, wg, wh, class ) then
                        # evaluate commutator in the group
                        a := GUARANA.EvaluateGroupCommutator( g, h, com );
                        # map to the Lie algebra
                        log_a := GUARANA.Logarithm( a );
                        r := r + term[1]*log_a;
                        #Print( "log_a ", log_a, "\n" );
                        #Print( "r ", r, "\n\n" );
                    fi;
                od;
            od;
            x_bracket_y_2 := r;
    
        # compare
        if not x_bracket_y = x_bracket_y_2 then
            Error( "Mist\n" );
        fi;
    od;
    return 0;
end;

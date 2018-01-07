
% insert commands specify a predecessor, the character being inserted, and an id.

% here is user 'a' writing 'cute'

insert(id(alice, 0), 'c', id(alice, 1)).

% after user 'alice' wrote 'c', user 'bob' simoultaneously wrote 'at'
% this introduces a conflict.
% we would like to define a total ordering, giving us a list structure, not a tre structure.

insert(id(alice, 1), 'a', id(bob, 2)).
insert(id(bob, 2)  , 't', id(bob, 3)).

% we return to alice

insert(id(alice, 1), 'u', id(alice, 2)).
insert(id(alice, 2), 't', id(alice, 3)).
insert(id(alice, 3), 'e', id(alice, 4)).

% bob then realizes the mistake, but fixes things.

insert(id(alice, 4), ' ', id(bob, 5)).
insert(id(bob, 5),   'c', id(bob, 6)).

% then alice edits cute cat into into cutie cat
insert(id(alice, 3), 'i', id(alice, 7)).
insert(id(alice, 7), 'e', id(alice, 8)).
deleted(id(alice, 4)).

% partial ordering of document locations derived from insert commands.

depends(X, Y) :- insert(X, _, Y).
depends(X, Z) :- insert(X, _, Y), depends(Y, Z).

% borrow from previous ordering

foo(X, Y) :- depends(X, Y).
foo(X, Y) :- \+ depends(X, Y), bar(X, Y). 

bar(id(X0, X1), id(Y0, Y1)) :- X0 @=< Y0, Y1 @=< X1.

my_compare(C, X, Y) :- ( foo(X, Y) -> C = '<'
                       ; foo(Y, X) -> C = '>'
                       ; compare(C, X, Y)).

baz(ID, C) :- insert(_, C, ID).

main(S) :-
  findall(ID, insert(_, _, ID), L0), % find all insert ids
  predsort(my_compare, L0, L1),      % sort using our total ordering
  exclude(deleted, L1, L2),          % remove deleted characters
  maplist(baz, L2, L3),              % get the char from each search
  string_chars(S, L3).               % turn the list of characters into a string


%
%  util.pl
%  marelle-deps
%
%  Utility methods common to multiple deps.
%

:- multifile git_step/3.

pkg(P) :- git_step(P, _, _).
met(P, _) :-
    git_step(P, _, Dest0),
    join([Dest0, '/.git'], Dest),
    isdir(Dest).
meet(P, _) :-
    git_step(P, Repo, Dest0),
    expand_path(Dest0, Dest),
    git_clone(Repo, Dest).

expand_path(Path0, Path) :-
    ( atom_concat('~/', Suffix, Path0) ->
        getenv('HOME', Home),
        join([Home, '/', Suffix], Path)
    ;
        Path = Path0
    ).

isfile(Path0) :-
    expand_path(Path0, Path),
    exists_file(Path).

isdir(Path0) :-
    expand_path(Path0, Path),
    exists_directory(Path).

make_executable(Path) :-
    join(['chmod a+x ', Path], Cmd),
    bash(Cmd).

curl(Source, Dest) :-
    join(['curl -o ', Dest, ' ', Source], Cmd),
    bash(Cmd).


% installs_with_apt(Pkg).
%   Pkg installs with apt package of same name on all Ubuntu/Debian flavours
:- multifile installs_with_apt/1.

% installs_with_apt(Pkg, AptName).
%   Pkg installs with apt package called AptName on all Ubuntu/Debian
%   flavours. AptName can also be a list of packages.
:- multifile installs_with_apt/2.

installs_with_apt(P, P) :- installs_with_apt(P).

% installs_with_apt(Pkg, Codename, AptName).
%   Pkg installs with apt package called AptName on given Ubuntu/Debian
%   variant with given Codename.
:- multifile installs_with_apt/3.

installs_with_apt(P, _, AptName) :- installs_with_apt(P, AptName).

met(P, linux(Codename)) :-
    installs_with_apt(P, Codename, PkgName), !,
    ( is_list(PkgName) ->
        maplist(check_dpkg, PkgName)
    ;
        check_dpkg(PkgName)
    ).

meet(P, linux(Codename)) :-
    installs_with_apt(P, Codename, PkgName), !,
    ( is_list(PkgName) ->
        maplist(install_apt, PkgName)
    ;
        install_apt(PkgName)
    ).

check_dpkg(PkgName) :-
    join(['dpkg -s ', PkgName, ' >/dev/null 2>/dev/null'], Cmd),
    bash(Cmd).

:- multifile meta_pkg/2.

pkg(P) :- meta_pkg(P, _).

met(P, _) :- meta_pkg(P, Deps), !,
    maplist(cached_met, Deps).

meet(P, _) :- meta_pkg(P, _), !.

depends(P, _, Deps) :- meta_pkg(P, Deps).

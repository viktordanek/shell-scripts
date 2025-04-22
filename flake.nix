{
    inputs =
        {
            environment-variable.url = "github:viktordanek/environment-variable" ;
            flake-utils.url = "github:numtide/flake-utils" ;
            nixpkgs.url = "github:NixOs/nixpkgs" ;
            shell-script.url = "github:viktordanek/shell-script/issue/47-new-imple" ;
            temporary.url = "github:viktordanek/temporary/issue/60-new-implementation-1" ;
            visitor.url = "github:viktordanek/visitor" ;
        } ;
    outputs =
        { environment-variable , flake-utils , nixpkgs , self , shell-script , temporary , visitor } :
            let
                fun =
                    system :
                        let
                            _environment-variable = builtins.getAttr system environment-variable.lib ;
                            _visitor = builtins.getAttr system visitor.lib ;
                            foobar =
                                lib
                                    {
                                        shell-scripts =
                                            {
                                                foobar =
                                                    { shell-script , ... } :
                                                        shell-script
                                                            {
                                                                profile =
                                                                    { path , string } :
                                                                        [
                                                                            ( string "JQ" "${ pkgs.jq }/bin/jq" )
                                                                            ( path "PATH_VALUE" 0 )
                                                                            ( string "STRING_VALUE" "a1895e773961f633c7c6178a7fda16f8d630cfcbc911080c7c8ec713dd882b8b5152abcc22c40b324c8b5df01070ba57348c02788cb07b31464fcba309036d1c" )
                                                                            ( string "TEMPLATE_FILE" ( self + "/scripts/foobar.json" ) )
                                                                            ( string "YQ" "${ pkgs.yq }/bin/yq" )
                                                                        ] ;
                                                                script = self + "/scripts/foobar.sh" ;
                                                            } ;
                                            } ;
                                    } ;
                            lib =
                                {
                                    archive ? "ARCHIVE" ,
                                    default-name ? "script" ,
                                    resources ? "RESOURCES" ,
                                    shell-scripts ? null ,
                                } :
                                    let
                                        derivation =
                                            pkgs.stdenv.mkDerivation
                                                {
                                                    installPhase =
                                                        let
                                                            constructor =
                                                                _visitor
                                                                    {
                                                                        lambda =
                                                                            path : value :
                                                                                [
                                                                                    "makeWrapper ${ let x = value null ; in x.shell-script } ${ _environment-variable "OUT" }/${ builtins.hashString "sha512" ( builtins.concatStringsSep "/" ( builtins.map builtins.toJSON path ) ) }.wrapped.sh"
                                                                                ] ;
                                                                    }
                                                                    {
                                                                        list = path : list : builtins.concatLists list ;
                                                                        set = path : set : builtins.concatLists ( builtins.attrValues set ) ;
                                                                    }
                                                                    primary.shell-scripts ;
                                                            in
                                                                ''
                                                                    ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                        ${ pkgs.coreutils }/bin/mkdir $out/bin
                                                                        ${ pkgs.coreutils }/bin/ln --symbolic ${ pkgs.writeShellScript "constructors" ( builtins.concatStringsSep " &&\n\t" ( builtins.concatLists [ [ "source ${ _environment-variable "MAKE_WRAPPER" }/nix-support/setup-hook" ] constructor ] ) ) } $out/bin/constructor.sh &&
                                                                        makeWrapper $out/bin/constructor.sh $out/bin/constructor.wrapped.sh --set MAKE_WRAPPER ${ pkgs.makeWrapper } --set MKDIR ${ pkgs.coreutils }/bin/mkdir --set OUT $out &&
                                                                        $out/bin/constructor.wrapped.sh
                                                                '' ;
                                                    name = "derivation" ;
                                                    nativeBuildInputs = [ pkgs.makeWrapper ] ;
                                                    src = ./. ;
                                                } ;
                                        primary =
                                            {
                                                archive = archive ;
                                                default-name =
                                                    if builtins.typeOf default-name == "string" then default-name
                                                    else builtins.throw "default-name is not string but ${ builtins.typeOf default-name }." ;
                                                resources = resources ;
                                                shell-scripts =
                                                    _visitor
                                                        {
                                                            lambda =
                                                                path : value : ignore :
                                                                    value
                                                                        {
                                                                            shell-script =
                                                                                {
                                                                                    mounts ? { } ,
                                                                                    name ? if builtins.length path > 0 then builtins.elemAt path ( ( builtins.length path ) - 1 ) else primary.default-name ,
                                                                                    profile ? { ... } : [ ] ,
                                                                                    script ,
                                                                                    tests ? null
                                                                                } :
                                                                                    let
                                                                                        eval  =
                                                                                            builtins.tryEval
                                                                                                (
                                                                                                    let
                                                                                                        _shell-script = builtins.getAttr system shell-script.lib ;
                                                                                                        arguments =
                                                                                                            {
                                                                                                                extensions =
                                                                                                                    {
                                                                                                                        path =
                                                                                                                            name : index :
                                                                                                                                let
                                                                                                                                    point =
                                                                                                                                        {
                                                                                                                                            index =
                                                                                                                                                if builtins.typeOf index == "int" then index
                                                                                                                                                else builtins.throw "index is not int but ${ builtins.typeOf index }." ;
                                                                                                                                            name =
                                                                                                                                                if builtins.typeOf name == "string" then name
                                                                                                                                                else builtins.throw "name is not string but ${ builtins.typeOf name }." ;
                                                                                                                                        } ;
                                                                                                                                    value = builtins.elemAt path point.index ;
                                                                                                                                    in "export ${ point.name }=${ builtins.toString value }" ;
                                                                                                                        string =
                                                                                                                            name : value :
                                                                                                                                let
                                                                                                                                    point =
                                                                                                                                        {
                                                                                                                                            name =
                                                                                                                                                if builtins.typeOf name == "string" then name
                                                                                                                                                else builtins.throw "name is not string but ${ builtins.typeOf name }." ;
                                                                                                                                            value =
                                                                                                                                                if builtins.typeOf value == "string" then value
                                                                                                                                                else builtins.throw "value is not string but ${ builtins.typeOf value }." ;
                                                                                                                                        } ;
                                                                                                                                    in "export ${ point.name }=${ point.value }" ;
                                                                                                                    } ;
                                                                                                                mounts = mounts ;
                                                                                                                name = name ;
                                                                                                                profile = profile ;
                                                                                                                script = script ;
                                                                                                                tests = tests ;
                                                                                                            } ;
                                                                                                        in _shell-script arguments
                                                                                                ) ;
                                                                                        in builtins.trace "HI" ( if eval.success then eval.value else builtins.throw "We had a problem evaluating ${ builtins.concatStringsSep " / " path }." ) ;
                                                                        } ;
                                                        }
                                                        { }
                                                        shell-scripts ;
                                            } ;
                                    in
                                        {
                                            derivation = derivation ;
                                        } ;
                                pkgs = builtins.import nixpkgs { system = system ; } ;
                            in
                                {
                                    apps =
                                        {
                                            foobar =
                                                {
                                                    type = "program" ;
                                                    program = "${ pkgs.coreutils }/bin/echo ${ foobar.derivation }" ;
                                                } ;
                                        } ;
                                    checks =
                                        {
                                            foobar =
                                                pkgs.stdenv.mkDerivation
                                                    {
                                                        installPhase =
                                                            ''
                                                                ${ pkgs.coreutils }/bin/touch $out &&
                                                                    ${ pkgs.coreutils }/bin/echo ${ foobar.derivation } &&
                                                                    exit 64
                                                            '' ;
                                                        name = "foobar" ;
                                                        src = ./. ;
                                                    } ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
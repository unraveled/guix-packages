(define-module (blockchain))

(use-modules
 (guix packages)
 (guix download)
 (guix build-system gnu)
 ((guix licenses) :prefix license:)
 (gnu packages gawk)
 (guix git-download)
 (guix build-system cmake)
 (gnu packages multiprecision)
 (gnu packages tls)
 (gnu packages python)
 (gnu packages version-control)
 (gnu packages documentation)
 (gnu packages pkg-config)
 (gnu packages curl)
 (gnu packages llvm))

(define-public eosio-cdt
  (package
    (name "eosio-cdt")
    (version "1.7.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference (url "https://github.com/EOSIO/eosio.cdt")
                           (commit (string-append "v" version))
                           (recursive? #t)))
       (sha256
        (base32
         "1mrc8dn7sf086456c63rlha4j3fh0g1a59dbd6in6nyhan712xps"))
       (file-name (git-file-name name version))))
    (build-system cmake-build-system)
    (native-inputs
     `(("git" ,git)
       ("doxygen" ,doxygen)
       ("clang" ,clang-9)
       ("pkg-config" ,pkg-config)
       ("curl" ,curl)))
    (inputs
     `(("gmp" ,gmp)
       ("openssl" ,openssl)
       ("python" ,python-3)))
    (arguments
     `(#:build-type "Release"
       ;; Note: the WABT dependency only compiles udner clang 9
       #:configure-flags '("-DCMAKE_CXX_COMPILER=clang++"
                           "-DCMAKE_C_COMPILER=clang"
                           "-DCMAKE_C_COMPILER_ID=Clang")
       #:phases
       (modify-phases
        %standard-phases
        (add-before 'configure 'set-cxx
                    (lambda _
                      ;; Make sure CMake picks Clang as compiler
                      (begin
                        (setenv "CXX" "clang++")
                        (setenv "CC" "clang")
                        #t))))))
    (home-page "https://developers.eos.io/manuals/eosio.cdt/latest/index")
    (synopsis "Suite of tools used to build EOSIO contracts")
    (description
     "EOSIO.CDT is a toolchain for WebAssembly (WASM) and set of tools to
facilitate smart contract development for the EOSIO platform.")
    (license license:expat)))

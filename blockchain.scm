(define-module (blockchain)
  #:use-module (nonguix build-system binary)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages base)
  #:use-module (gnu packages linux))

(use-modules
 (guix packages)
 (guix download)
 (guix build-system gnu)
 ((guix licenses) :prefix license:)
 (gnu packages gawk)
 (guix utils)
 (guix git-download)
 (guix build-system cmake)
 (gnu packages)
 (gnu packages multiprecision)
 (gnu packages tls)
 (gnu packages python)
 (gnu packages version-control)
 (gnu packages documentation)
 (gnu packages pkg-config)
 (gnu packages graphviz)
 (gnu packages libusb)
 (gnu packages boost)
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
      ;; Note: the WABT dependency only compiles under clang 9
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

(define-public boost-for-eosio
  (package
   (inherit boost)
   (version "1.70.0")
   (name "boost-for-eosio")
   (arguments
    (substitute-keyword-arguments
     (package-arguments boost)
     ((#:make-flags flags)
      `(append
        (cons "link=static" (delete "link=shared" ,flags))
        '("--with-iostreams" "--with-date_time"
          "--with-filesystem" "--with-system"
          "--with-program_options" "--with-chrono" "--with-test")))
     ((#:phases phases)
      `(modify-phases ,phases
                      (delete 'provide-libboost_python)))))))

(define-public leap
  (package
   (name "leap")
   (version "3.1.0")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference (url "https://github.com/AntelopeIO/leap")
                         (commit (string-append "v" version))
                         (recursive? #t)))
     (sha256
      (base32
       "102m765y9183w9az70s5mpwqjj3ch1469vdf1mk5wa3wbjn4dn18"))
     (file-name (git-file-name name version))
     (patches (search-patches
               ;;"eosio-fix-build-problem-for-git-abscence.patch"
               "0001-Fix-chain-cmakelists.patch"
               "0002-Fix-nodeos-version-without-git.patch"
               ))))
   (build-system cmake-build-system)
   (native-inputs
    `(("git" ,git)
      ("doxygen" ,doxygen)
      ("pkg-config" ,pkg-config)
      ("curl" ,curl)
      ("python" ,python-3)
      ("graphviz" ,graphviz)
      ("clang" ,clang-11)
      ("libusb" ,libusb)))
   (inputs
    `(("boost" ,boost-for-eosio)
      ("llvm-7" ,llvm-7)
      ("gmp" ,gmp)
      ("openssl" ,openssl)))
   (arguments
    `(#:configure-flags
      '("-DCMAKE_BUILD_TYPE='Release'"
        "-DCMAKE_CXX_COMPILER='clang++'"
        "-DCMAKE_C_COMPILER='clang'")
      #:build-type "Release"
      #:tests? #f))
   (home-page "https://antelope.io")
   (synopsis " C++ implementation of the Antelope protocol.")
   (description
    "Leap is blockchain node software and supporting tools that
implements the Antelope protocol.")
   (license license:expat)))

(define-public solana
  (package
    (name "solana")
    (version "1.10.38")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/solana-labs/solana/releases/download/v" version "/solana-release-x86_64-unknown-linux-gnu.tar.bz2"))
              (sha256
               (base32
                "077fbmyg6a3448vkalkn4xfx73vk0sgisp24pyd1ri5hdyvw0da3"))))
    (arguments
     `(#:patchelf-plan
       `(("bin/solana" ("glibc" "gcc:lib" "eudev"))
         ("bin/spl-token" ("glibc" "gcc:lib" "eudev")))
       #:install-plan
       `(("bin/solana" "bin/")
         ("bin/spl-token" "bin/"))))
    (inputs
     `(("gcc:lib" ,gcc "lib")
       ("glibc" ,glibc)
       ("eudev" ,eudev)))
    (build-system binary-build-system)
    (home-page "https://solana.com/")
    (synopsis "Blockchain, Rebuilt for Scale")
    (description "Blockchain, Rebuilt for Scale")
    (license license:asl2.0)))
